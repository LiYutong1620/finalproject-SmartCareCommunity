import request from '@/utils/request'

export function listResident(params) {
  return request({ url: '/property/resident/list', method: 'get', params })
}
export function getResident(residentId) {
  return request({ url: `/property/resident/${residentId}`, method: 'get' })
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
export function listOwnerOptions(excludeResidentId) {
  return request({
    url: '/property/resident/owner-options',
    method: 'get',
    params: excludeResidentId != null ? { excludeResidentId } : {}
  })
}

export function listOccupiedHouses(excludeResidentId) {
  return request({
    url: '/property/resident/occupied-houses',
    method: 'get',
    params: excludeResidentId != null ? { excludeResidentId } : {}
  })
}

export function listBuilding(params) {
  return request({ url: '/property/building/list', method: 'get', params })
}
export function addBuilding(data) {
  return request({ url: '/property/building', method: 'post', data })
}
export function updateBuilding(data) {
  return request({ url: '/property/building', method: 'put', data })
}
export function deleteBuilding(buildingId) {
  return request({ url: `/property/building/${buildingId}`, method: 'delete' })
}

export function listBuildingAll() {
  return request({ url: '/property/building/all', method: 'get' })
}

export function listHouse(params) {
  return request({ url: '/property/house/list', method: 'get', params })
}
export function addHouse(data) {
  return request({ url: '/property/house', method: 'post', data })
}
export function updateHouse(data) {
  return request({ url: '/property/house', method: 'put', data })
}
export function deleteHouse(houseId) {
  return request({ url: `/property/house/${houseId}`, method: 'delete' })
}

export function listTag() {
  return request({ url: '/property/tag/list', method: 'get' })
}
export function addTag(data) {
  return request({ url: '/property/tag', method: 'post', data })
}
export function deleteTag(tagId) {
  return request({ url: `/property/tag/${tagId}`, method: 'delete' })
}
