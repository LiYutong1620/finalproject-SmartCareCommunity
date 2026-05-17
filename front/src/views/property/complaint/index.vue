<template>
  <el-card>
    <el-table :data="list" v-loading="loading">
      <el-table-column prop="complaintNo" label="编号" width="160" />
      <el-table-column prop="title" label="标题" />
      <el-table-column prop="category" label="分类" width="80" />
      <el-table-column prop="status" label="状态" width="90" />
      <el-table-column label="操作" width="180">
        <template #default="{ row }">
          <el-button v-if="row.status === 'pending'" link @click="handleProcess(row)">受理</el-button>
          <el-button v-if="row.status === 'processing'" link type="primary" @click="openReply(row)">回复</el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-dialog v-model="replyVisible" title="回复投诉" width="480px">
      <el-input v-model="replyContent" type="textarea" rows="4" placeholder="回复内容" />
      <template #footer>
        <el-button @click="replyVisible = false">取消</el-button>
        <el-button type="primary" @click="submitReply">提交</el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { listPropertyComplaint, handleComplaint, replyComplaint } from '@/api/community'

const loading = ref(false)
const list = ref([])
const replyVisible = ref(false)
const replyContent = ref('')
const currentId = ref(null)

async function load() {
  loading.value = true
  try {
    const res = await listPropertyComplaint({ pageNum: 1, pageSize: 20 })
    list.value = res.data.rows
  } finally { loading.value = false }
}

async function handleProcess(row) {
  await handleComplaint({ complaintId: row.complaintId, status: 'processing' })
  ElMessage.success('已受理')
  load()
}

function openReply(row) {
  currentId.value = row.complaintId
  replyContent.value = ''
  replyVisible.value = true
}

async function submitReply() {
  await replyComplaint({ complaintId: currentId.value, reply: replyContent.value })
  ElMessage.success('回复成功')
  replyVisible.value = false
  load()
}

onMounted(load)
</script>
