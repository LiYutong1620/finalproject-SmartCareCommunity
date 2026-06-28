<template>
  <div class="app-container profile-page">
    <el-row :gutter="20">
      <el-col :span="8" :xs="24">
        <el-card shadow="never" class="info-card">
          <div class="profile-header">
            <el-upload
              class="avatar-uploader"
              :show-file-list="false"
              :http-request="handleAvatarUpload"
              accept="image/*"
            >
              <el-avatar :size="88" :src="avatarUrl" class="avatar">
                {{ profile.nickName?.charAt(0) || 'U' }}
              </el-avatar>
              <div class="avatar-mask">
                <el-icon><Camera /></el-icon>
                <span>更换头像</span>
              </div>
            </el-upload>
            <h2>{{ profile.nickName || profile.username }}</h2>
            <el-tag type="primary" round size="small">{{ roleLabel }}</el-tag>
            <p class="account">账号：{{ profile.username }}</p>
          </div>
          <el-divider />
          <div class="section-title"><el-icon><User /></el-icon>账户概览</div>
          <div class="info-item">
              <span class="label">登录账号</span>
              <span class="value">{{ profile.username || '-' }}</span>
            </div>
            <div class="info-item">
              <span class="label">用户昵称</span>
              <span class="value">{{ profile.nickName || '-' }}</span>
            </div>
            <div class="info-item">
              <span class="label">手机号码</span>
              <span class="value">{{ profile.phone || '-' }}</span>
            </div>
            <div class="info-item">
              <span class="label">账户角色</span>
              <span class="value">{{ roleLabel }}</span>
            </div>
          </el-card>
        </el-col>

        <el-col :span="16" :xs="24">
          <el-card shadow="never" class="form-card">
            <el-tabs v-model="activeTab" class="profile-tabs">
              <el-tab-pane label="基本资料" name="info">
                <div class="tab-desc">更新您的昵称与联系方式，保存后立即生效。</div>
                <el-form ref="infoRef" :model="infoForm" :rules="infoRules" label-width="88px" class="profile-form">
                  <el-form-item label="登录账号">
                    <el-input v-model="infoForm.username" disabled />
                  </el-form-item>
                  <el-form-item label="用户昵称" prop="nickName">
                    <el-input v-model="infoForm.nickName" maxlength="30" placeholder="请输入昵称" />
                  </el-form-item>
                  <el-form-item label="手机号码" prop="phone">
                    <el-input v-model="infoForm.phone" maxlength="11" placeholder="请输入手机号" />
                  </el-form-item>
                  <el-form-item>
                    <el-button type="primary" :loading="saving" @click="submitInfo">保存修改</el-button>
                  </el-form-item>
                </el-form>
              </el-tab-pane>
              <el-tab-pane label="修改密码" name="pwd">
                <div class="tab-desc">建议定期更换密码，密码长度至少 6 位。</div>
                <el-form ref="pwdRef" :model="pwdForm" :rules="pwdRules" label-width="88px" class="profile-form">
                  <el-form-item label="旧密码" prop="oldPassword">
                    <el-input v-model="pwdForm.oldPassword" type="password" show-password placeholder="请输入旧密码" />
                  </el-form-item>
                  <el-form-item label="新密码" prop="newPassword">
                    <el-input v-model="pwdForm.newPassword" type="password" show-password placeholder="请输入新密码" />
                  </el-form-item>
                  <el-form-item label="确认密码" prop="confirmPassword">
                    <el-input v-model="pwdForm.confirmPassword" type="password" show-password placeholder="请再次输入新密码" />
                  </el-form-item>
                  <el-form-item>
                    <el-button type="primary" :loading="saving" @click="submitPwd">更新密码</el-button>
                  </el-form-item>
                </el-form>
              </el-tab-pane>
            </el-tabs>
          </el-card>
        </el-col>
      </el-row>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Camera, User } from '@element-plus/icons-vue'
import { useUserStore } from '@/store/user'
import { getProfile, updateProfile, updateUserPwd, uploadAvatar } from '@/api/profile'

const userStore = useUserStore()
const activeTab = ref('info')
const saving = ref(false)
const profile = ref({})
const infoRef = ref()
const pwdRef = ref()

const roleMap = { '0': '业主', '1': '维修工', '2': '物业管理员' }
const roleLabel = computed(() => roleMap[profile.value.userType] || '用户')

const infoForm = reactive({
  username: '',
  nickName: '',
  phone: '',
  avatar: ''
})

const pwdForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const infoRules = {
  nickName: [{ required: true, message: '请输入昵称', trigger: 'blur' }],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1\d{10}$/, message: '手机号格式不正确', trigger: 'blur' }
  ]
}

const validateConfirmPwd = (rule, value, callback) => {
  if (value !== pwdForm.newPassword) callback(new Error('两次密码不一致'))
  else callback()
}

const pwdRules = {
  oldPassword: [{ required: true, message: '请输入旧密码', trigger: 'blur' }],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '至少6位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    { validator: validateConfirmPwd, trigger: 'blur' }
  ]
}

const avatarUrl = computed(() => {
  const av = profile.value.avatar || infoForm.avatar
  if (!av) return ''
  if (av.startsWith('http') || av.startsWith('data:')) return av
  return '/api' + av
})

async function loadProfile() {
  const res = await getProfile()
  profile.value = res.data
  infoForm.username = res.data.username
  infoForm.nickName = res.data.nickName
  infoForm.phone = res.data.phone
  infoForm.avatar = res.data.avatar
}

async function handleAvatarUpload({ file }) {
  const res = await uploadAvatar(file)
  infoForm.avatar = res.data.imgUrl
  profile.value.avatar = res.data.imgUrl
  syncUserStore()
  ElMessage.success('头像已更新')
}

async function submitInfo() {
  await infoRef.value.validate()
  saving.value = true
  try {
    const res = await updateProfile({
      nickName: infoForm.nickName,
      phone: infoForm.phone,
      avatar: infoForm.avatar
    })
    profile.value = res.data
    syncUserStore()
    ElMessage.success('保存成功')
  } finally {
    saving.value = false
  }
}

async function submitPwd() {
  await pwdRef.value.validate()
  saving.value = true
  try {
    await updateUserPwd({
      oldPassword: pwdForm.oldPassword,
      newPassword: pwdForm.newPassword
    })
    ElMessage.success('密码修改成功，请重新登录')
    pwdForm.oldPassword = ''
    pwdForm.newPassword = ''
    pwdForm.confirmPassword = ''
    userStore.logout()
    window.location.href = '/login'
  } finally {
    saving.value = false
  }
}

function syncUserStore() {
  userStore.user = {
    ...userStore.user,
    nickName: profile.value.nickName,
    phone: profile.value.phone,
    avatar: profile.value.avatar
  }
  localStorage.setItem('smartcare_user', JSON.stringify(userStore.user))
}

onMounted(loadProfile)
</script>

<style scoped lang="scss">
.profile-page {
  :deep(.el-col) {
    margin-bottom: 20px;
  }
}

.profile-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  padding: 8px 0 4px;

  h2 {
    margin: 14px 0 8px;
    font-size: 20px;
    font-weight: 600;
    color: #303133;
  }

  .account {
    margin: 10px 0 0;
    font-size: 13px;
    color: #909399;
  }
}

.avatar-uploader {
  position: relative;
  cursor: pointer;
  border-radius: 50%;
  overflow: hidden;

  &:hover .avatar-mask {
    opacity: 1;
  }
}

.avatar {
  border: 3px solid #e4e7ed;
  background: #409eff;
  font-size: 32px;
}

.avatar-mask {
  position: absolute;
  inset: 0;
  border-radius: 50%;
  background: rgba(0, 0, 0, 0.45);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 4px;
  opacity: 0;
  transition: opacity 0.2s;
  font-size: 12px;
  color: #fff;
}

.info-card,
.form-card {
  border-radius: 8px;
  border: none;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
}

.section-title {
  display: flex;
  align-items: center;
  gap: 6px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 4px;
  font-size: 15px;
}

.info-item {
  display: flex;
  justify-content: space-between;
  padding: 12px 0;
  border-bottom: 1px solid #f0f2f5;
  font-size: 14px;

  &:last-child {
    border-bottom: none;
  }

  .label {
    color: #909399;
  }
  .value {
    color: #303133;
    font-weight: 500;
  }
}

.profile-tabs {
  :deep(.el-tabs__header) {
    margin-bottom: 8px;
  }
}

.tab-desc {
  margin-bottom: 20px;
  padding: 10px 14px;
  background: #f4f8ff;
  border-radius: 6px;
  color: #606266;
  font-size: 13px;
  line-height: 1.6;
}

.profile-form {
  max-width: 480px;
}
</style>
