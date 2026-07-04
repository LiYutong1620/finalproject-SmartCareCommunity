<template>
  <el-drawer
    :model-value="modelValue"
    title="工单详情"
    size="560px"
    append-to-body
    destroy-on-close
    @update:model-value="v => emit('update:modelValue', v)"
    @open="onOpen"
  >
    <div v-loading="loading" class="detail-drawer">
      <template v-if="detail">
        <div class="drawer-head">
          <span class="order-no">{{ formatOrderNo(detail.orderNo) }}</span>
          <div class="header-tags">
            <el-tag
              :type="repairStatusTagType(detail.status) || undefined"
              :class="repairStatusTagClass(detail.status)"
              size="small"
              effect="plain"
              round
            >{{ REPAIR_STATUS_MAP[detail.status] || detail.status }}</el-tag>
            <el-tag
              :type="urgencyTagType(detail.urgency) || undefined"
              :class="urgencyTagClass(detail.urgency)"
              size="small"
              effect="plain"
              round
            >{{ REPAIR_URGENCY_MAP[detail.urgency] || detail.urgency }}</el-tag>
          </div>
        </div>

        <div v-if="canAudit || canReassign" class="drawer-actions">
          <el-button v-if="canAudit" size="small" type="warning" plain @click="openAdjust">审核调整</el-button>
          <el-button v-if="canReassign" size="small" type="primary" plain @click="openReassign">改派维修工</el-button>
        </div>

        <section class="repair-detail-section ai-section">
          <div class="ai-section-head">
            <h4>AI 分析结果</h4>
            <el-tag v-if="aiAnalysis.visionUsed" type="primary" size="small" effect="dark">GLM-4V 多模态</el-tag>
            <el-tag v-else type="info" size="small" effect="plain">规则引擎</el-tag>
          </div>
          <dl class="repair-detail-panel">
            <div class="repair-detail-row">
              <dt>识别类型</dt>
              <dd>{{ aiAnalysis.typeLabel || detail.aiTypeLabel || typeName || '—' }}</dd>
            </div>
            <div class="repair-detail-row">
              <dt>紧急程度</dt>
              <dd>{{ REPAIR_URGENCY_MAP[aiAnalysis.urgency || detail.urgency] || '—' }}</dd>
            </div>
            <div class="repair-detail-row">
              <dt>高风险</dt>
              <dd>
                <el-tag v-if="aiAnalysis.highRisk" type="danger" size="small" effect="plain">是</el-tag>
                <span v-else>否</span>
              </dd>
            </div>
            <div class="repair-detail-row">
              <dt>重复报修</dt>
              <dd>
                <el-tag v-if="aiAnalysis.duplicate" type="warning" size="small" effect="plain">7日内同户同类型</el-tag>
                <span v-else>否</span>
              </dd>
            </div>
            <div v-if="aiAnalysis.visionSummary" class="repair-detail-row is-block vision-summary">
              <dt>GLM-4V 现场判断</dt>
              <dd>{{ aiAnalysis.visionSummary }}</dd>
            </div>
            <div class="repair-detail-row">
              <dt>派单方式</dt>
              <dd>{{ detail.assignReason || (detail.workerId ? 'AI 系统自动派单' : '待派单') }}</dd>
            </div>
          </dl>
        </section>

        <section class="repair-detail-section">
          <h4>工单信息</h4>
          <dl class="repair-detail-panel">
            <div class="repair-detail-row is-block">
              <dt>故障描述</dt>
              <dd>{{ detail.description || '—' }}</dd>
            </div>
            <div class="repair-detail-row">
              <dt>报修时间</dt>
              <dd>{{ formatDateTime(detail.createTime) }}</dd>
            </div>
            <div v-if="detail.expectedTime" class="repair-detail-row">
              <dt>期望上门</dt>
              <dd>{{ formatDateTime(detail.expectedTime) }}</dd>
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

        <section class="repair-detail-section">
          <h4>维修信息</h4>
          <dl class="repair-detail-panel">
            <div class="repair-detail-row">
              <dt>维修工</dt>
              <dd>{{ workerInfo.name || (detail.workerId ? `ID ${detail.workerId}` : '未指派') }}</dd>
            </div>
            <div v-if="workerInfo.workerNo" class="repair-detail-row">
              <dt>工号</dt>
              <dd>{{ workerInfo.workerNo }}</dd>
            </div>
          </dl>
        </section>

        <section v-if="images.length" class="repair-detail-section">
          <h4>报修/现场图片</h4>
          <div class="repair-detail-images detail-images">
            <el-image
              v-for="(img, index) in images"
              :key="index"
              :src="resolveUrl(img.imageUrl)"
              :preview-src-list="images.map(i => resolveUrl(i.imageUrl))"
              fit="cover"
            />
          </div>
        </section>

        <section v-if="fieldRecords.length" class="repair-detail-section">
          <h4>维修工现场记录</h4>
          <div v-for="rec in fieldRecords" :key="rec.recordId" class="field-record-card">
            <div class="record-time">{{ formatDateTime(rec.createTime) || '—' }}</div>
            <p class="record-content">{{ rec.content || '（无文字说明）' }}</p>
            <div v-if="rec.images?.length" class="repair-detail-images detail-images">
              <el-image
                v-for="(img, index) in rec.images"
                :key="index"
                :src="resolveUrl(img.imageUrl)"
                :preview-src-list="rec.images.map(i => resolveUrl(i.imageUrl))"
                fit="cover"
              />
            </div>
          </div>
        </section>

        <section class="repair-detail-section">
          <h4>业主电子签名验收</h4>
          <div v-if="detail.signImage" class="sign-wrap">
            <el-image
              :src="resolveUrl(detail.signImage)"
              fit="contain"
              :preview-src-list="[resolveUrl(detail.signImage)]"
              class="sign-image"
            />
            <p v-if="acceptTime" class="sign-meta">验收时间：{{ acceptTime }}</p>
          </div>
          <p v-else class="sign-empty">暂无电子签名（业主验收后将在此展示）</p>
        </section>

        <section class="repair-detail-section repair-detail-timeline">
          <h4>操作时间轴</h4>
          <el-timeline v-if="progressList.length">
            <el-timeline-item
              v-for="(item, index) in progressList"
              :key="index"
              :timestamp="formatDateTime(item.createTime)"
              :type="item.nodeName?.includes('AI') ? 'primary' : item.nodeName === '派单' ? 'success' : undefined"
            >
              <div class="progress-node">
                <div class="node-name">{{ item.nodeName }}</div>
                <div v-if="item.operator" class="node-operator">操作人：{{ item.operator }}</div>
                <div v-if="item.remark" class="node-remark">{{ item.remark }}</div>
              </div>
            </el-timeline-item>
          </el-timeline>
          <el-empty v-else description="暂无进度记录" :image-size="64" />
        </section>
      </template>
    </div>

    <el-dialog v-model="adjustVisible" title="审核调整" width="420px" append-to-body>
      <el-form label-width="90px">
        <el-form-item label="紧急程度">
          <el-select v-model="adjustForm.urgency" clearable style="width:100%">
            <el-option v-for="(label, val) in REPAIR_URGENCY_MAP" :key="val" :label="label" :value="val" />
          </el-select>
        </el-form-item>
        <el-form-item label="故障类型">
          <el-select v-model="adjustForm.typeId" clearable filterable placeholder="请选择" style="width:100%">
            <el-option v-for="t in leafRepairTypes" :key="t.typeId" :label="t.label" :value="t.typeId" />
          </el-select>
        </el-form-item>
        <el-form-item label="审核说明" required>
          <el-input v-model="adjustForm.reason" type="textarea" placeholder="请填写调整原因" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="adjustVisible = false">取消</el-button>
        <el-button type="primary" @click="handleAdjust">保存</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="reassignVisible" title="改派维修工" width="440px" append-to-body>
      <el-form label-width="88px">
        <el-form-item label="维修工" required>
          <el-select v-model="reassignForm.workerId" filterable placeholder="请选择" style="width:100%">
            <el-option
              v-for="w in workers"
              :key="w.userId"
              :label="`${w.nickName}（${w.username}）`"
              :value="w.userId"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="改派原因" required>
          <el-input v-model="reassignForm.reason" type="textarea" placeholder="物业审核后改派" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="reassignVisible = false">取消</el-button>
        <el-button type="primary" :loading="reassignSaving" @click="handleReassign">确定</el-button>
      </template>
    </el-dialog>
  </el-drawer>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { getPropertyRepairDetail, adjustRepair, assignRepair, listRepairTypes } from '@/api/repair'
import { listUser } from '@/api/system'
import {
  formatOrderNo,
  formatDateTime,
  urgencyTagType,
  urgencyTagClass,
  REPAIR_STATUS_MAP,
  REPAIR_URGENCY_MAP,
  repairStatusTagType,
  repairStatusTagClass
} from '@/utils/orderFormat'
import '@/styles/repair-order-detail.css'

const props = defineProps({
  modelValue: { type: Boolean, default: false },
  orderId: { type: [Number, String], default: null }
})

const emit = defineEmits(['update:modelValue', 'changed'])

const loading = ref(false)
const detail = ref(null)
const ownerInfo = ref({})
const workerInfo = ref({})
const progressList = ref([])
const images = ref([])
const fieldRecords = ref([])
const aiAnalysis = ref({})
const repairTypes = ref([])
const workers = ref([])
const adjustVisible = ref(false)
const reassignVisible = ref(false)
const reassignSaving = ref(false)
const adjustForm = reactive({ orderId: null, urgency: '', typeId: null, reason: '' })
const reassignForm = reactive({ orderId: null, workerId: null, reason: '' })

const leafRepairTypes = computed(() => {
  const flat = repairTypes.value
  return flat
    .filter(t => (t.parentId || 0) > 0)
    .map(t => {
      const parent = flat.find(p => p.typeId === t.parentId)
      return { typeId: t.typeId, label: parent ? `${parent.typeName} / ${t.typeName}` : t.typeName }
    })
})

const typeName = computed(() => {
  if (!detail.value?.typeId) return ''
  const t = repairTypes.value.find(x => x.typeId === detail.value.typeId)
  return t?.typeName || ''
})

const canReassign = computed(() =>
  detail.value && ['pending', 'assigned'].includes(detail.value.status)
)

const canAudit = computed(() =>
  detail.value && !['completed', 'cancelled'].includes(detail.value.status)
)

const acceptTime = computed(() => {
  if (!detail.value?.signImage) return ''
  if (detail.value.repairCompleteTime) return formatDateTime(detail.value.repairCompleteTime)
  const node = [...progressList.value].reverse().find(p =>
    p.nodeName === '验收完成' || p.nodeName === '完成维修'
  )
  return node ? formatDateTime(node.createTime) : ''
})

async function onOpen() {
  if (!props.orderId) return
  if (!repairTypes.value.length) {
    const res = await listRepairTypes()
    repairTypes.value = res.data || []
  }
  if (!workers.value.length) {
    const res = await listUser({ pageNum: 1, pageSize: 100, userType: '1' })
    workers.value = res.data?.rows || []
  }
  await load()
}

async function load() {
  if (!props.orderId) return
  loading.value = true
  try {
    const res = await getPropertyRepairDetail(props.orderId)
    detail.value = res.data.order || res.data
    ownerInfo.value = res.data.owner || {}
    workerInfo.value = res.data.worker || {}
    progressList.value = res.data.progress || []
    images.value = res.data.images || []
    fieldRecords.value = res.data.fieldRecords || []
    aiAnalysis.value = res.data.aiAnalysis || {}
  } catch {
    ElMessage.error('加载工单详情失败')
  } finally {
    loading.value = false
  }
}

function openAdjust() {
  adjustForm.orderId = detail.value.orderId
  adjustForm.urgency = detail.value.urgency || ''
  adjustForm.typeId = detail.value.typeId || null
  adjustForm.reason = ''
  adjustVisible.value = true
}

async function handleAdjust() {
  if (!adjustForm.reason?.trim()) {
    ElMessage.warning('请填写审核说明')
    return
  }
  await adjustRepair({
    orderId: adjustForm.orderId,
    urgency: adjustForm.urgency || undefined,
    typeId: adjustForm.typeId || undefined,
    reason: adjustForm.reason
  })
  ElMessage.success('已保存调整')
  adjustVisible.value = false
  await load()
  emit('changed')
}

function openReassign() {
  reassignForm.orderId = detail.value.orderId
  reassignForm.workerId = detail.value.workerId || null
  reassignForm.reason = ''
  reassignVisible.value = true
}

async function handleReassign() {
  if (!reassignForm.workerId) {
    ElMessage.warning('请选择维修工')
    return
  }
  if (!reassignForm.reason?.trim()) {
    ElMessage.warning('请填写改派原因')
    return
  }
  reassignSaving.value = true
  try {
    await assignRepair({ ...reassignForm })
    ElMessage.success('改派成功')
    reassignVisible.value = false
    await load()
    emit('changed')
  } finally {
    reassignSaving.value = false
  }
}

function resolveUrl(url) {
  if (!url) return ''
  if (url.startsWith('http') || url.startsWith('data:')) return url
  return '/api' + url
}
</script>

<style scoped>
.detail-drawer {
  min-height: 200px;
}

.drawer-head {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 10px;
  margin-bottom: 12px;
}

.order-no {
  font-size: 17px;
  font-weight: 600;
}

.header-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.drawer-actions {
  display: flex;
  gap: 8px;
  margin-bottom: 16px;
}

.ai-section {
  background: linear-gradient(135deg, #f0f7ff 0%, #fafcff 100%);
  border-radius: 10px;
  padding: 12px 14px;
  margin-bottom: 16px;
  border: 1px solid #dce8f7;
}

.ai-section h4 {
  margin-top: 0;
  color: var(--el-color-primary);
}

.ai-section-head {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.ai-section-head h4 {
  margin: 0;
}

.vision-summary dd {
  line-height: 1.65;
  color: #303133;
}

.field-record-card {
  padding: 12px 14px;
  margin-bottom: 10px;
  background: #f8fafc;
  border-radius: 10px;
  border: 1px solid #ebeef5;
}

.record-time {
  font-size: 12px;
  color: #909399;
  margin-bottom: 6px;
}

.record-content {
  margin: 0 0 8px;
  font-size: 13px;
  color: #303133;
  white-space: pre-wrap;
}

.detail-images :deep(.el-image) {
  width: 88px;
  height: 88px;
}

.sign-wrap {
  padding: 12px;
  background: #fafbfc;
  border: 1px solid #ebeef5;
  border-radius: 10px;
  display: inline-block;
}

.sign-image {
  width: 200px;
  height: 100px;
}

.sign-meta {
  margin: 8px 0 0;
  font-size: 12px;
  color: var(--el-text-color-secondary);
}

.sign-empty {
  margin: 0;
  font-size: 13px;
  color: var(--el-text-color-placeholder);
}
</style>
