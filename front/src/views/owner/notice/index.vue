<template>
  <el-card>
    <el-table :data="list" v-loading="loading">
      <el-table-column prop="title" label="标题" />
      <el-table-column prop="noticeType" label="类型" width="100">
        <template #default="{ row }">{{ row.noticeType === 'outage' ? '停水停电' : '公告' }}</template>
      </el-table-column>
      <el-table-column prop="pinned" label="置顶" width="70">
        <template #default="{ row }"><el-tag v-if="row.pinned">置顶</el-tag></template>
      </el-table-column>
      <el-table-column prop="createTime" label="发布时间" width="170" />
    </el-table>
  </el-card>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { listNotice } from '@/api/community'

const loading = ref(false)
const list = ref([])

async function load() {
  loading.value = true
  try {
    const res = await listNotice({ pageNum: 1, pageSize: 50 })
    list.value = res.data.rows
  } finally { loading.value = false }
}

onMounted(load)
</script>
