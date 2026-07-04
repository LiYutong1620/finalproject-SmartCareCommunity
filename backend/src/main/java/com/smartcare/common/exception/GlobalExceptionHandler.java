package com.smartcare.common.exception;

import com.smartcare.common.core.domain.AjaxResult;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataAccessException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.validation.BindException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ServiceException.class)
    public AjaxResult handleServiceException(ServiceException e) {
        return AjaxResult.error(e.getMessage());
    }

    @ExceptionHandler(AccessDeniedException.class)
    public AjaxResult handleAccessDenied(AccessDeniedException e) {
        return AjaxResult.error(403, "没有权限访问");
    }

    @ExceptionHandler({MethodArgumentNotValidException.class, BindException.class})
    public AjaxResult handleValidException(Exception e) {
        String msg = "参数校验失败";
        if (e instanceof MethodArgumentNotValidException ex && ex.getBindingResult().hasErrors()) {
            msg = ex.getBindingResult().getAllErrors().get(0).getDefaultMessage();
        }
        return AjaxResult.error(msg);
    }

    @ExceptionHandler(DataAccessException.class)
    public AjaxResult handleDataAccessException(DataAccessException e) {
        log.error("数据库访问异常", e);
        String msg = e.getMostSpecificCause() != null ? e.getMostSpecificCause().getMessage() : e.getMessage();
        if (msg != null && (msg.contains("Unknown column") || msg.contains("doesn't exist"))) {
            return AjaxResult.error("数据库结构未更新，请重新导入 sql/smart_care_community.sql 或执行 sql/upgrade_after_merge.sql");
        }
        if (msg != null && (msg.contains("Data too long") || msg.contains("Data truncation"))) {
            return AjaxResult.error("数据长度超出限制，请联系管理员检查表结构");
        }
        return AjaxResult.error("数据库操作失败，请检查数据库连接与表结构");
    }

    @ExceptionHandler(Exception.class)
    public AjaxResult handleException(Exception e) {
        log.error("未处理异常", e);
        Throwable root = e;
        while (root.getCause() != null) {
            root = root.getCause();
        }
        String msg = root.getMessage();
        if (msg == null || msg.isBlank()) {
            msg = e.getClass().getSimpleName();
        }
        return AjaxResult.error(msg);
    }
}
