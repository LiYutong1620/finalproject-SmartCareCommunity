<template>
  <div class="app-container">
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain :loading="syncingNotices" @click="handleSyncNotices">
          同步公告知识点
        </el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="success" plain :loading="miningChats" @click="handleMineChats">
          挖掘咨询记录
        </el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="warning" plain :loading="importingDocs" @click="triggerFilePick">
          上传文档
        </el-button>
        <el-button type="warning" plain :loading="importingDocs" @click="triggerFolderPick">
          上传文件夹
        </el-button>
        <input ref="fileInputRef" type="file" multiple accept=".docx,.pdf,.txt" class="hidden-input" @change="handleFilesSelected" />
        <input ref="folderInputRef" type="file" webkitdirectory multiple class="hidden-input" @change="handleFilesSelected" />
      </el-col>
    </el-row>

    <el-form :inline="true" class="search-form">
      <el-form-item label="标题">
        <el-input v-model="draftQuery.title" placeholder="标题关键词" clearable style="width:160px" />
      </el-form-item>
      <el-form-item label="来源">
        <el-select v-model="draftQuery.sourceType" clearable placeholder="全部" style="width:120px">
          <el-option label="公告" value="notice" />
          <el-option label="咨询" value="chat" />
          <el-option label="文档" value="document" />
        </el-select>
      </el-form-item>
      <el-form-item label="状态">
        <el-select v-model="draftQuery.status" clearable placeholder="全部" style="width:120px">
          <el-option label="待审核" value="0" />
          <el-option label="已采纳" value="1" />
          <el-option label="已拒绝" value="2" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button icon="Refresh" @click="resetDraftQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-card shadow="never" class="table-card">
      <el-table v-loading="draftLoading" :data="draftList" border stripe>
        <el-table-column type="index" label="序号" width="60" align="center" />
        <el-table-column prop="title" label="标题" min-width="160" show-overflow-tooltip />
        <el-table-column prop="keywords" label="关键词" min-width="140" show-overflow-tooltip />
        <el-table-column label="来源" width="100" align="center">
          <template #default="{ row }">
            <el-tag size="small" :type="sourceTagType(row.sourceType)">{{ sourceLabel(row.sourceType) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="来源说明" min-width="140" show-overflow-tooltip>
          <template #default="{ row }">{{ formatSource(row) }}</template>
        </el-table-column>
        <el-table-column label="状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag size="small" :type="statusTagType(row.status)">{{ statusLabel(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="生成时间" width="170" align="center" />
        <el-table-column label="操作" width="200" align="center" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="openDraft(row)">查看</el-button>
            <template v-if="row.status === '0'">
              <el-button link type="success" @click="handleApprove(row)">采纳</el-button>
              <el-button link type="danger" @click="handleReject(row)">拒绝</el-button>
              <el-button link type="primary" @click="openEdit(row)">编辑</el-button>
            </template>
            <el-button v-if="row.status !== '0'" link type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <Pagination
        v-show="draftTotal > 0"
        :total="draftTotal"
        v-model:page="draftQuery.pageNum"
        v-model:limit="draftQuery.pageSize"
        @pagination="loadDrafts"
      />
    </el-card>

    <el-dialog v-model="viewDlg" title="草稿详情" width="640px" append-to-body destroy-on-close>
      <el-descriptions v-if="viewRow" :column="1" border>
        <el-descriptions-item label="标题">{{ viewRow.title }}</el-descriptions-item>
        <el-descriptions-item label="关键词">{{ viewRow.keywords || '-' }}</el-descriptions-item>
        <el-descriptions-item label="来源">{{ formatSource(viewRow) }}</el-descriptions-item>
        <el-descriptions-item label="正文"><div class="content-pre">{{ viewRow.content }}</div></el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <el-button @click="viewDlg = false">关闭</el-button>
        <el-button v-if="viewRow?.status === '0'" type="success" @click="handleApprove(viewRow)">采纳入库</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="editDlg" title="编辑草稿" width="640px" append-to-body destroy-on-close>
      <el-form ref="editFormRef" :model="editForm" :rules="editRules" label-width="80px">
        <el-form-item label="标题" prop="title">
          <el-input v-model="editForm.title" maxlength="128" show-word-limit />
        </el-form-item>
        <el-form-item label="关键词">
          <el-input v-model="editForm.keywords" maxlength="255" />
        </el-form-item>
        <el-form-item label="正文" prop="content">
          <el-input v-model="editForm.content" type="textarea" :rows="8" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="editDlg = false">取消</el-button>
        <el-button type="primary" :loading="editSaving" @click="submitEdit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  approveKbDraft, deleteKbDraft, importKbDocs, listKbLearnDrafts,
  mineKbFromChats, rejectKbDraft, syncKbFromNotices, updateKbDraft
} from '@/api/propertyAi'
import { useAutoQuery } from '@/composables/useAutoQuery'

const draftQuery = reactive({ pageNum: 1, pageSize: 10, title: '', sourceType: '', status: '0' })
const draftList = ref([])
const draftTotal = ref(0)
const syncingNotices = ref(false)
const miningChats = ref(false)
const importingDocs = ref(false)
const fileInputRef = ref(null)
const folderInputRef = ref(null)
const viewDlg = ref(false)
const viewRow = ref(null)
const editDlg = ref(false)
const editSaving = ref(false)
const editFormRef = ref(null)
const editForm = reactive({ draftId: null, title: '', keywords: '', content: '' })
const editRules = {
  title: [{ required: true, message: '请输入标题', trigger: 'blur' }],
  content: [{ required: true, message: '请输入正文', trigger: 'blur' }]
}

async function fetchList() {
  const params = { pageNum: draftQuery.pageNum, pageSize: draftQuery.pageSize }
  if (draftQuery.title?.trim()) params.title = draftQuery.title.trim()
  if (draftQuery.sourceType) params.sourceType = draftQuery.sourceType
  if (draftQuery.status !== '' && draftQuery.status != null) params.status = draftQuery.status
  const res = await listKbLearnDrafts(params)
  draftList.value = res.data.rows
  draftTotal.value = res.data.total
}

const { loading: draftLoading, load: loadDrafts, reset: resetAuto } = useAutoQuery(fetchList,
  () => [draftQuery.title, draftQuery.sourceType, draftQuery.status],
  { beforeLoad: () => { draftQuery.pageNum = 1 } }
)

function resetDraftQuery() {
  resetAuto(() => {
    draftQuery.title = ''
    draftQuery.sourceType = ''
    draftQuery.status = '0'
    draftQuery.pageNum = 1
  })
}

function sourceLabel(type) {
  if (type === 'notice') return '公告'
  if (type === 'chat') return '咨询'
  if (type === 'document') return '文档'
  return type || '-'
}

function formatSource(row) {
  if (!row) return '-'
  let ref = row.sourceRef || ''
  if (row.sourceType === 'notice' && ref.startsWith('公告：')) {
    ref = ref.substring(3)
  }
  if (row.sourceType === 'notice') {
    return ref ? `公告：${ref}` : '公告'
  }
  if (row.sourceType === 'chat') {
    return ref || '咨询记录'
  }
  if (row.sourceType === 'document') {
    return ref ? `文档：${ref}` : '文档'
  }
  return ref || sourceLabel(row.sourceType)
}

function sourceTagType(type) {
  if (type === 'notice') return 'primary'
  if (type === 'chat') return 'success'
  if (type === 'document') return 'warning'
  return 'info'
}

function statusLabel(status) {
  if (status === '1') return '已采纳'
  if (status === '2') return '已拒绝'
  return '待审核'
}

function statusTagType(status) {
  if (status === '1') return 'success'
  if (status === '2') return 'info'
  return 'warning'
}

async function handleSyncNotices() {
  syncingNotices.value = true
  try {
    const res = await syncKbFromNotices()
    ElMessage.success(`已从公告抽取 ${res.data.count || 0} 条待审核知识点`)
    loadDrafts()
  } finally {
    syncingNotices.value = false
  }
}

async function handleMineChats() {
  miningChats.value = true
  try {
    const res = await mineKbFromChats()
    ElMessage.success(`已从咨询记录提炼 ${res.data.count || 0} 条待审核问答`)
    loadDrafts()
  } finally {
    miningChats.value = false
  }
}

function triggerFilePick() {
  fileInputRef.value?.click()
}

function triggerFolderPick() {
  folderInputRef.value?.click()
}

async function handleFilesSelected(event) {
  const files = Array.from(event.target.files || []).filter(f => {
    const name = f.name.toLowerCase()
    return name.endsWith('.docx') || name.endsWith('.pdf') || name.endsWith('.txt')
  })
  event.target.value = ''
  if (files.length === 0) {
    ElMessage.warning('请选择 .docx / .pdf / .txt 文件')
    return
  }
  importingDocs.value = true
  try {
    const res = await importKbDocs(files)
    ElMessage.success(`已从 ${files.length} 个文件抽取 ${res.data.count || 0} 条知识点`)
    loadDrafts()
  } finally {
    importingDocs.value = false
  }
}

function openDraft(row) {
  viewRow.value = row
  viewDlg.value = true
}

function openEdit(row) {
  editForm.draftId = row.draftId
  editForm.title = row.title
  editForm.keywords = row.keywords || ''
  editForm.content = row.content
  editDlg.value = true
}

async function submitEdit() {
  await editFormRef.value.validate()
  editSaving.value = true
  try {
    await updateKbDraft({ ...editForm })
    ElMessage.success('已保存')
    editDlg.value = false
    loadDrafts()
  } finally {
    editSaving.value = false
  }
}

async function handleApprove(row) {
  await ElMessageBox.confirm(`确认采纳「${row.title}」并写入正式知识库？`, '采纳确认', { type: 'info' })
  await approveKbDraft(row.draftId)
  ElMessage.success('已采纳入库')
  viewDlg.value = false
  loadDrafts()
}

async function handleReject(row) {
  await ElMessageBox.confirm(`确认拒绝「${row.title}」？`, '提示', { type: 'warning' })
  await rejectKbDraft(row.draftId)
  ElMessage.success('已拒绝')
  viewDlg.value = false
  loadDrafts()
}

async function handleDelete(row) {
  await ElMessageBox.confirm(`确认删除草稿「${row.title}」？`, '提示', { type: 'warning' })
  await deleteKbDraft(row.draftId)
  ElMessage.success('已删除')
  loadDrafts()
}
</script>

<style scoped>
.mb8 { margin-bottom: 8px; }
.hidden-input { display: none; }
.content-pre { white-space: pre-wrap; line-height: 1.6; }
</style>
