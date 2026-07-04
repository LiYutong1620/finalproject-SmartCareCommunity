package com.smartcare.business.repair.service;

import com.smartcare.framework.storage.FileStorageService;
import com.smartcare.business.repair.util.RepairImageUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class RepairUploadService {

    private final FileStorageService fileStorageService;

    public List<String> saveRepairImages(MultipartFile[] files, boolean watermark) throws IOException {
        List<String> urls = new ArrayList<>();
        if (files == null) {
            return urls;
        }
        String dateDir = LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE);
        for (MultipartFile file : files) {
            if (file == null || file.isEmpty()) {
                continue;
            }
            String relative = fileStorageService.save(file, "repair", dateDir);
            Path saved = fileStorageService.getBasePath().resolve("repair").resolve(relative);
            if (watermark) {
                RepairImageUtil.addTimestampWatermark(saved);
            }
            urls.add("/upload/repair/" + relative);
        }
        return urls;
    }

    /** 将 canvas 导出的 data URL 保存为签名图片，返回可入库的访问路径 */
    public String saveSignatureDataUrl(String dataUrl) throws IOException {
        if (dataUrl == null || dataUrl.isBlank()) {
            throw new IllegalArgumentException("签名数据为空");
        }
        String payload = dataUrl.trim();
        String ext = ".png";
        if (payload.startsWith("data:")) {
            int comma = payload.indexOf(',');
            if (comma < 0) {
                throw new IllegalArgumentException("签名数据格式无效");
            }
            String header = payload.substring(0, comma).toLowerCase();
            payload = payload.substring(comma + 1);
            if (header.contains("jpeg") || header.contains("jpg")) {
                ext = ".jpg";
            }
        }
        byte[] bytes = Base64.getDecoder().decode(payload);
        String dateDir = LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE);
        Path uploadDir = fileStorageService.getBasePath().resolve("repair").resolve(dateDir).resolve("sign");
        Files.createDirectories(uploadDir);
        String fileName = UUID.randomUUID().toString().replace("-", "") + ext;
        Files.write(uploadDir.resolve(fileName), bytes);
        return "/upload/repair/" + dateDir + "/sign/" + fileName;
    }

    /** 将已入库的 /upload/ 路径图片读取为 Base64，供 GLM-4V 多模态分析 */
    public List<String> loadImageBase64List(List<String> imageUrls, int maxCount) {
        List<String> result = new ArrayList<>();
        if (imageUrls == null || maxCount <= 0) {
            return result;
        }
        for (String url : imageUrls) {
            if (result.size() >= maxCount) {
                break;
            }
            String base64 = readUploadUrlAsBase64(url);
            if (StringUtils.hasText(base64)) {
                result.add(base64);
            }
        }
        return result;
    }

    private String readUploadUrlAsBase64(String url) {
        if (!StringUtils.hasText(url)) {
            return null;
        }
        String path = url.trim();
        if (path.startsWith("/upload/")) {
            path = path.substring("/upload/".length());
        } else if (path.startsWith("upload/")) {
            path = path.substring("upload/".length());
        } else {
            return null;
        }
        Path file = fileStorageService.getBasePath().resolve(path).normalize();
        Path base = fileStorageService.getBasePath().normalize();
        if (!file.startsWith(base) || !Files.isRegularFile(file)) {
            return null;
        }
        try {
            return Base64.getEncoder().encodeToString(Files.readAllBytes(file));
        } catch (IOException e) {
            return null;
        }
    }
}
