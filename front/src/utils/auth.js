const TokenKey = 'smartcare_token'
const UserKey = 'smartcare_user'

// 使用 sessionStorage：关闭浏览器/标签页后会话失效，需重新登录（比 localStorage 更安全）
const storage = sessionStorage

// 清理旧版 localStorage 中的持久化 Token，避免升级后仍能免登录
localStorage.removeItem(TokenKey)
localStorage.removeItem(UserKey)

export function getToken() {
  return storage.getItem(TokenKey)
}

export function setToken(token) {
  storage.setItem(TokenKey, token)
}

export function removeToken() {
  storage.removeItem(TokenKey)
  storage.removeItem(UserKey)
}

export function getUser() {
  const s = storage.getItem(UserKey)
  return s ? JSON.parse(s) : null
}

export function setUser(user) {
  storage.setItem(UserKey, JSON.stringify(user))
}

/** 各角色登录后的默认首页 */
export const roleHomeMap = {
  '0': '/owner/repair',
  '1': '/worker/home',
  '2': '/property/dashboard'
}

export function getRoleHome() {
  const user = getUser()
  return roleHomeMap[user?.userType] || '/login'
}
