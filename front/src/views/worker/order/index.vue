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
        <el-table-column prop="description" label="故障描述" min-width="160" show-overflow-tooltip />
        <el-table-column prop="urgency" label="紧急程度" width="90" align="center" />
        <el-table-column prop="status" label="状态" width="100" align="center" />
        <el-table-column label="操作" width="200" align="center" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.status === 'pending'" link type="primary" @click="handleAccept(row)">接单</el-button>
            <el-button v-if="row.status === 'processing'" link type="primary" @click="handleComplete(row)">完成维修</el-button>
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
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { listWorkerOrder, acceptOrder, completeOrder } from '@/api/repair'

const loading = ref(false)
const list = ref([])
const total = ref(0)
const query = reactive({ pageNum: 1, pageSize: 10 })

async function load() {
  loading.value = true
  try {
    const res = await listWorkerOrder(query)
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
