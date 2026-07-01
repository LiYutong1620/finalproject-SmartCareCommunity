import request from "@/utils/request";

// 关怀人员
export function listCareStaff(params) {
  return request({ url: "/property/elder/staff/list", method: "get", params });
}
export function addCareStaff(data) {
  return request({ url: "/property/elder/staff", method: "post", data });
}
export function updateCareStaff(data) {
  return request({ url: "/property/elder/staff", method: "put", data });
}
export function deleteCareStaff(staffId) {
  return request({ url: `/property/elder/staff/${staffId}`, method: "delete" });
}

// 健康数据
export function recordHealth(data) {
  return request({
    url: "/property/elder/health/record",
    method: "post",
    data,
  });
}
export function getHealthRecords(residentId, params) {
  return request({
    url: `/property/elder/health/${residentId}`,
    method: "get",
    params,
  });
}

// 处置预案
export function listDisposalPlans(params) {
  return request({
    url: "/property/elder/disposal-plan/list",
    method: "get",
    params,
  });
}
export function addDisposalPlan(data) {
  return request({
    url: "/property/elder/disposal-plan",
    method: "post",
    data,
  });
}
export function updateDisposalPlan(data) {
  return request({ url: "/property/elder/disposal-plan", method: "put", data });
}
export function deleteDisposalPlan(planId) {
  return request({
    url: `/property/elder/disposal-plan/${planId}`,
    method: "delete",
  });
}

// 关怀工单
export function listCareOrders(params) {
  return request({
    url: "/property/elder/care-order/list",
    method: "get",
    params,
  });
}
export function createCareOrder(data) {
  return request({ url: "/property/elder/care-order", method: "post", data });
}
export function assignCareOrder(id, data) {
  return request({
    url: `/property/elder/care-order/${id}/assign`,
    method: "put",
    data,
  });
}
export function completeCareOrder(id, data) {
  return request({
    url: `/property/elder/care-order/${id}/complete`,
    method: "put",
    data,
  });
}
export function getCareOrderDetail(id) {
  return request({ url: `/property/elder/care-order/${id}`, method: "get" });
}

// 预警
export function listAlerts(params) {
  return request({ url: "/property/elder/alert/list", method: "get", params });
}
export function handleAlert(data) {
  return request({ url: "/property/elder/alert/handle", method: "put", data });
}
export function getAlertDetail(alertId) {
  return request({ url: `/property/elder/alert/${alertId}`, method: "get" });
}
export function closeAlert(alertId, data) {
  return request({
    url: `/property/elder/alert/${alertId}/close`,
    method: "put",
    data,
  });
}

// 处置记录
export function listDisposalRecords(params) {
  return request({
    url: "/property/elder/disposal-record/list",
    method: "get",
    params,
  });
}
export function addDisposalRecord(data) {
  return request({
    url: "/property/elder/disposal-record",
    method: "post",
    data,
  });
}
