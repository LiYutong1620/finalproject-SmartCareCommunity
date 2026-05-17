const TokenKey = 'smartcare_token'
const UserKey = 'smartcare_user'

export function getToken() {
  return localStorage.getItem(TokenKey)
}

export function setToken(token) {
  localStorage.setItem(TokenKey, token)
}

export function removeToken() {
  localStorage.removeItem(TokenKey)
  localStorage.removeItem(UserKey)
}

export function getUser() {
  const s = localStorage.getItem(UserKey)
  return s ? JSON.parse(s) : null
}

export function setUser(user) {
  localStorage.setItem(UserKey, JSON.stringify(user))
}
