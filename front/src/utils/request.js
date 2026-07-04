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
    const status = err.response?.status
    const bodyCode = typeof err.response?.data === 'object' ? err.response.data?.code : null
    if (status === 401 || bodyCode === 401 || (status === 403 && getToken())) {
      removeToken()
      router.push('/login')
    }
    const data = err.response?.data
    const msg = (typeof data === 'object' && data?.msg)
      || (err.response?.status === 404
        ? '接口不存在(404)，请确认后端已启动且通过 npm run dev 访问前端(5173端口)'
        : null)
      || err.message
      || '网络异常'
    ElMessage.error(msg)
    return Promise.reject(err)
  }
)

export default service
