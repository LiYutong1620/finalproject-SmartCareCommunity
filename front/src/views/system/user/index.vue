<template>
  <el-card>
    <el-table :data="list" v-loading="loading">
      <el-table-column prop="username" label="账号" />
      <el-table-column prop="nickName" label="昵称" />
      <el-table-column prop="phone" label="手机" />
      <el-table-column prop="userType" label="类型">
        <template #default="{ row }">{{ { '0':'业主','1':'维修工','2':'物业' }[row.userType] || '物业' }}</template>
      </el-table-column>
      <el-table-column prop="status" label="状态">
        <template #default="{ row }">{{ row.status === '0' ? '正常' : '停用' }}</template>
      </el-table-column>
    </el-table>
  </el-card>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { listUser } from '@/api/system'

const loading = ref(false)
const list = ref([])

onMounted(async () => {
  loading.value = true
  try {
    const res = await listUser({ pageNum: 1, pageSize: 50 })
    list.value = res.data.rows
  } finally { loading.value = false }
})
</script>
