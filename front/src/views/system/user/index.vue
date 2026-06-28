<template>
  <div class="app-container">
    <el-form :inline="true" class="search-form">
      <el-form-item label="账号">
        <el-input v-model="query.username" placeholder="请输入账号" clearable style="width:160px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="类型">
        <el-select v-model="query.userType" clearable placeholder="全部" style="width:120px">
          <el-option label="业主" value="0" />
          <el-option label="维修工" value="1" />
          <el-option label="物业" value="2" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-card shadow="never" class="table-card">
      <el-table :data="list" v-loading="loading" border stripe>
        <el-table-column type="index" label="序号" width="60" align="center" />
        <el-table-column prop="username" label="账号" min-width="120" />
        <el-table-column prop="nickName" label="昵称" min-width="120" />
        <el-table-column prop="phone" label="手机" width="130" />
        <el-table-column prop="userType" label="类型" width="90" align="center">
          <template #default="{ row }">{{ { '0':'业主','1':'维修工','2':'物业' }[row.userType] || '物业' }}</template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="row.status === '0' ? 'success' : 'danger'" size="small">
              {{ row.status === '0' ? '正常' : '停用' }}
            </el-tag>
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
import { listUser } from '@/api/system'

const loading = ref(false)
const list = ref([])
const total = ref(0)
const query = reactive({ pageNum: 1, pageSize: 10, username: '', userType: '' })

async function load() {
  loading.value = true
  try {
    const params = { pageNum: query.pageNum, pageSize: query.pageSize }
    if (query.username) params.username = query.username
    if (query.userType) params.userType = query.userType
    const res = await listUser(params)
    list.value = res.data.rows
    total.value = res.data.total
  } finally { loading.value = false }
}

function handleQuery() {
  query.pageNum = 1
  load()
}

function resetQuery() {
  query.username = ''
  query.userType = ''
  query.pageNum = 1
  query.pageSize = 10
  load()
}

onMounted(load)
</script>
