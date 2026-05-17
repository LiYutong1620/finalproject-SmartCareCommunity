<template>
  <div>
    <el-card class="mb-16"><el-button type="primary" @click="showAdd = true">提交投诉建议</el-button></el-card>
    <el-card>
      <el-table :data="list" v-loading="loading">
        <el-table-column prop="complaintNo" label="编号" width="160" />
        <el-table-column prop="title" label="标题" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">{{ { pending:'待处理', processing:'处理中', replied:'已回复' }[row.status] }}</template>
        </el-table-column>
        <el-table-column prop="reply" label="回复" show-overflow-tooltip />
        <el-table-column prop="createTime" label="提交时间" width="170" />
      </el-table>
    </el-card>
    <el-dialog v-model="showAdd" title="投诉建议" width="500px">
      <el-form :model="form" label-width="80px">
        <el-form-item label="标题"><el-input v-model="form.title" /></el-form-item>
        <el-form-item label="分类">
          <el-select v-model="form.category"><el-option label="噪音" value="noise" /><el-option label="卫生" value="hygiene" /><el-option label="治安" value="security" /><el-option label="其他" value="other" /></el-select>
        </el-form-item>
        <el-form-item label="内容"><el-input v-model="form.content" type="textarea" rows="4" /></el-form-item>
        <el-form-item label="匿名"><el-switch v-model="form.anonymous" :active-value="1" :inactive-value="0" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showAdd = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">提交</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { listOwnerComplaint, submitComplaint } from '@/api/community'

const loading = ref(false)
const list = ref([])
const showAdd = ref(false)
const form = reactive({ title: '', category: 'other', content: '', anonymous: 0 })

async function load() {
  loading.value = true
  try {
    const res = await listOwnerComplaint({ pageNum: 1, pageSize: 20 })
    list.value = res.data.rows
  } finally { loading.value = false }
}

async function handleSubmit() {
  await submitComplaint(form)
  ElMessage.success('提交成功')
  showAdd.value = false
  load()
}

onMounted(load)
</script>

<style scoped>.mb-16{margin-bottom:16px}</style>
