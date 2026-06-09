package com.smartcare.business.community.controller;

import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.exception.ServiceException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@RestController
@RequestMapping("/owner/file")
public class OwnerFileController {

    private static final Set<String> ALLOWED_EXT = Set.of(".jpg", ".jpeg", ".png", ".gif", ".webp");

    @Value("${smartcare.file.upload-path:./upload}")
    private String uploadPath;

    @PostMapping("/upload")
    public AjaxResult upload(@RequestParam("file") MultipartFile file) throws IOException {
        if (file == null || file.isEmpty()) {
            throw new ServiceException("请选择文件");
        }
        String original = file.getOriginalFilename();
        String ext = original != null && original.contains(".")
            ? original.substring(original.lastIndexOf('.')).toLowerCase() : "";
        if (!ALLOWED_EXT.contains(ext)) {
            throw new ServiceException("仅支持图片格式");
        }
        Path dir = Paths.get(uploadPath, "community");
        Files.createDirectories(dir);
        String filename = UUID.randomUUID().toString().replace("-", "") + ext;
        file.transferTo(dir.resolve(filename).toFile());
        String url = "/upload/community/" + filename;
        Map<String, String> data = new HashMap<>();
        data.put("url", url);
        return AjaxResult.success(data);
    }
}
