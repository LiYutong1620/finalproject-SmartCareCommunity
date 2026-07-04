<template>
  <div class="app-container">
    <div v-if="pageTitle" class="page-head">
      <h3>{{ pageTitle }}</h3>
      <p>{{ pageDesc }}</p>
    </div>

    <el-form :inline="true" class="search-form">
      <el-form-item label="账号">
        <el-input
          v-model="query.username"
          placeholder="账号模糊查询"
          clearable
          style="width: 160px"
        />
      </el-form-item>
      <el-form-item label="姓名">
        <el-input
          v-model="query.nickName"
          placeholder="姓名模糊查询"
          clearable
          style="width: 160px"
        />
      </el-form-item>
      <el-form-item v-if="!fixedUserType" label="类型">
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
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
        <el-button type="success" icon="Plus" @click="openAdd">新增{{ typeLabel }}</el-button>
      </el-form-item>
    </el-form>

    <el-card shadow="never" class="table-card">
      <el-table :data="list" v-loading="loading" border stripe>
        <el-table-column type="index" label="序号" width="60" align="center" />
        <el-table-column prop="username" label="账号" min-width="120" />
        <el-table-column prop="nickName" label="姓名" min-width="100" />
        <el-table-column prop="phone" label="手机" width="130" />
        <el-table-column v-if="fixedUserType === '0'" label="档案状态" width="96" align="center">
          <template #default="{ row }">
            <el-tag :type="row.residentBound ? 'success' : 'warning'" size="small">
              {{ row.residentBound ? '已绑定' : '待建档' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column v-if="fixedUserType === '0'" prop="houseAddress" label="房屋" min-width="120" show-overflow-tooltip>
          <template #default="{ row }">{{ row.houseAddress || '—' }}</template>
        </el-table-column>
        <el-table-column v-if="!fixedUserType" prop="userType" label="类型" width="90" align="center">
          <template #default="{ row }">{{
            { "0": "业主", "1": "维修工", "2": "物业" }[row.userType] || "-"
          }}</template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === '0' ? 'success' : 'danger'" size="small">
              {{ row.status === "0" ? "正常" : "停用" }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="220" align="center" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="openEdit(row)">编辑</el-button>
            <el-button type="info" link size="small" @click="handleResetPwd(row)">重置密码</el-button>
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
        @pagination="loadList"
      />
    </el-card>

    <el-dialog
      v-model="userDialogVisible"
      :title="isEdit ? `编辑${typeLabel}` : `新增${typeLabel}`"
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
        <el-form-item :label="fixedUserType === '0' ? '姓名' : '昵称'" prop="nickName">
          <el-input v-model="userForm.nickName" :placeholder="fixedUserType === '0' ? '与住户档案姓名一致' : '请输入昵称'" />
        </el-form-item>
        <el-form-item label="手机" prop="phone">
          <el-input v-model="userForm.phone" placeholder="请输入手机号" />
        </el-form-item>
        <el-form-item v-if="!fixedUserType" label="类型" prop="userType">
          <el-select v-model="userForm.userType" placeholder="请选择">
            <el-option label="业主" value="0" />
            <el-option label="维修工" value="1" />
            <el-option label="物业" value="2" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="userDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="handleSaveUser">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed } from "vue";
import { useRoute } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";
import {
  listUser,
  addUser,
  editUser,
  changeUserStatus,
  resetUserPwd,
} from "@/api/system";
import { useAutoQuery } from "@/composables/useAutoQuery";

const route = useRoute();
const fixedUserType = computed(() => route.meta.userType || "");

const typeMeta = {
  "0": { label: "业主", desc: "管理社区业主账号，支持新增、编辑、停用与密码重置。" },
  "1": { label: "维修工", desc: "管理维修工账号，新建后自动创建维修工档案。" },
  "2": { label: "物业人员", desc: "管理物业端工作人员账号与权限。" },
};

const pageTitle = computed(() =>
  fixedUserType.value ? typeMeta[fixedUserType.value]?.label + "管理" : "用户管理",
);
const pageDesc = computed(() =>
  fixedUserType.value ? typeMeta[fixedUserType.value]?.desc : "按类型管理业主、维修工与物业账号。",
);
const typeLabel = computed(() =>
  fixedUserType.value ? typeMeta[fixedUserType.value]?.label : "用户",
);

const saving = ref(false);
const list = ref([]);
const total = ref(0);
const query = reactive({
  pageNum: 1,
  pageSize: 10,
  username: "",
  nickName: "",
  userType: route.meta.userType || "",
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

async function fetchList() {
  const params = { pageNum: query.pageNum, pageSize: query.pageSize };
  if (query.username) params.username = query.username;
  if (query.nickName) params.nickName = query.nickName;
  if (query.userType) params.userType = query.userType;
  const res = await listUser(params);
  list.value = res.data.rows;
  total.value = res.data.total;
}

const { loading, load: loadList, reset: resetAuto } = useAutoQuery(
  fetchList,
  () => [query.username, query.nickName, query.userType],
  { beforeLoad: () => { query.pageNum = 1 } },
);

function resetQuery() {
  resetAuto(() => {
    query.username = "";
    query.nickName = "";
    query.userType = fixedUserType.value || "";
    query.pageNum = 1;
  });
}

function openAdd() {
  isEdit.value = false;
  Object.assign(userForm, {
    username: "",
    password: "",
    nickName: "",
    phone: "",
    userType: fixedUserType.value || "0",
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
  await userFormRef.value.validate();
  saving.value = true;
  try {
    if (isEdit.value) {
      await editUser({
        userId: userForm.userId,
        nickName: userForm.nickName,
        phone: userForm.phone,
        userType: fixedUserType.value || userForm.userType,
      });
    } else {
      await addUser({
        ...userForm,
        userType: fixedUserType.value || userForm.userType,
      });
    }
    ElMessage.success("保存成功");
    userDialogVisible.value = false;
    loadList();
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
  loadList();
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

</script>

<style scoped lang="scss">
.page-head {
  margin-bottom: 16px;

  h3 {
    margin: 0 0 4px;
    font-size: 18px;
    font-weight: 600;
    color: #303133;
  }

  p {
    margin: 0;
    font-size: 13px;
    color: #909399;
  }
}
</style>
