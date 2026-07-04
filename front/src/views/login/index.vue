<template>
  <AuthShell>
    <div class="login-body">
    <div class="auth-header">
      <h2>欢迎登录</h2>
      <p>智护社区 · 请选择角色并登录</p>
    </div>

    <el-form ref="loginFormRef" :model="loginForm" :rules="loginRules" label-width="0" class="auth-form">
      <el-form-item prop="userType">
        <el-select v-model="loginForm.userType" placeholder="登录角色" size="large" style="width: 100%">
          <el-option label="业主端" value="0">
            <span class="role-option"><el-icon><User /></el-icon> 业主端</span>
          </el-option>
          <el-option label="维修工端" value="1">
            <span class="role-option"><el-icon><Tools /></el-icon> 维修工端</span>
          </el-option>
          <el-option label="物业端" value="2">
            <span class="role-option"><el-icon><OfficeBuilding /></el-icon> 物业端</span>
          </el-option>
        </el-select>
      </el-form-item>
      <el-form-item prop="username">
        <el-input v-model="loginForm.username" placeholder="账号" prefix-icon="User" size="large" />
      </el-form-item>
      <el-form-item prop="password">
        <el-input
          v-model="loginForm.password"
          type="password"
          placeholder="密码"
          prefix-icon="Lock"
          size="large"
          show-password
          @keyup.enter="handleLogin"
        />
      </el-form-item>
      <el-form-item prop="code" v-if="captchaEnabled">
        <div class="captcha-row">
          <el-input
            v-model="loginForm.code"
            placeholder="验证码"
            prefix-icon="Key"
            size="large"
            maxlength="6"
            @keyup.enter="handleLogin"
          />
          <img
            v-if="captchaImg"
            :src="captchaImg"
            class="captcha-img"
            title="点击刷新验证码"
            alt="验证码"
            @click="loadCaptcha"
          />
        </div>
      </el-form-item>

      <div class="form-extra">
        <span class="register-hint">
          还没有账号？
          <router-link to="/register" class="link primary">立即注册</router-link>
        </span>
        <router-link to="/forgot-password" class="link">忘记密码？</router-link>
      </div>

      <el-form-item>
        <el-button type="primary" size="large" class="submit-btn" :loading="loading" @click="handleLogin">
          登 录
        </el-button>
      </el-form-item>
    </el-form>

    <div class="demo-section">
      <div class="demo-roles">
        <button
          v-for="item in demoRoles"
          :key="item.userType"
          type="button"
          class="demo-chip"
          :class="{ active: selectedDemo === item.userType }"
          @click="fillDemo(item)"
        >
          <el-icon><component :is="item.icon" /></el-icon>
          <span>{{ item.label }}</span>
        </button>
      </div>
    </div>
    </div>
  </AuthShell>
</template>

<script setup>
import { ref, reactive, onMounted, computed, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { User, Tools, OfficeBuilding } from '@element-plus/icons-vue'
import AuthShell from '@/components/AuthShell.vue'
import { useUserStore } from '@/store/user'
import { getCaptchaImage } from '@/api/login'
import { getRoleHome } from '@/utils/auth'

const DEMO_ACCOUNTS = {
  '0': { username: 'owner01', password: 'admin123', label: '业主', icon: User },
  '1': { username: 'worker01', password: 'admin123', label: '维修工', icon: Tools },
  '2': { username: 'property01', password: 'admin123', label: '物业', icon: OfficeBuilding }
}

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()
const loading = ref(false)
const captchaEnabled = ref(true)
const captchaImg = ref('')
const loginFormRef = ref()

const loginForm = reactive({
  userType: '0',
  username: '',
  password: '',
  code: '',
  uuid: ''
})

const selectedDemo = ref(null)

const demoRoles = Object.entries(DEMO_ACCOUNTS).map(([userType, v]) => ({
  userType,
  label: v.label,
  icon: v.icon,
  username: v.username,
  password: v.password
}))

const loginRules = computed(() => ({
  userType: [{ required: true, message: '请选择登录角色', trigger: 'change' }],
  username: [{ required: true, message: '请输入账号', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
  ...(captchaEnabled.value
    ? { code: [{ required: true, message: '请输入验证码', trigger: 'blur' }] }
    : {})
}))

watch(() => loginForm.userType, () => {
  selectedDemo.value = null
})

function fillDemo(item) {
  selectedDemo.value = item.userType
  loginForm.userType = item.userType
  loginForm.username = item.username
  loginForm.password = item.password
}

async function loadCaptcha() {
  try {
    const res = await getCaptchaImage()
    captchaEnabled.value = res.data.captchaEnabled !== false
    loginForm.uuid = res.data.uuid
    loginForm.code = ''
    captchaImg.value = res.data.img ? `data:image/jpeg;base64,${res.data.img}` : ''
  } catch {
    captchaEnabled.value = false
    captchaImg.value = ''
    loginForm.uuid = ''
    ElMessage.warning('验证码加载失败，请确认后端已启动')
  }
}

async function handleLogin() {
  await loginFormRef.value.validate()
  loading.value = true
  try {
    await userStore.login({ ...loginForm })
    router.push(getRoleHome())
  } catch {
    loadCaptcha()
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  if (route.query.username) {
    loginForm.username = route.query.username
    loginForm.password = ''
    loginForm.userType = '0'
  }
  loadCaptcha()
})
</script>

<style scoped lang="scss">
.role-option {
  display: inline-flex;
  align-items: center;
  gap: 6px;
}
</style>
