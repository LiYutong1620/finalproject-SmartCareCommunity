<template>
  <div class="app-container">
    <el-card v-loading="loading">
      <template #header>
        <div class="header-wrap">
          <span>月度服务质量趋势</span>
          <el-button @click="$router.back()">返回</el-button>
        </div>
      </template>

      <el-form inline style="margin-bottom: 16px">
        <el-form-item label="月份范围">
          <el-select v-model="months" style="width: 120px" @change="load">
            <el-option label="近3个月" :value="3" />
            <el-option label="近6个月" :value="6" />
            <el-option label="近12个月" :value="12" />
          </el-select>
        </el-form-item>
      </el-form>

      <el-row :gutter="20">
        <el-col :span="12">
          <div class="chart-title">评价得分趋势</div>
          <div v-for="(item, index) in chartData.labels" :key="'score-' + index" class="bar-row">
            <span class="bar-label">{{ item }}</span>
            <div class="bar-track">
              <div class="bar-fill score" :style="{ width: `${(chartData.scoreTrend[index] || 0) * 20}%` }"></div>
            </div>
            <span class="bar-value">{{ chartData.scoreTrend[index] || 0 }}</span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="chart-title">超时率趋势(%)</div>
          <div v-for="(item, index) in chartData.labels" :key="'overtime-' + index" class="bar-row">
            <span class="bar-label">{{ item }}</span>
            <div class="bar-track">
              <div class="bar-fill overtime" :style="{ width: `${Math.min(chartData.overtimeTrend[index] || 0, 100)}%` }"></div>
            </div>
            <span class="bar-value">{{ chartData.overtimeTrend[index] || 0 }}%</span>
          </div>
        </el-col>
      </el-row>

      <el-divider />

      <div class="chart-title">工单量趋势</div>
      <div v-for="(item, index) in chartData.labels" :key="'order-' + index" class="bar-row">
        <span class="bar-label">{{ item }}</span>
        <div class="bar-track">
          <div class="bar-fill order" :style="{ width: `${orderBarWidth(chartData.orderTrend[index])}%` }"></div>
        </div>
        <span class="bar-value">{{ chartData.orderTrend[index] || 0 }}</span>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getRepairMonthlyTrend } from '@/api/repair'

const loading = ref(false)
const months = ref(6)
const chartData = reactive({
  labels: [],
  scoreTrend: [],
  overtimeTrend: [],
  orderTrend: []
})

function orderBarWidth(value) {
  const max = Math.max(...chartData.orderTrend, 1)
  return ((value || 0) / max) * 100
}

async function load() {
  loading.value = true
  try {
    const res = await getRepairMonthlyTrend(months.value)
    chartData.labels = res.data.labels || []
    chartData.scoreTrend = res.data.scoreTrend || []
    chartData.overtimeTrend = res.data.overtimeTrend || []
    chartData.orderTrend = res.data.orderTrend || []
  } finally {
    loading.value = false
  }
}

onMounted(load)
</script>

<style scoped>
.header-wrap {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.chart-title {
  font-weight: 600;
  margin-bottom: 12px;
}
.bar-row {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 10px;
}
.bar-label {
  width: 80px;
  font-size: 13px;
  color: #606266;
}
.bar-track {
  flex: 1;
  height: 16px;
  background: #f2f3f5;
  border-radius: 8px;
  overflow: hidden;
}
.bar-fill {
  height: 100%;
  border-radius: 8px;
}
.bar-fill.score { background: #409eff; }
.bar-fill.overtime { background: #e6a23c; }
.bar-fill.order { background: #67c23a; }
.bar-value {
  width: 56px;
  text-align: right;
  font-size: 13px;
}
</style>
