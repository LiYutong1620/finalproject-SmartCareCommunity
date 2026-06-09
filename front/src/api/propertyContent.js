import request from '@/utils/request'
import axios from 'axios'
import { getToken } from '@/utils/auth'

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

export function listContentActivity() {
  return request({ url: `${base}/activity/list`, method: 'get' })
}
export function publishActivity(data) {
  return request({ url: `${base}/activity`, method: 'post', data })
}
export function updateContentActivity(data) {
  return request({ url: `${base}/activity`, method: 'put', data })
}
export function offlineActivity(activityId) {
  return request({ url: `${base}/activity/offline/${activityId}`, method: 'put' })
}
export function listActivityRegs(activityId) {
  return request({ url: `${base}/activity/${activityId}/regs`, method: 'get' })
}
export async function exportActivityRegs(activityId) {
  const res = await axios.get(`/api${base}/activity/${activityId}/export`, {
    responseType: 'blob',
    headers: { Authorization: 'Bearer ' + getToken() }
  })
  const blob = new Blob([res.data], { type: 'text/csv;charset=utf-8' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `activity_regs_${activityId}.csv`
  a.click()
  URL.revokeObjectURL(url)
}

export function listContentComplaint(params) {
  return request({ url: `${base}/complaint/list`, method: 'get', params })
}
export function getComplaintDetail(complaintId) {
  return request({ url: `${base}/complaint/${complaintId}`, method: 'get' })
}
export function complaintStats(params) {
  return request({ url: `${base}/complaint/stats`, method: 'get', params })
}
export function acceptComplaint(data) {
  return request({ url: `${base}/complaint/accept`, method: 'put', data })
}
export function replyContentComplaint(data) {
  return request({ url: `${base}/complaint/reply`, method: 'put', data })
}

export function listPendingPosts() {
  return request({ url: `${base}/forum/post/pending`, method: 'get' })
}
export function listPendingComments() {
  return request({ url: `${base}/forum/comment/pending`, method: 'get' })
}
export function auditPost(data) {
  return request({ url: `${base}/forum/post/audit`, method: 'put', data })
}
export function auditComment(data) {
  return request({ url: `${base}/forum/comment/audit`, method: 'put', data })
}
export function deleteForumPost(postId) {
  return request({ url: `${base}/forum/post/${postId}`, method: 'delete' })
}
export function deleteForumComment(commentId) {
  return request({ url: `${base}/forum/comment/${commentId}`, method: 'delete' })
}
