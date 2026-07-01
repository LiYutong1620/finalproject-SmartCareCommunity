<template>
  <div class="app-container">
    <el-card>
      <template #header>
        <div class="header-wrap">
          <span>工单 AI 复盘周报</span>
          <el-space>
            <el-button type="primary" :loading="generating" @click="handleGenerate">手动生成周报</el-button>
            <el-button @click="$router.back()">返回</el-button>
          </el-space>
        </div>
      </template>

      <el-table :data="list" v-loading="loading" border stripe>
        <el-table-column prop="weekStart" label="周起始" width="120" />
        <el-table-column prop="weekEnd" label="周结束" width="120" />
        <el-table-column prop="totalOrders" label="总工单数" width="100" align="center" />
        <el-table-column prop="avgCompleteHours" label="平均完成时长(h)" width="140" align="center" />
        <el-table-column prop="overtimeRate" label="超时率(%)" width="100" align="center" />
        <el-table-column prop="duplicateRate" label="重复报修率(%)" width="120" align="center" />
        <el-table-column prop="goodRate" label="好评率(%)" width="100" align="center" />
        <el-table-column label="优化建议" min-width="260">
          <template #default="{ row }">
            <div class="suggestion-text">{{ row.suggestions }}</div>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="生成时间" width="170" />
      </el-table>

      <Pagination
        v-show="total > 0"
        :total="total"
        v-model:page="query.pageNum"
        v-model:limit="query.pageSize"
        @pagination="load"
      />
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { listRepairWeeklyReports, generateRepairWeeklyReport } from '@/api/repair'

const loading = ref(false)
const generating = ref(false)
const list = ref([])
const total = ref(0)
const query = reactive({ pageNum: 1, pageSize: 10 })

async function load() {
  loading.value = true
  try {
    const res = await listRepairWeeklyReports(query)
    list.value = res.data.rows || []
    total.value = res.data.total || 0
  } finally {
    loading.value = false
  }
}

async function handleGenerate() {
  generating.value = true
  try {
    await generateRepairWeeklyReport()
    ElMessage.success('周报已生成')
    load()
  } finally {
    generating.value = false
  }
}

onMounted(load)
</script>

<style scoped>
.header-wrap {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.suggestion-text {
  white-space: pre-wrap;
  line-height: 1.5;
}
</style>
