import { defineStore } from 'pinia'
import { login, getInfo } from '@/api/login'
import { getToken, setToken, removeToken, setUser, getUser } from '@/utils/auth'

export const useUserStore = defineStore('user', {
  state: () => ({
    token: getToken() || '',
    user: getUser() || null
  }),
  getters: {
    userType: (s) => s.user?.userType,
    nickName: (s) => s.user?.nickName || s.user?.username
  },
  actions: {
    async login(loginForm) {
      const res = await login(loginForm)
      this.token = res.data.token
      this.user = res.data.user
      setToken(this.token)
      setUser(this.user)
    },
    async fetchInfo() {
      const res = await getInfo()
      this.user = res.data
      setUser(this.user)
    },
    logout() {
      this.token = ''
      this.user = null
      removeToken()
    }
  }
})
