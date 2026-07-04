<template>

  <div class="app-container report-page">

    <div class="page-head">

      <div>

        <h2 class="page-title">工单复盘</h2>

        <p class="page-desc">按自然周（周一至周日）汇总工单数据，支持选择周期生成复盘报告。</p>

      </div>

    </div>



    <el-card shadow="never" class="gen-card">

      <div class="gen-row">

        <div class="gen-left">

          <span class="gen-label">统计周期</span>

          <el-date-picker

            v-model="generateWeekDate"

            type="date"

            value-format="YYYY-MM-DD"

            placeholder="选择周内任意一天"

            :disabled-date="disableFutureDate"

            style="width: 180px"

          />

          <span class="week-range-tag">{{ weekRangeLabel(generateWeekDate) }}</span>

        </div>

        <div class="gen-right">

          <el-button type="primary" :loading="generating" @click="handleGenerate">生成该周复盘</el-button>

          <span class="gen-tip">未选择日期时，默认生成<strong>上一自然周</strong>复盘</span>

        </div>

      </div>

    </el-card>



    <div v-if="list.length" class="history-bar">

      <span class="history-label">历史复盘</span>

      <div class="history-chips">

        <button

          v-for="item in list"

          :key="item.reportId"

          type="button"

          class="week-chip"

          :class="{ active: selected?.reportId === item.reportId }"

          @click="selectReport(item)"

        >

          {{ item.weekStart }} ~ {{ item.weekEnd }}

        </button>

      </div>

    </div>



    <div v-loading="loading" class="report-body">

      <el-empty v-if="!loading && !selected" description="暂无复盘报告，请先生成" />



      <template v-if="selected">

        <div class="period-banner">

          <el-icon><Calendar /></el-icon>

          <span>复盘周期：<strong>{{ selected.weekStart }}</strong> 至 <strong>{{ selected.weekEnd }}</strong></span>

          <span class="gen-time">生成于 {{ formatDateTime(selected.createTime) }}</span>

        </div>



        <el-row :gutter="14" class="kpi-row">

          <el-col v-for="kpi in kpiCards" :key="kpi.key" :xs="12" :sm="8" :md="4">

            <div class="kpi-card" :style="{ '--accent': kpi.color }">

              <div class="kpi-value">{{ kpi.value }}</div>

              <div class="kpi-label">{{ kpi.label }}</div>

            </div>

          </el-col>

        </el-row>



        <el-row :gutter="16" class="chart-row">

          <el-col :xs="24" :md="12">

            <el-card shadow="never" class="chart-card">

              <template #header>

                <span class="chart-title">核心指标</span>

              </template>

              <div ref="gaugeRef" class="chart-box gauge-box" />

            </el-card>

          </el-col>

          <el-col :xs="24" :md="12">

            <el-card shadow="never" class="chart-card">

              <template #header>

                <span class="chart-title">故障类型分布</span>

                <span class="chart-sub">环形面积 = 本周报修量</span>

              </template>

              <div v-show="typeChartData.length" ref="typeChartRef" class="chart-box" />

              <el-empty v-if="!typeChartData.length" description="本周暂无报修工单" :image-size="56" />

            </el-card>

          </el-col>

        </el-row>



        <el-row :gutter="16" class="chart-row">

          <el-col :xs="24" :md="12">

            <el-card shadow="never" class="chart-card">

              <template #header>

                <span class="chart-title">类型平均完成时长</span>

                <span class="chart-sub">横向对比更直观 · 仅统计已完成单</span>

              </template>

              <div v-show="typeDurationData.length" ref="typeDurationRef" class="chart-box" />

              <el-empty v-if="!typeDurationData.length" description="本周暂无已完成工单" :image-size="56" />

            </el-card>

          </el-col>

          <el-col :xs="24" :md="12">

            <el-card shadow="never" class="chart-card">

              <template #header>

                <span class="chart-title">维修工负载与效率</span>

                <span class="chart-sub">横轴完成单 · 纵轴均时 · 气泡=接单量</span>

              </template>

              <div v-show="workerChartData.length" ref="workerChartRef" class="chart-box" />

              <el-empty v-if="!workerChartData.length" description="本周暂无维修工接单" :image-size="56" />

            </el-card>

          </el-col>

        </el-row>



        <el-card shadow="never" class="summary-card">

          <template #header><span class="chart-title">复盘总结</span></template>

          <el-row :gutter="14">

            <el-col :xs="24" :md="8">

              <div class="summary-block summary-block--good">

                <div class="summary-head">

                  <el-icon><CircleCheck /></el-icon>

                  <span>亮点 / 优点</span>

                </div>

                <ul class="summary-list">

                  <li v-for="(line, idx) in summarySections.highlights" :key="'h' + idx">{{ line }}</li>

                  <li v-if="!summarySections.highlights.length" class="empty-line">暂无数据，请重新生成复盘</li>

                </ul>

              </div>

            </el-col>

            <el-col :xs="24" :md="8">

              <div class="summary-block summary-block--warn">

                <div class="summary-head">

                  <el-icon><Warning /></el-icon>

                  <span>不足 / 待改进</span>

                </div>

                <ul class="summary-list">

                  <li v-for="(line, idx) in summarySections.issues" :key="'i' + idx">{{ line }}</li>

                  <li v-if="!summarySections.issues.length" class="empty-line">暂无明显问题</li>

                </ul>

              </div>

            </el-col>

            <el-col :xs="24" :md="8">

              <div class="summary-block summary-block--action">

                <div class="summary-head">

                  <el-icon><Promotion /></el-icon>

                  <span>优化建议</span>

                </div>

                <ul class="summary-list">

                  <li v-for="(line, idx) in summarySections.suggestions" :key="'s' + idx">{{ line }}</li>

                  <li v-if="!summarySections.suggestions.length" class="empty-line">暂无建议</li>

                </ul>

              </div>

            </el-col>

          </el-row>

        </el-card>

      </template>

    </div>

  </div>

</template>



<script setup>

import { ref, computed, onMounted, watch, nextTick, onBeforeUnmount } from 'vue'

import { ElMessage } from 'element-plus'

import { Calendar, CircleCheck, Warning, Promotion } from '@element-plus/icons-vue'

import * as echarts from 'echarts'

import { listRepairWeeklyReports, generateRepairWeeklyReport } from '@/api/repair'

import { formatDateTime } from '@/utils/orderFormat'



const TYPE_COLORS = ['#5470c6', '#91cc75', '#fac858', '#ee6666', '#73c0de', '#3ba272', '#fc8452', '#9a60b4', '#ea7ccc']



const loading = ref(false)

const generating = ref(false)

const list = ref([])

const selected = ref(null)

const generateWeekDate = ref('')



const gaugeRef = ref(null)

const typeChartRef = ref(null)

const typeDurationRef = ref(null)

const workerChartRef = ref(null)

let gaugeChart = null

let typeChart = null

let typeDurationChart = null

let workerChart = null



function disableFutureDate(d) {

  return d.getTime() > Date.now()

}



function toMonday(dateStr) {

  if (!dateStr) return null

  const d = new Date(dateStr + 'T12:00:00')

  const day = d.getDay()

  const diff = day === 0 ? -6 : 1 - day

  d.setDate(d.getDate() + diff)

  return d.toISOString().slice(0, 10)

}



function weekRangeLabel(dateStr) {

  const start = toMonday(dateStr)

  if (!start) return '默认：上一自然周（周一～周日）'

  const end = new Date(start + 'T12:00:00')

  end.setDate(end.getDate() + 6)

  return `${start} ～ ${end.toISOString().slice(0, 10)}`

}



function parseJsonValue(str, fallback) {

  if (!str) return fallback

  try {

    const val = JSON.parse(str)

    return val ?? fallback

  } catch {

    return fallback

  }

}



function normalizeTypeStats(raw) {

  const data = parseJsonValue(raw, [])

  if (Array.isArray(data)) {

    return data.map(item => ({

      name: item.name || '未分类',

      total: Number(item.total) || 0,

      completed: Number(item.completed) || 0,

      avgHours: item.avgHours != null ? Number(item.avgHours) : null

    }))

  }

  return Object.entries(data).map(([name, val]) => ({

    name,

    total: 0,

    completed: 1,

    avgHours: Number(val) || 0

  }))

}



function normalizeWorkerStats(raw) {

  const data = parseJsonValue(raw, [])

  if (Array.isArray(data)) {

    return data.map(item => ({

      name: item.name || `维修工 ${item.workerId || ''}`,

      assigned: Number(item.assigned) || 0,

      completed: Number(item.completed) || 0,

      avgHours: item.avgHours != null ? Number(item.avgHours) : null

    }))

  }

  return Object.entries(data).map(([key, val]) => ({

    name: key.replace(/^worker-/, '维修工 '),

    assigned: 0,

    completed: 1,

    avgHours: Number(val) || 0

  }))

}



function parseSummary(raw) {

  if (!raw) {

    return { highlights: [], issues: [], suggestions: [] }

  }

  const parsed = parseJsonValue(raw, null)

  if (parsed && typeof parsed === 'object' && !Array.isArray(parsed)) {

    return {

      highlights: (parsed.highlights || []).map(String),

      issues: (parsed.issues || []).map(String),

      suggestions: (parsed.suggestions || []).map(String)

    }

  }

  const lines = String(raw).split(/\n+/).map(s => s.trim()).filter(Boolean)

  return { highlights: [], issues: [], suggestions: lines }

}



const typeChartData = computed(() => normalizeTypeStats(selected.value?.typeStats).filter(d => d.total > 0))



const typeDurationData = computed(() =>

  normalizeTypeStats(selected.value?.typeStats)

    .filter(d => d.completed > 0 && d.avgHours != null)

    .sort((a, b) => b.avgHours - a.avgHours)

)



const workerChartData = computed(() => normalizeWorkerStats(selected.value?.workerStats).filter(d => d.assigned > 0))



const summarySections = computed(() => parseSummary(selected.value?.suggestions))



const kpiCards = computed(() => {

  const r = selected.value

  if (!r) return []

  return [

    { key: 'total', label: '工单总数', value: r.totalOrders ?? 0, color: '#409eff' },

    { key: 'hours', label: '平均完成(h)', value: r.avgCompleteHours ?? 0, color: '#67c23a' },

    { key: 'overtime', label: '超时率(%)', value: r.overtimeRate ?? 0, color: '#e6a23c' },

    { key: 'dup', label: '重复报修(%)', value: r.duplicateRate ?? 0, color: '#f56c6c' },

    { key: 'good', label: '好评率(%)', value: r.goodRate ?? 0, color: '#9b59b6' }

  ]

})



function selectReport(item) {

  selected.value = item

}



async function load() {

  loading.value = true

  try {

    const res = await listRepairWeeklyReports({ pageNum: 1, pageSize: 50 })

    list.value = res.data?.rows || []

    if (list.value.length) {

      if (!selected.value || !list.value.find(r => r.reportId === selected.value.reportId)) {

        selected.value = list.value[0]

      }

    } else {

      selected.value = null

    }

  } finally {

    loading.value = false

  }

}



async function handleGenerate() {

  generating.value = true

  try {

    const params = {}

    if (generateWeekDate.value) {

      params.weekStart = toMonday(generateWeekDate.value)

    }

    const res = await generateRepairWeeklyReport(params)

    ElMessage.success(`已生成 ${res.data?.weekStart} ~ ${res.data?.weekEnd} 复盘`)

    await load()

    if (res.data) selected.value = res.data

  } catch (e) {

    ElMessage.error(e?.message || '生成复盘失败')

  } finally {

    generating.value = false

  }

}



function renderGauge() {

  if (!gaugeRef.value || !selected.value) return

  if (!gaugeChart) gaugeChart = echarts.init(gaugeRef.value)

  const good = Number(selected.value.goodRate) || 0

  const overtime = Number(selected.value.overtimeRate) || 0

  gaugeChart.setOption({

    tooltip: { trigger: 'item' },

    series: [

      {

        type: 'gauge',

        center: ['25%', '55%'],

        radius: '70%',

        min: 0,

        max: 100,

        axisLine: { lineStyle: { width: 10, color: [[0.6, '#f56c6c'], [0.85, '#e6a23c'], [1, '#67c23a']] } },

        detail: { formatter: '{value}%', fontSize: 16 },

        title: { offsetCenter: [0, '78%'], fontSize: 13 },

        data: [{ value: good, name: '好评率' }]

      },

      {

        type: 'gauge',

        center: ['75%', '55%'],

        radius: '70%',

        min: 0,

        max: 100,

        axisLine: { lineStyle: { width: 10, color: [[0.3, '#67c23a'], [0.6, '#e6a23c'], [1, '#f56c6c']] } },

        detail: { formatter: '{value}%', fontSize: 16 },

        title: { offsetCenter: [0, '78%'], fontSize: 13 },

        data: [{ value: overtime, name: '超时率' }]

      }

    ]

  })

}



function renderTypePie() {

  if (!typeChartRef.value) return

  if (!typeChartData.value.length) {

    typeChart?.clear()

    return

  }

  if (!typeChart) typeChart = echarts.init(typeChartRef.value)

  typeChart.setOption({

    color: TYPE_COLORS,

    tooltip: {

      trigger: 'item',

      formatter: p => {

        const d = typeChartData.value[p.dataIndex]

        const avg = d.avgHours != null ? `${d.avgHours}h` : '—'

        return `${p.name}<br/>报修 ${d.total} 单 · 完成 ${d.completed} 单<br/>均时 ${avg}`

      }

    },

    legend: {

      type: 'scroll',

      orient: 'vertical',

      right: 8,

      top: 'middle',

      textStyle: { fontSize: 11 }

    },

    series: [{

      type: 'pie',

      radius: ['42%', '68%'],

      center: ['38%', '50%'],

      avoidLabelOverlap: true,

      itemStyle: { borderRadius: 6, borderColor: '#fff', borderWidth: 2 },

      label: { show: false },

      emphasis: {

        label: { show: true, fontSize: 13, fontWeight: 'bold' }

      },

      data: typeChartData.value.map(d => ({ name: d.name, value: d.total }))

    }]

  }, true)

}



function renderTypeDuration() {

  if (!typeDurationRef.value) return

  if (!typeDurationData.value.length) {

    typeDurationChart?.clear()

    return

  }

  if (!typeDurationChart) typeDurationChart = echarts.init(typeDurationRef.value)

  const names = typeDurationData.value.map(d => d.name).reverse()

  const values = typeDurationData.value.map(d => d.avgHours).reverse()

  const maxVal = Math.max(...values, 1)

  typeDurationChart.setOption({

    tooltip: {

      trigger: 'axis',

      axisPointer: { type: 'shadow' },

      formatter: params => {

        const p = params[0]

        const d = typeDurationData.value[typeDurationData.value.length - 1 - p.dataIndex]

        return `${p.name}<br/>平均 ${p.value}h · 完成 ${d.completed} 单`

      }

    },

    grid: { left: 8, right: 48, top: 16, bottom: 8, containLabel: true },

    xAxis: {

      type: 'value',

      name: '小时',

      max: Math.ceil(maxVal * 1.15)

    },

    yAxis: {

      type: 'category',

      data: names,

      axisLabel: { width: 72, overflow: 'truncate', fontSize: 11 }

    },

    series: [{

      type: 'bar',

      data: values,

      barMaxWidth: 18,

      itemStyle: {

        borderRadius: [0, 10, 10, 0],

        color: params => {

          const ratio = params.value / maxVal

          if (ratio > 0.7) return '#f56c6c'

          if (ratio > 0.4) return '#e6a23c'

          return '#67c23a'

        }

      },

      label: {

        show: true,

        position: 'right',

        formatter: '{c}h',

        fontSize: 11

      }

    }]

  }, true)

}



function renderWorkerBubble() {

  if (!workerChartRef.value) return

  if (!workerChartData.value.length) {

    workerChart?.clear()

    return

  }

  if (!workerChart) workerChart = echarts.init(workerChartRef.value)

  const maxAssigned = Math.max(...workerChartData.value.map(d => d.assigned), 1)

  const maxCompleted = Math.max(...workerChartData.value.map(d => d.completed), 1)

  const maxHours = Math.max(...workerChartData.value.map(d => d.avgHours || 0), 1)



  workerChart.setOption({

    tooltip: {

      trigger: 'item',

      formatter: p => {

        const d = p.data

        const avg = d.avgHours != null ? `${d.avgHours}h` : '暂无完成单'

        return `${d.name}<br/>接单 ${d.assigned} · 完成 ${d.completed}<br/>均时 ${avg}`

      }

    },

    grid: { left: 48, right: 24, top: 36, bottom: 40 },

    xAxis: {

      name: '完成单数',

      min: 0,

      max: Math.max(maxCompleted + 1, 3),

      splitLine: { lineStyle: { type: 'dashed' } }

    },

    yAxis: {

      name: '均时(h)',

      min: 0,

      max: Math.ceil(maxHours * 1.2) || 24,

      splitLine: { lineStyle: { type: 'dashed' } }

    },

    series: [{

      type: 'scatter',

      symbolSize: data => 28 + (data[2] / maxAssigned) * 36,

      data: workerChartData.value.map(d => ({

        name: d.name,

        value: [d.completed, d.avgHours ?? 0, d.assigned],

        assigned: d.assigned,

        completed: d.completed,

        avgHours: d.avgHours,

        label: { show: true, formatter: d.name, position: 'top', fontSize: 11 }

      })),

      itemStyle: {

        color: '#409eff',

        opacity: 0.75,

        shadowBlur: 8,

        shadowColor: 'rgba(64,158,255,0.35)'

      },

      emphasis: {

        itemStyle: { opacity: 1, borderColor: '#fff', borderWidth: 2 }

      }

    }]

  }, true)

}



function renderAllCharts() {

  nextTick(() => {

    renderGauge()

    renderTypePie()

    renderTypeDuration()

    renderWorkerBubble()

  })

}



function disposeCharts() {

  gaugeChart?.dispose()

  typeChart?.dispose()

  typeDurationChart?.dispose()

  workerChart?.dispose()

  gaugeChart = typeChart = typeDurationChart = workerChart = null

}



watch(selected, () => renderAllCharts(), { deep: true })



function onResize() {

  gaugeChart?.resize()

  typeChart?.resize()

  typeDurationChart?.resize()

  workerChart?.resize()

}



onMounted(() => {

  load()

  window.addEventListener('resize', onResize)

})



onBeforeUnmount(() => {

  window.removeEventListener('resize', onResize)

  disposeCharts()

})

</script>



<style scoped>

.report-page {

  max-width: 1100px;

}



.page-head {

  margin-bottom: 16px;

}



.page-title {

  margin: 0 0 6px;

  font-size: 22px;

  font-weight: 600;

}



.page-desc {

  margin: 0;

  font-size: 14px;

  color: var(--el-text-color-secondary);

}



.gen-card {

  margin-bottom: 16px;

  border-radius: 10px;

  border: 1px solid var(--el-border-color-lighter);

}



.gen-row {

  display: flex;

  flex-wrap: wrap;

  align-items: center;

  justify-content: space-between;

  gap: 12px;

}



.gen-left,

.gen-right {

  display: flex;

  flex-wrap: wrap;

  align-items: center;

  gap: 10px;

}



.gen-label {

  font-size: 14px;

  color: var(--el-text-color-regular);

}



.week-range-tag {

  font-size: 13px;

  color: var(--el-color-primary);

  background: var(--el-color-primary-light-9);

  padding: 4px 10px;

  border-radius: 6px;

}



.gen-tip {

  font-size: 12px;

  color: var(--el-text-color-secondary);

}



.history-bar {

  display: flex;

  align-items: flex-start;

  gap: 12px;

  margin-bottom: 16px;

}



.history-label {

  flex-shrink: 0;

  font-size: 13px;

  color: var(--el-text-color-secondary);

  line-height: 32px;

}



.history-chips {

  display: flex;

  flex-wrap: wrap;

  gap: 8px;

}



.week-chip {

  border: 1px solid var(--el-border-color);

  background: var(--el-fill-color-blank);

  border-radius: 8px;

  padding: 6px 12px;

  font-size: 13px;

  cursor: pointer;

  transition: all 0.2s;

}



.week-chip:hover {

  border-color: var(--el-color-primary-light-5);

  color: var(--el-color-primary);

}



.week-chip.active {

  border-color: var(--el-color-primary);

  background: var(--el-color-primary-light-9);

  color: var(--el-color-primary);

  font-weight: 600;

}



.period-banner {

  display: flex;

  flex-wrap: wrap;

  align-items: center;

  gap: 10px;

  padding: 12px 16px;

  margin-bottom: 14px;

  border-radius: 10px;

  background: linear-gradient(135deg, #f0f7ff 0%, #fafcff 100%);

  border: 1px solid #dce8f7;

  font-size: 14px;

}



.gen-time {

  margin-left: auto;

  font-size: 12px;

  color: var(--el-text-color-secondary);

}



.kpi-row {

  margin-bottom: 14px;

}



.kpi-card {

  padding: 14px;

  border-radius: 10px;

  border: 1px solid var(--el-border-color-lighter);

  border-top: 3px solid var(--accent, #409eff);

  background: var(--el-fill-color-blank);

  margin-bottom: 10px;

}



.kpi-value {

  font-size: 24px;

  font-weight: 700;

  color: var(--accent);

  line-height: 1.2;

}



.kpi-label {

  margin-top: 4px;

  font-size: 12px;

  color: var(--el-text-color-secondary);

}



.chart-row {

  margin-bottom: 14px;

}



.chart-card {

  border-radius: 10px;

  border: 1px solid var(--el-border-color-lighter);

  margin-bottom: 10px;

}



.chart-card :deep(.el-card__header) {

  display: flex;

  align-items: baseline;

  justify-content: space-between;

  gap: 8px;

  flex-wrap: wrap;

}



.chart-title {

  font-weight: 600;

  font-size: 14px;

}



.chart-sub {

  font-size: 12px;

  color: var(--el-text-color-secondary);

  font-weight: 400;

}



.chart-box {

  height: 280px;

}



.gauge-box {

  height: 240px;

}



.summary-card {

  border-radius: 10px;

  border: 1px solid var(--el-border-color-lighter);

}



.summary-block {

  border-radius: 10px;

  padding: 14px 16px;

  min-height: 180px;

  margin-bottom: 10px;

}



.summary-block--good {

  background: linear-gradient(180deg, #f0f9eb 0%, #fafdf8 100%);

  border: 1px solid #e1f3d8;

}



.summary-block--warn {

  background: linear-gradient(180deg, #fdf6ec 0%, #fffbf5 100%);

  border: 1px solid #faecd8;

}



.summary-block--action {

  background: linear-gradient(180deg, #ecf5ff 0%, #f8fbff 100%);

  border: 1px solid #d9ecff;

}



.summary-head {

  display: flex;

  align-items: center;

  gap: 6px;

  font-weight: 600;

  font-size: 14px;

  margin-bottom: 12px;

}



.summary-block--good .summary-head { color: #67c23a; }

.summary-block--warn .summary-head { color: #e6a23c; }

.summary-block--action .summary-head { color: #409eff; }



.summary-list {

  margin: 0;

  padding-left: 18px;

  font-size: 13px;

  line-height: 1.75;

  color: var(--el-text-color-regular);

}



.summary-list li {

  margin-bottom: 6px;

}



.empty-line {

  list-style: none;

  margin-left: -18px;

  color: var(--el-text-color-secondary);

}

</style>

