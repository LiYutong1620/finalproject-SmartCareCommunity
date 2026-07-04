import request from '@/utils/request'

export function getCaptchaImage() {
  return request({ url: '/captchaImage', method: 'get' })
}

export function login(data) {
  return request({ url: '/login', method: 'post', data })
}

export function getInfo() {
  return request({ url: '/getInfo', method: 'get' })
}

export function register(data) {
  return request({ url: '/register', method: 'post', data })
}

export function forgotVerify(data) {
  return request({ url: '/forgot-password/verify', method: 'post', data })
}

export function forgotSendCode(data) {
  return request({ url: '/forgot-password/send-code', method: 'post', data })
}

export function forgotReset(data) {
  return request({ url: '/forgot-password/reset', method: 'post', data })
}
