import request from '@/utils/request'

export function listOwnerRepair(params) {
  return request({ url: '/owner/repair/list', method: 'get', params })
}

export function submitRepair(data) {
  return request({ url: '/owner/repair', method: 'post', data })
}

export function cancelRepair(orderId) {
  return request({ url: `/owner/repair/cancel/${orderId}`, method: 'put' })
}

export function urgeRepair(orderId) {
  return request({ url: `/owner/repair/urge/${orderId}`, method: 'put' })
}

export function listWorkerOrder(params) {
  return request({ url: '/worker/repair/list', method: 'get', params })
}

export function acceptOrder(orderId) {
  return request({ url: `/worker/repair/accept/${orderId}`, method: 'put' })
}

export function updateOrderStatus(data) {
  return request({ url: '/worker/repair/status', method: 'put', data })
}

export function completeOrder(orderId) {
  return request({ url: `/worker/repair/complete/${orderId}`, method: 'put' })
}

export function listPropertyRepair(params) {
  return request({ url: '/property/repair/list', method: 'get', params })
}

export function assignRepair(data) {
  return request({ url: '/property/repair/assign', method: 'put', data })
}
