import request from '@/utils/request'

const base = '/property/content'

export function listContentNotice(params) {
  return request({ url: `${base}/notice/list`, method: 'get', params })
}
export function publishNotice(data) {
  return request({ url: `${base}/notice`, method: 'post', data })
}
export function updateContentNotice(data) {
  return request({ url: `${base}/notice`, method: 'put', data })
}
export function offlineNotice(noticeId) {
  return request({ url: `${base}/notice/offline/${noticeId}`, method: 'put' })
}
export function noticeReadStats(noticeId) {
  return request({ url: `${base}/notice/${noticeId}/read-stats`, method: 'get' })
}
export function forceNoticeRead(noticeId, userId) {
  return request({ url: `${base}/notice/${noticeId}/force-read/${userId}`, method: 'post' })
}
