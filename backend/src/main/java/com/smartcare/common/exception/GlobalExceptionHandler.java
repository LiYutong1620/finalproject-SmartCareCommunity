package com.smartcare.common.exception;

import com.smartcare.common.core.domain.AjaxResult;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.validation.BindException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

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

    @ExceptionHandler(Exception.class)
    public AjaxResult handleException(Exception e) {
        return AjaxResult.error(e.getMessage() != null ? e.getMessage() : "系统异常");
    }
}
