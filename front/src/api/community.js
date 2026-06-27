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
