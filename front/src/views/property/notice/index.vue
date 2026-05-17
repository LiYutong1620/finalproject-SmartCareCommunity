<template>
  <div>
    <el-card class="mb-16"><el-button type="primary" @click="showAdd = true">发布公告</el-button></el-card>
    <el-card>
      <el-table :data="list" v-loading="loading">
        <el-table-column prop="title" label="标题" />
        <el-table-column prop="noticeType" label="类型" width="100" />
        <el-table-column prop="pinned" label="置顶" width="70">
          <template #default="{ row }"><el-tag v-if="row.pinned">是</el-tag></template>
        </el-table-column>
        <el-table-column prop="createTime" label="时间" width="170" />
        <el-table-column label="操作" width="100">
          <template #default="{ row }">
            <el-button link type="danger" @click="handleRemove(row)">下架</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
    <el-dialog v-model="showAdd" title="发布公告" width="560px">
      <el-form :model="form" label-width="80px">
        <el-form-item label="标题"><el-input v-model="form.title" /></el-form-item>
        <el-form-item label="类型">
          <el-select v-model="form.noticeType"><el-option label="公告" value="announce" /><el-option label="停水停电" value="outage" /></el-select>
        </el-form-item>
        <el-form-item label="内容"><el-input v-model="form.content" type="textarea" rows="5" /></el-form-item>
        <el-form-item label="置顶"><el-switch v-model="form.pinned" :active-value="1" :inactive-value="0" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showAdd = false">取消</el-button>
        <el-button type="primary" @click="handleAdd">发布</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { listNotice, addNotice, removeNotice } from '@/api/community'

const loading = ref(false)
const list = ref([])
const showAdd = ref(false)
const form = reactive({ title: '', content: '', noticeType: 'announce', pinned: 0 })

async function load() {
  loading.value = true
  try {
    const res = await listNotice({ pageNum: 1, pageSize: 20 })
    list.value = res.data.rows
  } finally { loading.value = false }
}

async function handleAdd() {
  await addNotice(form)
  ElMessage.success('发布成功')
  showAdd.value = false
  load()
}

async function handleRemove(row) {
  await ElMessageBox.confirm('确认下架？')
  await removeNotice(row.noticeId)
  ElMessage.success('已下架')
  load()
}

onMounted(load)
</script>

<style scoped>.mb-16{margin-bottom:16px}</style>
