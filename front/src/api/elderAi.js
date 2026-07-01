import request from "@/utils/request";

export function getMonitorStatus() {
  return request({ url: "/property/elder/ai-monitor/status", method: "get" });
}

export function getMonitorLogs(params) {
  return request({
    url: "/property/elder/ai-monitor/logs",
    method: "get",
    params,
  });
}

export function manualCheck(residentId) {
  return request({
    url: `/property/elder/ai-monitor/manual-check/${residentId}`,
    method: "post",
  });
}

export function getAloneElders() {
  return request({
    url: "/property/elder/ai-monitor/alone-elders",
    method: "get",
  });
}

// ==================== 水电数据监测 ====================

export function getUtilityList(params) {
  return request({
    url: "/property/elder/utility/list",
    method: "get",
    params,
  });
}

export function getUtilityRecent(residentId, hours = 48) {
  return request({
    url: `/property/elder/utility/recent/${residentId}`,
    method: "get",
    params: { hours },
  });
}

export function utilityCheck(residentId) {
  return request({
    url: `/property/elder/utility/check/${residentId}`,
    method: "post",
  });
}

export function utilityDetect(residentId) {
  return request({
    url: `/property/elder/utility/detect/${residentId}`,
    method: "get",
  });
}

export function simulateNormalData(residentId, days = 7) {
  return request({
    url: "/property/elder/utility/simulate/normal",
    method: "post",
    params: { residentId, days },
  });
}

export function simulateAnomalyData(residentId, type = "no_usage") {
  return request({
    url: "/property/elder/utility/simulate/anomaly",
    method: "post",
    params: { residentId, type },
  });
}
