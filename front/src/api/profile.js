import request from '@/utils/request'

export function getProfile() {
  return request({ url: '/system/user/profile', method: 'get' })
}

export function updateProfile(data) {
  return request({ url: '/system/user/profile', method: 'put', data })
}

export function updateUserPwd(data) {
  return request({ url: '/system/user/profile/updatePwd', method: 'put', data })
}

export function uploadAvatar(file) {
  const formData = new FormData()
  formData.append('avatarfile', file)
  return request({
    url: '/system/user/profile/avatar',
    method: 'post',
    data: formData,
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}
