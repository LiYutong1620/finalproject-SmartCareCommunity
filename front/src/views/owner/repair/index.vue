<template>
  <div class="repair-page app-container">
    <div class="page-header">
      <h2 class="page-title">报修工单</h2>
      <el-button type="primary" size="large" icon="Plus" @click="openSubmit">提交报修</el-button>
    </div>

    <div class="filter-bar">
      <el-radio-group v-model="activeTab">
        <el-radio-button v-for="tab in repairTabs" :key="tab.value" :value="tab.value">
          {{ tab.label }}
        </el-radio-button>
      </el-radio-group>
    </div>

    <div v-loading="loading" class="order-list">
      <div
        v-for="row in list"
        :key="row.orderId"
        class="order-card"
      >
        <div class="card-main">
          <div class="card-top">
            <el-tag
              :type="repairStatusTagType(row.status) || undefined"
              :class="repairStatusTagClass(row.status)"
              size="small"
              effect="plain"
              round
            >
              {{ repairStatusLabel(row.status) }}
            </el-tag>
            <span v-if="row.aiTypeLabel" class="type-chip">{{ row.aiTypeLabel }}</span>
          </div>
          <p class="card-desc">{{ row.description }}</p>
          <div class="card-meta">
            <span class="meta-item">
              <el-icon><Clock /></el-icon>
              报修时间 {{ row.createTime }}
            </span>
          </div>
        </div>
        <div class="card-actions">
          <el-button link type="primary" @click="openDetail(row)">详情</el-button>
          <el-button v-if="canEditOrder(row)" link type="warning" @click="openEdit(row)">编辑</el-button>
          <el-button v-if="canAppendOrder(row)" link type="warning" @click="openAppend(row)">补充</el-button>
          <el-button v-if="row.status === 'wait_accept'" link type="success" @click="openAccept(row)">验收</el-button>
          <el-button v-if="canCancelOrder(row)" link type="danger" @click="handleCancel(row)">取消</el-button>
        </div>
      </div>

      <el-empty v-if="!loading && list.length === 0" :description="emptyText" />
    </div>

    <Pagination
      v-show="total > 0"
      :total="total"
      v-model:page="query.pageNum"
      v-model:limit="query.pageSize"
      @pagination="load"
    />

    <!-- 提交报修 -->
    <el-dialog v-model="showAdd" title="提交报修" width="580px" append-to-body @closed="resetSubmit">
      <el-form :model="form" label-width="96px">
        <el-form-item label="故障描述" required>
          <div class="desc-field">
            <el-input
              v-model="form.description"
              type="textarea"
              :rows="4"
              placeholder="请描述故障情况，或点击麦克风语音输入"
            />
            <el-button
              class="voice-btn"
              :type="listening ? 'danger' : 'default'"
              circle
              @click="toggleVoice"
            >
              <el-icon><Microphone /></el-icon>
            </el-button>
          </div>
          <div v-if="listening" class="voice-tip">正在聆听，请说话…</div>
        </el-form-item>
        <el-form-item label="现场图片">
          <ImageUploader v-model="form.images" :max-count="9" />
        </el-form-item>
        <el-form-item label="期望时间">
          <el-date-picker
            v-model="form.expectedTime"
            type="datetime"
            placeholder="选填，期望维修工上门维修时间"
            value-format="YYYY-MM-DD HH:mm:ss"
            :disabled-date="submitTimeDisabled.disabledDate"
            :disabled-hours="submitTimeDisabled.disabledHours"
            :disabled-minutes="submitTimeDisabled.disabledMinutes"
            style="width: 100%"
            @change="val => onSubmitExpectedTimeChange(val)"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showAdd = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">提交</el-button>
      </template>
    </el-dialog>

    <!-- 编辑报修（待接单） -->
    <el-dialog
      v-model="showEdit"
      title="编辑报修"
      width="600px"
      append-to-body
      class="repair-form-dialog"
      @closed="resetEdit"
    >
      <el-form :model="editForm" label-width="88px" class="repair-edit-form">
        <el-form-item label="故障描述" required>
          <el-input
            v-model="editForm.description"
            type="textarea"
            :rows="4"
            placeholder="请描述故障情况"
            maxlength="500"
            show-word-limit
          />
        </el-form-item>
        <el-form-item label="期望时间">
          <el-date-picker
            v-model="editForm.expectedTime"
            type="datetime"
            placeholder="选填，期望维修工上门维修时间"
            value-format="YYYY-MM-DD HH:mm:ss"
            :disabled-date="editTimeDisabled.disabledDate"
            :disabled-hours="editTimeDisabled.disabledHours"
            :disabled-minutes="editTimeDisabled.disabledMinutes"
            style="width: 100%"
            @change="val => onEditExpectedTimeChange(val)"
          />
        </el-form-item>
        <el-form-item label="现场图片">
          <div class="edit-images-panel">
            <div v-if="editForm.keptImages.length || editForm.images.length" class="edit-images">
              <div
                v-for="(img, idx) in editForm.keptImages"
                :key="img.imageId"
                class="edit-image-item"
              >
                <img
                  :src="resolveImageUrl(img.imageUrl)"
                  class="edit-thumb"
                  alt="现场图片"
                  @click="openKeptImagePreview(idx)"
                />
                <button
                  type="button"
                  class="edit-image-del"
                  title="删除图片"
                  @click.stop="removeKeptImage(img.imageId)"
                >
                  <el-icon><Delete /></el-icon>
                </button>
              </div>
              <ImageUploader
                v-model="editForm.images"
                :max-count="editUploaderMax"
                storage-key="__repairEditFiles"
              />
            </div>
            <ImageUploader
              v-else
              v-model="editForm.images"
              :max-count="editUploaderMax"
              storage-key="__repairEditFiles"
            />
            <p class="field-hint">最多9张</p>
          </div>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showEdit = false">取消</el-button>
        <el-button type="primary" :loading="editing" @click="handleEdit">保存</el-button>
      </template>
    </el-dialog>

    <!-- 补充信息（处理中） -->
    <el-dialog v-model="showAppend" title="补充信息" width="560px" append-to-body @closed="resetAppend">
      <p class="append-hint">追加的信息将通知维修工，便于了解最新情况。</p>
      <el-form :model="appendForm" label-width="80px">
        <el-form-item label="追加描述">
          <el-input
            v-model="appendForm.description"
            type="textarea"
            :rows="4"
            placeholder="补充说明新情况，如故障加重、临时不在家等"
          />
        </el-form-item>
        <el-form-item label="追加图片">
          <ImageUploader v-model="appendForm.images" :max-count="9" storage-key="__repairAppendFiles" />
          <p class="field-hint">最多9张</p>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showAppend = false">取消</el-button>
        <el-button type="primary" :loading="appending" @click="handleAppend">确认补充</el-button>
      </template>
    </el-dialog>

    <RepairOrderDrawer
      v-model:visible="detailVisible"
      :order-id="detailOrderId"
      ref="drawerRef"
      @edit="onDrawerEdit"
      @append="onDrawerAppend"
      @accept="openAccept"
      @cancel="handleCancel"
    />

    <ElImageViewer
      v-if="keptPreviewVisible"
      :url-list="keptPreviewUrls"
      :initial-index="keptPreviewIndex"
      :z-index="4000"
      teleported
      @close="keptPreviewVisible = false"
    />

    <RepairAcceptDrawer
      v-model:visible="acceptVisible"
      :order-id="acceptOrderId"
      @success="onAcceptSuccess"
    />
  </div>
</template>

<script setup>
import { ref, reactive, computed, watch, onMounted, toRef } from 'vue'
import { ElMessage, ElMessageBox, ElImageViewer } from 'element-plus'
import {
  listOwnerRepair,
  getOrderDetail,
  submitRepair,
  submitRepairWithFiles,
  cancelRepair,
  editRepair,
  appendRepair
} from '@/api/repair'
import { useSpeechInput } from '@/composables/useSpeechInput'
import {
  OWNER_REPAIR_TABS,
  repairStatusLabel,
  repairStatusTagType,
  repairStatusTagClass,
  canEditOrder,
  canCancelOrder,
  canAppendOrder
} from '@/utils/repairLabels'
import {
  createExpectedTimeDisabled,
  handleExpectedTimeChange,
  isExpectedTimeValid,
  warnInvalidExpectedTime
} from './utils/expectedTime'
import ImageUploader from './components/ImageUploader.vue'
import RepairOrderDrawer from './components/RepairOrderDrawer.vue'
import RepairAcceptDrawer from './components/RepairAcceptDrawer.vue'

const loading = ref(false)
const submitting = ref(false)
const editing = ref(false)
const appending = ref(false)
const list = ref([])
const total = ref(0)
const showAdd = ref(false)
const showEdit = ref(false)
const showAppend = ref(false)
const detailVisible = ref(false)
const detailOrderId = ref(null)
const drawerRef = ref(null)
const editTarget = ref(null)
const appendTarget = ref(null)
const repairTabs = OWNER_REPAIR_TABS
const activeTab = ref('all')

const query = reactive({ pageNum: 1, pageSize: 10 })
const form = reactive({ description: '', expectedTime: '', images: [] })
const editForm = reactive({ description: '', expectedTime: '', images: [], keptImages: [] })
const appendForm = reactive({ description: '', images: [] })

const submitTimeDisabled = createExpectedTimeDisabled(() => form.expectedTime)
const editTimeDisabled = createExpectedTimeDisabled(() => editForm.expectedTime)

const editUploaderMax = computed(() => Math.max(0, 9 - editForm.keptImages.length))

const keptPreviewUrls = computed(() =>
  editForm.keptImages.map(img => resolveImageUrl(img.imageUrl))
)
const keptPreviewVisible = ref(false)
const keptPreviewIndex = ref(0)
const acceptVisible = ref(false)
const acceptOrderId = ref(null)

const { listening, toggleVoice, stopVoice, initSpeech } = useSpeechInput(toRef(form, 'description'), {
  successMessage: '语音已填入描述框，请核对后提交'
})

const emptyText = computed(() => {
  const tab = repairTabs.find(t => t.value === activeTab.value)
  return tab && tab.value !== 'all' ? `暂无「${tab.label}」工单` : '暂无报修记录'
})

watch(activeTab, () => {
  query.pageNum = 1
  load()
})

onMounted(() => {
  load()
  initSpeech()
})

function resolveImageUrl(url) {
  if (!url) return ''
  if (url.startsWith('http') || url.startsWith('data:')) return url
  return '/api' + url
}

function buildListParams() {
  const params = { pageNum: query.pageNum, pageSize: query.pageSize }
  if (activeTab.value !== 'all') {
    params.status = activeTab.value
  }
  return params
}

async function load() {
  loading.value = true
  try {
    const res = await listOwnerRepair(buildListParams())
    list.value = res.data.rows
    total.value = res.data.total
  } finally {
    loading.value = false
  }
}

function openSubmit() {
  resetSubmit()
  showAdd.value = true
}

function resetSubmit() {
  stopVoice()
  form.description = ''
  form.expectedTime = ''
  form.images = []
  window.__repairFiles = []
}

function resetEditForm() {
  editForm.description = ''
  editForm.expectedTime = ''
  editForm.images = []
  editForm.keptImages = []
  keptPreviewVisible.value = false
  window.__repairEditFiles = []
}

function resetEdit() {
  resetEditForm()
  editTarget.value = null
}

function resetAppendForm() {
  appendForm.description = ''
  appendForm.images = []
  window.__repairAppendFiles = []
}

function resetAppend() {
  resetAppendForm()
  appendTarget.value = null
}

function onSubmitExpectedTimeChange(val) {
  handleExpectedTimeChange(val, () => { form.expectedTime = '' })
}

function onEditExpectedTimeChange(val) {
  handleExpectedTimeChange(val, () => { editForm.expectedTime = '' })
}

function removeKeptImage(imageId) {
  editForm.keptImages = editForm.keptImages.filter(img => img.imageId !== imageId)
}

function openKeptImagePreview(index) {
  keptPreviewIndex.value = index
  keptPreviewVisible.value = true
}

async function handleSubmit() {
  if (!form.description?.trim()) {
    ElMessage.warning('请填写故障描述')
    return
  }
  if (form.expectedTime && !isExpectedTimeValid(form.expectedTime)) {
    warnInvalidExpectedTime()
    return
  }
  submitting.value = true
  try {
    const payload = {
      description: form.description.trim(),
      expectedTime: form.expectedTime || undefined
    }
    const files = window.__repairFiles || []
    if (files.length) {
      const fd = new FormData()
      fd.append('description', payload.description)
      if (payload.expectedTime) fd.append('expectedTime', payload.expectedTime)
      files.forEach(f => fd.append('files', f))
      await submitRepairWithFiles(fd)
    } else {
      await submitRepair(payload)
    }
    ElMessage.success('提交成功')
    showAdd.value = false
    resetSubmit()
    activeTab.value = 'pending'
    query.pageNum = 1
    load()
  } finally {
    submitting.value = false
  }
}

async function openEdit(row) {
  resetEditForm()
  editTarget.value = row
  showEdit.value = true
  try {
    const res = await getOrderDetail(row.orderId)
    const order = res.data.order || {}
    editForm.description = order.description || ''
    editForm.expectedTime = order.expectedTime || ''
    editForm.keptImages = (res.data.images || []).map(img => ({ ...img }))
  } catch {
    editForm.description = row.description || ''
  }
}

async function handleEdit() {
  if (!editTarget.value?.orderId) {
    ElMessage.error('工单信息丢失，请关闭后重新编辑')
    return
  }
  if (!editForm.description?.trim()) {
    ElMessage.warning('请填写故障描述')
    return
  }
  if (editForm.expectedTime && !isExpectedTimeValid(editForm.expectedTime)) {
    warnInvalidExpectedTime()
    return
  }
  const files = window.__repairEditFiles || []
  editing.value = true
  try {
    await editRepair(editTarget.value.orderId, {
      description: editForm.description.trim(),
      expectedTime: editForm.expectedTime || undefined,
      files,
      keepImageIds: editForm.keptImages.map(img => img.imageId)
    })
    ElMessage.success('保存成功')
    showEdit.value = false
    load()
    if (detailVisible.value && detailOrderId.value === editTarget.value.orderId) {
      drawerRef.value?.reload?.()
    }
  } catch {
    // 错误已由 request 拦截器提示
  } finally {
    editing.value = false
  }
}

function openAppend(row) {
  resetAppendForm()
  appendTarget.value = row
  showAppend.value = true
}

async function handleAppend() {
  if (!appendTarget.value?.orderId) {
    ElMessage.error('工单信息丢失，请关闭后重新操作')
    return
  }
  if (
    !appendForm.description?.trim() &&
    (!window.__repairFiles || window.__repairFiles.length === 0)
  ) {
    ElMessage.warning('请填写追加内容或上传图片')
    return
  }
  appending.value = true
  try {
    await appendRepair(appendTarget.value.orderId, {
      description: appendForm.description,
      files: window.__repairAppendFiles || []
    })
    ElMessage.success('补充成功，已通知维修工')
    showAppend.value = false
    load()
    if (detailVisible.value && detailOrderId.value === appendTarget.value.orderId) {
      drawerRef.value?.reload?.()
    }
  } catch {
    // 错误已由 request 拦截器提示
  } finally {
    appending.value = false
  }
}

function openDetail(row) {
  detailOrderId.value = row.orderId
  detailVisible.value = true
}

function onDrawerEdit(order) {
  detailVisible.value = false
  openEdit(order)
}

function onDrawerAppend(order) {
  detailVisible.value = false
  openAppend(order)
}

function openAccept(row) {
  detailVisible.value = false
  acceptOrderId.value = row.orderId
  acceptVisible.value = true
}

function onAcceptSuccess() {
  load()
  if (detailOrderId.value && acceptOrderId.value === detailOrderId.value) {
    drawerRef.value?.reload?.()
  }
}

async function handleCancel(row) {
  await ElMessageBox.confirm('确认取消该报修？取消后工单状态将变为「已取消」。', '提示', { type: 'warning' })
  await cancelRepair(row.orderId)
  ElMessage.success('已取消')
  if (detailVisible.value && detailOrderId.value === row.orderId) {
    detailVisible.value = false
  }
  load()
}
</script>

<style scoped>
.repair-page {
  max-width: 960px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  margin-bottom: 20px;
}

.page-title {
  margin: 0;
  font-size: 22px;
  font-weight: 600;
  color: #1a1a2e;
}

.filter-bar {
  margin-bottom: 16px;
}

.filter-bar :deep(.el-radio-button__inner) {
  padding: 8px 16px;
}

.order-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
  min-height: 120px;
}

.order-card {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 16px;
  padding: 16px 20px;
  background: #fff;
  border: 1px solid #ebeef5;
  border-radius: 12px;
  transition: box-shadow 0.2s, border-color 0.2s;
}

.order-card:hover {
  border-color: #c6e2ff;
  box-shadow: 0 4px 16px rgba(64, 158, 255, 0.08);
}

.card-top {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.card-top :deep(.tag-wait-accept) {
  --el-tag-bg-color: #f9f0ff;
  --el-tag-border-color: #d3adf7;
  --el-tag-text-color: #722ed1;
}

.type-chip {
  font-size: 12px;
  color: #409eff;
  background: #ecf5ff;
  padding: 2px 8px;
  border-radius: 4px;
}

.card-desc {
  margin: 0 0 10px;
  font-size: 15px;
  line-height: 1.5;
  color: #303133;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.card-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
}

.meta-item {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  color: #909399;
}

.card-actions {
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 2px;
}

.desc-field {
  display: flex;
  gap: 8px;
  width: 100%;
  align-items: flex-start;
}

.desc-field .el-textarea {
  flex: 1;
}

.voice-btn {
  flex-shrink: 0;
  margin-top: 4px;
}

.voice-tip {
  margin-top: 6px;
  font-size: 12px;
  color: #e6a23c;
}

.field-hint,
.append-hint {
  margin: 6px 0 0;
  font-size: 12px;
  color: #909399;
  line-height: 1.5;
}

.append-hint {
  margin: 0 0 16px;
  padding: 10px 12px;
  background: #f5f7fa;
  border-radius: 8px;
}

.repair-edit-form :deep(.el-form-item) {
  margin-bottom: 22px;
}

.repair-edit-form :deep(.el-textarea__inner) {
  border-radius: 8px;
}

.edit-images-panel {
  width: 100%;
  padding: 12px;
  background: #fafbfc;
  border: 1px solid #ebeef5;
  border-radius: 10px;
}

.edit-images {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  align-items: flex-start;
}

.edit-image-item {
  position: relative;
  width: 80px;
  height: 80px;
  border-radius: 6px;
  overflow: hidden;
  border: 1px solid #ddd;
  flex-shrink: 0;
}

.edit-thumb {
  width: 80px;
  height: 80px;
  object-fit: cover;
  display: block;
  cursor: zoom-in;
}

.edit-image-del {
  position: absolute;
  top: 4px;
  right: 4px;
  width: 22px;
  height: 22px;
  padding: 0;
  border: none;
  border-radius: 4px;
  background: rgba(0, 0, 0, 0.55);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  opacity: 0;
  transition: opacity 0.2s;
}

.edit-image-item:hover .edit-image-del {
  opacity: 1;
}

.edit-image-del:hover {
  background: rgba(245, 108, 108, 0.9);
}

.edit-images-panel .field-hint {
  margin: 10px 0 0;
}
</style>
