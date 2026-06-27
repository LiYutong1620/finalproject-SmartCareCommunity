import request from '@/utils/request'

export const listNoticeV2 = (params) => request({ url: '/owner/notice/list/v2', method: 'get', params })
export const getNoticeDetail = (id) => request({ url: `/owner/notice/${id}`, method: 'get' })
export const markNoticeRead = (id) => request({ url: `/owner/notice/read/${id}`, method: 'post' })

export const getResidentMe = () => request({ url: '/owner/resident/me', method: 'get' })
export const updateEmergency = (emergencyContact) => request({ url: '/owner/resident/emergency', method: 'put', data: { emergencyContact } })
