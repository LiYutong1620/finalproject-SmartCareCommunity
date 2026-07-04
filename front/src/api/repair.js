import request from '@/utils/request'

// ---------- 业主端 ----------
export function listOwnerRepair(params) {
  return request({ url: '/owner/repair/list', method: 'get', params })
}

export function getOrderDetail(orderId) {
  return request({ url: `/owner/repair/${orderId}`, method: 'get' })
}

export function submitRepair(data) {
  return request({ url: '/owner/repair', method: 'post', data })
}

export function submitRepairWithFiles(formData) {
  return request({
    url: '/owner/repair/submit-with-files',
    method: 'post',
    data: formData,
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

export function cancelRepair(orderId) {
  return request({ url: `/owner/repair/cancel/${orderId}`, method: 'put' })
}

export function editRepair(orderId, { description, expectedTime, files, keepImageIds }) {
  const formData = new FormData()
  formData.append('description', description)
  if (expectedTime) formData.append('expectedTime', expectedTime)
  if (keepImageIds?.length) formData.append('keepImageIds', keepImageIds.join(','))
  if (files?.length) {
    files.forEach(f => formData.append('files', f))
  }
  return request({
    url: `/owner/repair/${orderId}/edit`,
    method: 'put',
    data: formData,
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

export function appendRepair(orderId, { description, files }) {
  const formData = new FormData()
  if (description) formData.append('description', description)
  if (files?.length) {
    files.forEach(f => formData.append('files', f))
  }
  return request({
    url: `/owner/repair/${orderId}/append`,
    method: 'post',
    data: formData,
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

export function ownerAccept(orderId, data) {
  return request({ url: `/owner/repair/accept/${orderId}`, method: 'put', data })
}

// ---------- 维修工端 ----------
export function listWorkerOrder(params) {
  return request({ url: '/worker/repair/list', method: 'get', params })
}

export function listWorkerTodo(params) {
  return request({ url: '/worker/repair/todo', method: 'get', params })
}

export function listWorkerHistory(params) {
  return request({ url: '/worker/repair/history', method: 'get', params })
}

export function listWorkerPool(params) {
  return request({ url: '/worker/repair/pool', method: 'get', params })
}

export function getWorkerDashboard(params) {
  return request({ url: '/worker/repair/dashboard', method: 'get', params })
}

export function getWorkerEvaluations() {
  return request({ url: '/worker/repair/evaluations', method: 'get' })
}

export function getWorkerOrderDetail(orderId) {
  return request({ url: `/worker/repair/${orderId}`, method: 'get' })
}

export function getWorkerAiSteps(orderId) {
  return request({ url: `/worker/repair/${orderId}/ai-steps`, method: 'get' })
}

export function acceptOrder(orderId) {
  return request({ url: `/worker/repair/accept/${orderId}`, method: 'put' })
}

export function rejectOrder(orderId, data) {
  return request({ url: `/worker/repair/reject/${orderId}`, method: 'put', data })
}

export function updateOrderStatus(data) {
  return request({ url: '/worker/repair/status', method: 'put', data })
}

export function completeOrder(orderId) {
  return request({ url: `/worker/repair/complete/${orderId}`, method: 'put' })
}

export function workerOnSite(orderId) {
  return request({ url: `/worker/repair/on-site/${orderId}`, method: 'put' })
}

export function saveWorkerFieldRecord(orderId, formData) {
  return request({
    url: `/worker/repair/${orderId}/field-record`,
    method: 'post',
    data: formData,
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

export function uploadWorkerImages(orderId, files) {
  const formData = new FormData()
  files.forEach(f => formData.append('files', f))
  return request({
    url: `/worker/repair/${orderId}/images`,
    method: 'post',
    data: formData,
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

export function getWorkerProfile() {
  return request({ url: '/worker/repair/profile', method: 'get' })
}

export function applyWorkerSkill(data) {
  return request({ url: '/worker/repair/skills/apply', method: 'post', data })
}

export function applyWorkerCert(data) {
  return request({ url: '/worker/repair/profile/cert', method: 'put', data })
}

export function updateWorkerStatus(data) {
  return request({ url: '/worker/repair/profile/status', method: 'put', data })
}

export function listMessages(params) {
  return request({ url: '/system/message/list', method: 'get', params })
}

export function markMessageRead(messageId) {
  return request({ url: `/system/message/read/${messageId}`, method: 'put' })
}

export function getUnreadMessageCount(params) {
  return request({ url: '/system/message/unreadCount', method: 'get', params })
}

export function listRecentMessages(params) {
  return request({ url: '/system/message/recent', method: 'get', params })
}

// ---------- 物业端 ----------
export function listPropertyRepair(params) {
  return request({ url: '/property/repair/list', method: 'get', params })
}

export function getPropertyRepairDetail(orderId) {
  return request({ url: `/property/repair/${orderId}`, method: 'get' })
}

export function assignRepair(data) {
  return request({ url: '/property/repair/assign', method: 'put', data })
}

export function forceRepairStatus(data) {
  return request({ url: '/property/repair/status', method: 'put', data })
}

export function adjustRepair(data) {
  return request({ url: '/property/repair/adjust', method: 'put', data })
}

export function aiAutoDispatch(orderId) {
  return request({ url: `/property/repair/ai/auto-dispatch/${orderId}`, method: 'post' })
}

export function batchAiAutoDispatch() {
  return request({ url: '/property/repair/ai/batch-dispatch', method: 'post' })
}

export function reanalyzeRepairOrder(orderId) {
  return request({ url: `/property/repair/ai/reanalyze/${orderId}`, method: 'post' })
}

export function recommendRepairWorker(orderId) {
  return request({ url: `/property/repair/ai/recommend/${orderId}`, method: 'get' })
}

export function getAutoDispatchConfig() {
  return request({ url: '/property/repair/ai/auto-dispatch/config', method: 'get' })
}

export function setAutoDispatchConfig(enabled) {
  return request({
    url: '/property/repair/ai/auto-dispatch/config',
    method: 'put',
    data: { enabled }
  })
}

export function getRepairSupervisionStats() {
  return request({ url: '/property/repair/supervision/stats', method: 'get' })
}

export function listRepairTypes() {
  return request({ url: '/property/repair/type/list', method: 'get' })
}

export function addRepairType(data) {
  return request({ url: '/property/repair/type', method: 'post', data })
}

export function updateRepairType(data) {
  return request({ url: '/property/repair/type', method: 'put', data })
}

export function deleteRepairType(typeId) {
  return request({ url: `/property/repair/type/${typeId}`, method: 'delete' })
}

export function listRepairWeeklyReports(params) {
  return request({ url: '/property/repair/ai/reports', method: 'get', params })
}

export function generateRepairWeeklyReport(params) {
  return request({ url: '/property/repair/ai/reports/generate', method: 'post', params })
}
