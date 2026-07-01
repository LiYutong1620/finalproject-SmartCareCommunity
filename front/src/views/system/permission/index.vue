<template>
  <div class="app-container">
    <el-card shadow="never" class="table-card">
      <template #header>
        <span>用户权限分配</span>
      </template>
      <el-table :data="userList" v-loading="userLoading" border stripe>
        <el-table-column type="index" label="序号" width="60" align="center" />
        <el-table-column prop="username" label="账号" min-width="120" />
        <el-table-column prop="nickName" label="昵称" min-width="120" />
        <el-table-column prop="userType" label="类型" width="90" align="center">
          <template #default="{ row }">
            <el-tag
              :type="row.userType === '1' ? 'warning' : 'primary'"
              size="small"
            >
              {{ { "1": "维修工", "2": "物业" }[row.userType] || "未知" }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="phone" label="手机" width="130" />
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
        <el-table-column label="操作" width="120" align="center" fixed="right">
          <template #default="{ row }">
            <el-button
              type="primary"
              link
              size="small"
              icon="Setting"
              @click="handleEditPerm(row)"
              >分配权限</el-button
            >
          </template>
        </el-table-column>
      </el-table>
      <Pagination
        v-show="userTotal > 0"
        :total="userTotal"
        v-model:page="userQuery.pageNum"
        v-model:limit="userQuery.pageSize"
        @pagination="loadUsers"
      />
    </el-card>

    <!-- 用户权限分配对话框 -->
    <el-dialog
      v-model="permDialogVisible"
      title="分配权限"
      width="600px"
      :close-on-click-modal="false"
    >
      <el-form label-position="top">
        <el-form-item label="账号">
          <el-input
            :model-value="
              currentUser.username + ' (' + (currentUser.nickName || '') + ')'
            "
            disabled
          />
        </el-form-item>
        <el-form-item label="权限配置">
          <el-checkbox-group
            v-model="selectedPermissions"
            class="permission-group"
          >
            <el-row :gutter="10">
              <el-col
                :span="12"
                v-for="item in allPermissions"
                :key="item.code"
              >
                <el-checkbox :label="item.code" border>{{
                  item.name
                }}</el-checkbox>
              </el-col>
            </el-row>
          </el-checkbox-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="permDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="permSaving" @click="handleSavePerm"
          >保存</el-button
        >
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from "vue";
import { ElMessage } from "element-plus";
import {
  listUser,
  listPermissions,
  getUserPermissions,
  updateUserPermissions,
} from "@/api/system";

const userLoading = ref(false);
const permSaving = ref(false);
const userList = ref([]);
const userTotal = ref(0);
const userQuery = reactive({ pageNum: 1, pageSize: 10 });
const permDialogVisible = ref(false);
const currentUser = ref({});
const allPermissions = ref([]);
const selectedPermissions = ref([]);

async function loadUsers() {
  userLoading.value = true;
  try {
    // 查询维修工(1)和物业(2)的用户
    const res1 = await listUser({
      pageNum: 1,
      pageSize: 100,
      userType: "1",
    });
    const res2 = await listUser({
      pageNum: 1,
      pageSize: 100,
      userType: "2",
    });
    const workers = res1.data?.rows || [];
    const props = res2.data?.rows || [];
    const all = [...props, ...workers];
    userTotal.value = all.length;
    const start = (userQuery.pageNum - 1) * userQuery.pageSize;
    userList.value = all.slice(start, start + userQuery.pageSize);
  } finally {
    userLoading.value = false;
  }
}

async function loadPermissions() {
  if (allPermissions.value.length > 0) return;
  const res = await listPermissions();
  allPermissions.value = res.data;
}

async function handleEditPerm(row) {
  currentUser.value = row;
  selectedPermissions.value = [];
  await loadPermissions();
  const res = await getUserPermissions(row.userId);
  selectedPermissions.value = res.data || [];
  permDialogVisible.value = true;
}

async function handleSavePerm() {
  permSaving.value = true;
  try {
    await updateUserPermissions(
      currentUser.value.userId,
      selectedPermissions.value,
    );
    ElMessage.success("保存成功");
    permDialogVisible.value = false;
  } finally {
    permSaving.value = false;
  }
}

onMounted(loadUsers);
</script>

<style scoped>
.permission-group {
  width: 100%;
}
.permission-group .el-checkbox {
  margin-bottom: 10px;
  width: 100%;
}
</style>
