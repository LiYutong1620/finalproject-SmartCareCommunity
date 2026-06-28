<template>
  <div class="assistant-page">
    <el-row :gutter="16" class="assistant-row">
      <el-col :xs="24" :sm="8" :md="7" class="history-col">
        <el-card shadow="never" class="history-card">
          <template #header>
            <div class="history-header">
              <span>历史问答</span>
              <el-button type="primary" link @click="startNewChat">新对话</el-button>
            </div>
          </template>
          <div v-loading="historyLoading" class="history-list">
            <div
              v-for="item in sessions"
              :key="item.sessionId"
              class="history-item"
              :class="{ active: item.sessionId === currentSessionId }"
              @click="openSession(item.sessionId)"
            >
              <div class="history-title">{{ item.title || '新对话' }}</div>
              <div class="history-preview">{{ item.lastMessage || '暂无消息' }}</div>
              <div class="history-meta">
                <span>{{ item.lastTime || item.updateTime || item.createTime }}</span>
              </div>
            </div>
            <el-empty v-if="!historyLoading && sessions.length === 0" description="暂无历史记录" />
          </div>
        </el-card>
      </el-col>

      <el-col :xs="24" :sm="16" :md="17" class="chat-col">
        <el-card shadow="never" class="chat-card">
          <template #header>
            <div class="chat-header">
              <div class="chat-title">AI 智能问答</div>
              <div class="header-right">
                <el-button v-if="isHumanMode" link type="danger" @click="handleCloseSession">结束对话</el-button>
                <el-button v-if="currentSessionId" link type="primary" @click="refreshMessages">刷新消息</el-button>
              </div>
            </div>
          </template>

          <div ref="messageBoxRef" class="message-box">
            <div v-if="messages.length === 0" class="welcome-panel">
              <el-icon :size="40" color="#409eff"><ChatDotRound /></el-icon>
              <p>您好，我是社区智能助手，可解答报修、公告、缴费、装修等问题。</p>
              <div class="quick-tags">
                <el-tag v-for="q in quickQuestions" :key="q" class="quick-tag" @click="sendQuick(q)">{{ q }}</el-tag>
              </div>
            </div>
            <div
              v-for="msg in messages"
              :key="msg.messageId || msg._tempId"
              class="message-item"
              :class="msg.role === 'user' ? 'user' : (msg.role === 'staff' ? 'staff' : 'assistant')"
            >
              <div class="bubble">
                <div class="bubble-role">{{ messageRoleLabel(msg) }}</div>
                <div class="bubble-content">{{ msg.content }}</div>
                <div v-if="msg.imagePreview" class="bubble-images">
                  <el-image :src="msg.imagePreview" fit="cover" class="msg-image" :preview-src-list="[msg.imagePreview]" />
                </div>
                <div class="bubble-time">
                  {{ msg.createTime || '' }}
                </div>
              </div>
            </div>
            <div v-if="asking" class="message-item assistant">
              <div class="bubble loading-bubble">
                <el-icon class="is-loading"><Loading /></el-icon>
                正在思考...
              </div>
            </div>
          </div>

          <div v-if="!isSessionEnded" class="input-area">
            <div v-if="pendingImages.length" class="image-preview-row">
              <div v-for="(img, idx) in pendingImages" :key="idx" class="preview-item">
                <el-image :src="img.preview" fit="cover" class="preview-thumb" />
                <el-icon class="remove-icon" @click="removeImage(idx)"><Close /></el-icon>
              </div>
            </div>
            <el-input
              v-model="question"
              type="textarea"
              :rows="3"
              maxlength="500"
              show-word-limit
              placeholder="请输入您的问题，可上传图片识别故障（如漏水、跳闸）"
              @keydown.enter.exact.prevent="handleSend"
            />
            <div class="input-actions">
              <div class="left-actions">
                <el-upload
                  v-if="!isHumanMode"
                  :show-file-list="false"
                  accept="image/jpeg,image/png,image/webp"
                  :auto-upload="false"
                  :disabled="pendingImages.length >= 3"
                  @change="handleImageSelect"
                >
                  <el-button icon="Picture">上传图片</el-button>
                </el-upload>
                <el-button
                  :type="listening ? 'danger' : 'default'"
                  icon="Microphone"
                  @click="toggleVoice"
                >
                  {{ listening ? '停止录音' : '语音输入' }}
                </el-button>
              </div>
              <el-button type="primary" :loading="asking" @click="handleSend">发送</el-button>
            </div>
          </div>
          <el-alert v-else type="info" :closable="false" title="该对话已结束，请点击「新对话」开始新的咨询" class="ended-alert" />
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { ChatDotRound, Close, Loading } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { aiAsk, closeAiSession, listAiMessages, listAiSessions } from '@/api/owner'

const sessions = ref([])
const messages = ref([])
const currentSessionId = ref(null)
const question = ref('')
const asking = ref(false)
const historyLoading = ref(false)
const messageBoxRef = ref(null)
const listening = ref(false)
const pendingImages = ref([])

const quickQuestions = [
  '如何提交报修工单？',
  '怎么查看停水停电通知？',
  '物业费怎么缴纳？'
]

let recognition = null
let tempId = 0
let pollTimer = null

const isHumanMode = computed(() => {
  if (!currentSessionId.value) return false
  const session = sessions.value.find((s) => s.sessionId === currentSessionId.value)
  return session?.status === '1'
})

const isSessionEnded = computed(() => {
  if (!currentSessionId.value) return false
  const session = sessions.value.find((s) => s.sessionId === currentSessionId.value)
  return session?.status === '2'
})

onMounted(() => {
  fetchSessions()
  initSpeech()
})

onBeforeUnmount(() => {
  stopVoice()
  if (pollTimer) clearInterval(pollTimer)
  pollTimer = null
})

watch(currentSessionId, (id) => {
  if (pollTimer) clearInterval(pollTimer)
  if (id && isHumanMode.value) {
    pollTimer = setInterval(refreshMessages, 4000)
  }
})

watch(isHumanMode, (val) => {
  if (pollTimer) clearInterval(pollTimer)
  if (val && currentSessionId.value) {
    pollTimer = setInterval(refreshMessages, 4000)
  }
})

function initSpeech() {
  const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition
  if (!SpeechRecognition) {
    return
  }
  recognition = new SpeechRecognition()
  recognition.lang = 'zh-CN'
  recognition.continuous = false
  recognition.interimResults = false
  recognition.onresult = (event) => {
    question.value = event.results[0][0].transcript
    ElMessage.success('语音已填入输入框，请核对后发送')
  }
  recognition.onerror = () => {
    listening.value = false
    ElMessage.warning('语音识别失败，请重试或使用文字输入')
  }
  recognition.onend = () => {
    listening.value = false
  }
}

function toggleVoice() {
  if (!recognition) {
    ElMessage.warning('当前浏览器不支持语音识别')
    return
  }
  if (listening.value) {
    stopVoice()
    return
  }
  listening.value = true
  recognition.start()
}

function stopVoice() {
  if (recognition && listening.value) {
    recognition.stop()
  }
  listening.value = false
}

async function fetchSessions() {
  historyLoading.value = true
  try {
    const res = await listAiSessions({ pageNum: 1, pageSize: 50 })
    sessions.value = res.data.rows || []
  } finally {
    historyLoading.value = false
  }
}

async function openSession(sessionId) {
  currentSessionId.value = sessionId
  await refreshMessages()
}

async function refreshMessages() {
  if (!currentSessionId.value) return
  const res = await listAiMessages(currentSessionId.value)
  messages.value = res.data || []
  scrollToBottom()
}

async function handleCloseSession() {
  if (!currentSessionId.value || !isHumanMode.value) return
  await ElMessageBox.confirm('确认结束当前人工对话？结束后将无法继续留言。', '提示', { type: 'warning' })
  await closeAiSession(currentSessionId.value)
  ElMessage.success('对话已结束')
  await fetchSessions()
  await refreshMessages()
}

function messageRoleLabel(msg) {
  if (msg.role === 'user') return '我'
  if (msg.role === 'staff') return msg.senderName || '物业客服'
  return '智能助手'
}

function startNewChat() {
  currentSessionId.value = null
  messages.value = []
  question.value = ''
  pendingImages.value = []
}

function handleImageSelect(uploadFile) {
  const file = uploadFile.raw
  if (!file) return
  if (!file.type.startsWith('image/')) {
    ElMessage.warning('仅支持图片文件')
    return
  }
  if (file.size > 4 * 1024 * 1024) {
    ElMessage.warning('单张图片不超过 4MB')
    return
  }
  if (pendingImages.value.length >= 3) {
    ElMessage.warning('最多上传 3 张图片')
    return
  }
  const reader = new FileReader()
  reader.onload = (e) => {
    const dataUrl = e.target.result
    const base64 = String(dataUrl).includes(',') ? String(dataUrl).split(',')[1] : String(dataUrl)
    pendingImages.value.push({ preview: dataUrl, base64 })
  }
  reader.readAsDataURL(file)
}

function removeImage(index) {
  pendingImages.value.splice(index, 1)
}

function sendQuick(text) {
  question.value = text
  handleSend('text')
}

async function handleSend(inputType = 'text') {
  const q = question.value.trim()
  const images = pendingImages.value.map((i) => i.base64)
  if ((!q && images.length === 0) || asking.value || isSessionEnded.value) return

  if (isHumanMode.value && images.length > 0) {
    ElMessage.warning('人工对话中请使用文字消息')
    return
  }

  const displayContent = q || '请帮我看看图片中的问题'
  const userMsg = {
    _tempId: ++tempId,
    role: 'user',
    content: displayContent,
    inputType: images.length ? 'image' : (inputType === 'voice' ? 'voice' : 'text'),
    imagePreview: images.length ? pendingImages.value[0].preview : null,
    createTime: new Date().toLocaleString('zh-CN', { hour12: false }).replace(/\//g, '-')
  }
  messages.value.push(userMsg)
  question.value = ''
  const sendImages = [...images]
  pendingImages.value = []
  asking.value = !isHumanMode.value
  scrollToBottom()

  try {
    const res = await aiAsk({
      sessionId: currentSessionId.value,
      question: q || displayContent,
      inputType: sendImages.length ? 'image' : (inputType === 'voice' ? 'voice' : 'text'),
      images: sendImages
    })
    const data = res.data
    currentSessionId.value = data.sessionId
    if (data.message) {
      messages.value.push(data.message)
    }
    await fetchSessions()
    if (data.humanMode) {
      await refreshMessages()
    }
  } catch (e) {
    if (!isHumanMode.value) {
      messages.value.push({
        _tempId: ++tempId,
        role: 'assistant',
        content: '请求失败，请稍后重试。',
        transferHuman: false
      })
    } else {
      ElMessage.error(e?.msg || '发送失败，请重试')
    }
  } finally {
    asking.value = false
    scrollToBottom()
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
.assistant-page {
  height: calc(100vh - 120px);
  min-height: 560px;
}

.assistant-row,
.history-col,
.chat-col,
.history-card,
.chat-card {
  height: 100%;
}

.history-card,
.chat-card {
  display: flex;
  flex-direction: column;
}

.history-card :deep(.el-card__body),
.chat-card :deep(.el-card__body) {
  flex: 1;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.history-header,
.chat-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 8px;
}

.chat-title {
  font-size: 16px;
  font-weight: 600;
}

.history-list {
  height: 100%;
  overflow-y: auto;
}

.history-item {
  padding: 12px;
  border-radius: 8px;
  cursor: pointer;
  border: 1px solid transparent;
  margin-bottom: 8px;
  transition: all 0.2s;
}

.history-item:hover,
.history-item.active {
  background: #f5f9ff;
  border-color: #d9ecff;
}

.history-title {
  font-weight: 600;
  margin-bottom: 4px;
}

.history-preview {
  font-size: 12px;
  color: #606266;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.history-meta {
  margin-top: 6px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 12px;
  color: #909399;
}

.message-box {
  flex: 1;
  overflow-y: auto;
  padding: 8px 4px 16px;
  background: #fafafa;
  border-radius: 8px;
}

.welcome-panel {
  text-align: center;
  padding: 48px 16px;
  color: #606266;
}

.quick-tags {
  margin-top: 16px;
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  justify-content: center;
}

.quick-tag {
  cursor: pointer;
}

.message-item {
  display: flex;
  margin-bottom: 12px;
}

.message-item.user {
  justify-content: flex-end;
}

.message-item.assistant {
  justify-content: flex-start;
}

.message-item.staff {
  justify-content: flex-start;
}

.bubble {
  max-width: 78%;
  padding: 10px 14px;
  border-radius: 12px;
  background: #fff;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}

.message-item.user .bubble {
  background: #409eff;
  color: #fff;
}

.message-item.user .bubble-role,
.message-item.user .bubble-time {
  color: rgba(255, 255, 255, 0.85);
}

.message-item.staff .bubble {
  background: #f0f9eb;
  border: 1px solid #e1f3d8;
}

.message-item.staff .bubble-role {
  color: #67c23a;
  font-weight: 600;
}

.bubble-role {
  font-size: 12px;
  margin-bottom: 4px;
  color: #909399;
}

.bubble-content {
  white-space: pre-wrap;
  line-height: 1.6;
  word-break: break-word;
}

.transfer-tip {
  margin-top: 8px;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
}

.bubble-time {
  margin-top: 6px;
  font-size: 12px;
  color: #909399;
}

.loading-bubble {
  display: flex;
  align-items: center;
  gap: 8px;
}

.input-area {
  margin-top: 12px;
}

.image-preview-row {
  display: flex;
  gap: 8px;
  margin-bottom: 8px;
  flex-wrap: wrap;
}

.preview-item {
  position: relative;
  width: 72px;
  height: 72px;
}

.preview-thumb {
  width: 72px;
  height: 72px;
  border-radius: 8px;
  border: 1px solid #ebeef5;
}

.remove-icon {
  position: absolute;
  top: -6px;
  right: -6px;
  background: #fff;
  border-radius: 50%;
  cursor: pointer;
  color: #f56c6c;
}

.bubble-images {
  margin-top: 8px;
}

.msg-image {
  width: 120px;
  height: 90px;
  border-radius: 8px;
}

.input-actions {
  margin-top: 10px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.left-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.ended-alert {
  margin-top: 12px;
}

@media (max-width: 768px) {
  .assistant-page {
    height: auto;
    min-height: auto;
  }

  .history-col {
    margin-bottom: 12px;
  }

  .history-list {
    max-height: 220px;
  }

  .message-box {
    min-height: 360px;
  }
}
</style>
