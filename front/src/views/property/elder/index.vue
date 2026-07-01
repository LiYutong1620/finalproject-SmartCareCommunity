<template>
  <div class="app-container elder-archive">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span>独居老人列表</span>
          <el-button icon="Refresh" @click="loadElders" :loading="elderLoading"
            >刷新</el-button
          >
        </div>
      </template>
      <el-table :data="elderList" v-loading="elderLoading" border stripe>
        <el-table-column type="index" label="序号" width="60" align="center" />
        <el-table-column prop="name" label="姓名" width="100" />
        <el-table-column prop="age" label="年龄" width="70" align="center" />
        <el-table-column prop="gender" label="性别" width="70" align="center">
          <template #default="{ row }">{{
            row.gender === "0" ? "男" : "女"
          }}</template>
        </el-table-column>
        <el-table-column prop="phone" label="联系电话" width="130" />
        <el-table-column
          prop="emergencyContact"
          label="紧急联系人"
          width="130"
        />
        <el-table-column
          prop="address"
          label="住址"
          min-width="160"
          show-overflow-tooltip
        />
        <el-table-column
          prop="livingAlone"
          label="独居标记"
          width="90"
          align="center"
        >
          <template #default="{ row }">
            <el-tag v-if="row.livingAlone === '1'" type="warning" size="small"
              >独居</el-tag
            >
            <el-tag v-else type="success" size="small">非独居</el-tag>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { getAloneElders } from "@/api/elderAi";

const elderLoading = ref(false);
const elderList = ref([]);

async function loadElders() {
  elderLoading.value = true;
  try {
    const res = await getAloneElders();
    elderList.value = res.data || [];
  } finally {
    elderLoading.value = false;
  }
}

onMounted(loadElders);
</script>

<style scoped lang="scss">
.elder-archive {
  padding: 16px;
}
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: 600;
}
</style>
