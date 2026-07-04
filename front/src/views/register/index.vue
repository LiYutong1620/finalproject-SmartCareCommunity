<template>
  <AuthShell>
    <div class="auth-header">
      <h2>创建账号</h2>
      <p>智护社区 · 业主自助注册</p>
    </div>

    <el-form ref="registerFormRef" :model="registerForm" :rules="registerRules" label-width="0" class="auth-form">
      <el-form-item prop="username">
        <el-input v-model="registerForm.username" placeholder="登录账号（4位及以上英文+数字）" prefix-icon="User" size="large" />
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
      <div class="form-extra register-link-row">
        <span>已有账号？</span>
        <router-link to="/login" class="link primary">返回登录</router-link>
      </div>
      <el-form-item>
        <el-button type="primary" size="large" class="submit-btn" :loading="loading" @click="handleRegister">
          注 册
        </el-button>
      </el-form-item>
    </el-form>
  </AuthShell>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import AuthShell from '@/components/AuthShell.vue'
import { getCaptchaImage, register } from '@/api/login'

const router = useRouter()
const loading = ref(false)
const captchaEnabled = ref(true)
const captchaImg = ref('')
const registerFormRef = ref()

const registerForm = reactive({
  username: '',
  nickName: '',
  phone: '',
  password: '',
  confirmPassword: '',
  code: '',
  uuid: ''
})

const validateConfirm = (rule, value, callback) => {
  if (value !== registerForm.password) {
    callback(new Error('两次输入的密码不一致'))
  } else {
    callback()
  }
}

const validateUsername = (rule, value, callback) => {
  if (!value) {
    callback(new Error('请输入账号'))
  } else if (!/^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]{4,}$/.test(value)) {
    callback(new Error('账号须为4位及以上英文字母与数字组合'))
  } else {
    callback()
  }
}

const registerRules = computed(() => ({
  username: [
    { required: true, validator: validateUsername, trigger: 'blur' }
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
  ...(captchaEnabled.value
    ? { code: [{ required: true, message: '请输入验证码', trigger: 'blur' }] }
    : {})
}))

async function loadCaptcha() {
  try {
    const res = await getCaptchaImage()
    captchaEnabled.value = res.data.captchaEnabled !== false
    registerForm.uuid = res.data.uuid
    registerForm.code = ''
    captchaImg.value = res.data.img ? `data:image/jpeg;base64,${res.data.img}` : ''
  } catch {
    captchaEnabled.value = false
    captchaImg.value = ''
    registerForm.uuid = ''
  }
}

async function handleRegister() {
  await registerFormRef.value.validate()
  loading.value = true
  try {
    await register({ ...registerForm })
    ElMessage.success('注册成功，请登录')
    router.push({ path: '/login', query: { username: registerForm.username } })
  } catch {
    loadCaptcha()
  } finally {
    loading.value = false
  }
}

onMounted(loadCaptcha)
</script>
