package com.smartcare.business.repair.util;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.nio.file.Path;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public final class RepairImageUtil {

    private RepairImageUtil() {
    }

    public static void addTimestampWatermark(Path imagePath) throws IOException {
        BufferedImage image = ImageIO.read(imagePath.toFile());
        if (image == null) {
            return;
        }
        int type = image.getColorModel().hasAlpha() ? BufferedImage.TYPE_INT_ARGB : BufferedImage.TYPE_INT_RGB;
        BufferedImage canvas = new BufferedImage(image.getWidth(), image.getHeight(), type);
        Graphics2D g = canvas.createGraphics();
        g.drawImage(image, 0, 0, null);
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
        String text = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        int fontSize = Math.max(14, Math.min(28, image.getWidth() / 24));
        g.setFont(new Font(Font.SANS_SERIF, Font.BOLD, fontSize));
        FontMetrics fm = g.getFontMetrics();
        int textWidth = fm.stringWidth(text);
        int padding = 8;
        int x = Math.max(padding, image.getWidth() - textWidth - padding * 2);
        int y = image.getHeight() - padding;
        g.setColor(new Color(0, 0, 0, 170));
        g.fillRoundRect(x - padding, y - fm.getAscent() - padding, textWidth + padding * 2, fm.getHeight() + padding, 6, 6);
        g.setColor(Color.WHITE);
        g.drawString(text, x, y);
        g.dispose();
        String name = imagePath.getFileName().toString().toLowerCase();
        String format = name.endsWith(".png") ? "png" : "jpg";
        ImageIO.write(canvas, format, imagePath.toFile());
    }
}
