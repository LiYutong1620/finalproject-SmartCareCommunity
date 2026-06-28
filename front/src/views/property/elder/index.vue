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
        <el-table-column prop="alertId" label="ID" width="80" align="center" />
        <el-table-column prop="residentId" label="老人档案ID" width="110" align="center" />
        <el-table-column prop="alertType" label="预警类型" width="100" />
        <el-table-column prop="alertLevel" label="等级" width="70" align="center" />
        <el-table-column prop="content" label="内容" min-width="160" show-overflow-tooltip />
        <el-table-column prop="status" label="状态" width="90" align="center" />
        <el-table-column label="操作" width="100" align="center" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.status === 'pending'" link type="primary" @click="handle(row)">处置</el-button>
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
import { ElMessage, ElMessageBox } from 'element-plus'
import { listElderAlert, handleElderAlert } from '@/api/property'

const loading = ref(false)
const list = ref([])
const total = ref(0)
const query = reactive({ pageNum: 1, pageSize: 10 })

async function load() {
  loading.value = true
  try {
    const res = await listElderAlert(query)
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

async function handle(row) {
  const { value } = await ElMessageBox.prompt('请输入处置结果', '处置预警')
  await handleElderAlert({ alertId: row.alertId, handleResult: value, status: 'handled' })
  ElMessage.success('处置完成')
  load()
}

onMounted(load)
</script>
