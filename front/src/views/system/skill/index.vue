<template>
  <div class="app-container">
    <el-form :inline="true" class="search-form">
      <el-form-item label="维修工">
        <el-select
          v-model="query.workerId"
          clearable
          placeholder="全部"
          style="width: 160px"
          @change="load"
        >
          <el-option
            v-for="w in workers"
            :key="w.userId"
            :label="w.nickName + ' (' + w.username + ')'"
            :value="w.userId"
          />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="success" icon="Plus" @click="openAdd"
          >新增技能标签</el-button
        >
      </el-form-item>
    </el-form>

    <el-card shadow="never">
      <el-table :data="list" v-loading="loading" border stripe>
        <el-table-column type="index" label="序号" width="60" align="center" />
        <el-table-column prop="workerId" label="维修工" min-width="120">
          <template #default="{ row }">
            {{ getWorkerName(row.workerId) }}
          </template>
        </el-table-column>
        <el-table-column prop="skillName" label="技能名称" min-width="140" />
        <el-table-column
          prop="skillLevel"
          label="技能等级"
          width="100"
          align="center"
        >
          <template #default="{ row }">
            <el-tag :type="levelType(row.skillLevel)" size="small">{{
              row.skillLevel || "初级"
            }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" align="center" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link size="small" @click="openEdit(row)"
              >编辑</el-button
            >
            <el-button
              type="danger"
              link
              size="small"
              @click="handleDelete(row)"
              >删除</el-button
            >
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 新增/编辑技能对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="isEdit ? '编辑技能标签' : '新增技能标签'"
      width="450px"
      :close-on-click-modal="false"
    >
      <el-form :model="form" label-width="90px">
        <el-form-item label="维修工" required>
          <el-select
            v-model="form.workerId"
            placeholder="请选择维修工"
            style="width: 100%"
          >
            <el-option
              v-for="w in workers"
              :key="w.userId"
              :label="w.nickName + ' (' + w.username + ')'"
              :value="w.userId"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="技能名称" required>
          <el-input
            v-model="form.skillName"
            placeholder="如：水电维修、空调维修、电梯维保"
          />
        </el-form-item>
        <el-form-item label="技能等级">
          <el-select
            v-model="form.skillLevel"
            placeholder="请选择"
            style="width: 100%"
          >
            <el-option label="初级" value="初级" />
            <el-option label="中级" value="中级" />
            <el-option label="高级" value="高级" />
            <el-option label="专家" value="专家" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="handleSave"
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
  listWorkerSkills,
  addWorkerSkill,
  editWorkerSkill,
  deleteWorkerSkill,
} from "@/api/system";

const loading = ref(false);
const saving = ref(false);
const list = ref([]);
const workers = ref([]);
const query = reactive({ workerId: null });

const dialogVisible = ref(false);
const isEdit = ref(false);
const form = reactive({
  skillId: null,
  workerId: null,
  skillName: "",
  skillLevel: "初级",
});

async function loadWorkers() {
  const res = await listUser({ pageNum: 1, pageSize: 100, userType: "1" });
  workers.value = res.data.rows || [];
}

async function load() {
  loading.value = true;
  try {
    const params = {};
    if (query.workerId) params.workerId = query.workerId;
    const res = await listWorkerSkills(params);
    list.value = res.data || [];
  } finally {
    loading.value = false;
  }
}

function getWorkerName(workerId) {
  const w = workers.value.find((x) => x.userId === workerId);
  return w ? w.nickName : `ID:${workerId}`;
}

function levelType(level) {
  const map = { 初级: "", 中级: "warning", 高级: "success", 专家: "danger" };
  return map[level] || "";
}

function openAdd() {
  isEdit.value = false;
  Object.assign(form, {
    skillId: null,
    workerId: query.workerId || null,
    skillName: "",
    skillLevel: "初级",
  });
  dialogVisible.value = true;
}

function openEdit(row) {
  isEdit.value = true;
  Object.assign(form, {
    skillId: row.skillId,
    workerId: row.workerId,
    skillName: row.skillName,
    skillLevel: row.skillLevel || "初级",
  });
  dialogVisible.value = true;
}

async function handleSave() {
  saving.value = true;
  try {
    if (isEdit.value) {
      await editWorkerSkill({ ...form });
    } else {
      await addWorkerSkill({ ...form });
    }
    ElMessage.success("保存成功");
    dialogVisible.value = false;
    load();
  } finally {
    saving.value = false;
  }
}

async function handleDelete(row) {
  await ElMessageBox.confirm(`确认删除技能标签 ${row.skillName}？`, "提示", {
    type: "warning",
  });
  await deleteWorkerSkill(row.skillId);
  ElMessage.success("删除成功");
  load();
}

onMounted(async () => {
  await loadWorkers();
  load();
});
</script>
