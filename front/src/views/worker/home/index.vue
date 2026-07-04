<template>
  <div class="worker-home app-container">
    <div class="page-header">
      <h2 class="page-title">工作台</h2>
      <p class="page-desc">工作数据与任务概览</p>
    </div>

    <!-- 派单横幅（替代弹窗通知） -->
    <transition-group name="banner" tag="div" class="banner-list">
      <div
        v-for="msg in dispatchBanners"
        :key="msg.messageId"
        class="dispatch-banner"
        @click="handleBannerClick(msg)"
      >
        <el-icon class="banner-icon"><Bell /></el-icon>
        <div class="banner-body">
          <div class="banner-title">{{ msg.title || '新工单通知' }}</div>
          <div class="banner-content">{{ msg.content }}</div>
        </div>
        <el-button link class="banner-action">查看详情</el-button>
        <el-icon class="banner-close" @click.stop="handleBannerClose(msg)"><Close /></el-icon>
      </div>
    </transition-group>

    <el-row v-loading="loading" :gutter="16" class="stat-row">
      <el-col v-for="card in statCards" :key="card.key" :xs="24" :sm="8">
        <div class="stat-card" :class="card.theme" @click="card.onClick()">
          <div class="stat-value">{{ card.value }}</div>
          <div class="stat-label">{{ card.label }}</div>
          <div class="stat-hint">{{ card.hint }}</div>
          <el-icon class="stat-arrow"><ArrowRight /></el-icon>
        </div>
      </el-col>
    </el-row>

    <el-row :gutter="16" class="mid-row">
      <el-col :xs="24" :lg="14" class="mid-col">
        <el-card shadow="never" class="panel-card panel-equal">
          <template #header>
            <div class="card-head">
              <span class="card-title">完成工单趋势</span>
              <el-radio-group v-model="trendDays" size="small" @change="loadTrend">
                <el-radio-button :value="7">近7日</el-radio-button>
                <el-radio-button :value="30">近30日</el-radio-button>
              </el-radio-group>
            </div>
          </template>
          <div ref="chartRef" class="chart-box" />
        </el-card>
      </el-col>
      <el-col :xs="24" :lg="10" class="mid-col">
        <el-card id="eval-section" shadow="never" class="panel-card panel-equal eval-card">
          <template #header>
            <span class="card-title">业主评价摘要</span>
          </template>
          <div v-if="evalSummary.evalCount > 0" class="eval-summary">
            <div class="eval-metrics">
              <div class="eval-metric">
                <div class="metric-value">{{ evalSummary.avgScore }}</div>
                <div class="metric-label">平均评分</div>
              </div>
              <div class="eval-metric">
                <div class="metric-value">{{ evalSummary.evalCount }}</div>
                <div class="metric-label">累计评价</div>
              </div>
              <div class="eval-metric">
                <div class="metric-value">{{ evalSummary.goodRate }}%</div>
                <div class="metric-label">好评率</div>
              </div>
            </div>
            <div class="eval-recent-list">
              <div
                v-for="item in evalSummary.recentEvals"
                :key="item.orderId + '-' + item.createTime"
                class="eval-item"
                @click="openOrderDetail(item.orderId)"
              >
                <div class="eval-item-head">
                  <span class="eval-order">{{ formatOrderNo(item.orderNo) }}</span>
                  <el-rate :model-value="item.score || 0" disabled size="small" />
                </div>
                <p v-if="item.content" class="eval-text">{{ item.content }}</p>
                <p v-else class="eval-text muted">未填写文字评价</p>
                <span class="eval-time">{{ item.createTime }}</span>
              </div>
            </div>
          </div>
          <el-empty v-else class="eval-empty" description="暂无业主评价" :image-size="72" />
        </el-card>
      </el-col>
    </el-row>

    <div class="quick-section">
      <h3 class="section-title">快捷入口</h3>
      <div class="quick-grid">
        <div class="quick-tile tile-todo" @click="router.push('/worker/order/todo')">
          <div class="tile-icon"><el-icon :size="28"><Tools /></el-icon></div>
          <div class="tile-text">
            <span class="tile-title">去处理工单</span>
            <span class="tile-desc">待办任务列表</span>
          </div>
          <el-icon class="tile-arrow"><ArrowRight /></el-icon>
        </div>
        <div class="quick-tile tile-status" @click="router.push('/worker/order/work-status')">
          <div class="tile-icon"><el-icon :size="28"><Medal /></el-icon></div>
          <div class="tile-text">
            <span class="tile-title">我的资质</span>
            <span class="tile-desc">技能 · 证书 · 忙闲状态</span>
          </div>
          <el-icon class="tile-arrow"><ArrowRight /></el-icon>
        </div>
      </div>
    </div>

    <WorkerOrderDrawer
      v-model:visible="detailVisible"
      :order-id="detailOrderId"
      @changed="onOrderChanged"
      @reject="openRejectFromDrawer"
    />

    <WorkerRejectDialog
      v-model="rejectVisible"
      :order="rejectTarget"
      @success="onRejectSuccess"
    />

    <WorkerEvalDrawer
      v-model:visible="evalDrawerVisible"
      @select-order="openOrderDetail"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import * as echarts from 'echarts'
import { ArrowRight, Bell, Close, Tools, Medal } from '@element-plus/icons-vue'
import { getWorkerDashboard, listRecentMessages, markMessageRead } from '@/api/repair'
import WorkerOrderDrawer from '@/views/worker/order/components/WorkerOrderDrawer.vue'
import WorkerRejectDialog from '@/views/worker/order/components/WorkerRejectDialog.vue'
import WorkerEvalDrawer from './components/WorkerEvalDrawer.vue'
import { formatOrderNo } from '@/utils/orderFormat'

const router = useRouter()
const loading = ref(false)
const chartRef = ref(null)
const trendDays = ref(7)
let chartInstance = null
let pollTimer = null

const detailVisible = ref(false)
const detailOrderId = ref(null)
const rejectVisible = ref(false)
const rejectTarget = ref(null)
const evalDrawerVisible = ref(false)
const dispatchBanners = ref([])

const dashboard = ref({
  pendingTotal: 0,
  completedTotal: 0,
  goodRateTotal: 0,
  trend: []
})

const evalSummary = ref({
  evalCount: 0,
  avgScore: 0,
  goodRate: 0,
  recentEvals: []
})

const statCards = computed(() => [
  {
    key: 'pending',
    label: '待处理工单',
    value: dashboard.value.pendingTotal,
    hint: '待接单 / 处理中 / 待验收',
    theme: 'theme-blue',
    onClick: () => router.push('/worker/order/todo')
  },
  {
    key: 'completed',
    label: '累计已完成',
    value: dashboard.value.completedTotal,
    hint: '历史完成工单总数',
    theme: 'theme-green',
    onClick: () => router.push('/worker/order/history')
  },
  {
    key: 'rate',
    label: '累计好评率',
    value: dashboard.value.goodRateTotal + '%',
    hint: '4 星及以上占比',
    theme: 'theme-gold',
    onClick: () => { evalDrawerVisible.value = true }
  }
])

function isUnread(item) {
  return item?.readFlag === 0 || item?.readFlag === false
}

async function loadDispatchBanners() {
  try {
    const res = await listRecentMessages({ msgType: 'order', limit: 5, unreadOnly: true })
    dispatchBanners.value = (res.data || []).filter(m => m.title === '系统派单' && isUnread(m))
  } catch { /* ignore */ }
}

async function handleBannerClick(msg) {
  if (isUnread(msg)) {
    await markMessageRead(msg.messageId)
  }
  dispatchBanners.value = dispatchBanners.value.filter(m => m.messageId !== msg.messageId)
  if (msg.bizId) {
    detailOrderId.value = Number(msg.bizId) || msg.bizId
    detailVisible.value = true
  }
}

async function handleBannerClose(msg) {
  if (isUnread(msg)) {
    await markMessageRead(msg.messageId)
  }
  dispatchBanners.value = dispatchBanners.value.filter(m => m.messageId !== msg.messageId)
}

function openOrderDetail(orderId) {
  if (!orderId) return
  detailOrderId.value = orderId
  detailVisible.value = true
}

async function openRejectFromDrawer(order) {
  detailVisible.value = false
  rejectTarget.value = order
  await nextTick()
  rejectVisible.value = true
}

function onRejectSuccess() {
  loadDashboard()
  loadDispatchBanners()
}

function onOrderChanged() {
  loadDashboard()
  loadDispatchBanners()
}

async function loadDashboard() {
  loading.value = true
  try {
    const res = await getWorkerDashboard({ trendDays: trendDays.value })
    dashboard.value = {
      pendingTotal: res.data?.pendingTotal ?? 0,
      completedTotal: res.data?.completedTotal ?? 0,
      goodRateTotal: res.data?.goodRateTotal ?? 0,
      trend: res.data?.trend ?? []
    }
    evalSummary.value = res.data?.evalSummary ?? {
      evalCount: 0, avgScore: 0, goodRate: 0, recentEvals: []
    }
    await nextTick()
    renderChart()
  } finally {
    loading.value = false
  }
}

async function loadTrend() {
  loading.value = true
  try {
    const res = await getWorkerDashboard({ trendDays: trendDays.value })
    dashboard.value.trend = res.data?.trend ?? []
    await nextTick()
    renderChart()
  } finally {
    loading.value = false
  }
}

function calcTrendYMax(counts) {
  const maxVal = Math.max(...counts, 0)
  if (maxVal <= 0) return 5
  const padded = Math.ceil(maxVal * 1.25)
  if (padded <= 5) return 5
  if (padded <= 10) return 10
  return Math.ceil(padded / 5) * 5
}

function renderChart() {
  if (!chartRef.value) return
  if (!chartInstance) {
    chartInstance = echarts.init(chartRef.value)
  }
  const trend = dashboard.value.trend || []
  const counts = trend.map(p => Number(p.count) || 0)
  const yMax = calcTrendYMax(counts)
  chartInstance.setOption({
    tooltip: { trigger: 'axis' },
    grid: { left: 40, right: 16, top: 24, bottom: 28 },
    xAxis: {
      type: 'category',
      data: trend.map(p => p.date),
      axisLine: { lineStyle: { color: '#dce8f0' } },
      axisLabel: { color: '#5e7f99', fontSize: 11 }
    },
    yAxis: {
      type: 'value',
      min: 0,
      max: yMax,
      minInterval: 1,
      splitNumber: Math.min(yMax, 5),
      axisLine: { show: false },
      splitLine: { lineStyle: { color: '#eef2f6' } },
      axisLabel: { color: '#909399' }
    },
    series: [{
      name: '完成工单',
      type: 'line',
      smooth: true,
      symbol: 'circle',
      symbolSize: 7,
      data: counts,
      lineStyle: { width: 3, color: '#4898CA' },
      itemStyle: { color: '#4898CA', borderWidth: 2, borderColor: '#fff' },
      areaStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: 'rgba(72, 152, 202, 0.25)' },
          { offset: 1, color: 'rgba(72, 152, 202, 0.02)' }
        ])
      }
    }]
  })
}

function handleResize() {
  chartInstance?.resize()
}

onMounted(() => {
  loadDashboard()
  loadDispatchBanners()
  pollTimer = setInterval(loadDispatchBanners, 15000)
  window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
  if (pollTimer) clearInterval(pollTimer)
  window.removeEventListener('resize', handleResize)
  chartInstance?.dispose()
  chartInstance = null
})
</script>

<style scoped>
.worker-home {
  max-width: 1100px;
}

.page-header {
  margin-bottom: 16px;
}

.page-title {
  margin: 0;
  font-size: 22px;
  font-weight: 600;
  color: #345568;
}

.page-desc {
  margin: 6px 0 0;
  font-size: 13px;
  color: #5e7f99;
}

.banner-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-bottom: 16px;
}

.dispatch-banner {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 14px;
  border-radius: 10px;
  border: 1px solid #ffd591;
  background: linear-gradient(135deg, #fffbe6 0%, #fff7e6 100%);
  cursor: pointer;
  transition: box-shadow 0.2s;
}

.dispatch-banner:hover {
  box-shadow: 0 4px 12px rgba(250, 140, 22, 0.12);
}

.banner-icon {
  flex-shrink: 0;
  font-size: 20px;
  color: #fa8c16;
}

.banner-body {
  flex: 1;
  min-width: 0;
}

.banner-title {
  font-size: 14px;
  font-weight: 600;
  color: #d48806;
}

.banner-content {
  margin-top: 2px;
  font-size: 13px;
  color: #8c6d1f;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.banner-action {
  flex-shrink: 0;
  color: #4898ca !important;
  font-weight: 600;
}

.banner-close {
  flex-shrink: 0;
  color: #909399;
  font-size: 16px;
  padding: 4px;
}

.banner-close:hover {
  color: #606266;
}

.banner-enter-active,
.banner-leave-active {
  transition: all 0.25s ease;
}

.banner-enter-from,
.banner-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}

.stat-row {
  margin-bottom: 16px;
}

.stat-card {
  position: relative;
  padding: 20px 18px;
  border-radius: 12px;
  margin-bottom: 16px;
  border: 1px solid transparent;
  cursor: pointer;
  transition: transform 0.15s, box-shadow 0.15s;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(52, 85, 104, 0.08);
}

.stat-card.theme-blue {
  background: linear-gradient(135deg, #eef7fc 0%, #d6ebf6 100%);
  border-color: #b8dcf0;
  color: #3585b8;
}

.stat-card.theme-green {
  background: linear-gradient(135deg, #f0faf5 0%, #dcf5ea 100%);
  border-color: #b7e4cc;
  color: #389e6a;
}

.stat-card.theme-gold {
  background: linear-gradient(135deg, #fffbf0 0%, #fff3d6 100%);
  border-color: #ffe7a3;
  color: #d48806;
}

.stat-value {
  font-size: 32px;
  font-weight: 700;
  line-height: 1.1;
}

.stat-label {
  margin-top: 8px;
  font-size: 14px;
  font-weight: 600;
}

.stat-hint {
  margin-top: 4px;
  font-size: 12px;
  opacity: 0.75;
}

.stat-arrow {
  position: absolute;
  right: 14px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 18px;
  opacity: 0.45;
}

.mid-row {
  margin-bottom: 16px;
}

.mid-col {
  display: flex;
}

.panel-equal {
  flex: 1;
  width: 100%;
  display: flex;
  flex-direction: column;
}

.panel-equal :deep(.el-card__body) {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-height: 0;
  padding-top: 8px;
}

.panel-card {
  border-radius: 12px;
  margin-bottom: 16px;
  border: 1px solid #eef2f6;
}

.card-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.card-title {
  font-size: 15px;
  font-weight: 600;
  color: #345568;
}

.chart-box {
  height: 300px;
  flex-shrink: 0;
}

.eval-summary {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-height: 0;
}

.eval-metrics {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
  margin-bottom: 12px;
  flex-shrink: 0;
}

.eval-recent-list {
  flex: 1;
  min-height: 0;
  max-height: 300px;
  overflow-y: auto;
  padding-right: 4px;
}

.eval-empty {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 300px;
}

.eval-metric {
  text-align: center;
  padding: 12px 8px;
  background: #f8fbfd;
  border-radius: 10px;
  border: 1px solid #eef2f6;
}

.metric-value {
  font-size: 22px;
  font-weight: 700;
  color: #4898ca;
}

.metric-label {
  margin-top: 4px;
  font-size: 12px;
  color: #909399;
}

.eval-item {
  padding: 10px 12px;
  margin-bottom: 8px;
  border-radius: 8px;
  background: #fafbfc;
  border: 1px solid #eef2f6;
  cursor: pointer;
  transition: background 0.2s;
}

.eval-item:hover {
  background: #f0f7fc;
}

.eval-item-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}

.eval-order {
  font-size: 13px;
  font-weight: 600;
  color: #345568;
}

.eval-text {
  margin: 8px 0 0;
  font-size: 13px;
  line-height: 1.5;
  color: #606266;
}

.eval-text.muted {
  color: #909399;
}

.eval-time {
  display: block;
  margin-top: 6px;
  font-size: 11px;
  color: #909399;
}

.quick-section {
  margin-top: 4px;
}

.section-title {
  margin: 0 0 12px;
  font-size: 15px;
  font-weight: 600;
  color: #345568;
}

.quick-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  gap: 14px;
}

.quick-tile {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 18px 16px;
  border-radius: 12px;
  border: 1px solid #eef2f6;
  cursor: pointer;
  transition: transform 0.15s, box-shadow 0.15s;
}

.quick-tile:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(52, 85, 104, 0.08);
}

.tile-todo {
  background: linear-gradient(135deg, #f5fbff 0%, #e8f4fb 100%);
  border-color: #c8e4f2;
}

.tile-status {
  background: linear-gradient(135deg, #faf8ff 0%, #f0ebfa 100%);
  border-color: #ddd6f3;
}

.tile-icon {
  width: 52px;
  height: 52px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.85);
  color: #4898ca;
}

.tile-status .tile-icon {
  color: #7c6bc4;
}

.tile-text {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.tile-title {
  font-size: 15px;
  font-weight: 600;
  color: #345568;
}

.tile-desc {
  font-size: 12px;
  color: #909399;
}

.tile-arrow {
  color: #c0c4cc;
  font-size: 18px;
}
</style>
