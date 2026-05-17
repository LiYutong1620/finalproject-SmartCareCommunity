import request from '@/utils/request'

export function listNotice(params) {
  return request({ url: '/owner/notice/list', method: 'get', params })
}

export function addNotice(data) {
  return request({ url: '/property/notice', method: 'post', data })
}

export function updateNotice(data) {
  return request({ url: '/property/notice', method: 'put', data })
}

export function removeNotice(noticeId) {
  return request({ url: `/property/notice/${noticeId}`, method: 'delete' })
}

export function listOwnerComplaint(params) {
  return request({ url: '/owner/complaint/list', method: 'get', params })
}

export function submitComplaint(data) {
  return request({ url: '/owner/complaint', method: 'post', data })
}

export function listPropertyComplaint(params) {
  return request({ url: '/property/complaint/list', method: 'get', params })
}

export function handleComplaint(data) {
  return request({ url: '/property/complaint/handle', method: 'put', data })
}

export function replyComplaint(data) {
  return request({ url: '/property/complaint/reply', method: 'put', data })
}
