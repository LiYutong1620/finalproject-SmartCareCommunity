<template>
  <el-card>
    <el-table :data="list" v-loading="loading">
      <el-table-column prop="username" label="账号" />
      <el-table-column prop="ipaddr" label="IP" />
      <el-table-column prop="device" label="设备" show-overflow-tooltip />
      <el-table-column prop="status" label="结果">
        <template #default="{ row }">{{ row.status === '0' ? '成功' : '失败' }}</template>
      </el-table-column>
      <el-table-column prop="loginTime" label="时间" width="170" />
    </el-table>
  </el-card>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { listLoginLog } from '@/api/system'

const loading = ref(false)
const list = ref([])

onMounted(async () => {
  loading.value = true
  try {
    const res = await listLoginLog({ pageNum: 1, pageSize: 50 })
    list.value = res.data.rows
  } finally { loading.value = false }
})
</script>
