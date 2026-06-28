import request from '@/utils/request'

export function listConfig(params) {
  return request({ url: '/system/config/list', method: 'get', params })
}

export function updateConfig(data) {
  return request({ url: '/system/config', method: 'put', data })
}

export function listUser(params) {
  return request({ url: '/system/user/list', method: 'get', params })
}
