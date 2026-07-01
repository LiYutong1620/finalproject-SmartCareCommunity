<template>
  <el-card>
    <el-form :inline="true" class="search-form" style="margin-bottom: 12px">
      <el-form-item label="状态">
        <el-select v-model="query.status" clearable placeholder="全部状态" style="width: 120px">
          <el-option label="待分配" value="pending" />
          <el-option label="处理中" value="processing" />
          <el-option label="待验收" value="wait_accept" />
          <el-option label="已完成" value="completed" />
          <el-option label="已取消" value="cancelled" />
        </el-select>
      </el-form-item>
      <el-form-item label="紧急程度">
        <el-select v-model="query.urgency" clearable placeholder="全部紧急程度" style="width: 120px">
          <el-option label="普通" value="normal" />
          <el-option label="较急" value="urgent" />
          <el-option label="紧急" value="emergency" />
        </el-select>
      </el-form-item>
      <el-form-item label="类型">
        <el-select v-model="query.typeId" clearable placeholder="全部类型" style="width: 150px">
          <el-option v-for="item in typeOptions" :key="item.typeId" :label="item.typeName" :value="item.typeId" />
        </el-select>
      </el-form-item>
      <el-form-item label="开始日期">
        <el-date-picker v-model="query.startDate" type="date" value-format="YYYY-MM-DD" placeholder="开始日期" />
      </el-form-item>
      <el-form-item label="结束日期">
        <el-date-picker v-model="query.endDate" type="date" value-format="YYYY-MM-DD" placeholder="结束日期" />
      </el-form-item>
      <el-form-item label="关键词">
        <el-input v-model="query.keyword" placeholder="工单号/描述" style="width: 180px" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
        <el-button type="primary" plain @click="$router.push('/property/repair/type-manage')">类型管理</el-button>
        <el-button type="success" plain @click="$router.push('/property/repair/ai-report')">AI复盘周报</el-button>
        <el-button type="warning" plain @click="$router.push('/property/repair/ai-trend')">服务质量趋势</el-button>
      </el-form-item>
    </el-form>

    <el-table :data="list" v-loading="loading" :row-class-name="rowClassName">
      <el-table-column prop="orderNo" label="工单号" width="180" />
      <el-table-column prop="description" label="描述" min-width="160" show-overflow-tooltip />
      <el-table-column label="AI标签" width="150">
        <template #default="{ row }">
          <el-space wrap>
            <el-tag v-if="row.highRisk === 1" type="danger" size="small">高风险</el-tag>
            <el-tag v-if="row.duplicateFlag === 1" type="warning" size="small">重复报修</el-tag>
            <el-tag v-if="row.aiTypeLabel" type="info" size="small">{{ row.aiTypeLabel }}</el-tag>
          </el-space>
        </template>
      </el-table-column>
      <el-table-column prop="status" label="状态" width="100">
        <template #default="{ row }">{{ statusMap[row.status] || row.status }}</template>
      </el-table-column>
      <el-table-column prop="urgency" label="紧急程度" width="90">
        <template #default="{ row }">{{ urgencyMap[row.urgency] || row.urgency }}</template>
      </el-table-column>
      <el-table-column prop="workerId" label="维修工ID" width="90" />
      <el-table-column label="操作" width="380">
        <template #default="{ row }">
          <el-button link type="primary" @click="openDetail(row)">详情</el-button>
          <el-button v-if="row.status === 'pending' && !row.workerId" link type="success" @click="openAssign(row)">派单</el-button>
          <el-button v-if="row.status === 'pending' && !row.workerId" link type="primary" @click="handleAutoDispatch(row)">AI派单</el-button>
          <el-button link type="warning" @click="openAdjust(row)">调整</el-button>
          <el-button v-if="row.status !== 'completed'" link type="danger" @click="forceComplete(row)">强制完成</el-button>
        </template>
      </el-table-column>
    </el-table>

    <Pagination
      v-show="total > 0"
      :total="total"
      v-model:page="query.pageNum"
      v-model:limit="query.pageSize"
      @pagination="load"
    />

    <el-dialog v-model="detailVisible" title="工单详情" width="860px">
      <el-descriptions v-if="detail" :column="2" border>
        <el-descriptions-item label="工单号">{{ detail.orderNo }}</el-descriptions-item>
        <el-descriptions-item label="状态">{{ statusMap[detail.status] || detail.status }}</el-descriptions-item>
        <el-descriptions-item label="故障描述" :span="2">{{ detail.description }}</el-descriptions-item>
        <el-descriptions-item label="紧急程度">{{ urgencyMap[detail.urgency] || detail.urgency }}</el-descriptions-item>
        <el-descriptions-item label="业主ID">{{ detail.ownerId }}</el-descriptions-item>
        <el-descriptions-item label="接单维修工">{{ detail.workerId || '-' }}</el-descriptions-item>
        <el-descriptions-item label="签名图片">
          <el-image v-if="detail.signImage" :src="detail.signImage" style="width: 120px; height: 60px" fit="contain" :preview-src-list="[detail.signImage]" />
          <span v-else>-</span>
        </el-descriptions-item>
      </el-descriptions>
      <el-divider>处理进度</el-divider>
      <el-timeline v-if="progressList.length > 0">
        <el-timeline-item v-for="(item, index) in progressList" :key="index" :timestamp="item.createTime" :type="index === progressList.length - 1 ? 'primary' : ''">
          <div class="progress-node">
            <span class="node-name">{{ item.nodeName }}</span>
            <span class="node-operator" v-if="item.operator">操作人：{{ item.operator }}</span>
            <span class="node-remark" v-if="item.remark">{{ item.remark }}</span>
          </div>
        </el-timeline-item>
      </el-timeline>
      <el-empty v-else description="暂无进度记录" />
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="assignVisible" title="指派维修工" width="420px">
      <el-form :model="assignForm" label-width="90px">
        <el-form-item label="维修工ID"><el-input v-model="assignForm.workerId" /></el-form-item>
        <el-form-item label="原因"><el-input v-model="assignForm.reason" type="textarea" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="assignVisible = false">取消</el-button>
        <el-button type="primary" @click="handleAssign">确定</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="adjustVisible" title="调整工单" width="420px">
      <el-form :model="adjustForm" label-width="90px">
        <el-form-item label="紧急程度">
          <el-select v-model="adjustForm.urgency" clearable style="width: 100%">
            <el-option label="普通" value="normal" />
            <el-option label="较急" value="urgent" />
            <el-option label="紧急" value="emergency" />
          </el-select>
        </el-form-item>
        <el-form-item label="故障类型ID"><el-input v-model="adjustForm.typeId" /></el-form-item>
        <el-form-item label="原因"><el-input v-model="adjustForm.reason" type="textarea" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="adjustVisible = false">取消</el-button>
        <el-button type="primary" @click="handleAdjust">确定</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="forceVisible" title="强制完成" width="420px">
      <el-form :model="forceForm" label-width="90px">
        <el-form-item label="原因"><el-input v-model="forceForm.reason" type="textarea" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="forceVisible = false">取消</el-button>
        <el-button type="primary" @click="handleForceComplete">确定</el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { listPropertyRepair, assignRepair, forceRepairStatus, adjustRepair, getPropertyRepairDetail, listRepairTypes, autoDispatchRepair } from '@/api/repair'

const loading = ref(false)
const list = ref([])
const total = ref(0)
const detailVisible = ref(false)
const assignVisible = ref(false)
const adjustVisible = ref(false)
const forceVisible = ref(false)
const detail = ref(null)
const progressList = ref([])
const typeOptions = ref([])
const query = reactive({ pageNum: 1, pageSize: 20, status: '', urgency: '', typeId: '', keyword: '', startDate: '', endDate: '' })
const assignForm = reactive({ orderId: null, workerId: '', reason: '' })
const adjustForm = reactive({ orderId: null, urgency: '', typeId: '', reason: '' })
const forceForm = reactive({ orderId: null, status: 'completed', reason: '' })

const statusMap = {
  pending: '待分配',
  processing: '处理中',
  wait_accept: '待验收',
  completed: '已完成',
  cancelled: '已取消'
}
const urgencyMap = {
  normal: '普通',
  urgent: '较急',
  emergency: '紧急'
}

async function load() {
  loading.value = true
  try {
    const res = await listPropertyRepair(query)
    list.value = res.data.rows || []
    total.value = res.data.total || 0
  } finally {
    loading.value = false
  }
}

async function loadTypes() {
  const res = await listRepairTypes()
  typeOptions.value = res.data || []
}

function handleQuery() {
  query.pageNum = 1
  load()
}

function resetQuery() {
  query.status = ''
  query.urgency = ''
  query.typeId = ''
  query.keyword = ''
  query.startDate = ''
  query.endDate = ''
  query.pageNum = 1
  query.pageSize = 20
  load()
}

async function openDetail(row) {
  const res = await getPropertyRepairDetail(row.orderId)
  detail.value = res.data.order || res.data
  progressList.value = res.data.progress || []
  detailVisible.value = true
}

function openAssign(row) {
  assignForm.orderId = row.orderId
  assignForm.workerId = ''
  assignForm.reason = ''
  assignVisible.value = true
}

async function handleAssign() {
  await assignRepair(assignForm)
  ElMessage.success('派单成功')
  assignVisible.value = false
  load()
}

function openAdjust(row) {
  adjustForm.orderId = row.orderId
  adjustForm.urgency = row.urgency
  adjustForm.typeId = row.typeId ? String(row.typeId) : ''
  adjustForm.reason = ''
  adjustVisible.value = true
}

async function handleAdjust() {
  await adjustRepair({
    orderId: adjustForm.orderId,
    urgency: adjustForm.urgency,
    typeId: adjustForm.typeId,
    reason: adjustForm.reason,
  })
  ElMessage.success('调整成功')
  adjustVisible.value = false
  load()
}

function forceComplete(row) {
  forceForm.orderId = row.orderId
  forceForm.reason = ''
  forceVisible.value = true
}

async function handleAutoDispatch(row) {
  const res = await autoDispatchRepair(row.orderId)
  ElMessage.success(`AI派单成功，维修工ID：${res.data.workerId}`)
  load()
}

function rowClassName({ row }) {
  return row.highRisk === 1 ? 'high-risk-row' : ''
}

async function handleForceComplete() {
  await forceRepairStatus(forceForm)
  ElMessage.success('状态已调整')
  forceVisible.value = false
  load()
}

onMounted(async () => {
  await loadTypes()
  await load()
})
</script>

<style scoped>
:deep(.high-risk-row) {
  background-color: #fef0f0 !important;
}
</style>
