<template>
  <div class="app-container">
    <el-form :inline="true" class="search-form">
      <el-form-item label="账号">
        <el-input
          v-model="query.username"
          placeholder="请输入账号"
          clearable
          style="width: 160px"
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="类型">
        <el-select
          v-model="query.userType"
          clearable
          placeholder="全部"
          style="width: 120px"
        >
          <el-option label="业主" value="0" />
          <el-option label="维修工" value="1" />
          <el-option label="物业" value="2" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery"
          >搜索</el-button
        >
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
        <el-button type="success" icon="Plus" @click="openAdd"
          >新增用户</el-button
        >
      </el-form-item>
    </el-form>

    <el-card shadow="never" class="table-card">
      <el-table :data="list" v-loading="loading" border stripe>
        <el-table-column type="index" label="序号" width="60" align="center" />
        <el-table-column prop="username" label="账号" min-width="120" />
        <el-table-column prop="nickName" label="昵称" min-width="120" />
        <el-table-column prop="phone" label="手机" width="130" />
        <el-table-column prop="userType" label="类型" width="90" align="center">
          <template #default="{ row }">{{
            { "0": "业主", "1": "维修工", "2": "物业" }[row.userType] || "物业"
          }}</template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-tag
              :type="row.status === '0' ? 'success' : 'danger'"
              size="small"
            >
              {{ row.status === "0" ? "正常" : "停用" }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" align="center" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="openEdit(row)"
              >编辑</el-button
            >
            <el-button
              type="info"
              link
              size="small"
              @click="handleResetPwd(row)"
              >重置密码</el-button
            >
            <el-button
              :type="row.status === '0' ? 'danger' : 'success'"
              link
              size="small"
              @click="handleToggleStatus(row)"
            >
              {{ row.status === "0" ? "停用" : "启用" }}
            </el-button>
          </template>
        </el-table-column>
      </el-table>
      <Pagination
        v-show="total > 0"
        :total="total"
        v-model:page="query.pageNum"
        v-model:limit="query.pageSize"
        @pagination="load"
      />
    </el-card>

    <!-- 新增/编辑用户对话框 -->
    <el-dialog
      v-model="userDialogVisible"
      :title="isEdit ? '编辑用户' : '新增用户'"
      width="500px"
      :close-on-click-modal="false"
    >
      <el-form
        :model="userForm"
        :rules="userRules"
        ref="userFormRef"
        label-width="80px"
      >
        <el-form-item label="账号" prop="username">
          <el-input
            v-model="userForm.username"
            :disabled="isEdit"
            placeholder="请输入账号"
          />
        </el-form-item>
        <el-form-item label="密码" prop="password" v-if="!isEdit">
          <el-input
            v-model="userForm.password"
            type="password"
            placeholder="请输入密码（至少6位）"
            show-password
          />
        </el-form-item>
        <el-form-item label="昵称" prop="nickName">
          <el-input v-model="userForm.nickName" placeholder="请输入昵称" />
        </el-form-item>
        <el-form-item label="手机" prop="phone">
          <el-input v-model="userForm.phone" placeholder="请输入手机号" />
        </el-form-item>
        <el-form-item label="类型" prop="userType">
          <el-select v-model="userForm.userType" placeholder="请选择">
            <el-option label="业主" value="0" />
            <el-option label="维修工" value="1" />
            <el-option label="物业" value="2" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="userDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="handleSaveUser"
          >保存</el-button
        >
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import {
  listUser,
  addUser,
  editUser,
  changeUserStatus,
  resetUserPwd,
} from "@/api/system";

const loading = ref(false);
const saving = ref(false);
const list = ref([]);
const total = ref(0);
const query = reactive({
  pageNum: 1,
  pageSize: 10,
  username: "",
  userType: "",
});

const userDialogVisible = ref(false);
const isEdit = ref(false);
const userFormRef = ref(null);
const userForm = reactive({
  username: "",
  password: "",
  nickName: "",
  phone: "",
  userType: "0",
  userId: null,
});
const userRules = {
  username: [{ required: true, message: "请输入账号", trigger: "blur" }],
  password: [{ required: true, message: "请输入密码", trigger: "blur" }],
  nickName: [{ required: true, message: "请输入昵称", trigger: "blur" }],
  userType: [{ required: true, message: "请选择类型", trigger: "change" }],
};

async function load() {
  loading.value = true;
  try {
    const params = { pageNum: query.pageNum, pageSize: query.pageSize };
    if (query.username) params.username = query.username;
    if (query.userType) params.userType = query.userType;
    const res = await listUser(params);
    list.value = res.data.rows;
    total.value = res.data.total;
  } finally {
    loading.value = false;
  }
}

function handleQuery() {
  query.pageNum = 1;
  load();
}
function resetQuery() {
  query.username = "";
  query.userType = "";
  query.pageNum = 1;
  load();
}

function openAdd() {
  isEdit.value = false;
  Object.assign(userForm, {
    username: "",
    password: "",
    nickName: "",
    phone: "",
    userType: "0",
    userId: null,
  });
  userDialogVisible.value = true;
}

function openEdit(row) {
  isEdit.value = true;
  Object.assign(userForm, {
    username: row.username,
    nickName: row.nickName,
    phone: row.phone,
    userType: row.userType,
    userId: row.userId,
    password: "",
  });
  userDialogVisible.value = true;
}

async function handleSaveUser() {
  saving.value = true;
  try {
    if (isEdit.value) {
      await editUser({
        userId: userForm.userId,
        nickName: userForm.nickName,
        phone: userForm.phone,
        userType: userForm.userType,
      });
    } else {
      await addUser({ ...userForm });
    }
    ElMessage.success("保存成功");
    userDialogVisible.value = false;
    load();
  } finally {
    saving.value = false;
  }
}

async function handleToggleStatus(row) {
  const newStatus = row.status === "0" ? "1" : "0";
  const action = newStatus === "1" ? "停用" : "启用";
  await ElMessageBox.confirm(`确认${action}用户 ${row.username}？`, "提示", {
    type: "warning",
  });
  await changeUserStatus({ userId: String(row.userId), status: newStatus });
  ElMessage.success(`${action}成功`);
  load();
}

async function handleResetPwd(row) {
  await ElMessageBox.confirm(
    `确认重置用户 ${row.username} 的密码为 123456？`,
    "提示",
    { type: "warning" },
  );
  await resetUserPwd({ userId: String(row.userId), password: "123456" });
  ElMessage.success("密码已重置为 123456");
}

onMounted(load);
</script>
