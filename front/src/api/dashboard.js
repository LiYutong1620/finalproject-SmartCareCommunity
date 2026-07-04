import request from "@/utils/request";

export function getSummary() {
  return request({ url: "/property/dashboard/summary", method: "get" });
}

export function getElderStats() {
  return request({ url: "/property/dashboard/elder-stats", method: "get" });
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

/** 预警处理趋势 */
export function getAlertProcessTrend() {
  return request({
    url: "/property/dashboard/alert-process-trend",
    method: "get",
  });
}

/** 住户结构 */
export function getResidentStructure() {
  return request({
    url: "/property/dashboard/resident-structure",
    method: "get",
  });
}

/** 房屋结构 */
export function getHouseStructure() {
  return request({
    url: "/property/dashboard/house-structure",
    method: "get",
  });
}

/** AI 安全预测 */
export function getAiSafetyPrediction() {
  return request({
    url: "/property/dashboard/ai-safety-prediction",
    method: "get",
  });
}
