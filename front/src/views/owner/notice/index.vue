<template>
  <div class="app-container">
    <el-form :inline="true" class="search-form">
      <el-form-item label="标题">
        <el-input v-model="query.title" placeholder="请输入标题" clearable style="width:180px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="状态">
        <el-select v-model="query.readStatus" clearable placeholder="全部" style="width:120px">
          <el-option label="已读" value="1" />
          <el-option label="未读" value="0" />
        </el-select>
      </el-form-item>
      <el-form-item label="发布时间">
        <el-date-picker
          v-model="query.publishTimeRange"
          type="datetimerange"
          range-separator="至"
          start-placeholder="开始时间"
          end-placeholder="结束时间"
          value-format="YYYY-MM-DD HH:mm:ss"
          style="width:360px"
        />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">查询</el-button>
        <el-button icon="Refresh" @click="handleReset">重置</el-button>
      </el-form-item>
    </el-form>

    <el-card shadow="never" class="table-card">
      <el-table :data="list" v-loading="loading" border stripe>
        <el-table-column type="index" label="序号" width="60" align="center" />
        <el-table-column prop="title" label="标题" min-width="180" show-overflow-tooltip />
        <el-table-column label="状态" width="80" align="center">
          <template #default="{ row }">
            <el-tag :type="row.read ? 'info' : 'warning'" size="small">{{ row.read ? '已读' : '未读' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="发布时间" width="170" align="center" />
        <el-table-column label="操作" width="90" align="center" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="goDetail(row)">详情</el-button>
          </template>
        </el-table-column>
      </el-table>
      <Pagination
        v-show="total > 0"
        :total="total"
        v-model:page="query.pageNum"
        v-model:limit="query.pageSize"
        @pagination="fetchList"
      />
    </el-card>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { listNoticeV2 } from '@/api/owner'

const router = useRouter()
const list = ref([])
const total = ref(0)
const loading = ref(false)
const query = reactive({ pageNum: 1, pageSize: 10, title: '', readStatus: '', publishTimeRange: null })

async function fetchList() {
  loading.value = true
  try {
    const params = { pageNum: query.pageNum, pageSize: query.pageSize, noticeType: 'announce' }
    if (query.title?.trim()) params.title = query.title.trim()
    if (query.readStatus !== '' && query.readStatus != null) params.readStatus = query.readStatus
    if (query.publishTimeRange?.length === 2) {
      params.publishTimeStart = query.publishTimeRange[0]
      params.publishTimeEnd = query.publishTimeRange[1]
    }
    const res = await listNoticeV2(params)
    list.value = res.data.rows
    total.value = res.data.total
  } finally {
    loading.value = false
  }
}

function handleQuery() {
  query.pageNum = 1
  fetchList()
}

function handleReset() {
  query.title = ''
  query.readStatus = ''
  query.publishTimeRange = null
  query.pageNum = 1
  fetchList()
}

function goDetail(row) {
  router.push({ path: `/owner/notice/detail/${row.noticeId}` })
}

onMounted(fetchList)
</script>
