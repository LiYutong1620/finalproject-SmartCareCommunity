<template>
  <div class="app-container ai-monitor">
    <el-row :gutter="16" class="stat-row">
      <el-col :span="6" v-for="(card, idx) in statCards" :key="idx">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon" :class="`theme-${idx + 1}`">
              <el-icon><component :is="card.icon" /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value" :class="{ 'stat-time': card.isTime }">{{ card.value }}</div>
              <div class="stat-label">{{ card.label }}</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <div class="toolbar">
      <div class="toolbar-left">
        <el-input
          v-model="alertQuery.keyword"
          placeholder="搜索预警内容"
          clearable
          style="width: 200px"
          @keyup.enter="searchAlerts"
        >
          <template #prefix><el-icon><Search /></el-icon></template>
        </el-input>
        <el-select
          v-model="alertQuery.status"
          clearable
          placeholder="状态"
          style="width: 120px"
          @change="searchAlerts"
        >
          <el-option label="全部" value="" />
          <el-option label="待处理" value="pending" />
          <el-option label="处理中" value="processing" />
          <el-option label="已完成" value="closed" />
        </el-select>
        <el-button type="primary" @click="searchAlerts">搜索</el-button>
      </div>
    </div>

    <div v-loading="alertLoading" class="alert-card-list">
      <div
        v-for="item in alertList"
        :key="item.alertId"
        class="alert-card"
        :class="alertCardClass(item)"
        @click="openDetail(item)"
      >
        <div class="alert-card-header">
          <span v-if="item.status === 'closed'" class="alert-level-badge badge-green">已完成</span>
          <span v-else class="alert-level-badge" :class="item.alertLevel === 1 ? 'badge-red' : 'badge-orange'">
            {{ item.alertLevel === 1 ? '一级预警' : '二级预警' }}
          </span>
          <span class="alert-elder-name">{{ item.residentName || '未知' }}</span>
          <span class="alert-address">{{ item.address || '—' }}</span>
          <el-tag :type="statusTagType(item.status)" size="small" effect="plain" round class="alert-status-tag">
            {{ statusLabel(item.status) }}
          </el-tag>
        </div>
        <div class="alert-card-body">
          <div class="alert-content">{{ displayReason(item) }}</div>
          <div class="alert-meta">
            <span>{{ alertTypeLabel(item.alertType) }}</span>
            <span>{{ item.createTime }}</span>
          </div>
        </div>
        <div class="alert-card-footer">
          <el-button type="primary" link size="small" @click.stop="openDetail(item)">查看并处置</el-button>
        </div>
      </div>
      <el-empty v-if="!alertLoading && alertList.length === 0" description="暂无预警消息" />
    </div>
    <Pagination
      v-show="alertTotal > 0"
      :total="alertTotal"
      v-model:page="alertQuery.pageNum"
      v-model:limit="alertQuery.pageSize"
      @pagination="loadAlerts"
    />

    <!-- 预警详情抽屉（含工单指派与闭环） -->
    <el-drawer
      v-model="detailDrawer"
      title="预警详情"
      size="560px"
      append-to-body
      destroy-on-close
      @open="onDetailDrawerOpen"
      @closed="onDetailDrawerClosed"
    >
      <div v-if="detailData.alert" v-loading="detailLoading" class="alert-drawer">
        <div class="drawer-level-bar" :class="detailData.alert.alertLevel === 1 ? 'level-1' : 'level-2'">
          <span>{{ detailData.alert.alertLevel === 1 ? '一级预警 · 规则判定高风险' : '二级预警 · 规则判定中风险' }}</span>
          <el-tag :type="statusTagType(detailData.alert.status)" size="small" effect="dark" round>
            {{ statusLabel(detailData.alert.status) }}
          </el-tag>
        </div>

        <el-descriptions :column="1" border size="small" class="drawer-desc">
          <el-descriptions-item label="老人">{{ detailData.alert.residentName }}（{{ detailData.alert.address || '未知' }}）</el-descriptions-item>
          <el-descriptions-item label="联系电话">{{ detailData.alert.elderPhone || '—' }}</el-descriptions-item>
          <el-descriptions-item label="紧急联系人">{{ detailData.alert.familyPhone || '—' }}</el-descriptions-item>
          <el-descriptions-item label="预警类型">{{ alertTypeLabel(detailData.alert.alertType) }}</el-descriptions-item>
          <el-descriptions-item label="触发时间">{{ detailData.alert.createTime }}</el-descriptions-item>
          <el-descriptions-item v-if="detailData.alert.processStartTime" label="开始处理">{{ detailData.alert.processStartTime }}</el-descriptions-item>
          <el-descriptions-item v-if="detailData.alert.status === 'closed'" label="完成时间">{{ detailData.alert.handleTime }}</el-descriptions-item>
        </el-descriptions>

        <div class="drawer-section">
          <div class="section-title">预警内容</div>
          <div class="info-block info-block--alert">
            {{ detailData.alert.alertReason || detailData.alert.content || '—' }}
          </div>
        </div>

        <div v-if="detailData.alert.aiSuggestion" class="drawer-section">
          <div class="section-title">AI 建议</div>
          <div class="info-block info-block--ai">{{ detailData.alert.aiSuggestion }}</div>
        </div>

        <div class="drawer-section">
          <div class="section-title">异常水电趋势（近24小时）</div>
          <div ref="chartRef" class="chart-box" />
        </div>

        <div class="drawer-section care-workflow">
          <div class="section-title">关怀处置</div>
          <template v-if="detailData.careOrder">
            <div class="workflow-meta">
              <el-tag
                :class="detailData.careOrder.status === 'pending' ? 'tag-pending-assign' : ''"
                :type="detailData.careOrder.status === 'pending' ? undefined : orderStatusTagType(detailData.careOrder.status)"
                size="small"
                effect="plain"
                round
              >{{ orderStatusLabel(detailData.careOrder.status) }}</el-tag>
              <span class="workflow-item">{{ detailData.careOrder.careItem }}</span>
            </div>
            <div v-if="detailData.careOrder.assigneeName" class="workflow-assignee">
              已指派：<strong>{{ detailData.careOrder.assigneeName }}</strong>
            </div>

            <div v-if="canAssign" class="assign-box">
              <el-select
                v-model="assignStaffId"
                placeholder="选择负责该楼栋的关怀人员"
                filterable
                style="width: 100%"
              >
                <el-option
                  v-for="s in assignStaffOptions"
                  :key="s.staffId"
                  :label="`${s.name}（${s.staffType}）`"
                  :value="s.staffId"
                />
              </el-select>
              <p v-if="!assignStaffOptions.length" class="field-hint">该楼栋暂无负责人员，请先在「关怀人员」中配置</p>
              <el-button
                type="primary"
                class="assign-btn"
                :loading="assignLoading"
                :disabled="!assignStaffId"
                @click="submitAssign"
              >指派并开始处理</el-button>
            </div>
          </template>
          <el-alert
            v-else-if="detailData.alert.status !== 'closed'"
            type="info"
            :closable="false"
            show-icon
            title="本条预警无关联工单（历史数据），可直接填写处置结果完成闭环"
          />

          <div v-if="showCompleteForm" class="close-form-wrap">
            <el-form ref="closeFormRef" :model="closeForm" :rules="closeRules" label-width="110px" class="close-form">
              <el-form-item label="上门核查时间" prop="visitTime">
                <el-date-picker
                  v-model="closeForm.visitTime"
                  type="datetime"
                  placeholder="选择实际上门核查时间"
                  value-format="YYYY-MM-DD HH:mm:ss"
                  style="width: 100%"
                />
              </el-form-item>
              <el-form-item label="上门核查情况" prop="checkResult">
                <el-input v-model="closeForm.checkResult" type="textarea" :rows="3" placeholder="描述上门看到的情况、老人状态等" />
              </el-form-item>
              <el-form-item label="处理结果" prop="disposalResult">
                <el-input v-model="closeForm.disposalResult" type="textarea" :rows="2" placeholder="最终处理结论，如已解除风险、已联系家属等" />
              </el-form-item>
              <el-button type="success" :loading="closeLoading" @click="submitClose">完成处置</el-button>
            </el-form>
          </div>

          <div v-if="showLegacyStart" class="legacy-start">
            <el-button type="primary" :loading="processLoading" @click="startProcess">开始处理</el-button>
          </div>
        </div>

        <div class="drawer-section">
          <div class="section-title">处置记录</div>
          <el-timeline v-if="detailData.records?.length">
            <el-timeline-item
              v-for="rec in detailData.records"
              :key="rec.recordId"
              :timestamp="rec.handleTime"
              placement="top"
            >
              <div class="timeline-card">
                <div class="timeline-handler">{{ rec.handlerName || '系统' }}</div>
                <div v-if="rec.checkResult" class="timeline-line">核查情况：{{ rec.checkResult }}</div>
                <div v-if="rec.disposalResult" class="timeline-line">处理结果：{{ rec.disposalResult }}</div>
              </div>
            </el-timeline-item>
          </el-timeline>
          <el-empty v-else description="暂无处置记录" :image-size="48" />
        </div>
      </div>
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, User, Monitor, Warning, Clock } from '@element-plus/icons-vue'
import * as echarts from 'echarts'
import Pagination from '@/components/Pagination/index.vue'
import {
  listAlerts, getAlertDetail, closeAlert, processAlert, assignAlertCare,
  listCareStaffByResident
} from '@/api/elder'
import { getMonitorStatus, getUtilityRecent } from '@/api/elderAi'

function displayReason(item) {
  if (item.alertReason) return item.alertReason
  const c = item.content || ''
  const idx = c.indexOf(' | AI建议：')
  return idx >= 0 ? c.substring(0, idx) : c
}

function alertCardClass(item) {
  if (item.status === 'closed') return 'alert-level-closed'
  return item.alertLevel === 1 ? 'alert-level-1' : 'alert-level-2'
}

function defaultVisitTime() {
  const d = new Date()
  const pad = n => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`
}

function statusTagType(status) {
  if (status === 'pending') return 'warning'
  if (status === 'processing' || status === 'handled') return 'primary'
  if (status === 'closed') return 'success'
  return 'info'
}
function statusLabel(status) {
  const map = { pending: '待处理', processing: '处理中', handled: '处理中', closed: '已完成' }
  return map[status] || status
}
function orderStatusLabel(status) {
  const map = { pending: '待指派', assigned: '进行中', completed: '已完成' }
  return map[status] || status
}
function orderStatusTagType(status) {
  if (status === 'assigned') return 'warning'
  if (status === 'completed') return 'success'
  return 'info'
}
function alertTypeLabel(type) {
  const map = {
    living_sign: '生活迹象',
    utility_anomaly: '用量异常',
    alone_monitor: '生活迹象',
    no_living_sign: '生活迹象',
    no_activity: '生活迹象',
    device_offline: '设备离线'
  }
  return map[type] || type || '其他'
}

const status = ref({})
const statCards = computed(() => [
  { icon: User, label: '监测中老人', value: status.value.aloneElderCount ?? 0 },
  { icon: Monitor, label: '今日检查次数', value: status.value.todayCheckCount ?? 0 },
  { icon: Warning, label: '今日预警数', value: status.value.todayAlertCount ?? 0 },
  {
    icon: Clock,
    label: '最近预警时间',
    value: status.value.latestAlert?.checkTime || '暂无',
    isTime: true
  }
])

async function loadStatus() {
  try {
    const res = await getMonitorStatus()
    status.value = res.data || {}
  } catch { /* ignore */ }
}

const alertLoading = ref(false)
const alertList = ref([])
const alertTotal = ref(0)
const alertQuery = reactive({ pageNum: 1, pageSize: 10, keyword: '', status: '' })

async function loadAlerts() {
  alertLoading.value = true
  try {
    const res = await listAlerts(alertQuery)
    alertList.value = res.data?.rows || []
    alertTotal.value = res.data?.total || 0
  } finally {
    alertLoading.value = false
  }
}
function searchAlerts() {
  alertQuery.pageNum = 1
  loadAlerts()
}

const detailDrawer = ref(false)
const detailLoading = ref(false)
const detailData = ref({ alert: null, records: [], careOrder: null })
const currentAlertId = ref(null)
const chartRef = ref(null)
let chartInstance = null
const closeForm = reactive({ visitTime: '', checkResult: '', disposalResult: '' })
const closeFormRef = ref(null)
const closeRules = {
  visitTime: [{ required: true, message: '请选择上门核查时间', trigger: 'change' }],
  checkResult: [{ required: true, message: '请填写上门核查情况', trigger: 'blur' }],
  disposalResult: [{ required: true, message: '请填写处理结果', trigger: 'blur' }]
}
const closeLoading = ref(false)
const processLoading = ref(false)
const assignStaffId = ref(null)
const assignStaffOptions = ref([])
const assignLoading = ref(false)

const canAssign = computed(() => {
  const alert = detailData.value.alert
  const order = detailData.value.careOrder
  return alert && alert.status !== 'closed' && order?.status === 'pending'
})

const showCompleteForm = computed(() => {
  const alert = detailData.value.alert
  const order = detailData.value.careOrder
  if (!alert || alert.status === 'closed') return false
  if (order?.status === 'pending') return false
  if (order?.status === 'assigned') return true
  if (!order && (alert.status === 'processing' || alert.status === 'handled')) return true
  return false
})

const showLegacyStart = computed(() => {
  const alert = detailData.value.alert
  const order = detailData.value.careOrder
  return alert?.status === 'pending' && !order
})

async function openDetail(item) {
  currentAlertId.value = item.alertId
  detailDrawer.value = true
}

async function loadDetail() {
  if (!currentAlertId.value) return
  detailLoading.value = true
  try {
    const res = await getAlertDetail(currentAlertId.value)
    detailData.value = res.data || { alert: null, records: [], careOrder: null }
    closeForm.visitTime = defaultVisitTime()
    closeForm.checkResult = ''
    closeForm.disposalResult = ''
    assignStaffId.value = null
    if (detailData.value.alert?.residentId) {
      assignStaffOptions.value = await loadStaffForResident(detailData.value.alert.residentId)
    }
    await nextTick()
    loadChartData()
  } finally {
    detailLoading.value = false
  }
}

function onDetailDrawerOpen() {
  loadDetail()
}

function onDetailDrawerClosed() {
  if (chartInstance) {
    chartInstance.dispose()
    chartInstance = null
  }
  loadAlerts()
  loadStatus()
}

async function loadStaffForResident(residentId) {
  if (!residentId) return []
  try {
    const res = await listCareStaffByResident(residentId)
    return res.data || []
  } catch {
    return []
  }
}

async function loadChartData() {
  if (!detailData.value.alert?.residentId || !chartRef.value) return
  try {
    const res = await getUtilityRecent(detailData.value.alert.residentId, 24)
    renderChart(res.data || [])
  } catch { /* ignore */ }
}

function renderChart(data) {
  if (!chartRef.value) return
  if (chartInstance) chartInstance.dispose()
  chartInstance = echarts.init(chartRef.value)
  const times = data.map(d => (d.recordTime || '').substring(5, 16))
  const waterData = data.map(d => Number(d.waterUsage) || 0)
  const electricData = data.map(d => Number(d.electricUsage) || 0)
  chartInstance.setOption({
    tooltip: {
      trigger: 'axis',
      backgroundColor: 'rgba(255,255,255,0.96)',
      borderColor: '#e4e7ed'
    },
    legend: { data: ['用水量', '用电量'], bottom: 0, icon: 'roundRect' },
    grid: { left: 52, right: 52, top: 32, bottom: 52 },
    xAxis: {
      type: 'category',
      data: times,
      boundaryGap: false,
      axisLabel: { rotate: 35, fontSize: 10, color: '#909399' }
    },
    yAxis: [
      { type: 'value', name: '用水(L)', nameTextStyle: { color: '#E85D5D', fontSize: 11 }, splitLine: { lineStyle: { type: 'dashed', color: '#ebeef5' } } },
      { type: 'value', name: '用电(kWh)', nameTextStyle: { color: '#F5A623', fontSize: 11 }, splitLine: { show: false } }
    ],
    series: [
      {
        name: '用水量', type: 'line', data: waterData, smooth: 0.35, symbol: 'circle', symbolSize: 4, yAxisIndex: 0,
        lineStyle: { width: 2.5, color: '#E85D5D' }, itemStyle: { color: '#E85D5D' },
        areaStyle: { color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{ offset: 0, color: 'rgba(232,93,93,0.25)' }, { offset: 1, color: 'rgba(232,93,93,0.02)' }]) }
      },
      {
        name: '用电量', type: 'line', data: electricData, smooth: 0.35, symbol: 'circle', symbolSize: 4, yAxisIndex: 1,
        lineStyle: { width: 2.5, color: '#F5A623' }, itemStyle: { color: '#F5A623' },
        areaStyle: { color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{ offset: 0, color: 'rgba(245,166,35,0.2)' }, { offset: 1, color: 'rgba(245,166,35,0.02)' }]) }
      }
    ]
  })
}

async function submitAssign() {
  if (!assignStaffId.value) {
    ElMessage.warning('请选择关怀人员')
    return
  }
  assignLoading.value = true
  try {
    await assignAlertCare(currentAlertId.value, { staffId: assignStaffId.value })
    ElMessage.success('已指派并开始处理')
    await loadDetail()
    loadAlerts()
  } finally {
    assignLoading.value = false
  }
}

async function startProcess() {
  processLoading.value = true
  try {
    await processAlert(currentAlertId.value)
    ElMessage.success('已开始处理')
    await loadDetail()
    loadAlerts()
  } finally {
    processLoading.value = false
  }
}

async function submitClose() {
  await closeFormRef.value?.validate()
  closeLoading.value = true
  try {
    await closeAlert(currentAlertId.value, { ...closeForm })
    ElMessage.success('处置已完成')
    await loadDetail()
    loadAlerts()
  } finally {
    closeLoading.value = false
  }
}

onMounted(() => {
  loadStatus()
  loadAlerts()
})
</script>

<style scoped lang="scss">
.ai-monitor {
  padding: 16px;
}

.stat-row {
  margin-bottom: 20px;
}

.stat-card :deep(.el-card__body) {
  padding: 18px 20px;
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 14px;
}

.stat-icon {
  width: 46px;
  height: 46px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 22px;
  color: #fff;
  flex-shrink: 0;

  &.theme-1 { background: linear-gradient(135deg, #6aa8cc, #3e8ab8); }
  &.theme-2 { background: linear-gradient(135deg, #52c9a8, #36a88a); }
  &.theme-3 { background: linear-gradient(135deg, #ffb88c, #e89868); }
  &.theme-4 { background: linear-gradient(135deg, #b8aeeb, #9588d8); }
}

.stat-value {
  font-size: 22px;
  font-weight: 700;
  color: #2c4a60;
  line-height: 1.2;

  &.stat-time {
    font-size: 13px;
    font-weight: 600;
  }
}

.stat-label {
  font-size: 13px;
  color: #5e7f99;
  margin-top: 4px;
}

.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  flex-wrap: wrap;
  gap: 10px;
}

.toolbar-left {
  display: flex;
  gap: 10px;
  align-items: center;
  flex-wrap: wrap;
}

.alert-card-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
  min-height: 120px;
}

.alert-card {
  border: 1px solid #eef2f6;
  border-radius: 10px;
  padding: 16px 18px;
  cursor: pointer;
  transition: box-shadow 0.2s, transform 0.2s;
  background: #fff;

  &:hover {
    box-shadow: 0 6px 16px rgba(62, 138, 184, 0.12);
    transform: translateY(-1px);
  }

  &.alert-level-1 {
    border-left: 4px solid #e85d5d;
    background: linear-gradient(90deg, #fff8f8 0%, #fff 12%);
  }

  &.alert-level-2 {
    border-left: 4px solid #e6a23c;
    background: linear-gradient(90deg, #fffbf5 0%, #fff 12%);
  }

  &.alert-level-closed {
    border-left: 4px solid #52c9a8;
    background: linear-gradient(90deg, #f0faf6 0%, #fff 12%);

    .alert-content {
      color: #466880;
    }

    .alert-level-badge.badge-red,
    .alert-level-badge.badge-orange {
      color: #52a87a;
      background: #e8f7f0;
    }
  }
}

.alert-card-header {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
  margin-bottom: 10px;
}

.alert-level-badge {
  font-size: 12px;
  font-weight: 600;
  padding: 2px 8px;
  border-radius: 4px;

  &.badge-red {
    color: #c45656;
    background: #fdecec;
  }

  &.badge-orange {
    color: #b88230;
    background: #fdf6ec;
  }

  &.badge-green {
    color: #52a87a;
    background: #e8f7f0;
  }
}

.alert-elder-name {
  font-size: 15px;
  font-weight: 600;
  color: #2c4a60;
}

.alert-address {
  font-size: 13px;
  color: #5e7f99;
}

.alert-status-tag {
  margin-left: auto;
}

.alert-content {
  font-size: 13px;
  color: #466880;
  line-height: 1.6;
  margin-bottom: 8px;
}

.alert-meta {
  display: flex;
  gap: 16px;
  font-size: 12px;
  color: #909399;
}

.alert-card-footer {
  margin-top: 8px;
  text-align: right;
}

.tag-pending-assign {
  color: #7c5cbf !important;
  background: #f3edff !important;
  border-color: #d4c4f0 !important;
}

.alert-drawer {
  padding: 0 4px 24px;
}

.drawer-level-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 14px;
  border-radius: 8px;
  margin-bottom: 16px;
  font-size: 13px;
  font-weight: 600;

  &.level-1 {
    background: #fdecec;
    color: #c45656;
  }

  &.level-2 {
    background: #fdf6ec;
    color: #b88230;
  }
}

.drawer-desc {
  margin-bottom: 16px;
}

.drawer-section {
  margin-bottom: 20px;
}

.section-title {
  font-size: 14px;
  font-weight: 600;
  color: #2c4a60;
  margin-bottom: 10px;
  padding-left: 8px;
  border-left: 3px solid #3e8ab8;
}

.info-block {
  padding: 12px 14px;
  border-radius: 8px;
  font-size: 13px;
  line-height: 1.65;
  white-space: pre-wrap;

  &--alert {
    background: #fff8f8;
    border: 1px solid #fde2e2;
    color: #c45656;
  }

  &--ai {
    background: #f0f7fc;
    border: 1px solid #d4e8f5;
    color: #466880;
  }
}


.chart-box {
  height: 240px;
  width: 100%;
}

.care-workflow {
  padding: 14px;
  background: #f8fbfd;
  border-radius: 10px;
  border: 1px solid #eef2f6;
}

.workflow-meta {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  margin-bottom: 10px;
}

.workflow-item {
  font-size: 13px;
  color: #466880;
  line-height: 1.5;
}

.workflow-assignee {
  font-size: 13px;
  color: #606266;
  margin-bottom: 12px;
}

.assign-box {
  margin-bottom: 12px;
}

.assign-btn {
  margin-top: 10px;
  width: 100%;
}

.close-form-wrap {
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px dashed #dcdfe6;
}

.legacy-start {
  margin-top: 12px;
}

.timeline-card {
  font-size: 13px;
  color: #466880;
}

.timeline-handler {
  font-weight: 600;
  color: #3e8ab8;
  margin-bottom: 4px;
}

.timeline-line {
  line-height: 1.5;
}

.field-hint {
  margin: 6px 0 0;
  font-size: 12px;
  color: #909399;
}
</style>
