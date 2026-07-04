package com.smartcare.framework.storage;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.net.URISyntaxException;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

@Component
public class FileStorageService {

    private final Path basePath;

    public FileStorageService(@Value("${smartcare.file.upload-path:./upload}") String uploadPath) throws IOException {
        this.basePath = resolveUploadBase(uploadPath);
        Files.createDirectories(this.basePath);
    }

    public Path getBasePath() {
        return basePath;
    }

    public String save(MultipartFile file, String subDir, String dateDir) throws IOException {
        Path uploadDir = basePath.resolve(subDir).resolve(dateDir).normalize();
        Files.createDirectories(uploadDir);

        String original = file.getOriginalFilename();
        String ext = "";
        if (original != null && original.contains(".")) {
            ext = original.substring(original.lastIndexOf("."));
        }
        String fileName = UUID.randomUUID().toString().replace("-", "") + ext;
        Path dest = uploadDir.resolve(fileName).normalize();
        file.transferTo(dest);
        return dateDir + "/" + fileName;
    }

    /** 保存到固定子目录（如 avatar），返回文件名 */
    public String saveFlat(MultipartFile file, String subDir) throws IOException {
        Path uploadDir = basePath.resolve(subDir).normalize();
        Files.createDirectories(uploadDir);

        String original = file.getOriginalFilename();
        String ext = "";
        if (original != null && original.contains(".")) {
            ext = original.substring(original.lastIndexOf("."));
        }
        String fileName = UUID.randomUUID().toString().replace("-", "") + ext;
        Path dest = uploadDir.resolve(fileName).normalize();
        file.transferTo(dest);
        return fileName;
    }

    private static Path resolveUploadBase(String uploadPath) {
        Path configured = Paths.get(uploadPath);
        if (configured.isAbsolute()) {
            return configured.normalize();
        }
        return detectApplicationDirectory().resolve(configured).normalize();
    }

    /**
     * 相对路径基于 backend 模块目录解析，避免 Tomcat 临时工作目录导致路径错误。
     */
    private static Path detectApplicationDirectory() {
        try {
            URL location = FileStorageService.class.getProtectionDomain().getCodeSource().getLocation();
            Path codePath = Paths.get(location.toURI());
            if (Files.isRegularFile(codePath)) {
                codePath = codePath.getParent();
            }
            if (codePath != null && "target".equals(codePath.getFileName().toString())) {
                Path backend = codePath.getParent();
                if (backend != null) {
                    return backend.toAbsolutePath().normalize();
                }
            }
        } catch (URISyntaxException ignored) {
            // fall through
        }
        return Paths.get(System.getProperty("user.dir")).toAbsolutePath().normalize();
    }
}
