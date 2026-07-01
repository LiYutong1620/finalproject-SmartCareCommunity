package com.smartcare.business.repair.controller;

import com.smartcare.business.ai.domain.KbArticle;
import com.smartcare.business.ai.service.RagService;
import com.smartcare.business.repair.domain.RpOrder;
import com.smartcare.business.repair.service.RepairStepTemplateService;
import com.smartcare.business.repair.service.RpOrderService;
import com.smartcare.business.repair.service.RpWorkerProfileService;
import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.framework.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/worker/repair")
@RequiredArgsConstructor
public class WorkerRepairController {

    private static final List<String> REJECT_REASONS = List.of(
        "当前繁忙无法处理",
        "缺少专业工具或配件",
        "故障类型不在技能范围",
        "距离过远无法及时到达",
        "其他原因"
    );

    private final RpOrderService orderService;
    private final RpWorkerProfileService workerProfileService;
    private final RagService ragService;
    private final RepairStepTemplateService repairStepTemplateService;

    @Value("${smartcare.file.upload-path:./upload}")
    private String uploadPath;

    @GetMapping("/list")
    public AjaxResult list(@RequestParam(defaultValue = "1") int pageNum,
                           @RequestParam(defaultValue = "10") int pageSize,
                           @RequestParam(required = false) String status,
                           @RequestParam(required = false) String urgency,
                           @RequestParam(required = false) String keyword,
                           @RequestParam(required = false) String startDate,
                           @RequestParam(required = false) String endDate) {
        var page = orderService.pageByWorker(SecurityUtils.getUserId(), pageNum, pageSize, status, urgency, keyword, startDate, endDate);
        return AjaxResult.success(new TableDataInfo(page.getTotal(), page.getRecords()));
    }

    @GetMapping("/{orderId}")
    public AjaxResult detail(@PathVariable Long orderId) {
        return AjaxResult.success(orderService.workerDetail(orderId, SecurityUtils.getUserId()));
    }

    @GetMapping("/profile")
    public AjaxResult profile() {
        return AjaxResult.success(workerProfileService.getWorkerPublicInfo(SecurityUtils.getUserId()));
    }

    @PutMapping("/profile/status")
    public AjaxResult updateProfileStatus(@RequestBody Map<String, String> body) {
        workerProfileService.updateWorkStatus(SecurityUtils.getUserId(), body.get("workStatus"));
        return AjaxResult.success();
    }

    @GetMapping("/reject-reasons")
    public AjaxResult rejectReasons() {
        return AjaxResult.success(REJECT_REASONS);
    }

    @GetMapping("/knowledge/search")
    public AjaxResult searchKnowledge(@RequestParam String keyword) {
        List<KbArticle> articles = ragService.search(keyword, null);
        return AjaxResult.success(articles);
    }

    @GetMapping("/steps/{orderId}")
    public AjaxResult repairSteps(@PathVariable Long orderId) {
        orderService.workerDetail(orderId, SecurityUtils.getUserId());
        RpOrder order = orderService.getById(orderId);
        return AjaxResult.success(repairStepTemplateService.matchSteps(order.getTypeId(), order.getDescription()));
    }

    @PutMapping("/accept/{orderId}")
    public AjaxResult accept(@PathVariable Long orderId) {
        orderService.accept(orderId, SecurityUtils.getUserId());
        return AjaxResult.success();
    }

    @PutMapping("/reject/{orderId}")
    public AjaxResult reject(@PathVariable Long orderId, @RequestBody Map<String, String> body) {
        orderService.reject(orderId, SecurityUtils.getUserId(), body.get("reason"));
        return AjaxResult.success();
    }

    @PutMapping("/status")
    public AjaxResult updateStatus(@RequestBody Map<String, String> body) {
        orderService.updateStatus(Long.parseLong(body.get("orderId")),
            body.get("status"), SecurityUtils.getUserId().toString(), body.get("remark"));
        return AjaxResult.success();
    }

    @PutMapping("/complete/{orderId}")
    public AjaxResult complete(@PathVariable Long orderId) {
        orderService.complete(orderId);
        return AjaxResult.success();
    }

    @PostMapping("/upload/{orderId}")
    public AjaxResult upload(@PathVariable Long orderId,
                             @RequestParam("files") MultipartFile[] files) {
        List<String> urls = new ArrayList<>();
        if (files != null) {
            for (MultipartFile file : files) {
                if (file.isEmpty()) {
                    continue;
                }
                try {
                    urls.add(saveWatermarkFile(file));
                } catch (IOException e) {
                    return AjaxResult.error("上传失败: " + e.getMessage());
                }
            }
        }
        orderService.saveWorkerImages(orderId, SecurityUtils.getUserId(), urls);
        return AjaxResult.success(urls);
    }

    private String saveWatermarkFile(MultipartFile file) throws IOException {
        String dateDir = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        Path uploadDir = Paths.get(uploadPath, "repair-worker", dateDir).toAbsolutePath().normalize();
        Files.createDirectories(uploadDir);

        String original = file.getOriginalFilename();
        String ext = "";
        if (original != null && original.contains(".")) {
            ext = original.substring(original.lastIndexOf("."));
        }
        String fileName = UUID.randomUUID().toString().replace("-", "") + ext;
        Path dest = uploadDir.resolve(fileName).normalize();

        BufferedImage image = ImageIO.read(file.getInputStream());
        if (image == null) {
            Files.copy(file.getInputStream(), dest, StandardCopyOption.REPLACE_EXISTING);
        } else {
            BufferedImage rgb = new BufferedImage(image.getWidth(), image.getHeight(), BufferedImage.TYPE_INT_RGB);
            Graphics2D g = rgb.createGraphics();
            g.drawImage(image, 0, 0, null);
            String watermark = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
            int barHeight = Math.max(28, image.getHeight() / 12);
            g.setColor(new Color(0, 0, 0, 120));
            g.fillRect(0, image.getHeight() - barHeight, image.getWidth(), barHeight);
            g.setColor(Color.WHITE);
            g.setFont(new Font("SansSerif", Font.BOLD, Math.max(12, barHeight - 10)));
            g.drawString(watermark, 8, image.getHeight() - barHeight / 3);
            g.dispose();
            String format = "jpg";
            if (".png".equalsIgnoreCase(ext)) {
                format = "png";
            } else if (".gif".equalsIgnoreCase(ext)) {
                format = "gif";
            }
            ImageIO.write(rgb, format, dest.toFile());
        }
        return "/upload/repair-worker/" + dateDir + "/" + fileName;
    }
}
