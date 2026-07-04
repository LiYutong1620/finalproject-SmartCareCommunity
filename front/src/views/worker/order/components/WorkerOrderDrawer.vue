<template>
  <el-drawer
    :model-value="visible"
    title="工单详情"
    direction="rtl"
    size="520px"
    destroy-on-close
    @update:model-value="emit('update:visible', $event)"
    @closed="handleClosed"
  >
    <div v-loading="loading" class="drawer-body repair-detail-body">
      <template v-if="order.orderId">
        <header class="repair-detail-header">
          <span class="order-no">{{ formatOrderNo(order.orderNo) }}</span>
          <div class="header-tags">
            <el-tag
              :type="workerStatusTagType(order.status) || undefined"
              :class="workerStatusTagClass(order.status)"
              size="small"
              effect="plain"
              round
            >
              {{ workerStatusLabel(order.status) }}
            </el-tag>
            <el-tag :type="urgencyTagType(order.urgency)" size="small" effect="plain" round>
              {{ workerUrgencyLabel(order.urgency) }}
            </el-tag>
            <el-tag v-if="order.appendPending" class="tag-append" size="small" effect="plain" round>业主已补充</el-tag>
          </div>
        </header>

        <section class="repair-detail-section">
          <h4>工单信息</h4>
          <dl class="repair-detail-panel">
            <div class="repair-detail-row"><dt>报修时间</dt><dd>{{ formatDateTime(order.createTime) }}</dd></div>
            <div v-if="order.status === 'completed'" class="repair-detail-row">
              <dt>完成时间</dt><dd>{{ formatDateTime(order.repairCompleteTime) }}</dd>
            </div>
            <div class="repair-detail-row is-block">
              <dt>故障描述</dt>
              <dd>{{ order.description || '—' }}</dd>
            </div>
          </dl>
        </section>

        <section class="repair-detail-section">
          <h4>业主信息</h4>
          <dl class="repair-detail-panel">
            <div class="repair-detail-row"><dt>姓名</dt><dd>{{ ownerInfo.name || '—' }}</dd></div>
            <div class="repair-detail-row"><dt>联系电话</dt><dd>{{ ownerInfo.phone || '—' }}</dd></div>
            <div class="repair-detail-row"><dt>地址</dt><dd>{{ ownerInfo.address || '—' }}</dd></div>
          </dl>
        </section>

        <section v-if="order.status === 'processing'" class="repair-detail-section ai-steps-section">
          <button
            type="button"
            class="ai-steps-trigger"
            :class="{ expanded: stepsExpanded, loading: stepsLoading }"
            :disabled="stepsLoading"
            @click="toggleAiSteps"
          >
            <span class="trigger-label">
              <span class="trigger-badge">AI</span>
              推荐维修步骤
            </span>
            <el-icon v-if="stepsLoading" class="trigger-icon is-loading"><Loading /></el-icon>
            <el-icon v-else class="trigger-icon" :class="{ expanded: stepsExpanded }"><ArrowDown /></el-icon>
          </button>
          <el-collapse-transition>
            <div v-show="stepsExpanded" class="ai-steps-panel">
              <div v-if="stepsLoading" class="steps-hint">AI 正在生成推荐步骤…</div>
              <template v-else-if="steps?.steps?.length">
                <ol class="ai-step-list">
                  <li v-for="(step, idx) in steps.steps" :key="idx" class="ai-step-item">
                    <span class="step-index">{{ idx + 1 }}</span>
                    <p class="step-text">{{ step }}</p>
                  </li>
                </ol>
                <p v-if="steps.source === 'ai'" class="steps-source">
                  <el-icon class="steps-source-icon"><InfoFilled /></el-icon>
                  由 AI 根据故障描述生成，仅供参考
                </p>
              </template>
              <p v-else-if="stepsError" class="steps-error">{{ stepsError }}</p>
            </div>
          </el-collapse-transition>
        </section>

        <section v-if="ownerImages.length" class="repair-detail-section">
          <h4>报修图片</h4>
          <div class="repair-detail-images image-list">
            <el-image
              v-for="(img, index) in ownerImages"
              :key="index"
              :src="resolveUrl(img.imageUrl)"
              :preview-src-list="ownerImageUrls"
              fit="cover"
              class="repair-image"
            />
          </div>
        </section>

        <section v-if="savedFieldRecords.length" class="repair-detail-section">
          <h4>历史现场记录</h4>
          <div v-for="rec in savedFieldRecords" :key="rec.recordId" class="field-record-card">
            <div class="record-time">{{ rec.createTime || '—' }}</div>
            <p class="record-content">{{ rec.content || '（无文字说明）' }}</p>
            <div v-if="rec.images?.length" class="image-list">
              <el-image
                v-for="(img, index) in rec.images"
                :key="index"
                :src="resolveUrl(img.imageUrl)"
                :preview-src-list="rec.images.map(i => resolveUrl(i.imageUrl))"
                fit="cover"
                class="repair-image"
              />
            </div>
          </div>
        </section>

        <section v-if="order.status === 'completed'" class="repair-detail-section">
          <h4>业主评价</h4>
          <div v-if="evaluation" class="eval-card">
            <el-rate :model-value="evaluation.score || 0" disabled show-score score-template="{value} 分" />
            <div v-if="evalTagList.length" class="eval-tags">
              <el-tag v-for="tag in evalTagList" :key="tag" size="small" effect="plain" round>{{ tag }}</el-tag>
            </div>
            <p v-if="evaluation.content" class="eval-content">{{ evaluation.content }}</p>
            <p v-if="evaluation.createTime" class="eval-time">评价时间：{{ evaluation.createTime }}</p>
          </div>
          <p v-else class="eval-empty">业主已完成验收，暂未留下评分评价</p>
        </section>

        <section v-if="activeVisit" class="repair-detail-section field-form">
          <h4>现场记录</h4>
          <p class="upload-tip">请填写现场情况说明并上传照片；离场可不点完成维修，记录将自动保存</p>
          <el-input
            v-model="fieldContent"
            type="textarea"
            :rows="4"
            maxlength="1000"
            show-word-limit
            placeholder="如：检查发现水管老化，需更换配件，预计明日带材料再来维修"
          />
          <input ref="fileInputRef" type="file" accept="image/*" multiple hidden @change="handleUpload" />
          <div class="field-actions">
            <el-button type="primary" plain :loading="uploading" @click="fileInputRef?.click()">上传现场照片</el-button>
          </div>
          <div v-if="visitImages.length" class="image-list">
            <el-image
              v-for="(img, index) in visitImages"
              :key="index"
              :src="resolveUrl(img.imageUrl)"
              :preview-src-list="visitImageUrls"
              fit="cover"
              class="repair-image"
            />
          </div>
        </section>
      </template>
    </div>

    <template v-if="order.orderId && showActions" #footer>
      <div class="drawer-footer repair-detail-footer">
        <el-button v-if="order.status === 'assigned'" type="success" :loading="acting" @click="handleAccept">确认接单</el-button>
        <el-button v-if="order.status === 'assigned'" type="danger" plain :loading="acting" @click="emit('reject', order)">拒单</el-button>
        <el-button
          v-if="order.status === 'processing' && canOnSite"
          type="warning"
          :loading="acting"
          @click="handleOnSite"
        >
          已到场
        </el-button>
        <el-button
          v-if="order.status === 'processing' && activeVisit"
          type="primary"
          :loading="acting"
          @click="handleComplete"
        >
          完成维修
        </el-button>
      </div>
    </template>
  </el-drawer>
</template>

<script setup>
import { ref, watch, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { ArrowDown, Loading, InfoFilled } from '@element-plus/icons-vue'
import {
  getWorkerOrderDetail, getWorkerAiSteps, acceptOrder, completeOrder,
  workerOnSite, saveWorkerFieldRecord
} from '@/api/repair'
import { workerStatusLabel, workerStatusTagType, workerStatusTagClass, workerUrgencyLabel } from '@/utils/workerLabels'
import { formatOrderNo, formatDateTime, urgencyTagType } from '@/utils/orderFormat'
import '@/styles/repair-order-detail.css'

const props = defineProps({
  visible: { type: Boolean, default: false },
  orderId: { type: [Number, String], default: null },
  showActions: { type: Boolean, default: true }
})

const emit = defineEmits(['update:visible', 'changed', 'reject'])

const loading = ref(false)
const acting = ref(false)
const uploading = ref(false)
const fileInputRef = ref(null)
const order = ref({})
const ownerInfo = ref({})
const ownerImages = ref([])
const steps = ref(null)
const stepsExpanded = ref(false)
const stepsLoading = ref(false)
const stepsError = ref('')
const canOnSite = ref(false)
const activeVisit = ref(null)
const fieldRecords = ref([])
const fieldContent = ref('')
const evaluation = ref(null)

const savedFieldRecords = computed(() =>
  fieldRecords.value.filter(r => r.status === '1' || r.status === '2')
)

const evalTagList = computed(() => {
  const tags = evaluation.value?.tags
  if (!tags) return []
  return tags.split(/[,，]/).map(t => t.trim()).filter(Boolean)
})

const visitImages = computed(() => activeVisit.value?.images || [])
const visitImageUrls = computed(() => visitImages.value.map(i => resolveUrl(i.imageUrl)))
const ownerImageUrls = computed(() => ownerImages.value.map(i => resolveUrl(i.imageUrl)))

watch(
  () => [props.visible, props.orderId],
  ([vis, id]) => { if (vis && id) loadDetail(id) },
  { immediate: true }
)

function resolveUrl(url) {
  if (!url) return ''
  if (url.startsWith('http') || url.startsWith('data:')) return url
  return '/api' + url
}

async function loadDetail(orderId) {
  loading.value = true
  steps.value = null
  stepsExpanded.value = false
  stepsLoading.value = false
  stepsError.value = ''
  try {
    const res = await getWorkerOrderDetail(orderId)
    order.value = res.data.order || {}
    ownerInfo.value = res.data.owner || {}
    ownerImages.value = res.data.images || []
    canOnSite.value = !!res.data.canOnSite
    activeVisit.value = res.data.activeVisit || null
    fieldRecords.value = res.data.fieldRecords || []
    fieldContent.value = activeVisit.value?.content || ''
    evaluation.value = res.data.evaluation || null
  } catch {
    ElMessage.error('加载详情失败')
    emit('update:visible', false)
  } finally {
    loading.value = false
  }
}

async function persistFieldRecord({ files, closeVisit = false, silent = false, forceContent = false } = {}) {
  if (!activeVisit.value) return
  const formData = new FormData()
  formData.append('recordId', String(activeVisit.value.recordId))
  if (forceContent || fieldContent.value?.trim()) {
    formData.append('content', (fieldContent.value || '').trim())
  }
  formData.append('closeVisit', String(closeVisit))
  if (files?.length) {
    files.forEach(f => formData.append('files', f))
  }
  const res = await saveWorkerFieldRecord(props.orderId, formData)
  if (closeVisit) {
    activeVisit.value = null
    canOnSite.value = true
    fieldContent.value = ''
  } else if (res.data) {
    activeVisit.value = res.data
    fieldContent.value = res.data.content || fieldContent.value
  }
  if (!silent && !closeVisit) {
    ElMessage.success(files?.length ? '上传成功' : '已保存')
  }
}

async function toggleAiSteps() {
  if (stepsExpanded.value && !stepsLoading.value) {
    stepsExpanded.value = false
    return
  }
  stepsExpanded.value = true
  if (steps.value?.steps?.length || stepsLoading.value) {
    return
  }
  stepsLoading.value = true
  stepsError.value = ''
  try {
    const res = await getWorkerAiSteps(props.orderId)
    steps.value = res.data || null
    if (!steps.value?.steps?.length) {
      stepsError.value = '暂未生成有效步骤，请稍后重试'
    }
  } catch {
    stepsError.value = '加载失败，请重试'
    ElMessage.error('AI推荐步骤加载失败')
  } finally {
    stepsLoading.value = false
  }
}

async function handleUpload(e) {
  const files = Array.from(e.target.files || [])
  if (!files.length || !activeVisit.value) return
  uploading.value = true
  try {
    await persistFieldRecord({ files: files.slice(0, 9), silent: false })
    await loadDetail(props.orderId)
    emit('changed')
  } finally {
    uploading.value = false
    e.target.value = ''
  }
}

async function handleAccept() {
  acting.value = true
  try {
    await acceptOrder(props.orderId)
    ElMessage.success('接单成功')
    await loadDetail(props.orderId)
    emit('changed')
  } finally {
    acting.value = false
  }
}

async function handleOnSite() {
  acting.value = true
  try {
    await workerOnSite(props.orderId)
    ElMessage.success('已记录到场，请填写现场记录')
    await loadDetail(props.orderId)
    emit('changed')
  } finally {
    acting.value = false
  }
}

async function handleComplete() {
  if (!fieldContent.value?.trim()) {
    ElMessage.warning('请填写现场记录说明')
    return
  }
  const imgCount = visitImages.value.length
  if (imgCount < 1) {
    ElMessage.warning('请上传至少一张现场照片')
    return
  }
  acting.value = true
  try {
    await persistFieldRecord({ closeVisit: false, silent: true, forceContent: true })
    await completeOrder(props.orderId)
    ElMessage.success('已提交待验收')
    emit('update:visible', false)
    emit('changed')
  } catch {
    ElMessage.error('提交失败')
  } finally {
    acting.value = false
  }
}

async function handleClosed() {
  if (activeVisit.value && (fieldContent.value?.trim() || visitImages.value.length)) {
    try {
      await persistFieldRecord({ closeVisit: true, silent: true })
      emit('changed')
    } catch {
      /* 忽略关闭时保存失败 */
    }
  }
  order.value = {}
  ownerInfo.value = {}
  ownerImages.value = []
  steps.value = null
  stepsExpanded.value = false
  stepsLoading.value = false
  stepsError.value = ''
  canOnSite.value = false
  activeVisit.value = null
  fieldRecords.value = []
  fieldContent.value = ''
  evaluation.value = null
}

defineExpose({ loadDetail })
</script>

<style scoped>
.drawer-body { min-height: 200px; }
.tag-append {
  --el-tag-bg-color: #fff7e6;
  --el-tag-border-color: #ffd591;
  --el-tag-text-color: #d48806;
}
:deep(.tag-wait-accept) {
  --el-tag-bg-color: #f9f0ff;
  --el-tag-border-color: #d3adf7;
  --el-tag-text-color: #722ed1;
}
.ai-steps-section { padding: 0; }
.ai-steps-trigger {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  padding: 13px 16px;
  border: 1px solid #c6e2ff;
  border-radius: 12px;
  background: linear-gradient(135deg, #ecf5ff 0%, #f8fbff 55%, #ffffff 100%);
  color: #0958d9;
  font-size: 14px;
  font-weight: 600;
  letter-spacing: 0.02em;
  cursor: pointer;
  transition: border-color 0.2s, box-shadow 0.2s, transform 0.15s;
}
.ai-steps-trigger:hover:not(:disabled) {
  border-color: #69b1ff;
  box-shadow: 0 4px 14px rgba(22, 119, 255, 0.12);
  transform: translateY(-1px);
}
.ai-steps-trigger:disabled { cursor: wait; opacity: 0.88; }
.ai-steps-trigger.expanded {
  border-radius: 12px 12px 0 0;
  border-bottom-color: #e6f4ff;
  box-shadow: none;
  transform: none;
}
.trigger-label {
  display: inline-flex;
  align-items: center;
  gap: 8px;
}
.trigger-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 28px;
  height: 22px;
  padding: 0 6px;
  border-radius: 6px;
  background: linear-gradient(135deg, #1677ff 0%, #4096ff 100%);
  color: #fff;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.06em;
  box-shadow: 0 2px 6px rgba(22, 119, 255, 0.35);
}
.trigger-icon { transition: transform 0.25s; font-size: 16px; color: #4096ff; }
.trigger-icon.expanded { transform: rotate(180deg); }
.ai-steps-panel {
  padding: 16px 14px 14px;
  border: 1px solid #c6e2ff;
  border-top: none;
  border-radius: 0 0 12px 12px;
  background: linear-gradient(180deg, #ffffff 0%, #f7fbff 100%);
}
.steps-hint {
  margin: 0;
  font-size: 13px;
  color: #64748b;
  text-align: center;
  padding: 12px 0;
  letter-spacing: 0.02em;
}
.steps-error {
  margin: 0;
  padding: 10px 12px;
  font-size: 13px;
  color: #cf1322;
  background: #fff2f0;
  border-radius: 8px;
  border: 1px solid #ffccc7;
}
.ai-step-list {
  list-style: none;
  margin: 0;
  padding: 0;
}
.ai-step-item {
  display: flex;
  gap: 12px;
  align-items: flex-start;
  padding: 12px 10px;
  border-radius: 10px;
  transition: background 0.2s;
}
.ai-step-item + .ai-step-item {
  margin-top: 4px;
}
.ai-step-item:hover {
  background: rgba(22, 119, 255, 0.04);
}
.step-index {
  flex-shrink: 0;
  width: 26px;
  height: 26px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: linear-gradient(145deg, #1677ff 0%, #69b1ff 100%);
  color: #fff;
  font-size: 12px;
  font-weight: 700;
  line-height: 1;
  box-shadow: 0 2px 8px rgba(22, 119, 255, 0.28);
}
.step-text {
  flex: 1;
  margin: 2px 0 0;
  font-size: 14px;
  font-weight: 500;
  line-height: 1.65;
  color: #1e293b;
  letter-spacing: 0.01em;
}
.steps-source {
  display: flex;
  align-items: center;
  gap: 6px;
  margin: 14px 0 0;
  padding: 10px 12px;
  font-size: 12px;
  color: #64748b;
  background: #f1f5f9;
  border-radius: 8px;
  border-left: 3px solid #91caff;
}
.steps-source-icon {
  flex-shrink: 0;
  font-size: 14px;
  color: #4096ff;
}
.info-block h4 { margin: 0 0 10px; font-size: 14px; font-weight: 600; color: #303133; }
.upload-tip { margin: 0 0 10px; font-size: 12px; color: #909399; line-height: 1.5; }
.image-list { display: flex; flex-wrap: wrap; gap: 10px; margin-top: 10px; }
.repair-image { width: 88px; height: 88px; border-radius: 8px; }
.field-form :deep(.el-textarea) { margin-bottom: 10px; }
.field-actions { margin-top: 4px; }
.field-record-card {
  padding: 12px 14px; margin-bottom: 10px;
  background: #f8fafc; border-radius: 10px; border: 1px solid #ebeef5;
}
.record-time { font-size: 12px; color: #909399; margin-bottom: 6px; }
.record-content { margin: 0 0 8px; font-size: 13px; color: #303133; white-space: pre-wrap; }
.eval-card {
  padding: 14px 16px;
  background: #fffbe6;
  border: 1px solid #ffe58f;
  border-radius: 10px;
}
.eval-tags { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 10px; }
.eval-content {
  margin: 12px 0 0;
  font-size: 14px;
  line-height: 1.65;
  color: #334155;
}
.eval-time { margin: 10px 0 0; font-size: 12px; color: #909399; }
.eval-empty { margin: 0; font-size: 13px; color: #909399; }
</style>
