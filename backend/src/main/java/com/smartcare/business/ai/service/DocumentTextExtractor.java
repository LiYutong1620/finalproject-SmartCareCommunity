package com.smartcare.business.ai.service;

import com.smartcare.common.exception.ServiceException;
import org.apache.pdfbox.Loader;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.apache.poi.xwpf.usermodel.XWPFParagraph;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

@Component
public class DocumentTextExtractor {

    public String extract(MultipartFile file) throws IOException {
        if (file == null || file.isEmpty()) {
            throw new ServiceException("文件不能为空");
        }
        String filename = file.getOriginalFilename();
        if (!StringUtils.hasText(filename)) {
            throw new ServiceException("文件名无效");
        }
        String lower = filename.toLowerCase();
        if (lower.endsWith(".docx")) {
            return extractDocx(file.getInputStream());
        }
        if (lower.endsWith(".pdf")) {
            return extractPdf(file.getBytes());
        }
        if (lower.endsWith(".txt")) {
            return new String(file.getBytes(), StandardCharsets.UTF_8);
        }
        throw new ServiceException("不支持的文件格式，请上传 .docx / .pdf / .txt");
    }

    private String extractDocx(InputStream inputStream) throws IOException {
        try (XWPFDocument document = new XWPFDocument(inputStream)) {
            StringBuilder sb = new StringBuilder();
            for (XWPFParagraph paragraph : document.getParagraphs()) {
                String text = paragraph.getText();
                if (StringUtils.hasText(text)) {
                    sb.append(text.trim()).append('\n');
                }
            }
            return sb.toString().trim();
        }
    }

    private String extractPdf(byte[] bytes) throws IOException {
        try (PDDocument document = Loader.loadPDF(bytes)) {
            PDFTextStripper stripper = new PDFTextStripper();
            return stripper.getText(document).trim();
        }
    }
}
