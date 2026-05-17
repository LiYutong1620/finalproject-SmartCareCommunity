import request from '@/utils/request'

export function listMessage(params) {
  return request({ url: '/system/message/list', method: 'get', params })
}

export function markMessageRead(messageId) {
  return request({ url: `/system/message/read/${messageId}`, method: 'put' })
}

export function listConfig(params) {
  return request({ url: '/system/config/list', method: 'get', params })
}

export function updateConfig(data) {
  return request({ url: '/system/config', method: 'put', data })
}

export function listUser(params) {
  return request({ url: '/system/user/list', method: 'get', params })
}

export function listLoginLog(params) {
  return request({ url: '/system/loginlog/list', method: 'get', params })
}
