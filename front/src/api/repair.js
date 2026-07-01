import request from "@/utils/request";

export function listOwnerRepair(params) {
  return request({ url: "/owner/repair/list", method: "get", params });
}

export function submitRepairWithImages(data) {
  const formData = new FormData();
  formData.append("description", data.description);
  formData.append("urgency", data.urgency || "normal");
  if (data.houseId) formData.append("houseId", data.houseId);
  if (data.typeId) formData.append("typeId", data.typeId);
  if (data.files && data.files.length) {
    data.files.forEach((file) => {
      formData.append("files", file);
    });
  }
  return request({
    url: "/owner/repair",
    method: "post",
    data: formData,
    headers: { "Content-Type": "multipart/form-data" },
  });
}

export function submitRepair(data) {
  return request({ url: "/owner/repair", method: "post", data });
}

export function supplementRepair(orderId, data) {
  const formData = new FormData();
  if (data.description) formData.append("description", data.description);
  if (data.files && data.files.length) {
    data.files.forEach((file) => formData.append("files", file));
  }
  return request({
    url: `/owner/repair/supplement/${orderId}`,
    method: "put",
    data: formData,
    headers: { "Content-Type": "multipart/form-data" },
  });
}

export function cancelRepair(orderId) {
  return request({ url: `/owner/repair/cancel/${orderId}`, method: "put" });
}

export function urgeRepair(orderId) {
  return request({ url: `/owner/repair/urge/${orderId}`, method: "put" });
}

export function listWorkerOrder(params) {
  return request({ url: "/worker/repair/list", method: "get", params });
}

export function getWorkerOrderDetail(orderId) {
  return request({ url: `/worker/repair/${orderId}`, method: "get" });
}

export function getWorkerRejectReasons() {
  return request({ url: "/worker/repair/reject-reasons", method: "get" });
}

export function searchWorkerKnowledge(keyword) {
  return request({ url: "/worker/repair/knowledge/search", method: "get", params: { keyword } });
}

export function getWorkerProfile() {
  return request({ url: "/worker/repair/profile", method: "get" });
}

export function updateWorkerStatus(data) {
  return request({ url: "/worker/repair/profile/status", method: "put", data });
}

export function getRepairWorkerInfo(workerId) {
  return request({ url: `/owner/repair/worker/${workerId}`, method: "get" });
}

export function acceptOrder(orderId) {
  return request({ url: `/worker/repair/accept/${orderId}`, method: "put" });
}

export function rejectOrder(orderId, data) {
  return request({ url: `/worker/repair/reject/${orderId}`, method: "put", data });
}

export function updateOrderStatus(data) {
  return request({ url: "/worker/repair/status", method: "put", data });
}

export function completeOrder(orderId) {
  return request({ url: `/worker/repair/complete/${orderId}`, method: "put" });
}

export function uploadWorkerRepairImages(orderId, files) {
  const formData = new FormData();
  files.forEach((file) => formData.append("files", file));
  return request({
    url: `/worker/repair/upload/${orderId}`,
    method: "post",
    data: formData,
    headers: { "Content-Type": "multipart/form-data" },
  });
}

export function listPropertyRepair(params) {
  return request({ url: "/property/repair/list", method: "get", params });
}

export function getPropertyRepairDetail(orderId) {
  return request({ url: `/property/repair/${orderId}`, method: "get" });
}

export function listRepairTypes() {
  return request({ url: "/property/repair/types", method: "get" });
}

export function addRepairType(data) {
  return request({ url: "/property/repair/types", method: "post", data });
}

export function updateRepairType(data) {
  return request({ url: "/property/repair/types", method: "put", data });
}

export function deleteRepairType(typeId) {
  return request({ url: `/property/repair/types/${typeId}`, method: "delete" });
}

export function assignRepair(data) {
  return request({ url: "/property/repair/assign", method: "put", data });
}

export function forceRepairStatus(data) {
  return request({ url: "/property/repair/status", method: "put", data });
}

export function adjustRepair(data) {
  return request({ url: "/property/repair/adjust", method: "put", data });
}

export function ownerAccept(orderId, data) {
  return request({
    url: `/owner/repair/accept/${orderId}`,
    method: "put",
    data,
  });
}

export function getOrderDetail(orderId) {
  return request({ url: `/owner/repair/${orderId}`, method: "get" });
}

export function submitEvaluate(data) {
  return request({
    url: "/owner/repair/evaluate",
    method: "post",
    data,
  });
}

export function listMessages(params) {
  return request({ url: "/system/message/list", method: "get", params });
}

export function unreadMessageCount() {
  return request({ url: "/system/message/unreadCount", method: "get" });
}

export function markMessageRead(messageId) {
  return request({ url: `/system/message/read/${messageId}`, method: "put" });
}

export function autoDispatchRepair(orderId) {
  return request({ url: `/property/repair/ai/auto-dispatch/${orderId}`, method: "post" });
}

export function listRepairWeeklyReports(params) {
  return request({ url: "/property/repair/ai/reports", method: "get", params });
}

export function generateRepairWeeklyReport(weekStart) {
  return request({
    url: "/property/repair/ai/reports/generate",
    method: "post",
    params: weekStart ? { weekStart } : {},
  });
}

export function getRepairMonthlyTrend(months = 6) {
  return request({ url: "/property/repair/ai/trend", method: "get", params: { months } });
}

export function getWorkerRepairSteps(orderId) {
  return request({ url: `/worker/repair/steps/${orderId}`, method: "get" });
}
