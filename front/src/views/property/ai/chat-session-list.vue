<template>
  <div class="app-container">
    <el-form :inline="true" class="search-form">
      <el-form-item label="对话主题">
        <el-input
          v-model="chatQuery.title"
          placeholder="请输入对话主题"
          clearable
          style="width:180px"
        />
      </el-form-item>
      <el-form-item v-if="isHistory" label="对话类型">
        <el-select v-model="chatQuery.sessionType" clearable placeholder="全部" style="width:140px">
          <el-option label="AI问答" value="ai" />
          <el-option label="人工对话" value="human" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button icon="Refresh" @click="resetChatQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-card shadow="never" class="table-card">
      <el-table v-loading="chatLoading" :data="chatList" border stripe>
        <el-table-column type="index" label="序号" width="60" align="center" />
        <el-table-column label="业主" width="120" align="center">
          <template #default="{ row }">{{ row.nickName || row.username || '-' }}</template>
        </el-table-column>
        <el-table-column prop="phone" label="联系电话" width="120" align="center" />
        <el-table-column prop="title" label="对话主题" min-width="140" show-overflow-tooltip />
        <el-table-column v-if="isHistory" label="对话类型" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="row.sessionType === 'ai' ? 'primary' : 'info'" size="small">
              {{ sessionTypeLabel(row.sessionType) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="lastMessage" label="最新消息" min-width="200" show-overflow-tooltip />
        <el-table-column v-if="!isHistory" label="未读" width="70" align="center">
          <template #default="{ row }">
            <el-badge v-if="row.unreadCount > 0" :value="row.unreadCount" />
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column prop="lastTime" label="最后消息时间" width="170" align="center" />
        <el-table-column label="操作" width="120" align="center" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="goChat(row)">
              {{ isHistory ? '查看记录' : '进入对话' }}
            </el-button>
          </template>
        </el-table-column>
      </el-table>
      <Pagination
        v-show="chatTotal > 0"
        :total="chatTotal"
        v-model:page="chatQuery.pageNum"
        v-model:limit="chatQuery.pageSize"
        @pagination="loadChatSessions"
      />
    </el-card>
  </div>
</template>

<script setup>
import { computed, reactive, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { listHumanChatSessions } from '@/api/propertyAi'
import { useAutoQuery } from '@/composables/useAutoQuery'

const route = useRoute()
const router = useRouter()

const isHistory = computed(() => route.meta.mode === 'history')
const chatQuery = reactive({ pageNum: 1, pageSize: 10, title: '', sessionType: '' })
const chatList = ref([])
const chatTotal = ref(0)

async function fetchList() {
  const params = {
    pageNum: chatQuery.pageNum,
    pageSize: chatQuery.pageSize,
    scope: isHistory.value ? 'history' : 'active'
  }
  if (chatQuery.title?.trim()) params.title = chatQuery.title.trim()
  if (isHistory.value && chatQuery.sessionType) params.sessionType = chatQuery.sessionType
  const res = await listHumanChatSessions(params)
  chatList.value = res.data.rows
  chatTotal.value = res.data.total
}

const { loading: chatLoading, load: loadChatSessions, reset: resetAuto } = useAutoQuery(fetchList,
  () => [chatQuery.title, chatQuery.sessionType, route.meta.mode],
  { beforeLoad: () => { chatQuery.pageNum = 1 } }
)

watch(() => route.meta.mode, () => {
  chatQuery.title = ''
  chatQuery.sessionType = ''
})

function sessionTypeLabel(type) {
  if (type === 'ai') return 'AI问答'
  if (type === 'human_closed') return '人工对话'
  return '-'
}

function resetChatQuery() {
  resetAuto(() => {
    chatQuery.title = ''
    chatQuery.sessionType = ''
    chatQuery.pageNum = 1
  })
}

function goChat(row) {
  router.push({
    path: `/property/ai/chat/${row.sessionId}`,
    query: { from: isHistory.value ? 'history' : 'active' }
  })
}
</script>

<style scoped>
</style>
