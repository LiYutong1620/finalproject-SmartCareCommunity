import request from "@/utils/request";

export function getSummary() {
  return request({ url: "/property/dashboard/summary", method: "get" });
}

export function getElderStats() {
  return request({ url: "/property/dashboard/elder-stats", method: "get" });
}

export function getAlertTrend() {
  return request({ url: "/property/dashboard/alert-trend", method: "get" });
}

export function getOrderTrend() {
  return request({ url: "/property/dashboard/order-trend", method: "get" });
}

export function getStaffPerformance() {
  return request({
    url: "/property/dashboard/staff-performance",
    method: "get",
  });
}

export function getRiskResidents() {
  return request({ url: "/property/dashboard/risk-residents", method: "get" });
}

/** 工单完成率趋势（日/周/月） */
export function getCompletionRate(period) {
  return request({
    url: "/property/dashboard/completion-rate",
    method: "get",
    params: { period },
  });
}

/** 报修分布（按故障类型 + 按楼栋） */
export function getRepairDistribution() {
  return request({
    url: "/property/dashboard/repair-distribution",
    method: "get",
  });
}

/** 预警趋势（按类型分类） */
export function getAlertTrendByType() {
  return request({
    url: "/property/dashboard/alert-trend-by-type",
    method: "get",
  });
}

/** 工单状态分布 */
export function getOrderStatusDistribution() {
  return request({
    url: "/property/dashboard/order-status-distribution",
    method: "get",
  });
}

/** 维修工负载TOP5 */
export function getWorkerLoad() {
  return request({
    url: "/property/dashboard/worker-load",
    method: "get",
  });
}
