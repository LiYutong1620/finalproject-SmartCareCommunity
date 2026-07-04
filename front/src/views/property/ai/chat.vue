<template>
  <div class="chat-page">
    <el-card shadow="never" class="chat-card">
      <template #header>
        <div class="chat-header">
          <div>
            <el-button link icon="ArrowLeft" @click="goBack">返回列表</el-button>
            <div class="chat-title">
              与 {{ sessionInfo.nickName || sessionInfo.username || '业主' }} 的对话
              <el-tag v-if="sessionInfo.status === '0'" type="primary" size="small" class="ml8">AI问答</el-tag>
              <el-tag v-else-if="sessionInfo.status === '1'" type="warning" size="small" class="ml8">进行中</el-tag>
              <el-tag v-else type="info" size="small" class="ml8">已结束</el-tag>
            </div>
            <div v-if="sessionInfo.phone" class="chat-sub">联系电话：{{ sessionInfo.phone }}</div>
          </div>
          <div class="header-actions">
            <el-button link type="primary" @click="refreshMessages">刷新</el-button>
            <el-button v-if="sessionInfo.status === '1'" type="danger" plain @click="handleClose">结束对话</el-button>
          </div>
        </div>
      </template>

      <div ref="messageBoxRef" class="message-box" v-loading="loading">
        <div
          v-for="msg in messages"
          :key="msg.messageId"
          class="message-item"
          :class="msg.role === 'user' ? 'user' : (msg.role === 'staff' ? 'staff' : 'assistant')"
        >
          <div class="bubble">
            <div class="bubble-role">{{ messageRoleLabel(msg) }}</div>
            <div class="bubble-content">{{ msg.content }}</div>
            <div class="bubble-time">{{ msg.createTime || '' }}</div>
          </div>
        </div>
        <el-empty v-if="!loading && messages.length === 0" description="暂无消息" />
      </div>

      <div class="chat-footer">
        <div v-if="sessionInfo.status === '1'" class="input-area">
          <el-input
            v-model="replyText"
            type="textarea"
            :rows="3"
            maxlength="500"
            show-word-limit
            placeholder="输入回复内容，或使用语音输入，Enter 发送"
            @keydown.enter.exact.prevent="handleSend"
          />
          <div class="input-actions">
            <el-button
              :type="listening ? 'danger' : 'default'"
              icon="Microphone"
              @click="toggleVoice"
            >
              {{ listening ? '停止录音' : '语音输入' }}
            </el-button>
            <el-button type="primary" :loading="sending" @click="handleSend">发送</el-button>
          </div>
        </div>
        <el-alert
          v-else-if="sessionInfo.status === '0'"
          type="info"
          :closable="false"
          title="AI 问答记录，仅可查看。如需优化回答，请前往知识库管理补充或调整条目。"
        />
        <el-alert v-else type="info" :closable="false" title="对话已结束，仅可查看历史记录" />
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { nextTick, onBeforeUnmount, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  closeHumanChatSession, getHumanChatSession, listHumanChatMessages, sendHumanChatMessage
} from '@/api/propertyAi'
import { useSpeechInput } from '@/composables/useSpeechInput'

const route = useRoute()
const router = useRouter()
const sessionId = Number(route.params.sessionId)

const sessionInfo = ref({})
const messages = ref([])
const replyText = ref('')
const loading = ref(false)
const sending = ref(false)
const messageBoxRef = ref(null)
let pollTimer = null

const { listening, toggleVoice, initSpeech } = useSpeechInput(replyText, {
  successMessage: '语音已填入输入框，请核对后发送',
})

onMounted(async () => {
  initSpeech()
  await loadSession()
  await refreshMessages()
  if (sessionInfo.value.status === '1') {
    pollTimer = setInterval(refreshMessages, 4000)
  }
})

onBeforeUnmount(() => {
  if (pollTimer) clearInterval(pollTimer)
})

function messageRoleLabel(msg) {
  if (msg.role === 'user') return sessionInfo.value.nickName || sessionInfo.value.username || '业主'
  if (msg.role === 'staff') return msg.senderName || '物业客服'
  return '智能助手'
}

async function loadSession() {
  const res = await getHumanChatSession(sessionId)
  sessionInfo.value = res.data || {}
}

async function refreshMessages() {
  loading.value = messages.value.length === 0
  try {
    const res = await listHumanChatMessages(sessionId)
    messages.value = res.data || []
    scrollToBottom()
  } finally {
    loading.value = false
  }
}

async function handleSend() {
  const text = replyText.value.trim()
  if (!text || sending.value) return
  sending.value = true
  try {
    const res = await sendHumanChatMessage(sessionId, text)
    messages.value.push(res.data)
    replyText.value = ''
    scrollToBottom()
  } finally {
    sending.value = false
  }
}

async function handleClose() {
  await ElMessageBox.confirm('确认结束与该业主的人工对话？', '提示', { type: 'warning' })
  await closeHumanChatSession(sessionId)
  ElMessage.success('对话已结束')
  await loadSession()
}

function goBack() {
  const from = route.query.from
  if (from === 'history') {
    router.push('/property/ai/chat-history')
  } else {
    router.push('/property/ai/chat-active')
  }
}

function scrollToBottom() {
  nextTick(() => {
    const el = messageBoxRef.value
    if (el) el.scrollTop = el.scrollHeight
  })
}
</script>

<style scoped>
.chat-page {
  box-sizing: border-box;
  padding: 16px;
  height: calc(100vh - 56px);
  min-height: 0;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.chat-card {
  flex: 1;
  min-height: 0;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.chat-card :deep(.el-card__header) {
  flex-shrink: 0;
}

.chat-card :deep(.el-card__body) {
  flex: 1;
  min-height: 0;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.chat-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
}

.chat-title {
  font-size: 16px;
  font-weight: 600;
  margin-top: 4px;
}

.chat-sub {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}

.ml8 { margin-left: 8px; }

.header-actions {
  display: flex;
  gap: 8px;
  align-items: center;
  flex-shrink: 0;
}

.message-box {
  flex: 1;
  min-height: 0;
  overflow-x: hidden;
  overflow-y: auto;
  padding: 12px 8px;
  background: #fafafa;
  border-radius: 8px;
}

.chat-footer {
  flex-shrink: 0;
  margin-top: 12px;
}

.message-item {
  display: flex;
  margin-bottom: 12px;
}

.message-item.user { justify-content: flex-start; }
.message-item.staff, .message-item.assistant { justify-content: flex-end; }

.bubble {
  max-width: 72%;
  padding: 10px 14px;
  border-radius: 12px;
  background: #fff;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}

.message-item.staff .bubble {
  background: #f0f9eb;
  border: 1px solid #e1f3d8;
}

.message-item.assistant .bubble {
  background: #ecf5ff;
  border: 1px solid #d9ecff;
}

.bubble-role {
  font-size: 12px;
  margin-bottom: 4px;
  color: #909399;
}

.message-item.staff .bubble-role { color: #67c23a; font-weight: 600; }

.bubble-content {
  white-space: pre-wrap;
  line-height: 1.6;
  word-break: break-word;
  overflow-wrap: anywhere;
}

.bubble-time {
  margin-top: 6px;
  font-size: 12px;
  color: #909399;
}

.input-actions {
  margin-top: 10px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  flex-wrap: wrap;
}
</style>
