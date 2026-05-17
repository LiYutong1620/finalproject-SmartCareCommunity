import axios from 'axios'
import { ElMessage } from 'element-plus'
import { getToken, removeToken } from './auth'
import router from '@/router'

const service = axios.create({
  baseURL: '/api',
  timeout: 30000
})

service.interceptors.request.use(config => {
  const token = getToken()
  if (token) config.headers.Authorization = 'Bearer ' + token
  return config
})

service.interceptors.response.use(
  res => {
    const data = res.data
    if (data.code === 200) return data
    ElMessage.error(data.msg || '请求失败')
    return Promise.reject(data)
  },
  err => {
    if (err.response?.status === 401) {
      removeToken()
      router.push('/login')
    }
    ElMessage.error(err.message || '网络异常')
    return Promise.reject(err)
  }
)

export default service
