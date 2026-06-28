package com.smartcare.business.ai.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.smartcare.business.ai.domain.AiChatMessage;
import com.smartcare.business.ai.domain.KbArticle;
import com.smartcare.business.ai.mapper.KbArticleMapper;
import com.smartcare.framework.ai.ZhipuAiClient;
import com.smartcare.framework.ai.ZhipuChatMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class RagService {

    private final KbArticleMapper articleMapper;
    private final ZhipuAiClient zhipuAiClient;

    public List<KbArticle> search(String question, String contextHint) {
        String merged = mergeQuery(question, contextHint);
        if (!StringUtils.hasText(merged)) {
            return List.of();
        }
        List<KbArticle> all = articleMapper.selectList(new LambdaQueryWrapper<KbArticle>()
            .orderByDesc(KbArticle::getCreateTime));
        if (all.isEmpty()) {
            return List.of();
        }
        Set<String> tokens = tokenize(merged);
        List<ScoredArticle> scored = new ArrayList<>();
        for (KbArticle article : all) {
            int score = scoreArticle(article, tokens, merged);
            if (score > 0) {
                scored.add(new ScoredArticle(article, score));
            }
        }
        scored.sort((a, b) -> Integer.compare(b.score, a.score));
        return scored.stream()
            .limit(3)
            .map(s -> s.article)
            .collect(Collectors.toList());
    }

    /** 基于知识库 + GLM-4-Plus 生成回答（支持多轮上下文） */
    public String generateAnswer(String question, List<KbArticle> articles,
                                 List<AiChatMessage> priorMessages) {
        if (zhipuAiClient.isAvailable()) {
            try {
                String systemPrompt = buildSystemPrompt(articles);
                List<ZhipuChatMessage> history = toZhipuHistory(priorMessages);
                return sanitizeAiResponse(zhipuAiClient.chatWithHistory(systemPrompt, history, question));
            } catch (Exception e) {
                log.warn("智谱AI文本问答失败，使用本地兜底: {}", e.getMessage());
            }
        }
        return buildFallbackAnswer(articles);
    }

    /** 图片 + 文字多模态问答（GLM-4V） */
    public String generateAnswerWithVision(String question, List<KbArticle> articles,
                                           List<String> imageBase64List) {
        if (zhipuAiClient.isAvailable()) {
            try {
                String prompt = buildVisionPrompt(question, articles);
                return sanitizeAiResponse(zhipuAiClient.multimodalChat(prompt, imageBase64List));
            } catch (Exception e) {
                log.warn("智谱AI多模态问答失败，使用本地兜底: {}", e.getMessage());
            }
        }
        if (articles != null && !articles.isEmpty()) {
            return buildFallbackAnswer(articles);
        }
        return "已收到您的图片，但 AI 服务暂不可用。请补充文字描述或输入「转人工」联系物业客服。";
    }

    private String buildSystemPrompt(List<KbArticle> articles) {
        String context = buildKnowledgeContext(articles);
        return """
            你是智慧社区物业 AI 助手，专门解答业主关于报修、公告、缴费、装修、宠物、访客等社区生活问题。

            回答规则：
            1. 优先参考下方「知识库内容」作答，不要编造政策或费用标准
            2. 若知识库中没有相关信息，礼貌说明暂时无法确认，并建议联系物业或说「转人工」
            3. 语气友好、简洁，步骤类问题请分点说明
            4. 结合对话历史理解追问（如「那具体怎么操作？」），不要重复已说过的内容
            5. 以社区助手身份直接回答，不要暴露大模型身份
            6. 禁止添加脚注、注释、免责声明，不要提及「知识库」「匹配条目」「基于常见场景判断」等内部说明

            知识库内容：
            %s
            """.formatted(context);
    }

    private String buildVisionPrompt(String question, List<KbArticle> articles) {
        String context = buildKnowledgeContext(articles);
        String q = StringUtils.hasText(question) ? question : "请结合图片内容，分析可能的问题并给出社区物业相关建议。";
        return """
            你是智慧社区物业 AI 助手。请结合用户上传的图片和文字描述进行分析。

            若图片涉及报修场景（如水管漏水、电路跳闸、门窗损坏等），请按以下结构直接回答（不要加标题编号以外的多余说明）：
            1. 图片情况描述
            2. 故障类型与紧急程度（紧急/较急/普通）
            3. 业主可立即采取的步骤，以及是否建议提交报修工单

            可参考下方知识库内容，但不要编造。若无完全匹配条目，仍应基于图片给出专业判断。
            禁止添加脚注、注释、免责声明，不要提及「知识库」「暂无匹配条目」「基于常见场景判断」等文字。

            知识库内容：
            %s

            用户描述：%s
            """.formatted(context, q);
    }

    /** 去除模型自行添加的知识库/免责声明类脚注 */
    private String sanitizeAiResponse(String content) {
        if (!StringUtils.hasText(content)) {
            return content;
        }
        String result = content.trim();
        result = result.replaceAll("(?s)\\n*[（(]注[：:][^）)]*[）)]\\s*$", "");
        result = result.replaceAll("(?s)\\n*（注[：:].*$", "");
        result = result.replaceAll("(?s)\\n*\\(注[：:].*$", "");
        result = result.replaceAll("(?s)\\n*---\\s*\\n*注[：:].*$", "");
        return result.trim();
    }

    private String buildKnowledgeContext(List<KbArticle> articles) {
        if (articles == null || articles.isEmpty()) {
            return "（暂无匹配知识库条目）";
        }
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < articles.size(); i++) {
            KbArticle a = articles.get(i);
            sb.append("【").append(i + 1).append("】").append(a.getTitle()).append("\n");
            sb.append(a.getContent()).append("\n\n");
        }
        return sb.toString().trim();
    }

    private List<ZhipuChatMessage> toZhipuHistory(List<AiChatMessage> priorMessages) {
        if (priorMessages == null || priorMessages.isEmpty()) {
            return List.of();
        }
        List<ZhipuChatMessage> history = new ArrayList<>();
        for (AiChatMessage msg : priorMessages) {
            if (!StringUtils.hasText(msg.getContent())) {
                continue;
            }
            if ("user".equals(msg.getRole())) {
                history.add(ZhipuChatMessage.user(msg.getContent()));
            } else if ("assistant".equals(msg.getRole())) {
                history.add(ZhipuChatMessage.assistant(msg.getContent()));
            }
        }
        return history;
    }

    private String buildFallbackAnswer(List<KbArticle> articles) {
        if (articles == null || articles.isEmpty()) {
            return "抱歉，知识库中暂未找到与您问题直接相关的内容。您可以换个说法再试，或输入「转人工」联系物业客服。";
        }
        StringBuilder sb = new StringBuilder();
        if (articles.size() == 1) {
            KbArticle a = articles.get(0);
            sb.append("根据社区知识库，关于「").append(a.getTitle()).append("」：\n\n");
            sb.append(a.getContent());
        } else {
            sb.append("根据知识库为您整理如下：\n\n");
            for (int i = 0; i < articles.size(); i++) {
                KbArticle a = articles.get(i);
                sb.append(i + 1).append(". ").append(a.getTitle()).append("\n");
                sb.append(a.getContent()).append("\n\n");
            }
        }
        sb.append("\n如需进一步帮助，请继续追问或说「转人工」。");
        return sb.toString().trim();
    }

    private String mergeQuery(String question, String contextHint) {
        String q = question != null ? question.trim() : "";
        if (isFollowUp(q) && StringUtils.hasText(contextHint)) {
            return contextHint + " " + q;
        }
        return q;
    }

    private boolean isFollowUp(String question) {
        if (!StringUtils.hasText(question)) {
            return false;
        }
        String q = question.trim();
        if (q.length() <= 12) {
            return q.contains("怎么") || q.contains("如何") || q.contains("具体")
                || q.contains("那") || q.contains("呢") || q.contains("吗")
                || q.contains("什么") || q.contains("哪");
        }
        return false;
    }

    private Set<String> tokenize(String text) {
        Set<String> tokens = new LinkedHashSet<>();
        String normalized = text.replaceAll("[\\s，。！？、；：()\\[\\]【】\"']", " ");
        for (String part : normalized.split("\\s+")) {
            if (part.length() >= 2) {
                tokens.add(part.toLowerCase());
            }
        }
        for (int i = 0; i < text.length(); i++) {
            if (i + 2 <= text.length()) {
                tokens.add(text.substring(i, i + 2));
            }
        }
        for (int i = 0; i < text.length(); i++) {
            char c = text.charAt(i);
            if (!Character.isWhitespace(c)) {
                tokens.add(String.valueOf(c));
            }
        }
        return tokens;
    }

    private int scoreArticle(KbArticle article, Set<String> tokens, String mergedQuery) {
        int score = 0;
        String title = nullToEmpty(article.getTitle());
        String keywords = nullToEmpty(article.getKeywords());
        String content = nullToEmpty(article.getContent());
        String haystack = (title + " " + keywords + " " + content).toLowerCase();
        String queryLower = mergedQuery.toLowerCase();
        if (haystack.contains(queryLower) && queryLower.length() >= 4) {
            score += 20;
        }
        for (String token : tokens) {
            if (token.length() < 2) {
                continue;
            }
            if (title.contains(token)) {
                score += 8;
            }
            if (keywords.contains(token)) {
                score += 6;
            }
            if (content.contains(token)) {
                score += 3;
            }
        }
        return score;
    }

    private String nullToEmpty(String s) {
        return s != null ? s : "";
    }

    private record ScoredArticle(KbArticle article, int score) {}
}
