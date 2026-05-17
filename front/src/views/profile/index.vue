<template>
  <el-row :gutter="20">
    <el-col :span="6" :xs="24">
      <el-card class="profile-card">
        <div class="avatar-block">
          <el-upload
            class="avatar-uploader"
            :show-file-list="false"
            :http-request="handleAvatarUpload"
            accept="image/*"
          >
            <el-avatar :size="100" :src="avatarUrl">
              {{ profile.nickName?.charAt(0) || 'U' }}
            </el-avatar>
            <div class="avatar-tip">点击更换头像</div>
          </el-upload>
          <h3>{{ profile.nickName || profile.username }}</h3>
          <p class="sub">{{ roleLabel }}</p>
        </div>
      </el-card>
    </el-col>
    <el-col :span="18" :xs="24">
      <el-card>
        <el-tabs v-model="activeTab">
          <el-tab-pane label="基本资料" name="info">
            <el-form ref="infoRef" :model="infoForm" :rules="infoRules" label-width="88px" style="max-width:480px">
              <el-form-item label="登录账号">
                <el-input v-model="infoForm.username" disabled />
              </el-form-item>
              <el-form-item label="用户昵称" prop="nickName">
                <el-input v-model="infoForm.nickName" maxlength="30" />
              </el-form-item>
              <el-form-item label="手机号码" prop="phone">
                <el-input v-model="infoForm.phone" maxlength="11" />
              </el-form-item>
              <el-form-item>
                <el-button type="primary" :loading="saving" @click="submitInfo">保存</el-button>
              </el-form-item>
            </el-form>
          </el-tab-pane>
          <el-tab-pane label="修改密码" name="pwd">
            <el-form ref="pwdRef" :model="pwdForm" :rules="pwdRules" label-width="88px" style="max-width:480px">
              <el-form-item label="旧密码" prop="oldPassword">
                <el-input v-model="pwdForm.oldPassword" type="password" show-password />
              </el-form-item>
              <el-form-item label="新密码" prop="newPassword">
                <el-input v-model="pwdForm.newPassword" type="password" show-password />
              </el-form-item>
              <el-form-item label="确认密码" prop="confirmPassword">
                <el-input v-model="pwdForm.confirmPassword" type="password" show-password />
              </el-form-item>
              <el-form-item>
                <el-button type="primary" :loading="saving" @click="submitPwd">保存</el-button>
              </el-form-item>
            </el-form>
          </el-tab-pane>
        </el-tabs>
      </el-card>
    </el-col>
  </el-row>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/store/user'
import { getProfile, updateProfile, updateUserPwd, uploadAvatar } from '@/api/profile'

const userStore = useUserStore()
const activeTab = ref('info')
const saving = ref(false)
const profile = ref({})
const infoRef = ref()
const pwdRef = ref()

const roleMap = { '0': '业主', '1': '维修工', '2': '物业' }
const roleLabel = computed(() => roleMap[profile.value.userType] || '')

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
.profile-card {
  text-align: center;
}
.avatar-block {
  padding: 12px 0;
  h3 { margin: 12px 0 4px; }
  .sub { color: #909399; font-size: 13px; }
}
.avatar-uploader {
  display: inline-block;
  cursor: pointer;
}
.avatar-tip {
  font-size: 12px;
  color: #909399;
  margin-top: 8px;
}
</style>
