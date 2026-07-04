<template>
  <AuthShell>
    <div class="auth-header">
      <h2>重置密码</h2>
      <p>通过身份与手机验证后设置新密码</p>
    </div>

    <el-steps :active="step" finish-status="success" align-center class="reset-steps">
      <el-step title="身份验证" />
      <el-step title="手机验证" />
      <el-step title="重置密码" />
      <el-step title="完成" />
    </el-steps>

    <!-- Step 1 -->
    <el-form
      v-if="step === 0"
      ref="step1Ref"
      :model="step1Form"
      :rules="step1Rules"
      label-width="0"
      class="auth-form"
    >
      <el-form-item prop="userType">
        <el-select v-model="step1Form.userType" placeholder="选择角色" size="large" style="width: 100%">
          <el-option label="业主端" value="0" />
          <el-option label="维修工端" value="1" />
          <el-option label="物业端" value="2" />
        </el-select>
      </el-form-item>
      <el-form-item prop="username">
        <el-input v-model="step1Form.username" placeholder="登录账号" prefix-icon="User" size="large" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" size="large" class="submit-btn" :loading="loading" @click="handleStep1">
          下一步
        </el-button>
      </el-form-item>
    </el-form>

    <!-- Step 2 -->
    <el-form
      v-else-if="step === 1"
      ref="step2Ref"
      :model="step2Form"
      :rules="step2Rules"
      label-width="0"
      class="auth-form"
    >
      <el-alert type="info" :closable="false" class="phone-hint">
        账号已绑定手机：{{ phoneMasked || '—' }}
      </el-alert>
      <el-form-item prop="phone">
        <el-input v-model="step2Form.phone" placeholder="请输入完整手机号" prefix-icon="Iphone" size="large" maxlength="11" />
      </el-form-item>
      <el-form-item prop="code">
        <div class="code-row">
          <el-input v-model="step2Form.code" placeholder="6位验证码" prefix-icon="Message" size="large" maxlength="6" />
          <el-button size="large" :disabled="countdown > 0" :loading="sendingCode" @click="handleSendCode">
            {{ countdown > 0 ? `${countdown}s 后重发` : '获取验证码' }}
          </el-button>
        </div>
      </el-form-item>
      <el-form-item class="btn-row">
        <el-button size="large" @click="step = 0">上一步</el-button>
        <el-button type="primary" size="large" :loading="loading" @click="handleStep2">
          下一步
        </el-button>
      </el-form-item>
    </el-form>

    <!-- Step 3 -->
    <el-form
      v-else-if="step === 2"
      ref="step3Ref"
      :model="step3Form"
      :rules="step3Rules"
      label-width="0"
      class="auth-form"
    >
      <el-form-item prop="newPassword">
        <el-input v-model="step3Form.newPassword" type="password" placeholder="新密码（至少6位）" prefix-icon="Lock" size="large" show-password />
      </el-form-item>
      <el-form-item prop="confirmPassword">
        <el-input v-model="step3Form.confirmPassword" type="password" placeholder="确认新密码" prefix-icon="Lock" size="large" show-password />
      </el-form-item>
      <el-form-item class="btn-row">
        <el-button size="large" @click="step = 1">上一步</el-button>
        <el-button type="primary" size="large" :loading="loading" @click="handleStep3">
          确认重置
        </el-button>
      </el-form-item>
    </el-form>

    <!-- Step 4 -->
    <div v-else class="success-panel">
      <el-icon class="success-icon" color="#67c23a" :size="64"><CircleCheckFilled /></el-icon>
      <h3>密码重置成功</h3>
      <p>请使用新密码登录系统</p>
      <el-button type="primary" size="large" class="submit-btn" @click="router.push('/login')">
        返回登录
      </el-button>
    </div>

    <div v-if="step < 3" class="auth-footer">
      <router-link to="/login" class="link">返回登录</router-link>
    </div>
  </AuthShell>
</template>

<script setup>
import { ref, reactive, onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { CircleCheckFilled } from '@element-plus/icons-vue'
import AuthShell from '@/components/AuthShell.vue'
import { forgotVerify, forgotSendCode, forgotReset } from '@/api/login'

const router = useRouter()
const step = ref(0)
const loading = ref(false)
const sendingCode = ref(false)
const countdown = ref(0)
const verifyToken = ref('')
const phoneMasked = ref('')
const step1Ref = ref()
const step2Ref = ref()
const step3Ref = ref()
let countdownTimer = null

const step1Form = reactive({ userType: '0', username: '' })
const step2Form = reactive({ phone: '', code: '' })
const step3Form = reactive({ newPassword: '', confirmPassword: '' })

const step1Rules = {
  userType: [{ required: true, message: '请选择角色', trigger: 'change' }],
  username: [{ required: true, message: '请输入账号', trigger: 'blur' }]
}

const step2Rules = {
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1\d{10}$/, message: '手机号格式不正确', trigger: 'blur' }
  ],
  code: [
    { required: true, message: '请输入验证码', trigger: 'blur' },
    { len: 6, message: '验证码为6位数字', trigger: 'blur' }
  ]
}

const validateConfirm = (rule, value, callback) => {
  if (value !== step3Form.newPassword) {
    callback(new Error('两次输入的密码不一致'))
  } else {
    callback()
  }
}

const step3Rules = {
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '密码至少6位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认新密码', trigger: 'blur' },
    { validator: validateConfirm, trigger: 'blur' }
  ]
}

function startCountdown() {
  countdown.value = 60
  countdownTimer = setInterval(() => {
    countdown.value--
    if (countdown.value <= 0) {
      clearInterval(countdownTimer)
      countdownTimer = null
    }
  }, 1000)
}

async function handleStep1() {
  await step1Ref.value.validate()
  loading.value = true
  try {
    const res = await forgotVerify({ ...step1Form })
    verifyToken.value = res.data.verifyToken
    phoneMasked.value = res.data.phoneMasked
    step2Form.phone = ''
    step2Form.code = ''
    step.value = 1
  } finally {
    loading.value = false
  }
}

async function handleSendCode() {
  if (!/^1\d{10}$/.test(step2Form.phone)) {
    ElMessage.warning('请先输入正确的手机号')
    return
  }
  sendingCode.value = true
  try {
    const res = await forgotSendCode({
      verifyToken: verifyToken.value,
      phone: step2Form.phone
    })
    startCountdown()
    if (res.data.demoCode) {
      step2Form.code = res.data.demoCode
      ElMessage.success(`验证码已发送（演示：${res.data.demoCode}）`)
    } else {
      ElMessage.success('验证码已发送')
    }
  } finally {
    sendingCode.value = false
  }
}

async function handleStep2() {
  await step2Ref.value.validate()
  step.value = 2
}

async function handleStep3() {
  await step3Ref.value.validate()
  loading.value = true
  try {
    await forgotReset({
      verifyToken: verifyToken.value,
      code: step2Form.code,
      newPassword: step3Form.newPassword,
      confirmPassword: step3Form.confirmPassword
    })
    step.value = 3
  } finally {
    loading.value = false
  }
}

onBeforeUnmount(() => {
  if (countdownTimer) clearInterval(countdownTimer)
})
</script>

<style scoped lang="scss">
.reset-steps {
  margin-bottom: 14px;
  :deep(.el-step__title) {
    font-size: 11px;
  }
  :deep(.el-step__head) {
    padding-right: 4px;
  }
}

.phone-hint {
  margin-bottom: 10px;
  padding: 8px 12px;
}

.code-row {
  display: flex;
  gap: 8px;
  width: 100%;
  .el-input { flex: 1; }
  .el-button { flex-shrink: 0; min-width: 108px; height: 38px; }
}

.btn-row {
  :deep(.el-form-item__content) {
    display: flex;
    gap: 10px;
    .el-button {
      flex: 1;
      height: 38px;
      border-radius: 8px;
    }
  }
}

.success-panel {
  text-align: center;
  padding: 16px 0 4px;

  .success-icon { margin-bottom: 12px; }

  h3 {
    font-size: 18px;
    color: #3D5266;
    margin-bottom: 6px;
  }

  p {
    color: #8B9AAB;
    font-size: 13px;
    margin-bottom: 20px;
  }
}

.auth-footer {
  text-align: center;
  margin-top: 12px;
}
</style>
