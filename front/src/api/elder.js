import request from "@/utils/request";

// 关怀人员
export function listCareStaffByResident(residentId) {
  return request({ url: `/property/elder/staff/by-resident/${residentId}`, method: "get" });
}
export function processAlert(alertId) {
  return request({ url: `/property/elder/alert/${alertId}/process`, method: "put" });
}
export function assignAlertCare(alertId, data) {
  return request({ url: `/property/elder/alert/${alertId}/assign`, method: "put", data });
}
export function listCareStaffTypes() {
  return request({ url: "/property/elder/staff-type/list", method: "get" });
}
export function addCareStaffType(data) {
  return request({ url: "/property/elder/staff-type", method: "post", data });
}
export function deleteCareStaffType(typeId) {
  return request({ url: `/property/elder/staff-type/${typeId}`, method: "delete" });
}
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
