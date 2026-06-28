<template>
  <div class="app-container">
    <el-form :inline="true" class="search-form">
      <el-form-item label="标题">
        <el-input v-model="kbQuery.title" placeholder="请输入标题" clearable style="width:180px" />
      </el-form-item>
      <el-form-item label="关键词">
        <el-input v-model="kbQuery.keywords" placeholder="请输入关键词" clearable style="width:180px" />
      </el-form-item>
      <el-form-item label="正文">
        <el-input v-model="kbQuery.content" placeholder="请输入正文关键词" clearable style="width:180px" />
      </el-form-item>
      <el-form-item>
        <el-button icon="Refresh" @click="resetKbQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="openKbForm()">新增条目</el-button>
      </el-col>
    </el-row>

    <el-card shadow="never" class="table-card">
      <el-table v-loading="kbLoading" :data="kbList" border stripe>
        <el-table-column type="index" label="序号" width="60" align="center" />
        <el-table-column prop="title" label="标题" min-width="180" show-overflow-tooltip />
        <el-table-column prop="keywords" label="关键词" min-width="160" show-overflow-tooltip />
        <el-table-column prop="createTime" label="创建时间" width="170" align="center" />
        <el-table-column label="操作" width="160" align="center" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="openKbForm(row)">编辑</el-button>
            <el-button link type="danger" @click="removeKb(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <Pagination
        v-show="kbTotal > 0"
        :total="kbTotal"
        v-model:page="kbQuery.pageNum"
        v-model:limit="kbQuery.pageSize"
        @pagination="loadKnowledge"
      />
    </el-card>

    <el-dialog v-model="kbDlg" :title="kbForm.articleId ? '编辑知识库' : '新增知识库'" width="640px" append-to-body destroy-on-close>
      <el-form ref="kbFormRef" :model="kbForm" :rules="kbRules" label-width="80px">
        <el-form-item label="标题" prop="title">
          <el-input v-model="kbForm.title" maxlength="128" show-word-limit placeholder="请输入标题" />
        </el-form-item>
        <el-form-item label="关键词" prop="keywords">
          <el-input v-model="kbForm.keywords" maxlength="255" placeholder="多个关键词用逗号分隔，便于检索匹配" />
        </el-form-item>
        <el-form-item label="正文" prop="content">
          <el-input v-model="kbForm.content" type="textarea" :rows="8" placeholder="请输入知识库正文" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="kbDlg = false">取消</el-button>
        <el-button type="primary" :loading="kbSaving" @click="submitKb">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { addAiKnowledge, deleteAiKnowledge, listAiKnowledge, updateAiKnowledge } from '@/api/propertyAi'
import { useAutoQuery } from '@/composables/useAutoQuery'

const kbQuery = reactive({ pageNum: 1, pageSize: 10, title: '', keywords: '', content: '' })
const kbList = ref([])
const kbTotal = ref(0)
const kbDlg = ref(false)
const kbSaving = ref(false)
const kbFormRef = ref(null)
const kbForm = reactive({ articleId: null, title: '', keywords: '', content: '' })
const kbRules = {
  title: [{ required: true, message: '请输入标题', trigger: 'blur' }],
  content: [{ required: true, message: '请输入正文', trigger: 'blur' }]
}

async function fetchList() {
  const params = { pageNum: kbQuery.pageNum, pageSize: kbQuery.pageSize }
  if (kbQuery.title?.trim()) params.title = kbQuery.title.trim()
  if (kbQuery.keywords?.trim()) params.keywords = kbQuery.keywords.trim()
  if (kbQuery.content?.trim()) params.content = kbQuery.content.trim()
  const res = await listAiKnowledge(params)
  kbList.value = res.data.rows
  kbTotal.value = res.data.total
}

const { loading: kbLoading, load: loadKnowledge, reset: resetAuto } = useAutoQuery(fetchList,
  () => [kbQuery.title, kbQuery.keywords, kbQuery.content],
  { beforeLoad: () => { kbQuery.pageNum = 1 } }
)

function resetKbQuery() {
  resetAuto(() => {
    kbQuery.title = ''
    kbQuery.keywords = ''
    kbQuery.content = ''
    kbQuery.pageNum = 1
  })
}

function openKbForm(row) {
  if (row) {
    kbForm.articleId = row.articleId
    kbForm.title = row.title
    kbForm.keywords = row.keywords || ''
    kbForm.content = row.content
  } else {
    kbForm.articleId = null
    kbForm.title = ''
    kbForm.keywords = ''
    kbForm.content = ''
  }
  kbDlg.value = true
}

async function submitKb() {
  await kbFormRef.value.validate()
  kbSaving.value = true
  try {
    const data = { title: kbForm.title, keywords: kbForm.keywords, content: kbForm.content }
    if (kbForm.articleId) {
      await updateAiKnowledge({ ...data, articleId: kbForm.articleId })
    } else {
      await addAiKnowledge(data)
    }
    ElMessage.success('保存成功')
    kbDlg.value = false
    loadKnowledge()
  } finally {
    kbSaving.value = false
  }
}

async function removeKb(row) {
  await ElMessageBox.confirm(`确认删除「${row.title}」？`, '提示', { type: 'warning' })
  await deleteAiKnowledge(row.articleId)
  ElMessage.success('删除成功')
  loadKnowledge()
}
</script>

<style scoped>
.mb8 { margin-bottom: 8px; }
</style>
