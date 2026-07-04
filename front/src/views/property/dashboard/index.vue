<template>
  <div class="dashboard-container">
    <!-- KPI -->
    <el-row :gutter="20">
      <el-col :span="6" v-for="card in kpiCards" :key="card.label">
        <div class="kpi-card" :style="{ '--accent': card.color }">
          <div class="kpi-icon" :style="{ background: card.iconBg }">
            <el-icon :size="26" :color="card.color"><component :is="card.icon" /></el-icon>
          </div>
          <div class="kpi-info">
            <div class="kpi-value">{{ card.value }}</div>
            <div class="kpi-label">{{ card.label }}</div>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 工单完成率 + 预警处理 -->
    <el-row :gutter="20" class="chart-row">
      <el-col :xs="24" :lg="12">
        <el-card shadow="never" class="chart-card">
          <template #header>
            <div class="chart-header">
              <span class="chart-title">工单完成率趋势</span>
              <el-radio-group v-model="ratePeriod" size="small" @change="loadCompletionRate">
                <el-radio-button label="day">日</el-radio-button>
                <el-radio-button label="week">周</el-radio-button>
                <el-radio-button label="month">月</el-radio-button>
              </el-radio-group>
            </div>
          </template>
          <div ref="rateChartRef" class="chart-box" />
        </el-card>
      </el-col>
      <el-col :xs="24" :lg="12">
        <el-card shadow="never" class="chart-card">
          <template #header><span class="chart-title">预警处理趋势</span></template>
          <div ref="alertProcessRef" class="chart-box" />
        </el-card>
      </el-col>
    </el-row>

    <!-- 报修类型 + 楼栋热力 -->
    <el-row :gutter="20" class="chart-row">
      <el-col :xs="24" :lg="12">
        <el-card shadow="never" class="chart-card">
          <template #header>
            <span class="chart-title">报修类型分布</span>
            <span class="chart-sub">南丁格尔玫瑰图 · 花瓣半径代表报修量</span>
          </template>
          <div ref="repairTypeRef" class="chart-box" />
        </el-card>
      </el-col>
      <el-col :xs="24" :lg="12">
        <el-card shadow="never" class="chart-card">
          <template #header>
            <span class="chart-title">楼栋报修热力</span>
            <span class="chart-sub">面积=报修量 · 马卡龙暖色渐变</span>
          </template>
          <div ref="buildingHeatRef" class="chart-box" />
        </el-card>
      </el-col>
    </el-row>

    <!-- 住户结构 + 房屋结构 -->
    <el-row :gutter="20" class="chart-row">
      <el-col :xs="24" :lg="12">
        <el-card shadow="never" class="chart-card">
          <template #header>
            <span class="chart-title">住户结构</span>
            <span class="chart-sub">年龄段 · 雷达对比</span>
          </template>
          <div ref="residentRef" class="chart-box" />
        </el-card>
      </el-col>
      <el-col :xs="24" :lg="12">
        <el-card shadow="never" class="chart-card">
          <template #header>
            <span class="chart-title">房屋结构</span>
            <span class="chart-sub">Treemap 户型 · 环形面积段</span>
          </template>
          <div ref="houseRef" class="chart-box" />
        </el-card>
      </el-col>
    </el-row>

    <!-- AI 安全预测 -->
    <el-card shadow="never" class="ai-card chart-row">
      <template #header>
        <div class="ai-header">
          <div>
            <span class="chart-title">AI 安全预测</span>
            <p class="ai-desc">
              AI 智能体综合报修数据、预警信息、公共设施运行状态，对楼栋高风险问题、高频故障点位进行预判，
              主动推送预防性维护建议，实现从被动维修向主动预防转变。
            </p>
          </div>
          <el-tag type="danger" effect="plain" v-if="aiData.pendingDeviceAlerts">
            设备预警 {{ aiData.pendingDeviceAlerts }}
          </el-tag>
          <el-tag type="warning" effect="plain" v-if="aiData.pendingElderAlerts">
            老人预警 {{ aiData.pendingElderAlerts }}
          </el-tag>
        </div>
      </template>

      <div class="ai-overview">{{ aiData.overview || '加载中…' }}</div>

      <el-row :gutter="16" class="ai-body">
        <el-col :xs="24" :md="10">
          <div class="ai-panel-title">楼栋风险指数</div>
          <div ref="riskBuildingRef" class="chart-box chart-box--sm" />
        </el-col>
        <el-col :xs="24" :md="14">
          <div class="ai-panel-title">预防性维护建议</div>
          <div class="suggest-list">
            <div
              v-for="(item, idx) in aiData.suggestions || []"
              :key="idx"
              class="suggest-item"
              :class="'level-' + (item.level === '高' ? 'high' : item.level === '中' ? 'mid' : 'low')"
            >
              <div class="suggest-top">
                <span class="suggest-title">{{ item.title }}</span>
                <el-tag size="small" :type="item.level === '高' ? 'danger' : item.level === '中' ? 'warning' : 'info'">
                  {{ item.level }}风险
                </el-tag>
              </div>
              <p class="suggest-content">{{ item.content }}</p>
            </div>
          </div>
        </el-col>
      </el-row>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount, nextTick, shallowRef } from 'vue'
import * as echarts from 'echarts'
import { Tickets, DocumentAdd, View, Bell } from '@element-plus/icons-vue'
import {
  getSummary,
  getCompletionRate,
  getRepairDistribution,
  getAlertProcessTrend,
  getResidentStructure,
  getHouseStructure,
  getAiSafetyPrediction
} from '@/api/dashboard'

/** 大屏统一马卡龙配色 */
const MACARON = [
  '#A8D8EA', '#FFAAA5', '#A8E6CF', '#FFD3B6', '#C9C9FF',
  '#B5EAD7', '#FFB7B2', '#DCD6F7', '#FFEAA7', '#E2F0CB'
]
const MACARON_SKY = '#A8D8EA'
const MACARON_MINT = '#A8E6CF'
const MACARON_PINK = '#FFAAA5'
const MACARON_PEACH = '#FFD3B6'
const MACARON_LAVENDER = '#C9C9FF'
const MACARON_HEAT = ['#FFF9F5', '#FFE8DC', '#FFD3B6', '#FFBCBC', '#FFAAA5', '#F8A5C2', '#E8909C']

function macaronAt(i) {
  return MACARON[i % MACARON.length]
}

function macaronGradient(i, vertical = true) {
  const base = macaronAt(i)
  return new echarts.graphic.LinearGradient(0, 0, 0, vertical ? 1 : 0, [
    { offset: 0, color: base },
    { offset: 1, color: echarts.color.modifyAlpha(base, 0.62) }
  ])
}

function macaronArea(color, opacity = 0.35) {
  return { color, opacity }
}

const ratePeriod = ref('day')
const aiData = ref({})

const rateChartRef = ref(null)
const alertProcessRef = ref(null)
const repairTypeRef = ref(null)
const buildingHeatRef = ref(null)
const residentRef = ref(null)
const houseRef = ref(null)
const riskBuildingRef = ref(null)

let rateChart = null
let alertProcessChart = null
let repairTypeChart = null
let buildingHeatChart = null
let residentChart = null
let houseChart = null
let riskBuildingChart = null

const kpiCards = ref([
  { label: '总工单数', value: '-', color: '#7EC8E3', iconBg: '#E8F6FA', icon: shallowRef(Tickets) },
  { label: '今日报修', value: '-', color: '#FF9AA2', iconBg: '#FFF0F1', icon: shallowRef(DocumentAdd) },
  { label: '监测老人', value: '-', color: '#88D8B0', iconBg: '#EDFAF3', icon: shallowRef(View) },
  { label: '今日预警', value: '-', color: '#FFBE98', iconBg: '#FFF5EE', icon: shallowRef(Bell) }
])

function updateKpi(summary) {
  kpiCards.value[0].value = summary.totalOrders ?? 0
  kpiCards.value[1].value = summary.todayRepairs ?? 0
  kpiCards.value[2].value = summary.monitorElders ?? 0
  kpiCards.value[3].value = summary.todayAlerts ?? 0
}

function renderRateChart(trendData) {
  if (!rateChartRef.value) return
  if (!rateChart) rateChart = echarts.init(rateChartRef.value)
  rateChart.setOption({
    tooltip: { trigger: 'axis' },
    legend: { data: ['完成率', '总工单数'], top: 4 },
    grid: { left: 50, right: 50, top: 40, bottom: 30 },
    xAxis: { type: 'category', data: trendData.map(d => d.label) },
    yAxis: [
      { type: 'value', name: '完成率', min: 0, max: 100, axisLabel: { formatter: '{value}%' } },
      { type: 'value', name: '工单数', min: 0, minInterval: 1, splitLine: { show: false } }
    ],
    series: [
      {
        name: '总工单数',
        type: 'bar',
        yAxisIndex: 1,
        data: trendData.map(d => d.total),
        barMaxWidth: 24,
        itemStyle: {
          borderRadius: [4, 4, 0, 0],
          color: macaronGradient(0)
        }
      },
      {
        name: '完成率',
        type: 'line',
        yAxisIndex: 0,
        data: trendData.map(d => d.rate),
        smooth: true,
        symbolSize: 7,
        lineStyle: { width: 3, color: MACARON_LAVENDER },
        itemStyle: { color: MACARON_LAVENDER },
        areaStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: 'rgba(201,201,255,0.35)' },
            { offset: 1, color: 'rgba(201,201,255,0.04)' }
          ])
        }
      }
    ]
  }, true)
}

function renderAlertProcessChart(data) {
  if (!alertProcessRef.value) return
  if (!alertProcessChart) alertProcessChart = echarts.init(alertProcessRef.value)
  alertProcessChart.setOption({
    tooltip: { trigger: 'axis' },
    legend: { data: ['新增预警', '已处理'], top: 4 },
    grid: { left: 45, right: 20, top: 40, bottom: 30 },
    xAxis: { type: 'category', data: data.labels || [], boundaryGap: false },
    yAxis: { type: 'value', minInterval: 1 },
    series: [
      {
        name: '新增预警',
        type: 'line',
        data: data.newAlerts || [],
        smooth: true,
        symbol: 'circle',
        itemStyle: { color: MACARON_PINK },
        areaStyle: { color: 'rgba(255,170,165,0.28)' }
      },
      {
        name: '已处理',
        type: 'line',
        data: data.processedAlerts || [],
        smooth: true,
        symbol: 'circle',
        itemStyle: { color: MACARON_MINT },
        areaStyle: { color: 'rgba(168,230,207,0.28)' }
      }
    ]
  }, true)
}

function normalizePieData(data) {
  const map = new Map()
  ;(data || []).forEach(d => {
    const name = (d.name && String(d.name).trim()) || '未分类'
    const value = Number(d.value) || 0
    if (value <= 0) return
    map.set(name, (map.get(name) || 0) + value)
  })
  return [...map.entries()]
    .map(([name, value]) => ({ name, value }))
    .sort((a, b) => b.value - a.value)
}

function typeSliceColor(index) {
  return macaronGradient(index)
}

function shortAgeLabel(name) {
  return String(name).replace(/\(.*\)/, '').trim()
}

function renderRepairTypeChart(data) {
  if (!repairTypeRef.value) return
  const pieData = normalizePieData(data)
  if (!pieData.length) {
    repairTypeChart?.clear()
    return
  }
  if (!repairTypeChart) repairTypeChart = echarts.init(repairTypeRef.value)
  repairTypeChart.setOption({
    tooltip: {
      trigger: 'item',
      confine: true,
      formatter: '{b}<br/>{c} 单 · {d}%'
    },
    legend: {
      type: 'scroll',
      orient: 'vertical',
      right: 4,
      top: 'middle',
      height: '85%',
      textStyle: { fontSize: 12, color: '#606266' },
      pageIconColor: MACARON_SKY,
      pageTextStyle: { color: '#909399' }
    },
    series: [{
      type: 'pie',
      roseType: 'radius',
      radius: ['16%', '72%'],
      center: ['36%', '50%'],
      minAngle: 6,
      itemStyle: {
        borderRadius: 6,
        borderColor: '#fff',
        borderWidth: 2,
        shadowBlur: 6,
        shadowColor: 'rgba(0,0,0,0.08)'
      },
      label: { show: false },
      labelLine: { show: false },
      emphasis: {
        scale: true,
        scaleSize: 8,
        itemStyle: { shadowBlur: 14, shadowColor: 'rgba(0,0,0,0.15)' },
        label: { show: false },
        labelLine: { show: false }
      },
      data: pieData.map((d, i) => ({
        name: d.name,
        value: d.value,
        itemStyle: { color: typeSliceColor(i) }
      }))
    }]
  }, true)
}

function renderBuildingHeatChart(data) {
  if (!buildingHeatRef.value || !data?.length) return
  if (!buildingHeatChart) buildingHeatChart = echarts.init(buildingHeatRef.value)
  const items = data.map(d => ({
    name: d.name || '未知',
    value: Number(d.value) || 0
  }))
  const maxVal = Math.max(...items.map(d => d.value), 1)
  buildingHeatChart.setOption({
    tooltip: {
      formatter: p => `${p.name}<br/>报修 <b>${p.value}</b> 单`
    },
    visualMap: {
      show: true,
      type: 'continuous',
      min: 0,
      max: maxVal,
      orient: 'horizontal',
      left: 'center',
      bottom: 4,
      itemWidth: 14,
      itemHeight: 120,
      text: ['高', '低'],
      textStyle: { fontSize: 11, color: '#909399' },
      inRange: { color: MACARON_HEAT }
    },
    series: [{
      type: 'treemap',
      roam: false,
      nodeClick: false,
      breadcrumb: { show: false },
      left: 8,
      right: 8,
      top: 8,
      bottom: 36,
      label: {
        show: true,
        formatter: '{b}\n{c}单',
        fontSize: 12,
        color: '#666',
        textShadowColor: 'rgba(255,255,255,0.6)',
        textShadowBlur: 2
      },
      upperLabel: { show: false },
      itemStyle: {
        borderColor: '#fff',
        borderWidth: 2,
        gapWidth: 2
      },
      emphasis: {
        itemStyle: { borderColor: '#fff', borderWidth: 3, shadowBlur: 12, shadowColor: 'rgba(0,0,0,0.2)' }
      },
      data: items
    }]
  }, true)
}

function parseResidentStack(sunburst) {
  const children = sunburst?.children || []
  const categories = []
  const ownerData = []
  const familyData = []
  children.forEach(ag => {
    categories.push(shortAgeLabel(ag.name))
    const roles = ag.children || []
    ownerData.push(roles.find(r => r.name === '产权人')?.value || 0)
    familyData.push(roles.find(r => r.name === '家属/租客')?.value || 0)
  })
  return { categories, ownerData, familyData }
}

function renderResidentChart(data) {
  if (!residentRef.value || !data?.sunburst) return
  const { categories, ownerData, familyData } = parseResidentStack(data.sunburst)
  if (!categories.length) {
    residentChart?.clear()
    return
  }
  if (!residentChart) residentChart = echarts.init(residentRef.value)
  const maxVal = Math.max(
    ...categories.map((_, i) => ownerData[i] + familyData[i]),
    1
  )
  const indicators = categories.map(name => ({
    name,
    max: Math.ceil(maxVal * 1.25)
  }))
  residentChart.setOption({
    color: [MACARON_MINT, MACARON_PEACH],
    tooltip: { trigger: 'item' },
    legend: { data: ['产权人', '家属/租客'], bottom: 4 },
    radar: {
      center: ['50%', '48%'],
      radius: '62%',
      splitNumber: 4,
      axisName: { color: '#606266', fontSize: 12 },
      splitLine: { lineStyle: { color: 'rgba(0,0,0,0.06)' } },
      splitArea: {
        areaStyle: {
          color: ['rgba(255,255,255,0.9)', 'rgba(248,250,252,0.9)']
        }
      },
      indicator: indicators
    },
    series: [{
      type: 'radar',
      data: [
        {
          name: '产权人',
          value: ownerData,
          areaStyle: macaronArea(MACARON_MINT, 0.45),
          lineStyle: { width: 2, color: MACARON_MINT },
          itemStyle: { color: MACARON_MINT }
        },
        {
          name: '家属/租客',
          value: familyData,
          areaStyle: macaronArea(MACARON_PEACH, 0.45),
          lineStyle: { width: 2, color: MACARON_PEACH },
          itemStyle: { color: MACARON_PEACH }
        }
      ]
    }]
  }, true)
}

function renderHouseChart(data) {
  if (!houseRef.value) return
  const layout = (data?.byLayout || []).slice(0, 10)
  const area = data?.byAreaRange || []
  if (!layout.length && !area.length) {
    houseChart?.clear()
    return
  }
  if (!houseChart) houseChart = echarts.init(houseRef.value)

  houseChart.setOption({
    tooltip: {
      trigger: 'item',
      formatter: p => {
        const unit = p.seriesName === '面积段' ? '套' : '户'
        return `${p.name}<br/>${p.seriesName}: ${p.value} ${unit}`
      }
    },
    legend: [
      { data: ['户型'], top: 4, left: '12%' },
      { data: ['面积段'], top: 4, right: '8%' }
    ],
    series: [
      {
        name: '户型',
        type: 'treemap',
        left: '4%',
        right: '52%',
        top: '14%',
        bottom: '8%',
        roam: false,
        nodeClick: false,
        breadcrumb: { show: false },
        label: {
          show: true,
          formatter: '{b}\n{c}',
          fontSize: 11,
          color: '#666'
        },
        itemStyle: { borderColor: '#fff', borderWidth: 2, gapWidth: 2 },
        data: layout.map((d, i) => ({
          name: d.name,
          value: Number(d.value) || 0,
          itemStyle: { color: macaronAt(i) }
        }))
      },
      {
        name: '面积段',
        type: 'pie',
        radius: ['36%', '58%'],
        center: ['76%', '52%'],
        itemStyle: { borderRadius: 8, borderColor: '#fff', borderWidth: 2 },
        label: {
          show: true,
          formatter: '{b}\n{d}%',
          fontSize: 11,
          color: '#606266'
        },
        labelLine: { length: 10, length2: 8, smooth: true },
        emphasis: {
          scale: true,
          scaleSize: 6,
          label: { show: true, fontWeight: 'bold' }
        },
        data: area.map((d, i) => ({
          name: d.name,
          value: Number(d.value) || 0,
          itemStyle: { color: macaronAt(i + 3) }
        }))
      }
    ]
  }, true)
}

function renderRiskBuildingChart(buildings) {
  if (!riskBuildingRef.value || !buildings?.length) return
  if (!riskBuildingChart) riskBuildingChart = echarts.init(riskBuildingRef.value)
  const sorted = [...buildings].sort((a, b) => b.score - a.score)
  riskBuildingChart.setOption({
    tooltip: {
      trigger: 'axis',
      formatter: params => {
        const p = params[0]
        const d = sorted[p.dataIndex]
        return `${d.name}<br/>风险指数 ${d.score}<br/>报修 ${d.repairCount} · 预警 ${d.alertCount}`
      }
    },
    grid: { left: 8, right: 40, top: 16, bottom: 8, containLabel: true },
    xAxis: { type: 'value', max: 100, name: '风险指数' },
    yAxis: {
      type: 'category',
      data: sorted.map(d => d.name).reverse(),
      axisLabel: { fontSize: 11 }
    },
    series: [{
      type: 'bar',
      data: sorted.map(d => d.score).reverse(),
      barMaxWidth: 16,
      itemStyle: {
        borderRadius: [0, 8, 8, 0],
        color: params => {
          const v = params.value
          if (v >= 70) return MACARON_PINK
          if (v >= 40) return MACARON_PEACH
          return MACARON_MINT
        }
      },
      label: { show: true, position: 'right', formatter: '{c}' }
    }]
  }, true)
}

async function loadCompletionRate() {
  const res = await getCompletionRate(ratePeriod.value)
  await nextTick()
  renderRateChart((res.data || {}).trendData || [])
}

function handleResize() {
  ;[rateChart, alertProcessChart, repairTypeChart, buildingHeatChart, residentChart, houseChart, riskBuildingChart]
    .forEach(c => c?.resize())
}

onMounted(async () => {
  const [summaryRes, rateRes, distRes, alertRes, residentRes, houseRes, aiRes] = await Promise.all([
    getSummary(),
    getCompletionRate(ratePeriod.value),
    getRepairDistribution(),
    getAlertProcessTrend(),
    getResidentStructure(),
    getHouseStructure(),
    getAiSafetyPrediction()
  ])

  updateKpi(summaryRes.data || {})
  aiData.value = aiRes.data || {}

  await nextTick()
  renderRateChart((rateRes.data || {}).trendData || [])
  renderAlertProcessChart(alertRes.data || {})
  renderRepairTypeChart((distRes.data || {}).byType || [])
  renderBuildingHeatChart((distRes.data || {}).byBuilding || [])
  renderResidentChart(residentRes.data || {})
  renderHouseChart(houseRes.data || {})
  renderRiskBuildingChart(aiData.value.riskBuildings || [])

  window.addEventListener('resize', handleResize)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize)
  ;[rateChart, alertProcessChart, repairTypeChart, buildingHeatChart, residentChart, houseChart, riskBuildingChart]
    .forEach(c => { c?.dispose() })
})
</script>

<style scoped>
.dashboard-container {
  padding: 20px;
  background: #f5f7fa;
  min-height: calc(100vh - 60px);
}

.kpi-card {
  display: flex;
  align-items: center;
  padding: 18px 20px;
  border-radius: 10px;
  margin-bottom: 20px;
  background: var(--el-bg-color);
  border: 1px solid var(--el-border-color-lighter);
  border-top: 3px solid var(--accent, #409eff);
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.04);
  transition: transform 0.25s, box-shadow 0.25s;
}

.kpi-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 18px rgba(168, 216, 234, 0.25);
}

.kpi-icon {
  width: 48px;
  height: 48px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 14px;
  flex-shrink: 0;
}

.kpi-value {
  font-size: 26px;
  font-weight: 700;
  color: var(--accent, #409eff);
  line-height: 1.2;
}

.kpi-label {
  margin-top: 4px;
  color: var(--el-text-color-secondary);
  font-size: 13px;
}

.chart-row {
  margin-bottom: 20px;
}

.chart-card {
  border-radius: 12px;
  border: none;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
  margin-bottom: 10px;
}

.chart-card :deep(.el-card__header) {
  padding: 14px 20px;
  border-bottom: 1px solid #f0f0f0;
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 8px;
}

.chart-title {
  font-size: 15px;
  font-weight: 600;
  color: #333;
}

.chart-sub {
  font-size: 12px;
  color: #999;
  font-weight: 400;
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.chart-box {
  height: 320px;
}

.chart-box--sm {
  height: 260px;
}

.ai-card {
  border-radius: 12px;
  border: none;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
}

.ai-header {
  display: flex;
  flex-wrap: wrap;
  align-items: flex-start;
  gap: 10px;
}

.ai-desc {
  margin: 6px 0 0;
  font-size: 13px;
  color: #888;
  font-weight: 400;
  line-height: 1.6;
  max-width: 720px;
}

.ai-overview {
  padding: 14px 16px;
  margin-bottom: 16px;
  border-radius: 10px;
  background: linear-gradient(135deg, #f5fbff 0%, #fff8f5 100%);
  border: 1px solid #e8f0f5;
  font-size: 14px;
  line-height: 1.75;
  color: #555;
}

.ai-panel-title {
  font-size: 14px;
  font-weight: 600;
  color: #333;
  margin-bottom: 8px;
}

.suggest-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
  max-height: 280px;
  overflow-y: auto;
}

.suggest-item {
  padding: 12px 14px;
  border-radius: 10px;
  border-left: 4px solid #A8D8EA;
  background: #f8fcfe;
}

.suggest-item.level-high {
  border-left-color: #FFAAA5;
  background: #fff8f7;
}

.suggest-item.level-mid {
  border-left-color: #FFD3B6;
  background: #fffcf9;
}

.suggest-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  margin-bottom: 6px;
}

.suggest-title {
  font-weight: 600;
  font-size: 14px;
}

.suggest-content {
  margin: 0;
  font-size: 13px;
  line-height: 1.65;
  color: #555;
}
</style>
