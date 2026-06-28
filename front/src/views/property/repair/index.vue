<template>
  <div class="app-container">
    <el-form :inline="true" class="search-form">
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-card shadow="never" class="table-card">
      <el-table :data="list" v-loading="loading" border stripe>
        <el-table-column type="index" label="序号" width="60" align="center" />
        <el-table-column prop="orderNo" label="工单号" width="180" />
        <el-table-column prop="description" label="描述" min-width="160" show-overflow-tooltip />
        <el-table-column prop="status" label="状态" width="100" align="center" />
        <el-table-column prop="urgency" label="紧急程度" width="90" align="center" />
        <el-table-column prop="workerId" label="维修工ID" width="90" align="center" />
        <el-table-column label="操作" width="100" align="center" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.status === 'pending'" link type="primary" @click="openAssign(row)">派单</el-button>
          </template>
        </el-table-column>
      </el-table>
      <Pagination
        v-show="total > 0"
        :total="total"
        v-model:page="query.pageNum"
        v-model:limit="query.pageSize"
        @pagination="load"
      />
    </el-card>

    <el-dialog v-model="assignVisible" title="指派维修工" width="400px" append-to-body>
      <el-form label-width="90px">
        <el-form-item label="维修工ID"><el-input v-model="assignForm.workerId" /></el-form-item>
        <el-form-item label="原因"><el-input v-model="assignForm.reason" type="textarea" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="assignVisible = false">取消</el-button>
        <el-button type="primary" @click="handleAssign">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { listPropertyRepair, assignRepair } from '@/api/repair'

const loading = ref(false)
const list = ref([])
const total = ref(0)
const query = reactive({ pageNum: 1, pageSize: 10 })
const assignVisible = ref(false)
const assignForm = reactive({ orderId: null, workerId: '3', reason: '' })

async function load() {
  loading.value = true
  try {
    const res = await listPropertyRepair(query)
    list.value = res.data.rows
    total.value = res.data.total
  } finally { loading.value = false }
}

function handleQuery() {
  query.pageNum = 1
  load()
}

function resetQuery() {
  query.pageNum = 1
  query.pageSize = 10
  load()
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
