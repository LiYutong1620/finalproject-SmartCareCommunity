<template>
  <div class="app-container utility-monitor">
    <!-- 顶部操作区 -->
    <el-card shadow="never" class="toolbar-card">
      <el-row :gutter="16" align="middle">
        <el-col :span="6">
          <el-select
            v-model="selectedElder"
            placeholder="选择监测对象"
            filterable
            style="width: 100%"
            @change="onElderChange"
          >
            <el-option
              v-for="e in aloneElders"
              :key="e.residentId"
              :label="`${e.name}（${e.address || '—'}）`"
              :value="e.residentId"
            />
          </el-select>
        </el-col>
        <el-col :span="18" class="toolbar-actions">
          <el-button
            class="btn-normal"
            icon="DataLine"
            :disabled="!selectedElder"
            :loading="simLoading && simMode === 'normal'"
            @click="handleSimulateNormal"
          >生成正常数据</el-button>
          <el-button
            class="btn-anomaly"
            :disabled="!selectedElder"
            :loading="simLoading && simMode === 'anomaly'"
            @click="handleSimulateAnomaly"
          >生成异常数据</el-button>
        </el-col>
      </el-row>
    </el-card>

    <!-- AI检测结果 -->
    <el-card
      v-if="checkResult"
      shadow="never"
      class="result-card"
      :class="resultCardClass"
    >
      <template #header>
        <div class="result-header">
          <span>最近检测结果</span>
          <el-tag :type="resultTagType" effect="dark">{{ resultStatusText }}</el-tag>
        </div>
      </template>
      <el-descriptions :column="2" border size="small">
        <el-descriptions-item label="检测时间">{{ checkResult.checkTime }}</el-descriptions-item>
        <el-descriptions-item label="风险等级">{{ riskLevelText }}</el-descriptions-item>
        <el-descriptions-item v-if="checkResult.alertId" label="预警ID">{{ checkResult.alertId }}</el-descriptions-item>
        <el-descriptions-item v-if="checkResult.careOrderId" label="工单ID">{{ checkResult.careOrderId }}</el-descriptions-item>
      </el-descriptions>
      <p v-if="checkResult.skippedDuplicate" class="check-hint check-hint--warn">
        该老人已有未处理预警，本次未重复生成。请前往「AI安全监测」处理现有预警。
      </p>
      <p v-else-if="checkResult.alertCreated || checkResult.orderCreated" class="check-hint">
        已自动生成 1 条预警和 1 条待指派关怀工单，请前往「AI安全监测」处理。
      </p>
      <div v-if="displayAnomalies.length" class="anomaly-list">
        <div v-for="(a, i) in displayAnomalies" :key="i" class="anomaly-item">
          <el-tag :type="a.level === 1 ? 'danger' : 'warning'" size="small">
            {{ a.level === 1 ? '高风险' : '中风险' }}
          </el-tag>
          <span class="anomaly-desc">{{ a.description }}</span>
        </div>
      </div>
    </el-card>

    <!-- 卡片一：正常数据趋势（近7天） -->
    <el-card v-if="selectedElder" shadow="never" class="chart-card chart-card--normal">
      <template #header>
        <div class="chart-header">
          <div class="chart-header__title">
            <span class="chart-title">正常数据趋势</span>
            <span class="chart-subtitle">近 7 天 · {{ selectedElderName }}</span>
          </div>
          <el-button icon="Refresh" size="small" text @click="loadMainChart">刷新</el-button>
        </div>
      </template>
      <div v-show="mainChartEmpty" class="chart-empty">
        <el-empty description="暂无正常数据，可点击「生成正常数据」查看趋势" :image-size="72" />
      </div>
      <div ref="mainChartRef" v-show="!mainChartEmpty" class="chart-box" />
    </el-card>

    <!-- 卡片二：异常数据趋势（近24小时，始终展示） -->
    <el-card v-if="selectedElder" shadow="never" class="chart-card chart-card--anomaly">
      <template #header>
        <div class="chart-header">
          <div class="chart-header__title">
            <span class="chart-title">异常数据趋势</span>
            <span class="chart-subtitle">
              {{ hasAnomalyData ? `近 24 小时 · ${anomalyTypeLabel}` : '暂无异常数据' }}
            </span>
          </div>
          <el-tag v-if="hasAnomalyData" type="danger" effect="plain" size="small">测试数据</el-tag>
        </div>
      </template>
      <div v-show="!hasAnomalyData" class="chart-empty">
        <el-empty description="无异常数据，可点击「生成异常数据」查看近24小时异常趋势" :image-size="72" />
      </div>
      <div v-show="hasAnomalyData && anomalyChartEmpty" class="chart-empty">
        <el-empty description="异常数据加载失败，请重新生成" :image-size="72" />
      </div>
      <div ref="anomalyChartRef" v-show="hasAnomalyData && !anomalyChartEmpty" class="chart-box chart-box--anomaly" />
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import * as echarts from 'echarts'
import {
  getAloneElders,
  getUtilityRecent,
  simulateNormalData,
  simulateAnomalyData,
} from '@/api/elderAi'

const DEFAULT_ELDER_NAME = '郑丽'
const HOURS_7_DAYS = 7 * 24
const HOURS_24 = 24

const ANOMALY_TYPE_LABEL = {
  no_living_sign: '生活迹象异常（近3小时无用水用电）',
  no_usage: '24小时全零用量',
  surge: '用量突增',
  night_high: '夜间高用量',
}

const aloneElders = ref([])
const selectedElder = ref(null)
const checkResult = ref(null)
const simLoading = ref(false)
const simMode = ref('')
const hasAnomalyData = ref(false)
const lastAnomalyType = ref('')
const mainChartEmpty = ref(true)
const anomalyChartEmpty = ref(false)
/** 记录各老人是否已生成异常数据（切换老人时恢复展示状态） */
const elderAnomalyState = ref({})

const mainChartRef = ref(null)
const anomalyChartRef = ref(null)
let mainChartInstance = null
let anomalyChartInstance = null

const selectedElderName = computed(() => {
  const e = aloneElders.value.find(x => x.residentId === selectedElder.value)
  return e?.name || '—'
})

const anomalyTypeLabel = computed(() => ANOMALY_TYPE_LABEL[lastAnomalyType.value] || '异常模拟数据')

function clearAnomalyChart() {
  if (anomalyChartInstance) {
    anomalyChartInstance.dispose()
    anomalyChartInstance = null
  }
  anomalyChartEmpty.value = false
}

const resultTagType = computed(() => {
  if (!checkResult.value) return 'info'
  if (checkResult.value.riskLevel === 'green') return 'success'
  return 'danger'
})

const resultStatusText = computed(() => {
  if (!checkResult.value) return ''
  if (checkResult.value.riskLevel === 'green') return '正常'
  if (checkResult.value.skippedDuplicate) return '异常仍存在，未重复生成预警'
  return '已生成预警及待指派工单'
})

const riskLevelText = computed(() => {
  const r = checkResult.value?.riskLevel
  if (r === 'red') return '高风险'
  if (r === 'yellow') return '中风险'
  return '正常'
})

const resultCardClass = computed(() => {
  if (!checkResult.value) return ''
  return checkResult.value.riskLevel === 'green' ? 'result-normal' : 'result-alert'
})

const displayAnomalies = computed(() => {
  const r = checkResult.value
  if (!r) return []
  return r.anomalies || r.utilityAnomalies || []
})

function buildNormalChartOption(data) {
  const times = data.map(d => (d.recordTime || '').substring(5, 11))
  const waterData = data.map(d => Number(d.waterUsage) || 0)
  const electricData = data.map(d => Number(d.electricUsage) || 0)
  const waterColor = '#3E8AB8'
  const electricColor = '#52C9A8'

  return {
    backgroundColor: 'transparent',
    tooltip: buildTooltip(),
    legend: {
      data: ['用水量', '用电量'],
      top: 4,
      icon: 'roundRect',
      itemWidth: 14,
      itemHeight: 8,
      textStyle: { color: '#606266', fontSize: 12 },
    },
    grid: { left: 58, right: 58, top: 44, bottom: 72 },
    dataZoom: [
      { type: 'inside', start: 0, end: 100 },
      {
        type: 'slider',
        height: 18,
        bottom: 24,
        borderColor: 'transparent',
        backgroundColor: '#f0f2f5',
        fillerColor: 'rgba(62,138,184,0.15)',
        handleStyle: { color: '#3E8AB8' },
        textStyle: { color: '#909399', fontSize: 10 },
      },
    ],
    xAxis: {
      type: 'category',
      data: times,
      boundaryGap: false,
      axisLine: { lineStyle: { color: '#dcdfe6' } },
      axisTick: { show: false },
      axisLabel: {
        color: '#909399',
        fontSize: 10,
        interval: Math.max(0, Math.floor(times.length / 8) - 1),
      },
    },
    yAxis: [
      {
        type: 'value',
        name: '用水(L)',
        nameLocation: 'end',
        nameGap: 8,
        nameTextStyle: { color: waterColor, fontSize: 11, align: 'left' },
        position: 'left',
        splitLine: { lineStyle: { type: 'dashed', color: '#ebeef5' } },
        axisLabel: { color: '#909399', fontSize: 10 },
      },
      {
        type: 'value',
        name: '用电(kWh)',
        nameLocation: 'end',
        nameGap: 8,
        nameTextStyle: { color: electricColor, fontSize: 11, align: 'right' },
        position: 'right',
        splitLine: { show: false },
        axisLabel: { color: '#909399', fontSize: 10 },
      },
    ],
    series: [
      buildLineSeries('用水量', waterData, 0, waterColor, false),
      buildLineSeries('用电量', electricData, 1, electricColor, false),
    ],
  }
}

/** 异常趋势：上下分开展示用水/用电，避免双 Y 轴与时间轴重叠 */
function buildAnomalyChartOption(data) {
  const times = data.map(d => {
    const t = d.recordTime || ''
    return t.length >= 16 ? t.substring(5, 16) : t
  })
  const waterData = data.map(d => Number(d.waterUsage) || 0)
  const electricData = data.map(d => Number(d.electricUsage) || 0)
  const waterColor = '#E85D5D'
  const electricColor = '#F5A623'

  return {
    backgroundColor: 'transparent',
    tooltip: buildTooltip(),
    axisPointer: { link: [{ xAxisIndex: 'all' }] },
    legend: {
      data: ['用水量', '用电量'],
      top: 4,
      icon: 'roundRect',
      itemWidth: 14,
      itemHeight: 8,
      textStyle: { color: '#606266', fontSize: 12 },
    },
    grid: [
      { left: 58, right: 20, top: 44, height: '34%' },
      { left: 58, right: 20, top: '52%', height: '34%', bottom: 48 },
    ],
    dataZoom: [
      { type: 'inside', xAxisIndex: [0, 1], start: 0, end: 100 },
    ],
    xAxis: [
      {
        type: 'category',
        gridIndex: 0,
        data: times,
        boundaryGap: false,
        axisLine: { lineStyle: { color: '#dcdfe6' } },
        axisTick: { show: false },
        axisLabel: { show: false },
      },
      {
        type: 'category',
        gridIndex: 1,
        data: times,
        boundaryGap: false,
        axisLine: { lineStyle: { color: '#dcdfe6' } },
        axisTick: { show: false },
        axisLabel: {
          color: '#909399',
          fontSize: 10,
          interval: Math.max(0, Math.floor(times.length / 6) - 1),
          margin: 12,
        },
      },
    ],
    yAxis: [
      {
        type: 'value',
        gridIndex: 0,
        name: '用水量 (L)',
        nameLocation: 'end',
        nameGap: 10,
        nameTextStyle: { color: waterColor, fontSize: 12, fontWeight: 600 },
        splitLine: { lineStyle: { type: 'dashed', color: '#fde2e2' } },
        axisLabel: { color: '#909399', fontSize: 10 },
      },
      {
        type: 'value',
        gridIndex: 1,
        name: '用电量 (kWh)',
        nameLocation: 'end',
        nameGap: 10,
        nameTextStyle: { color: electricColor, fontSize: 12, fontWeight: 600 },
        splitLine: { lineStyle: { type: 'dashed', color: '#faecd8' } },
        axisLabel: { color: '#909399', fontSize: 10 },
      },
    ],
    series: [
      { ...buildLineSeries('用水量', waterData, 0, waterColor, true), xAxisIndex: 0, yAxisIndex: 0 },
      { ...buildLineSeries('用电量', electricData, 0, electricColor, true), xAxisIndex: 1, yAxisIndex: 1 },
    ],
  }
}

function buildTooltip() {
  return {
    trigger: 'axis',
    backgroundColor: 'rgba(255,255,255,0.96)',
    borderColor: '#e4e7ed',
    borderWidth: 1,
    textStyle: { color: '#303133', fontSize: 12 },
    axisPointer: {
      type: 'line',
      lineStyle: { type: 'dashed', color: '#909399' },
    },
    formatter(params) {
      if (!params?.length) return ''
      let html = `<div style="font-weight:600;margin-bottom:6px">${params[0].axisValue}</div>`
      params.forEach(p => {
        const unit = p.seriesName.includes('用水') ? ' L' : ' kWh'
        html += `<div style="display:flex;align-items:center;gap:6px;line-height:1.8">
          ${p.marker}<span>${p.seriesName}</span>
          <span style="margin-left:auto;font-weight:600">${p.value}${unit}</span>
        </div>`
      })
      return html
    },
  }
}

function buildLineSeries(name, data, yAxisIndex, color, isAnomaly) {
  return {
    name,
    type: 'line',
    data,
    yAxisIndex,
    smooth: 0.35,
    symbol: isAnomaly ? 'circle' : 'none',
    symbolSize: 5,
    lineStyle: { width: isAnomaly ? 2.5 : 2, color },
    itemStyle: { color },
    areaStyle: {
      color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
        { offset: 0, color: isAnomaly ? `${color}44` : `${color}38` },
        { offset: 1, color: `${color}05` },
      ]),
    },
  }
}

async function renderMainChart(data) {
  mainChartEmpty.value = !data.length
  if (!data.length) {
    mainChartInstance?.dispose()
    mainChartInstance = null
    return
  }
  await nextTick()
  if (!mainChartRef.value) return
  if (mainChartInstance) mainChartInstance.dispose()
  mainChartInstance = echarts.init(mainChartRef.value)
  mainChartInstance.setOption(buildNormalChartOption(data), true)
  mainChartInstance.resize()
}

async function renderAnomalyChart(data) {
  anomalyChartEmpty.value = !data.length
  if (!data.length) {
    anomalyChartInstance?.dispose()
    anomalyChartInstance = null
    return
  }
  await nextTick()
  if (!anomalyChartRef.value) return
  if (anomalyChartInstance) anomalyChartInstance.dispose()
  anomalyChartInstance = echarts.init(anomalyChartRef.value)
  anomalyChartInstance.setOption(buildAnomalyChartOption(data), true)
  anomalyChartInstance.resize()
}

function handleResize() {
  mainChartInstance?.resize()
  anomalyChartInstance?.resize()
}

async function loadElders() {
  try {
    const res = await getAloneElders({ pageNum: 1, pageSize: 500 })
    aloneElders.value = res.data?.rows || res.data || []
  } catch {
    aloneElders.value = []
  }
}

async function loadMainChart() {
  if (!selectedElder.value) return
  try {
    const res = await getUtilityRecent(selectedElder.value, HOURS_7_DAYS)
    const data = res.data || []
    await renderMainChart(data)
  } catch {
    mainChartEmpty.value = true
    mainChartInstance?.dispose()
    mainChartInstance = null
  }
}

async function loadAnomalyChart() {
  if (!selectedElder.value || !hasAnomalyData.value) return
  try {
    const res = await getUtilityRecent(selectedElder.value, HOURS_24)
    const data = res.data || []
    await renderAnomalyChart(data)
  } catch {
    anomalyChartEmpty.value = true
    anomalyChartInstance?.dispose()
    anomalyChartInstance = null
  }
}

function saveElderAnomalyState(residentId, type) {
  if (!residentId) return
  elderAnomalyState.value = {
    ...elderAnomalyState.value,
    [residentId]: { hasAnomaly: true, type },
  }
}

function clearElderAnomalyState(residentId) {
  if (!residentId) return
  const next = { ...elderAnomalyState.value }
  delete next[residentId]
  elderAnomalyState.value = next
}

function restoreElderAnomalyState(residentId) {
  const saved = elderAnomalyState.value[residentId]
  hasAnomalyData.value = !!saved?.hasAnomaly
  lastAnomalyType.value = saved?.type || ''
}

function onElderChange() {
  checkResult.value = null
  clearAnomalyChart()
  restoreElderAnomalyState(selectedElder.value)
  loadMainChart()
  if (hasAnomalyData.value) {
    loadAnomalyChart()
  }
}

async function handleSimulateAnomaly() {
  if (!selectedElder.value) return
  simLoading.value = true
  simMode.value = 'anomaly'
  try {
    const types = ['no_living_sign', 'no_usage', 'surge', 'night_high']
    const randomType = types[Math.floor(Math.random() * types.length)]
    const res = await simulateAnomalyData(selectedElder.value, randomType)
    const payload = res.data || {}
    lastAnomalyType.value = payload.anomalyType || randomType
    hasAnomalyData.value = true
    saveElderAnomalyState(selectedElder.value, lastAnomalyType.value)
    checkResult.value = payload.checkResult || null
    ElMessage.success(
      payload.message
      || `已为【${selectedElderName.value}】生成近24小时异常数据（${ANOMALY_TYPE_LABEL[lastAnomalyType.value]}），并完成安全监测`
    )
    await loadMainChart()
    await loadAnomalyChart()
  } finally {
    simLoading.value = false
    simMode.value = ''
  }
}

async function handleSimulateNormal() {
  if (!selectedElder.value) return
  simLoading.value = true
  simMode.value = 'normal'
  try {
    const res = await simulateNormalData(selectedElder.value, 7)
    ElMessage.success(res.data || `已为【${selectedElderName.value}】生成近 7 天正常水电数据`)
    hasAnomalyData.value = false
    lastAnomalyType.value = ''
    clearElderAnomalyState(selectedElder.value)
    checkResult.value = null
    clearAnomalyChart()
    await loadMainChart()
  } finally {
    simLoading.value = false
    simMode.value = ''
  }
}

onMounted(async () => {
  window.addEventListener('resize', handleResize)
  await loadElders()
  const defaultElder = aloneElders.value.find(e => e.name === DEFAULT_ELDER_NAME)
    || aloneElders.value[0]
  if (defaultElder) {
    selectedElder.value = defaultElder.residentId
    await loadMainChart()
  }
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize)
  mainChartInstance?.dispose()
  anomalyChartInstance?.dispose()
})
</script>

<style scoped lang="scss">
.utility-monitor {
  padding: 16px;
}

.toolbar-card {
  margin-bottom: 16px;
}

.toolbar-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  align-items: center;
}

.btn-normal {
  --el-button-bg-color: #52c9a8;
  --el-button-border-color: #52c9a8;
  --el-button-hover-bg-color: #45b897;
  --el-button-hover-border-color: #45b897;
  --el-button-active-bg-color: #3aa686;
  --el-button-active-border-color: #3aa686;
  color: #fff;
}

.btn-anomaly {
  --el-button-bg-color: #e85d5d;
  --el-button-border-color: #e85d5d;
  --el-button-hover-bg-color: #d94f4f;
  --el-button-hover-border-color: #d94f4f;
  --el-button-active-bg-color: #c94444;
  --el-button-active-border-color: #c94444;
  color: #fff;
}

.result-card {
  margin-bottom: 16px;

  &.result-normal {
    border-left: 4px solid #67c23a;
  }

  &.result-alert {
    border-left: 4px solid #f56c6c;
  }
}

.result-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: 600;
}

.anomaly-list {
  margin-top: 12px;

  .anomaly-item {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 6px;

    .anomaly-desc {
      font-size: 13px;
      color: #606266;
    }
  }
}

.chart-card {
  margin-bottom: 16px;
  border-radius: 10px;
  overflow: hidden;

  &--normal {
    border-top: 3px solid #3e8ab8;
  }

  &--anomaly {
    border-top: 3px solid #e85d5d;
    background: linear-gradient(180deg, #fffbfb 0%, #fff 48px);
  }
}

.chart-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;

  &__title {
    display: flex;
    flex-direction: column;
    gap: 2px;
  }
}

.chart-title {
  font-weight: 600;
  font-size: 15px;
  color: #303133;
}

.chart-subtitle {
  font-size: 12px;
  color: #909399;
  font-weight: 400;
}

.chart-box {
  width: 100%;
  height: 340px;

  &--anomaly {
    height: 420px;
  }
}

.chart-empty {
  padding: 24px 0;
}

.check-hint {
  margin-top: 12px;
  font-size: 13px;
  color: #3e8ab8;

  &--warn {
    color: #e6a23c;
  }
}
</style>
