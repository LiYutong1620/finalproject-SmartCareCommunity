package com.smartcare.framework.captcha;

import com.smartcare.common.exception.ServiceException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.util.Base64;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.random.RandomGenerator;

@Service
public class CaptchaService {

    private static final int WIDTH = 120;
    private static final int HEIGHT = 40;
    private static final int CODE_LEN = 4;
    private static final long EXPIRE_MS = 120_000;
    private static final String CHAR_POOL = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ";

    private final Map<String, CaptchaEntry> store = new ConcurrentHashMap<>();
    private final RandomGenerator random = RandomGenerator.getDefault();

    @Value("${smartcare.captcha.enabled:true}")
    private boolean captchaEnabled;

    public CaptchaResult create() {
        if (!captchaEnabled) {
            return new CaptchaResult("", "", false);
        }
        String code = randomCode();
        String uuid = UUID.randomUUID().toString().replace("-", "");
        store.put(uuid, new CaptchaEntry(code.toLowerCase(), System.currentTimeMillis()));
        String img = generateBase64Image(code);
        return new CaptchaResult(uuid, img, true);
    }

    public void validate(String uuid, String code) {
        if (!captchaEnabled) {
            return;
        }
        if (!StringUtils.hasText(uuid) || !StringUtils.hasText(code)) {
            throw new ServiceException("请输入验证码");
        }
        CaptchaEntry entry = store.remove(uuid);
        if (entry == null) {
            throw new ServiceException("验证码已失效，请刷新后重试");
        }
        if (System.currentTimeMillis() - entry.createTime > EXPIRE_MS) {
            throw new ServiceException("验证码已过期，请刷新后重试");
        }
        if (!entry.code.equalsIgnoreCase(code.trim())) {
            throw new ServiceException("验证码错误");
        }
    }

    private String randomCode() {
        StringBuilder sb = new StringBuilder(CODE_LEN);
        for (int i = 0; i < CODE_LEN; i++) {
            sb.append(CHAR_POOL.charAt(random.nextInt(CHAR_POOL.length())));
        }
        return sb.toString();
    }

    private String generateBase64Image(String code) {
        BufferedImage image = new BufferedImage(WIDTH, HEIGHT, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = image.createGraphics();
        try {
            g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
            g.setColor(new Color(245, 246, 250));
            g.fillRect(0, 0, WIDTH, HEIGHT);
            for (int i = 0; i < 6; i++) {
                g.setColor(randomColor(160, 220));
                g.drawLine(random.nextInt(WIDTH), random.nextInt(HEIGHT),
                    random.nextInt(WIDTH), random.nextInt(HEIGHT));
            }
            g.setFont(new Font("Arial", Font.BOLD, 28));
            int x = 12;
            for (char c : code.toCharArray()) {
                g.setColor(randomColor(20, 130));
                double angle = (random.nextInt(30) - 15) * Math.PI / 180;
                g.rotate(angle, x, 28);
                g.drawString(String.valueOf(c), x, 30);
                g.rotate(-angle, x, 28);
                x += 26;
            }
            for (int i = 0; i < 30; i++) {
                g.setColor(randomColor(100, 200));
                g.fillRect(random.nextInt(WIDTH), random.nextInt(HEIGHT), 2, 2);
            }
        } finally {
            g.dispose();
        }
        try (ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            ImageIO.write(image, "jpg", out);
            return Base64.getEncoder().encodeToString(out.toByteArray());
        } catch (Exception e) {
            throw new ServiceException("验证码生成失败");
        }
    }

    private Color randomColor(int min, int max) {
        int r = min + random.nextInt(max - min);
        int g = min + random.nextInt(max - min);
        int b = min + random.nextInt(max - min);
        return new Color(r, g, b);
    }

    private record CaptchaEntry(String code, long createTime) {}

    public record CaptchaResult(String uuid, String img, boolean captchaEnabled) {}
}
