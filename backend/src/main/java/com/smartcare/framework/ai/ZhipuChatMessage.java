package com.smartcare.framework.ai;

import lombok.Data;

@Data
public class ZhipuChatMessage {

    private String role;
    private Object content;

    public ZhipuChatMessage() {}

    public ZhipuChatMessage(String role, String content) {
        this.role = role;
        this.content = content;
    }

    public static ZhipuChatMessage system(String content) {
        return new ZhipuChatMessage("system", content);
    }

    public static ZhipuChatMessage user(String content) {
        return new ZhipuChatMessage("user", content);
    }

    public static ZhipuChatMessage assistant(String content) {
        return new ZhipuChatMessage("assistant", content);
    }
}
