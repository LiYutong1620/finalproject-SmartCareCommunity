<template>
  <div class="app-container profile-page">
    <el-row :gutter="20" class="profile-row">
      <el-col :span="8" :xs="24">
        <el-card shadow="never" class="profile-card">
          <div class="profile-header">
            <el-upload
              class="avatar-uploader"
              :show-file-list="false"
              :http-request="handleAvatarUpload"
              accept="image/*"
            >
              <el-avatar
                :size="96"
                :src="avatarUrl"
                class="avatar"
                :style="avatarFallbackStyle"
              >
                {{ profile.nickName?.charAt(0) || "U" }}
              </el-avatar>
              <div class="avatar-mask">
                <el-icon><Camera /></el-icon>
                <span>更换</span>
              </div>
            </el-upload>
            <h2>{{ profile.nickName || profile.username }}</h2>
            <el-tag type="primary" round effect="plain" size="small">{{ roleLabel }}</el-tag>
            <p class="account">@{{ profile.username }}</p>
          </div>

          <div class="profile-stats">
            <div class="stat-item">
              <span class="stat-label">绑定手机</span>
              <span class="stat-value">{{ profile.phone || "-" }}</span>
            </div>
            <div class="stat-item">
              <span class="stat-label">性别</span>
              <span class="stat-value">{{ genderLabel(profile.gender) }}</span>
            </div>
            <div class="stat-item">
              <span class="stat-label">年龄</span>
              <span class="stat-value">{{ profile.age != null ? profile.age + " 岁" : "-" }}</span>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="16" :xs="24">
        <el-card shadow="never" class="form-card">
          <el-tabs v-model="activeTab" class="profile-tabs">
            <el-tab-pane label="基本资料" name="info">
              <div class="tab-desc">
                <el-icon><EditPen /></el-icon>
                更新您的昵称与基本资料，保存后立即生效。
              </div>
              <el-form
                ref="infoRef"
                :model="infoForm"
                :rules="infoRules"
                label-width="96px"
                class="profile-form"
              >
                <el-form-item label="登录账号">
                  <el-input v-model="infoForm.username" disabled />
                </el-form-item>
                <el-form-item label="用户昵称" prop="nickName">
                  <el-input
                    v-model="infoForm.nickName"
                    maxlength="30"
                    placeholder="请输入昵称"
                  />
                </el-form-item>
                <el-form-item label="绑定手机号">
                  <div class="phone-bind-row">
                    <span class="phone-display">{{ originalPhone || "未绑定" }}</span>
                    <el-button type="primary" link @click="openPhoneDialog">更换绑定</el-button>
                  </div>
                </el-form-item>
                <el-form-item label="性别">
                  <el-select
                    v-model="infoForm.gender"
                    clearable
                    placeholder="选填"
                    style="width: 100%"
                  >
                    <el-option label="男" value="0" />
                    <el-option label="女" value="1" />
                  </el-select>
                </el-form-item>
                <el-form-item label="年龄" prop="age">
                  <el-input-number
                    v-model="infoForm.age"
                    :min="1"
                    :max="120"
                    controls-position="right"
                    placeholder="选填"
                    style="width: 100%"
                  />
                </el-form-item>
                <el-form-item>
                  <el-button type="primary" :loading="saving" @click="submitInfo">
                    保存修改
                  </el-button>
                </el-form-item>
              </el-form>
            </el-tab-pane>

            <el-tab-pane label="修改密码" name="pwd">
              <div class="tab-desc">
                <el-icon><Lock /></el-icon>
                建议定期更换密码，密码长度至少 6 位。
              </div>
              <el-form
                ref="pwdRef"
                :model="pwdForm"
                :rules="pwdRules"
                label-width="96px"
                class="profile-form"
              >
                <el-form-item label="旧密码" prop="oldPassword">
                  <el-input
                    v-model="pwdForm.oldPassword"
                    type="password"
                    show-password
                    placeholder="请输入旧密码"
                  />
                </el-form-item>
                <el-form-item label="新密码" prop="newPassword">
                  <el-input
                    v-model="pwdForm.newPassword"
                    type="password"
                    show-password
                    placeholder="请输入新密码"
                  />
                </el-form-item>
                <el-form-item label="确认密码" prop="confirmPassword">
                  <el-input
                    v-model="pwdForm.confirmPassword"
                    type="password"
                    show-password
                    placeholder="请再次输入新密码"
                  />
                </el-form-item>
                <el-form-item>
                  <el-button type="primary" :loading="saving" @click="submitPwd">
                    更新密码
                  </el-button>
                </el-form-item>
              </el-form>
            </el-tab-pane>
          </el-tabs>
        </el-card>
      </el-col>
    </el-row>

    <el-dialog
      v-model="phoneDialogVisible"
      title="更换绑定手机号"
      width="440px"
      destroy-on-close
      @closed="resetPhoneDialog"
    >
      <el-form
        ref="phoneFormRef"
        :model="phoneForm"
        :rules="phoneRules"
        label-width="96px"
      >
        <el-form-item label="新手机号" prop="newPhone">
          <el-input
            v-model="phoneForm.newPhone"
            maxlength="11"
            placeholder="请输入新手机号"
          />
        </el-form-item>
        <el-form-item label="验证码" prop="phoneCode">
          <div class="code-row">
            <el-input
              v-model="phoneForm.phoneCode"
              maxlength="6"
              placeholder="6位验证码"
            />
            <el-button
              type="primary"
              plain
              :disabled="phoneCodeSending || phoneCountdown > 0 || !canSendDialogCode"
              :loading="phoneCodeSending"
              @click="handleSendPhoneCode"
            >
              {{ phoneCountdown > 0 ? `${phoneCountdown}s 后重发` : "获取验证码" }}
            </el-button>
          </div>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="phoneDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="phoneSaving" @click="submitPhoneChange">
          确认更换
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, onBeforeUnmount } from "vue";
import { ElMessage } from "element-plus";
import { Camera, EditPen, Lock } from "@element-plus/icons-vue";
import { useUserStore } from "@/store/user";
import { getRoleAvatarColor } from "@/utils/avatar";
import {
  getProfile,
  updateProfile,
  updateUserPwd,
  uploadAvatar,
  sendProfilePhoneCode,
} from "@/api/profile";

const userStore = useUserStore();
const activeTab = ref("info");
const saving = ref(false);
const phoneSaving = ref(false);
const phoneCodeSending = ref(false);
const phoneDialogVisible = ref(false);
const phoneCountdown = ref(0);
const profile = ref({});
const originalPhone = ref("");
const infoRef = ref();
const pwdRef = ref();
const phoneFormRef = ref();
let phoneCountdownTimer = null;

const roleMap = { 0: "业主", 1: "维修工", 2: "物业管理员" };
const roleLabel = computed(() => roleMap[profile.value.userType] || "用户");

function genderLabel(gender) {
  if (gender === "0") return "男";
  if (gender === "1") return "女";
  return "-";
}

const infoForm = reactive({
  username: "",
  nickName: "",
  avatar: "",
  gender: "",
  age: null,
});

const phoneForm = reactive({
  newPhone: "",
  phoneCode: "",
});

const pwdForm = reactive({
  oldPassword: "",
  newPassword: "",
  confirmPassword: "",
});

const canSendDialogCode = computed(() => /^1\d{10}$/.test(phoneForm.newPhone.trim()));

const infoRules = {
  nickName: [{ required: true, message: "请输入昵称", trigger: "blur" }],
  age: [
    {
      type: "number",
      min: 1,
      max: 120,
      message: "年龄应在1-120之间",
      trigger: "blur",
    },
  ],
};

const phoneRules = {
  newPhone: [
    { required: true, message: "请输入新手机号", trigger: "blur" },
    { pattern: /^1\d{10}$/, message: "手机号格式不正确", trigger: "blur" },
  ],
  phoneCode: [
    { required: true, message: "请输入验证码", trigger: "blur" },
    { pattern: /^\d{6}$/, message: "验证码为6位数字", trigger: "blur" },
  ],
};

const validateConfirmPwd = (rule, value, callback) => {
  if (value !== pwdForm.newPassword) callback(new Error("两次密码不一致"));
  else callback();
};

const pwdRules = {
  oldPassword: [{ required: true, message: "请输入旧密码", trigger: "blur" }],
  newPassword: [
    { required: true, message: "请输入新密码", trigger: "blur" },
    { min: 6, message: "至少6位", trigger: "blur" },
  ],
  confirmPassword: [
    { required: true, message: "请确认密码", trigger: "blur" },
    { validator: validateConfirmPwd, trigger: "blur" },
  ],
};

const avatarUrl = computed(() => {
  const av = profile.value.avatar || infoForm.avatar;
  if (!av) return "";
  if (av.startsWith("http") || av.startsWith("data:")) return av;
  return "/api" + av;
});

const avatarFallbackStyle = computed(() => {
  if (avatarUrl.value) return {};
  const userType = profile.value.userType ?? userStore.userType;
  return {
    backgroundColor: getRoleAvatarColor(userType),
    color: "#fff",
  };
});

async function loadProfile() {
  const res = await getProfile();
  profile.value = res.data;
  infoForm.username = res.data.username;
  infoForm.nickName = res.data.nickName;
  originalPhone.value = res.data.phone || "";
  infoForm.avatar = res.data.avatar;
  infoForm.gender = res.data.gender || "";
  infoForm.age = res.data.age ?? null;
}

function openPhoneDialog() {
  phoneDialogVisible.value = true;
}

function resetPhoneDialog() {
  phoneForm.newPhone = "";
  phoneForm.phoneCode = "";
  phoneFormRef.value?.clearValidate();
  if (phoneCountdownTimer) {
    clearInterval(phoneCountdownTimer);
    phoneCountdownTimer = null;
  }
  phoneCountdown.value = 0;
}

async function handleAvatarUpload({ file }) {
  const res = await uploadAvatar(file);
  infoForm.avatar = res.data.imgUrl;
  profile.value.avatar = res.data.imgUrl;
  syncUserStore();
  ElMessage.success("头像已更新");
}

async function handleSendPhoneCode() {
  if (!canSendDialogCode.value) {
    ElMessage.warning("请先输入正确的新手机号");
    return;
  }
  if (phoneForm.newPhone.trim() === originalPhone.value) {
    ElMessage.warning("新手机号不能与当前绑定号码相同");
    return;
  }
  phoneCodeSending.value = true;
  try {
    const res = await sendProfilePhoneCode(phoneForm.newPhone.trim());
    if (res.data?.demoCode) {
      ElMessage.success(`验证码已发送（演示：${res.data.demoCode}）`);
    } else {
      ElMessage.success("验证码已发送");
    }
    phoneCountdown.value = 60;
    phoneCountdownTimer = setInterval(() => {
      phoneCountdown.value -= 1;
      if (phoneCountdown.value <= 0) {
        clearInterval(phoneCountdownTimer);
        phoneCountdownTimer = null;
      }
    }, 1000);
  } finally {
    phoneCodeSending.value = false;
  }
}

async function submitPhoneChange() {
  await phoneFormRef.value.validate();
  phoneSaving.value = true;
  try {
    const res = await updateProfile({
      nickName: infoForm.nickName,
      phone: phoneForm.newPhone.trim(),
      phoneCode: phoneForm.phoneCode.trim(),
      avatar: infoForm.avatar,
      gender: infoForm.gender || null,
      age: infoForm.age,
    });
    profile.value = res.data;
    originalPhone.value = res.data.phone || "";
    infoForm.gender = res.data.gender || "";
    infoForm.age = res.data.age ?? null;
    syncUserStore();
    phoneDialogVisible.value = false;
    ElMessage.success("手机号更换成功");
  } finally {
    phoneSaving.value = false;
  }
}

async function submitInfo() {
  await infoRef.value.validate();
  saving.value = true;
  try {
    const res = await updateProfile({
      nickName: infoForm.nickName,
      phone: originalPhone.value,
      avatar: infoForm.avatar,
      gender: infoForm.gender || null,
      age: infoForm.age,
    });
    profile.value = res.data;
    infoForm.nickName = res.data.nickName || "";
    infoForm.gender = res.data.gender || "";
    infoForm.age = res.data.age ?? null;
    syncUserStore();
    ElMessage.success("保存成功");
  } finally {
    saving.value = false;
  }
}

async function submitPwd() {
  await pwdRef.value.validate();
  saving.value = true;
  try {
    await updateUserPwd({
      oldPassword: pwdForm.oldPassword,
      newPassword: pwdForm.newPassword,
    });
    ElMessage.success("密码修改成功，请重新登录");
    pwdForm.oldPassword = "";
    pwdForm.newPassword = "";
    pwdForm.confirmPassword = "";
    userStore.logout();
    window.location.href = "/login";
  } finally {
    saving.value = false;
  }
}

function syncUserStore() {
  userStore.user = {
    ...userStore.user,
    nickName: profile.value.nickName,
    phone: profile.value.phone,
    avatar: profile.value.avatar,
  };
  localStorage.setItem("smartcare_user", JSON.stringify(userStore.user));
}

onMounted(loadProfile);

onBeforeUnmount(() => {
  if (phoneCountdownTimer) clearInterval(phoneCountdownTimer);
});
</script>

<style scoped lang="scss">
.profile-page {
  max-width: 1100px;
  margin: 0 auto;
}

.profile-row :deep(.el-col) {
  margin-bottom: 20px;
}

.profile-card,
.form-card {
  background: #fff;
  border-radius: 12px;
  border: 1px solid #ebeef5;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
}

.profile-card {
  :deep(.el-card__body) {
    padding: 28px 20px 20px;
  }
}

.profile-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  padding: 0 8px;

  h2 {
    margin: 16px 0 8px;
    font-size: 20px;
    font-weight: 600;
    color: #303133;
  }

  .account {
    margin: 8px 0 0;
    font-size: 13px;
    color: #909399;
  }
}

.avatar-uploader {
  position: relative;
  cursor: pointer;
  border-radius: 50%;
  overflow: hidden;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.06);

  &:hover .avatar-mask {
    opacity: 1;
  }
}

.avatar {
  border: 3px solid #f5f7fa;
  font-size: 36px;
  font-weight: 600;
}

.avatar-mask {
  position: absolute;
  inset: 0;
  border-radius: 50%;
  background: rgba(0, 0, 0, 0.42);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 2px;
  opacity: 0;
  transition: opacity 0.2s;
  font-size: 12px;
  color: #fff;
}

.profile-stats {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 8px;
  margin-top: 24px;
  padding: 14px 12px;
  background: #fafbfc;
  border: 1px solid #f0f2f5;
  border-radius: 10px;
}

.stat-item {
  text-align: center;
  min-width: 0;

  .stat-label {
    display: block;
    font-size: 12px;
    color: #909399;
    margin-bottom: 4px;
  }

  .stat-value {
    display: block;
    font-size: 13px;
    font-weight: 600;
    color: #303133;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
}

.form-card :deep(.el-card__body) {
  padding: 8px 24px 24px;
  background: #fff;
}

.profile-tabs {
  :deep(.el-tabs__header) {
    margin-bottom: 4px;
  }

  :deep(.el-tabs__item) {
    font-size: 15px;
    font-weight: 500;
  }
}

.tab-desc {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  margin: 12px 0 24px;
  padding: 12px 14px;
  background: #f8fafc;
  border: 1px solid #eef2f6;
  border-radius: 8px;
  color: #606266;
  font-size: 13px;
  line-height: 1.6;

  .el-icon {
    margin-top: 2px;
    color: #909399;
    flex-shrink: 0;
  }
}

.profile-form {
  max-width: 520px;
}

.phone-bind-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  min-height: 32px;
  padding: 0 12px;
  background: #fafbfc;
  border: 1px solid #ebeef5;
  border-radius: 6px;
}

.phone-display {
  font-size: 14px;
  color: #303133;
  font-weight: 500;
}

.code-row {
  display: flex;
  gap: 12px;
  width: 100%;

  .el-input {
    flex: 1;
  }

  .el-button {
    flex-shrink: 0;
    min-width: 108px;
  }
}

@media (max-width: 768px) {
  .profile-stats {
    grid-template-columns: 1fr;
    text-align: left;

    .stat-item {
      display: flex;
      justify-content: space-between;
      align-items: center;
      text-align: right;

      .stat-label {
        margin-bottom: 0;
      }
    }
  }

  .code-row {
    flex-direction: column;

    .el-button {
      width: 100%;
    }
  }
}
</style>
