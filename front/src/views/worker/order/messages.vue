<template>
  <div class="app-container">
    <el-card>
      <template #header>
        <div class="header-wrap">
          <span>工单消息通知</span>
          <el-button size="small" @click="$router.back()">返回</el-button>
        </div>
      </template>

      <el-table :data="list" v-loading="loading" border stripe>
        <el-table-column prop="title" label="标题" min-width="160" />
        <el-table-column prop="content" label="内容" min-width="260" show-overflow-tooltip />
        <el-table-column prop="createTime" label="时间" width="170" />
        <el-table-column label="操作" width="100" align="center">
          <template #default="{ row }">
            <el-button link type="primary" @click="markRead(row)">标记已读</el-button>
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
import { listMessages, markMessageRead } from '@/api/repair'

const loading = ref(false)
const list = ref([])
const total = ref(0)
const query = reactive({ pageNum: 1, pageSize: 10, msgType: 'order' })

async function load() {
  loading.value = true
  try {
    const res = await listMessages(query)
    list.value = res.data.rows || []
    total.value = res.data.total || 0
  } finally {
    loading.value = false
  }
}

async function markRead(row) {
  await markMessageRead(row.messageId)
  ElMessage.success('已标记为已读')
  load()
}

onMounted(load)
</script>

<style scoped>
.header-wrap {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
</style>
