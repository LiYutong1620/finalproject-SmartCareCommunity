package com.smartcare.business.repair.controller;

import com.smartcare.business.repair.domain.RpOrder;
import com.smartcare.business.repair.service.RepairUploadService;
import com.smartcare.business.repair.service.RpOrderService;
import com.smartcare.common.exception.ServiceException;
import com.smartcare.common.core.domain.AjaxResult;
import com.smartcare.common.core.page.TableDataInfo;
import com.smartcare.framework.security.SecurityUtils;
import com.smartcare.system.domain.SysUser;
import com.smartcare.system.service.UserAccountService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/owner/repair")
@RequiredArgsConstructor
public class OwnerRepairController {

    private final RpOrderService orderService;
    private final RepairUploadService uploadService;
    private final UserAccountService accountService;

    @PostMapping
    public AjaxResult submit(@RequestBody RpOrder order) throws Exception {
        validateExpectedTime(order.getExpectedTime());
        return AjaxResult.success(doSubmit(order, null));
    }

    @PostMapping("/submit-with-files")
    public AjaxResult submitWithFiles(@RequestParam String description,
                                    @RequestParam(required = false)
                                    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") LocalDateTime expectedTime,
                                    @RequestParam(required = false) MultipartFile[] files) throws Exception {
        validateExpectedTime(expectedTime);
        RpOrder order = buildOwnerOrder(description, expectedTime);
        var imageUrls = uploadService.saveRepairImages(files, true);
        return AjaxResult.success(orderService.submitWithImages(order, imageUrls));
    }

    @GetMapping("/list")
    public AjaxResult list(@RequestParam(defaultValue = "1") int pageNum,
                           @RequestParam(defaultValue = "10") int pageSize,
                           @RequestParam(required = false) String status,
                           @RequestParam(required = false) String scope) {
        var page = orderService.pageByOwner(SecurityUtils.getUserId(), pageNum, pageSize, status, scope);
        return AjaxResult.success(new TableDataInfo(page.getTotal(), page.getRecords()));
    }

    @GetMapping("/{orderId}")
    public AjaxResult detail(@PathVariable Long orderId) {
        return AjaxResult.success(orderService.buildDetail(orderId, SecurityUtils.getUserId(), "owner"));
    }

    @PutMapping("/cancel/{orderId}")
    public AjaxResult cancel(@PathVariable Long orderId) {
        orderService.cancel(orderId, SecurityUtils.getUserId());
        return AjaxResult.success();
    }

    @PutMapping("/{orderId}/edit")
    public AjaxResult edit(@PathVariable Long orderId,
                           @RequestParam String description,
                           @RequestParam(required = false)
                           @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") LocalDateTime expectedTime,
                           @RequestParam(required = false) String keepImageIds,
                           @RequestParam(required = false) MultipartFile[] files) throws Exception {
        validateExpectedTime(expectedTime);
        var imageUrls = uploadService.saveRepairImages(files, true);
        orderService.editPending(orderId, SecurityUtils.getUserId(), description, expectedTime,
            imageUrls, parseImageIds(keepImageIds));
        return AjaxResult.success();
    }

    @PostMapping("/{orderId}/append")
    public AjaxResult append(@PathVariable Long orderId,
                             @RequestParam(required = false) String description,
                             @RequestParam(required = false) MultipartFile[] files) throws Exception {
        var imageUrls = uploadService.saveRepairImages(files, true);
        orderService.appendInfo(orderId, SecurityUtils.getUserId(), description, imageUrls);
        return AjaxResult.success();
    }

    @PutMapping("/accept/{orderId}")
    public AjaxResult accept(@PathVariable Long orderId, @RequestBody Map<String, Object> body) throws Exception {
        String signImage = (String) body.get("signImage");
        if (!StringUtils.hasText(signImage)) {
            throw new ServiceException("请先签名");
        }
        if (signImage.startsWith("data:image")) {
            signImage = uploadService.saveSignatureDataUrl(signImage);
        }
        orderService.ownerAccept(orderId,
            signImage,
            body.get("score") == null ? null : Integer.parseInt(body.get("score").toString()),
            (String) body.get("tags"),
            (String) body.get("content"));
        return AjaxResult.success();
    }

    private RpOrder doSubmit(RpOrder order, MultipartFile[] files) throws Exception {
        order.setOwnerId(SecurityUtils.getUserId());
        order.setUrgency("normal");
        fillHouseId(order);
        if (files != null && files.length > 0) {
            return orderService.submitWithImages(order, uploadService.saveRepairImages(files, true));
        }
        return orderService.submit(order);
    }

    private RpOrder buildOwnerOrder(String description, LocalDateTime expectedTime) {
        RpOrder order = new RpOrder();
        order.setDescription(description);
        order.setExpectedTime(expectedTime);
        order.setUrgency("normal");
        order.setOwnerId(SecurityUtils.getUserId());
        fillHouseId(order);
        return order;
    }

    private void fillHouseId(RpOrder order) {
        if (order.getHouseId() != null) {
            return;
        }
        SysUser user = accountService.findById(SecurityUtils.getUserId());
        if (user != null && user.getHouseId() != null) {
            order.setHouseId(user.getHouseId());
        }
    }

    private void validateExpectedTime(LocalDateTime expectedTime) {
        if (expectedTime == null) {
            return;
        }
        LocalDateTime nowMinute = LocalDateTime.now().withSecond(0).withNano(0);
        LocalDateTime selected = expectedTime.withSecond(0).withNano(0);
        if (selected.isBefore(nowMinute)) {
            throw new com.smartcare.common.exception.ServiceException("期望时间不能早于当前时间");
        }
    }

    private List<Long> parseImageIds(String keepImageIds) {
        if (!org.springframework.util.StringUtils.hasText(keepImageIds)) {
            return List.of();
        }
        return Arrays.stream(keepImageIds.split(","))
            .map(String::trim)
            .filter(org.springframework.util.StringUtils::hasText)
            .map(Long::parseLong)
            .collect(Collectors.toList());
    }
}
