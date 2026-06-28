import request from '@/utils/request'

export function listAiKnowledge(params) {
  return request({ url: '/property/ai/knowledge/list', method: 'get', params })
}
export function getAiKnowledge(articleId) {
  return request({ url: `/property/ai/knowledge/${articleId}`, method: 'get' })
}
export function addAiKnowledge(data) {
  return request({ url: '/property/ai/knowledge', method: 'post', data })
}
export function updateAiKnowledge(data) {
  return request({ url: '/property/ai/knowledge', method: 'put', data })
}
export function deleteAiKnowledge(articleId) {
  return request({ url: `/property/ai/knowledge/${articleId}`, method: 'delete' })
}

export function listHumanChatSessions(params) {
  return request({ url: '/property/ai/chat/sessions', method: 'get', params })
}
export function getHumanChatSession(sessionId) {
  return request({ url: `/property/ai/chat/session/${sessionId}`, method: 'get' })
}
export function listHumanChatMessages(sessionId) {
  return request({ url: `/property/ai/chat/session/${sessionId}/messages`, method: 'get' })
}
export function sendHumanChatMessage(sessionId, content) {
  return request({ url: `/property/ai/chat/session/${sessionId}/send`, method: 'post', data: { content } })
}
export function closeHumanChatSession(sessionId) {
  return request({ url: `/property/ai/chat/session/${sessionId}/close`, method: 'put' })
}

export function listKbLearnDrafts(params) {
  return request({ url: '/property/ai/learn/drafts', method: 'get', params })
}
export function syncKbFromNotices() {
  return request({ url: '/property/ai/learn/sync-notices', method: 'post', timeout: 120000 })
}
export function mineKbFromChats() {
  return request({ url: '/property/ai/learn/mine-chats', method: 'post', timeout: 120000 })
}
export function importKbDocs(files) {
  const formData = new FormData()
  files.forEach(file => formData.append('files', file))
  return request({
    url: '/property/ai/learn/import-docs',
    method: 'post',
    data: formData,
    timeout: 180000,
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}
export function approveKbDraft(draftId) {
  return request({ url: `/property/ai/learn/draft/${draftId}/approve`, method: 'put' })
}
export function rejectKbDraft(draftId) {
  return request({ url: `/property/ai/learn/draft/${draftId}/reject`, method: 'put' })
}
export function updateKbDraft(data) {
  return request({ url: '/property/ai/learn/draft', method: 'put', data })
}
export function deleteKbDraft(draftId) {
  return request({ url: `/property/ai/learn/draft/${draftId}`, method: 'delete' })
}
