package com.smartcare.common.core.domain;

import java.util.HashMap;

public class AjaxResult extends HashMap<String, Object> {

    private static final long serialVersionUID = 1L;

    public static final int SUCCESS = 200;
    public static final int ERROR = 500;

    public AjaxResult() {}

    public AjaxResult(int code, String msg, Object data) {
        super.put("code", code);
        super.put("msg", msg);
        if (data != null) {
            super.put("data", data);
        }
    }

    public static AjaxResult success() {
        return success("操作成功");
    }

    public static AjaxResult success(Object data) {
        return success("操作成功", data);
    }

    public static AjaxResult success(String msg) {
        return success(msg, null);
    }

    public static AjaxResult success(String msg, Object data) {
        return new AjaxResult(SUCCESS, msg, data);
    }

    public static AjaxResult error(String msg) {
        return new AjaxResult(ERROR, msg, null);
    }

    public static AjaxResult error(int code, String msg) {
        return new AjaxResult(code, msg, null);
    }
}
