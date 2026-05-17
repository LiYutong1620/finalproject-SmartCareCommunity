<template>
  <el-card>
    <el-table :data="list" v-loading="loading">
      <el-table-column prop="title" label="标题" />
      <el-table-column prop="msgType" label="类型" width="100" />
      <el-table-column prop="priority" label="优先级" width="80" />
      <el-table-column prop="recalled" label="状态" width="90">
        <template #default="{ row }">{{ row.recalled ? '已撤回' : '正常' }}</template>
      </el-table-column>
      <el-table-column prop="createTime" label="时间" width="170" />
      <el-table-column label="操作" width="80">
        <template #default="{ row }">
          <el-button link @click="markRead(row)">标已读</el-button>
        </template>
      </el-table-column>
    </el-table>
  </el-card>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { listMessage, markMessageRead } from '@/api/system'

const loading = ref(false)
const list = ref([])

async function load() {
  loading.value = true
  try {
    const res = await listMessage({ pageNum: 1, pageSize: 20 })
    list.value = res.data.rows
  } finally { loading.value = false }
}

async function markRead(row) {
  await markMessageRead(row.messageId)
  ElMessage.success('已标记')
  load()
}

onMounted(load)
</script>
