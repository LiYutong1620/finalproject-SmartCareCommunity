<template>
  <el-card>
    <el-table :data="list" v-loading="loading">
      <el-table-column prop="orderNo" label="工单号" width="180" />
      <el-table-column prop="description" label="故障描述" show-overflow-tooltip />
      <el-table-column prop="urgency" label="紧急程度" width="90" />
      <el-table-column prop="status" label="状态" width="100" />
      <el-table-column label="操作" width="260">
        <template #default="{ row }">
          <el-button v-if="row.status === 'pending'" link type="primary" @click="handleAccept(row)">接单</el-button>
          <el-button v-if="row.status === 'processing'" link @click="handleComplete(row)">完成维修</el-button>
        </template>
      </el-table-column>
    </el-table>
  </el-card>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { listWorkerOrder, acceptOrder, completeOrder } from '@/api/repair'

const loading = ref(false)
const list = ref([])

async function load() {
  loading.value = true
  try {
    const res = await listWorkerOrder({ pageNum: 1, pageSize: 20 })
    list.value = res.data.rows
  } finally { loading.value = false }
}

async function handleAccept(row) {
  await acceptOrder(row.orderId)
  ElMessage.success('接单成功')
  load()
}

async function handleComplete(row) {
  await completeOrder(row.orderId)
  ElMessage.success('已提交待验收')
  load()
}

onMounted(load)
</script>
