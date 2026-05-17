import request from '@/utils/request'

export function listResident(params) {
  return request({ url: '/property/resident/list', method: 'get', params })
}

export function addResident(data) {
  return request({ url: '/property/resident', method: 'post', data })
}

export function updateResident(data) {
  return request({ url: '/property/resident', method: 'put', data })
}

export function listBuilding() {
  return request({ url: '/property/building/list', method: 'get' })
}

export function addBuilding(data) {
  return request({ url: '/property/building', method: 'post', data })
}

export function dashboardStats() {
  return request({ url: '/property/dashboard/stats', method: 'get' })
}

export function listElderAlert(params) {
  return request({ url: '/property/elder/alert/list', method: 'get', params })
}

export function handleElderAlert(data) {
  return request({ url: '/property/elder/alert/handle', method: 'put', data })
}

export function listPropertyBill(params) {
  return request({ url: '/property/bill/list', method: 'get', params })
}

export function createBill(data) {
  return request({ url: '/property/bill', method: 'post', data })
}
