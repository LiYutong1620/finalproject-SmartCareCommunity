<template>
  <div>
    <el-card class="mb-16">
      <el-button type="primary" @click="showAdd = true">提交报修</el-button>
    </el-card>
    <el-card>
      <el-table :data="list" v-loading="loading">
        <el-table-column prop="orderNo" label="工单号" width="180" />
        <el-table-column prop="description" label="描述" show-overflow-tooltip />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">{{ statusMap[row.status] || row.status }}</template>
        </el-table-column>
        <el-table-column prop="urgency" label="紧急程度" width="90" />
        <el-table-column prop="createTime" label="创建时间" width="170" />
        <el-table-column label="操作" width="200">
          <template #default="{ row }">
            <el-button v-if="row.status === 'pending'" link type="danger" @click="handleCancel(row)">撤销</el-button>
            <el-button v-if="!['completed','cancelled'].includes(row.status)" link @click="handleUrge(row)">催单</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-pagination class="mt-16" v-model:current-page="query.pageNum" v-model:page-size="query.pageSize" :total="total" layout="total, prev, pager, next" @current-change="load" />
    </el-card>
    <el-dialog v-model="showAdd" title="提交报修" width="500px">
      <el-form :model="form" label-width="80px">
        <el-form-item label="故障描述"><el-input v-model="form.description" type="textarea" rows="4" /></el-form-item>
        <el-form-item label="紧急程度">
          <el-select v-model="form.urgency"><el-option label="普通" value="normal" /><el-option label="较急" value="urgent" /><el-option label="紧急" value="emergency" /></el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showAdd = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">提交</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { listOwnerRepair, submitRepair, cancelRepair, urgeRepair } from '@/api/repair'

const statusMap = { pending: '待分配', processing: '处理中', wait_accept: '待验收', completed: '已完成', cancelled: '已取消' }
const loading = ref(false)
const list = ref([])
const total = ref(0)
const showAdd = ref(false)
const query = reactive({ pageNum: 1, pageSize: 10 })
const form = reactive({ description: '', urgency: 'normal' })

async function load() {
  loading.value = true
  try {
    const res = await listOwnerRepair(query)
    list.value = res.data.rows
    total.value = res.data.total
  } finally { loading.value = false }
}

async function handleSubmit() {
  await submitRepair(form)
  ElMessage.success('提交成功')
  showAdd.value = false
  form.description = ''
  load()
}

async function handleCancel(row) {
  await ElMessageBox.confirm('确认撤销该报修？')
  await cancelRepair(row.orderId)
  ElMessage.success('已撤销')
  load()
}

async function handleUrge(row) {
  await urgeRepair(row.orderId)
  ElMessage.success('催单成功')
  load()
}

onMounted(load)
</script>

<style scoped>.mb-16{margin-bottom:16px}.mt-16{margin-top:16px}</style>
