import request from '@/utils/request'

export const uploadImage = (file) => {
  const fd = new FormData()
  fd.append('file', file)
  return request({ url: '/owner/file/upload', method: 'post', data: fd, headers: { 'Content-Type': 'multipart/form-data' } })
}

export const listNoticeV2 = (params) => request({ url: '/owner/notice/list/v2', method: 'get', params })
export const getNoticeDetail = (id) => request({ url: `/owner/notice/${id}`, method: 'get' })
export const markNoticeRead = (id) => request({ url: `/owner/notice/read/${id}`, method: 'post' })

export const listActivity = () => request({ url: '/owner/activity/list', method: 'get' })
export const getActivity = (id) => request({ url: `/owner/activity/${id}`, method: 'get' })
export const registerActivity = (data) => request({ url: '/owner/activity/register', method: 'post', data })
export const listMyActivityReg = () => request({ url: '/owner/activity/reg/list', method: 'get' })
export const cancelActivityReg = (regId) => request({ url: `/owner/activity/reg/cancel/${regId}`, method: 'put' })

export const listFamily = () => request({ url: '/owner/family/list', method: 'get' })
export const addFamily = (data) => request({ url: '/owner/family', method: 'post', data })
export const updateFamilyAlert = (bindId, shareAlert) => request({ url: `/owner/family/${bindId}/alert`, method: 'put', data: { shareAlert } })
export const removeFamily = (bindId) => request({ url: `/owner/family/${bindId}`, method: 'delete' })
export const listSharedAlerts = () => request({ url: '/owner/family/alerts', method: 'get' })

export const listVisitor = () => request({ url: '/owner/visitor/list', method: 'get' })
export const addVisitor = (data) => request({ url: '/owner/visitor', method: 'post', data })
export const updateVisitor = (data) => request({ url: '/owner/visitor', method: 'put', data })

export const listForumPost = (params) => request({ url: '/owner/forum/post/list', method: 'get', params })
export const listMyPosts = () => request({ url: '/owner/forum/post/mine', method: 'get' })
export const addForumPost = (data) => request({ url: '/owner/forum/post', method: 'post', data })
export const editForumPost = (data) => request({ url: '/owner/forum/post', method: 'put', data })
export const deleteForumPost = (postId) => request({ url: `/owner/forum/post/${postId}`, method: 'delete' })
export const listForumComment = (postId) => request({ url: `/owner/forum/comment/${postId}`, method: 'get' })
export const addForumComment = (data) => request({ url: '/owner/forum/comment', method: 'post', data })
export const editForumComment = (data) => request({ url: '/owner/forum/comment', method: 'put', data })
export const deleteForumComment = (commentId) => request({ url: `/owner/forum/comment/${commentId}`, method: 'delete' })

export const listVenue = () => request({ url: '/owner/venue/list', method: 'get' })
export const getVenueSlots = (params) => request({ url: '/owner/venue/slots', method: 'get', params })
export const bookVenue = (data) => request({ url: '/owner/venue/booking', method: 'post', data })
export const listMyVenueBooking = () => request({ url: '/owner/venue/booking/list', method: 'get' })
export const cancelVenueBooking = (id) => request({ url: `/owner/venue/booking/cancel/${id}`, method: 'put' })
export const updateVenueBooking = (data) => request({ url: '/owner/venue/booking', method: 'put', data })

export const listVote = () => request({ url: '/owner/vote/list', method: 'get' })
export const getVote = (id) => request({ url: `/owner/vote/${id}`, method: 'get' })
export const castVote = (voteId, option) => request({ url: `/owner/vote/${voteId}`, method: 'post', data: { option } })

export const getResidentMe = () => request({ url: '/owner/resident/me', method: 'get' })
export const updateEmergency = (emergencyContact) => request({ url: '/owner/resident/emergency', method: 'put', data: { emergencyContact } })

export const listBillV2 = (params) => request({ url: '/owner/bill/list/v2', method: 'get', params })
export const listPayments = () => request({ url: '/owner/bill/payments', method: 'get' })

export const listComplaintV2 = () => request({ url: '/owner/complaint/list/v2', method: 'get' })
export const submitComplaintV2 = (data) => request({ url: '/owner/complaint/v2', method: 'post', data })
