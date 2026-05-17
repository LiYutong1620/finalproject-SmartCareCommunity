<template>
  <el-card>
    <el-table :data="list" v-loading="loading">
      <el-table-column prop="alertId" label="ID" width="80" />
      <el-table-column prop="residentId" label="老人档案ID" />
      <el-table-column prop="alertType" label="预警类型" />
      <el-table-column prop="alertLevel" label="等级" width="70" />
      <el-table-column prop="content" label="内容" show-overflow-tooltip />
      <el-table-column prop="status" label="状态" width="90" />
      <el-table-column label="操作" width="100">
        <template #default="{ row }">
          <el-button v-if="row.status === 'pending'" link type="primary" @click="handle(row)">处置</el-button>
        </template>
      </el-table-column>
    </el-table>
  </el-card>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { listElderAlert, handleElderAlert } from '@/api/property'

const loading = ref(false)
const list = ref([])

async function load() {
  loading.value = true
  try {
    const res = await listElderAlert({ pageNum: 1, pageSize: 20 })
    list.value = res.data.rows
  } finally { loading.value = false }
}

async function handle(row) {
  const { value } = await ElMessageBox.prompt('请输入处置结果', '处置预警')
  await handleElderAlert({ alertId: row.alertId, handleResult: value, status: 'handled' })
  ElMessage.success('处置完成')
  load()
}

onMounted(load)
</script>
