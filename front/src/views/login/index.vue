<template>
  <div class="login-container">
    <div class="login-card">
      <div class="login-title">
        <h1>Smart Care Community</h1>
        <p>智慧社区服务平台</p>
      </div>

      <el-tabs v-model="activeTab" class="login-tabs" @tab-change="onTabChange">
        <el-tab-pane label="登录" name="login">
          <el-form ref="loginFormRef" :model="loginForm" :rules="loginRules" label-width="0">
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
            <el-form-item>
              <el-button type="primary" size="large" class="submit-btn" :loading="loading" @click="handleLogin">
                登 录
              </el-button>
            </el-form-item>
          </el-form>
        </el-tab-pane>

        <el-tab-pane label="注册" name="register">
          <el-form ref="registerFormRef" :model="registerForm" :rules="registerRules" label-width="0">
            <el-form-item prop="username">
              <el-input v-model="registerForm.username" placeholder="登录账号（至少4位）" prefix-icon="User" size="large" />
            </el-form-item>
            <el-form-item prop="nickName">
              <el-input v-model="registerForm.nickName" placeholder="昵称（选填）" prefix-icon="UserFilled" size="large" />
            </el-form-item>
            <el-form-item prop="phone">
              <el-input v-model="registerForm.phone" placeholder="手机号" prefix-icon="Iphone" size="large" />
            </el-form-item>
            <el-form-item prop="password">
              <el-input v-model="registerForm.password" type="password" placeholder="密码（至少6位）" prefix-icon="Lock" size="large" show-password />
            </el-form-item>
            <el-form-item prop="confirmPassword">
              <el-input v-model="registerForm.confirmPassword" type="password" placeholder="确认密码" prefix-icon="Lock" size="large" show-password />
            </el-form-item>
            <el-form-item prop="code" v-if="captchaEnabled">
              <div class="captcha-row">
                <el-input v-model="registerForm.code" placeholder="验证码" prefix-icon="Key" size="large" maxlength="6" />
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
            <el-form-item>
              <el-button type="primary" size="large" class="submit-btn" :loading="loading" @click="handleRegister">
                注 册
              </el-button>
            </el-form-item>
          </el-form>
          <p class="register-tip">业主自助注册，注册后可使用报修、公告、缴费等功能</p>
        </el-tab-pane>
      </el-tabs>

      <p class="demo-tip">演示账号: property01 / owner01 / worker01 &nbsp; 密码 admin123</p>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/store/user'
import { getCaptchaImage, register } from '@/api/login'

const router = useRouter()
const userStore = useUserStore()
const activeTab = ref('login')
const loading = ref(false)
const captchaEnabled = ref(true)
const captchaImg = ref('')
const loginFormRef = ref()
const registerFormRef = ref()

const loginForm = reactive({
  username: 'property01',
  password: 'admin123',
  code: '',
  uuid: ''
})

const registerForm = reactive({
  username: '',
  nickName: '',
  phone: '',
  password: '',
  confirmPassword: '',
  code: '',
  uuid: ''
})

const loginRules = {
  username: [{ required: true, message: '请输入账号', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
  code: [{ required: true, message: '请输入验证码', trigger: 'blur' }]
}

const validateConfirm = (rule, value, callback) => {
  if (value !== registerForm.password) {
    callback(new Error('两次输入的密码不一致'))
  } else {
    callback()
  }
}

const registerRules = {
  username: [
    { required: true, message: '请输入账号', trigger: 'blur' },
    { min: 4, message: '账号至少4位', trigger: 'blur' }
  ],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1\d{10}$/, message: '手机号格式不正确', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码至少6位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    { validator: validateConfirm, trigger: 'blur' }
  ],
  code: [{ required: true, message: '请输入验证码', trigger: 'blur' }]
}

import { getRoleHome } from '@/utils/auth'

async function loadCaptcha() {
  const res = await getCaptchaImage()
  captchaEnabled.value = res.data.captchaEnabled !== false
  loginForm.uuid = res.data.uuid
  registerForm.uuid = res.data.uuid
  loginForm.code = ''
  registerForm.code = ''
  captchaImg.value = res.data.img ? `data:image/jpeg;base64,${res.data.img}` : ''
}

function onTabChange() {
  loadCaptcha()
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

async function handleRegister() {
  await registerFormRef.value.validate()
  loading.value = true
  try {
    await register({ ...registerForm })
    ElMessage.success('注册成功，请登录')
    activeTab.value = 'login'
    loginForm.username = registerForm.username
    loginForm.password = ''
    registerForm.password = ''
    registerForm.confirmPassword = ''
    await loadCaptcha()
  } catch {
    loadCaptcha()
  } finally {
    loading.value = false
  }
}

onMounted(loadCaptcha)
</script>

<style scoped lang="scss">
.login-card {
  width: 420px;
  padding: 36px 40px 28px;
}
.login-tabs {
  :deep(.el-tabs__header) {
    margin-bottom: 24px;
  }
  :deep(.el-tabs__item) {
    font-size: 16px;
  }
}
.captcha-row {
  display: flex;
  align-items: center;
  gap: 10px;
  width: 100%;
  .el-input {
    flex: 1;
  }
}
.captcha-img {
  width: 120px;
  height: 40px;
  cursor: pointer;
  border-radius: 4px;
  border: 1px solid #dcdfe6;
  object-fit: cover;
}
.submit-btn {
  width: 100%;
}
.register-tip {
  text-align: center;
  color: #909399;
  font-size: 12px;
  margin-top: -8px;
}
.demo-tip {
  text-align: center;
  color: #999;
  font-size: 12px;
  margin-top: 16px;
}
</style>
