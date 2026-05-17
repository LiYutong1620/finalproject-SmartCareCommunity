<template>
  <el-card>
    <el-table :data="list" v-loading="loading">
      <el-table-column prop="orderNo" label="工单号" width="180" />
      <el-table-column prop="description" label="描述" show-overflow-tooltip />
      <el-table-column prop="status" label="状态" width="100" />
      <el-table-column prop="urgency" label="紧急程度" width="90" />
      <el-table-column prop="workerId" label="维修工ID" width="90" />
      <el-table-column label="操作" width="160">
        <template #default="{ row }">
          <el-button v-if="row.status === 'pending'" link type="primary" @click="openAssign(row)">派单</el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-dialog v-model="assignVisible" title="指派维修工" width="400px">
      <el-form label-width="90px">
        <el-form-item label="维修工ID"><el-input v-model="assignForm.workerId" /></el-form-item>
        <el-form-item label="原因"><el-input v-model="assignForm.reason" type="textarea" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="assignVisible = false">取消</el-button>
        <el-button type="primary" @click="handleAssign">确定</el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { listPropertyRepair, assignRepair } from '@/api/repair'

const loading = ref(false)
const list = ref([])
const assignVisible = ref(false)
const assignForm = reactive({ orderId: null, workerId: '3', reason: '' })

async function load() {
  loading.value = true
  try {
    const res = await listPropertyRepair({ pageNum: 1, pageSize: 20 })
    list.value = res.data.rows
  } finally { loading.value = false }
}

function openAssign(row) {
  assignForm.orderId = row.orderId
  assignVisible.value = true
}

async function handleAssign() {
  await assignRepair(assignForm)
  ElMessage.success('派单成功')
  assignVisible.value = false
  load()
}

onMounted(load)
</script>
