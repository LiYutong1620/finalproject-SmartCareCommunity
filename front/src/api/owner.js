import request from '@/utils/request'

export const listNoticeV2 = (params) => request({ url: '/owner/notice/list/v2', method: 'get', params })
export const getNoticeDetail = (id) => request({ url: `/owner/notice/${id}`, method: 'get' })
export const markNoticeRead = (id) => request({ url: `/owner/notice/read/${id}`, method: 'post' })

export const getResidentMe = () => request({ url: '/owner/resident/me', method: 'get' })
export const updateEmergency = (data) => request({ url: '/owner/resident/emergency', method: 'put', data })

export const aiAsk = (data) => request({ url: '/owner/ai/ask', method: 'post', data })
export const listAiSessions = (params) => request({ url: '/owner/ai/sessions', method: 'get', params })
export const listAiMessages = (sessionId) => request({ url: `/owner/ai/session/${sessionId}/messages`, method: 'get' })
export const closeAiSession = (sessionId) => request({ url: `/owner/ai/session/${sessionId}/close`, method: 'put' })
