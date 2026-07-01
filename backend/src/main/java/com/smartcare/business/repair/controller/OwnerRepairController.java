package com.smartcare.business.repair.controller;

import com.smartcare.business.repair.domain.RpOrder;
import com.smartcare.business.repair.domain.RpOrderProgress;
import com.smartcare.business.repair.mapper.RpOrderProgressMapper;
import com.smartcare.business.repair.service.RpOrderEvalService;
import com.smartcare.business.repair.service.RpOrderService;
import com.smartcare.business.repair.service.RpWorkerProfileService;
import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.framework.security.SecurityUtils;
import com.smartcare.framework.storage.FileStorageService;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/owner/repair")
@RequiredArgsConstructor
public class OwnerRepairController {

    private final RpOrderService orderService;
    private final RpOrderProgressMapper progressMapper;
    private final RpOrderEvalService evalService;
    private final RpWorkerProfileService workerProfileService;
    private final FileStorageService fileStorageService;

    @PostMapping
    public AjaxResult submit(
            @RequestParam("description") String description,
            @RequestParam(value = "urgency", defaultValue = "normal") String urgency,
            @RequestParam(value = "houseId", required = false) Long houseId,
            @RequestParam(value = "typeId", required = false) Long typeId,
            @RequestParam(value = "files", required = false) MultipartFile[] files
    ) {
        Long userId = SecurityUtils.getUserId();

        List<String> imageUrls = new ArrayList<>();
        if (files != null && files.length > 0) {
            for (MultipartFile file : files) {
                if (file.isEmpty()) {
                    continue;
                }
                try {
                    String fileName = saveFile(file);
                    imageUrls.add("/upload/repair/" + fileName);
                } catch (IOException e) {
                    return AjaxResult.error("图片上传失败: " + e.getMessage());
                }
            }
        }

        RpOrder order = new RpOrder();
        order.setOwnerId(userId);
        order.setHouseId(houseId);
        order.setTypeId(typeId);
        order.setDescription(description);
        order.setUrgency(urgency);

        orderService.submit(order, imageUrls);
        return AjaxResult.success(order);
    }

    private String saveFile(MultipartFile file) throws IOException {
        String dateDir = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        return fileStorageService.save(file, "repair", dateDir);
    }

    @GetMapping("/list")
    public AjaxResult list(@RequestParam(defaultValue = "1") int pageNum,
                           @RequestParam(defaultValue = "10") int pageSize,
                           @RequestParam(required = false) String status) {
        var page = orderService.pageByOwner(SecurityUtils.getUserId(), pageNum, pageSize, status);
        return AjaxResult.success(new TableDataInfo(page.getTotal(), page.getRecords()));
    }

    @GetMapping("/{orderId}")
    public AjaxResult detail(@PathVariable Long orderId) {
        return AjaxResult.success(orderService.ownerDetail(orderId, SecurityUtils.getUserId()));
    }

    @GetMapping("/progress/{orderId}")
    public AjaxResult progress(@PathVariable Long orderId) {
        return AjaxResult.success(orderService.listProgress(orderId));
    }

    @GetMapping("/worker/{workerId}")
    public AjaxResult worker(@PathVariable Long workerId) {
        return AjaxResult.success(workerProfileService.getWorkerPublicInfo(workerId));
    }

    @PutMapping("/cancel/{orderId}")
    public AjaxResult cancel(@PathVariable Long orderId) {
        orderService.cancel(orderId, SecurityUtils.getUserId());
        return AjaxResult.success();
    }

    @PutMapping("/urge/{orderId}")
    public AjaxResult urge(@PathVariable Long orderId) {
        orderService.urge(orderId, SecurityUtils.getUserId());
        return AjaxResult.success();
    }

    @PostMapping("/copy/{orderId}")
    public AjaxResult copy(@PathVariable Long orderId) {
        return AjaxResult.success(orderService.copyOrder(orderId, SecurityUtils.getUserId()));
    }

    @PutMapping("/accept/{orderId}")
    public AjaxResult accept(@PathVariable Long orderId, @RequestBody Map<String, Object> body) {
        orderService.ownerAccept(orderId,
            (String) body.get("signImage"),
            (Integer) body.get("score"),
            (String) body.get("tags"));
        return AjaxResult.success();
    }

    @PostMapping("/evaluate")
    public AjaxResult evaluate(@RequestBody Map<String, Object> body) {
        Long orderId = Long.valueOf(body.get("orderId").toString());
        Integer score = (Integer) body.get("score");
        String tags = (String) body.get("tags");
        String content = (String) body.get("content");
        evalService.saveEval(orderId, score, tags, content);
        return AjaxResult.success();
    }

    @PutMapping("/supplement/{orderId}")
    public AjaxResult supplement(@PathVariable Long orderId,
                                 @RequestParam(value = "description", required = false) String description,
                                 @RequestParam(value = "files", required = false) MultipartFile[] files) {
        Long userId = SecurityUtils.getUserId();
        List<String> imageUrls = new ArrayList<>();
        if (files != null) {
            for (MultipartFile file : files) {
                if (file.isEmpty()) {
                    continue;
                }
                try {
                    String fileName = saveFile(file);
                    imageUrls.add("/upload/repair/" + fileName);
                } catch (IOException e) {
                    return AjaxResult.error("图片上传失败: " + e.getMessage());
                }
            }
        }
        orderService.supplement(orderId, userId, description, imageUrls);
        return AjaxResult.success();
    }
}
