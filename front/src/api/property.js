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
export function deleteResident(residentId) {
  return request({ url: `/property/resident/${residentId}`, method: 'delete' })
}

export function listBuilding() {
  return request({ url: '/property/building/list', method: 'get' })
}
export function addBuilding(data) {
  return request({ url: '/property/building', method: 'post', data })
}
export function updateBuilding(data) {
  return request({ url: '/property/building', method: 'put', data })
}

export function listHouse(params) {
  return request({ url: '/property/house/list', method: 'get', params })
}
export function listRentHouse(params) {
  return request({ url: '/property/house/rent/list', method: 'get', params })
}
export function addHouse(data) {
  return request({ url: '/property/house', method: 'post', data })
}
export function updateHouse(data) {
  return request({ url: '/property/house', method: 'put', data })
}

export function listEquipment(params) {
  return request({ url: '/property/equipment/list', method: 'get', params })
}
export function addEquipment(data) {
  return request({ url: '/property/equipment', method: 'post', data })
}
export function updateEquipment(data) {
  return request({ url: '/property/equipment', method: 'put', data })
}
export function deleteEquipment(id) {
  return request({ url: `/property/equipment/${id}`, method: 'delete' })
}

export function listTag() {
  return request({ url: '/property/tag/list', method: 'get' })
}
export function addTag(data) {
  return request({ url: '/property/tag', method: 'post', data })
}

export function listParking() {
  return request({ url: '/property/parking/list', method: 'get' })
}
export function addParking(data) {
  return request({ url: '/property/parking', method: 'post', data })
}
export function updateParking(data) {
  return request({ url: '/property/parking', method: 'put', data })
}
export function bindParking(data) {
  return request({ url: '/property/parking/bind', method: 'post', data })
}
export function unbindParking(parkingId) {
  return request({ url: `/property/parking/bind/${parkingId}`, method: 'delete' })
}
export function listParkingPayment(params) {
  return request({ url: '/property/parking/payment/list', method: 'get', params })
}
export function addParkingPayment(data) {
  return request({ url: '/property/parking/payment', method: 'post', data })
}

export function listViolation(params) {
  return request({ url: '/property/violation/list', method: 'get', params })
}
export function addViolation(data) {
  return request({ url: '/property/violation', method: 'post', data })
}
export function updateViolation(data) {
  return request({ url: '/property/violation', method: 'put', data })
}
export function removeViolation(id) {
  return request({ url: `/property/violation/remove/${id}`, method: 'put' })
}

export function listMove(params) {
  return request({ url: '/property/move/list', method: 'get', params })
}
export function addMove(data) {
  return request({ url: '/property/move', method: 'post', data })
}
export function auditMove(data) {
  return request({ url: '/property/move/audit', method: 'put', data })
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
