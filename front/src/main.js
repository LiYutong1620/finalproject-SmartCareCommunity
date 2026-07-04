import { createApp } from 'vue'
import { createPinia } from 'pinia'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import zhCn from 'element-plus/dist/locale/zh-cn.mjs'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'
import App from './App.vue'
import router from './router'
import './styles/index.scss'
import './styles/auth.scss'
import Pagination from '@/components/Pagination/index.vue'
import { APP_NAME_SHORT } from '@/constants/brand'

const app = createApp(App)
app.component('Pagination', Pagination)
for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
  app.component(key, component)
}
app.use(createPinia())
app.use(router)
app.use(ElementPlus, { locale: zhCn })
app.mount('#app')

router.afterEach((to) => {
  const page = to.meta?.title
  document.title = page ? `${page} - ${APP_NAME_SHORT}` : '智护社区：AI 智能服务平台'
})
