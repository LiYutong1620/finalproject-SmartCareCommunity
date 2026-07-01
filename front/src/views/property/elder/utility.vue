<template>
  <div class="app-container utility-monitor">
    <!-- 顶部操作区 -->
    <el-card shadow="never" class="toolbar-card">
      <el-row :gutter="16" align="middle">
        <el-col :span="6">
          <el-select
            v-model="selectedElder"
            placeholder="选择独居老人"
            filterable
            style="width: 100%"
            @change="onElderChange"
          >
            <el-option
              v-for="e in aloneElders"
              :key="e.residentId"
              :label="`${e.name}（ID:${e.residentId}）`"
              :value="e.residentId"
            />
          </el-select>
        </el-col>
        <el-col :span="18">
          <el-button-group>
            <el-button
              type="primary"
              icon="Refresh"
              :loading="checkLoading"
              :disabled="!selectedElder"
              @click="handleCheck"
              >AI异常检测</el-button
            >
            <el-button
              type="success"
              icon="DataLine"
              :disabled="!selectedElder"
              @click="handleSimulateNormal"
              >生成正常数据</el-button
            >
            <el-button
              type="warning"
              :disabled="!selectedElder"
              :loading="simLoading"
              @click="handleSimulateAnomaly"
              >生成异常数据</el-button
            >
          </el-button-group>
        </el-col>
      </el-row>
    </el-card>

    <!-- AI检测结果展示 -->
    <el-card
      v-if="checkResult"
      shadow="never"
      class="result-card"
      :class="resultCardClass"
    >
      <template #header>
        <div class="result-header">
          <span>最近检测结果</span>
          <el-tag :type="resultTagType" effect="dark">{{
            resultStatusText
          }}</el-tag>
        </div>
      </template>
      <el-descriptions :column="2" border size="small">
        <el-descriptions-item label="检测时间">{{
          checkResult.checkTime
        }}</el-descriptions-item>
        <el-descriptions-item label="异常数量">{{
          checkResult.anomalyCount
        }}</el-descriptions-item>
        <el-descriptions-item label="预警ID" v-if="checkResult.alertId">{{
          checkResult.alertId
        }}</el-descriptions-item>
        <el-descriptions-item label="工单ID" v-if="checkResult.careOrderId">{{
          checkResult.careOrderId
        }}</el-descriptions-item>
      </el-descriptions>
      <div
        v-if="checkResult.anomalies && checkResult.anomalies.length"
        class="anomaly-list"
      >
        <div
          v-for="(a, i) in checkResult.anomalies"
          :key="i"
          class="anomaly-item"
        >
          <el-tag :type="a.level === 1 ? 'danger' : 'warning'" size="small">{{
            a.level === 1 ? "高风险" : "中风险"
          }}</el-tag>
          <span class="anomaly-desc">{{ a.description }}</span>
        </div>
      </div>
      <div v-if="checkResult.aiAnalysis" class="ai-analysis">
        <div class="ai-title">AI分析建议：</div>
        <div class="ai-text">{{ checkResult.aiAnalysis }}</div>
      </div>
    </el-card>

    <!-- 水电数据图表 -->
    <el-card v-if="selectedElder" shadow="never" class="chart-card">
      <template #header>
        <div class="card-header">
          <span>水电使用趋势（最近48小时）</span>
          <el-button icon="Refresh" size="small" @click="loadChartData"
            >刷新</el-button
          >
        </div>
      </template>
      <div ref="chartRef" style="height: 320px; width: 100%"></div>
    </el-card>

    <!-- 数据列表 -->
    <el-card v-if="selectedElder" shadow="never" class="table-card">
      <template #header>
        <div class="card-header">
          <span>水电数据记录</span>
        </div>
      </template>
      <el-table
        :data="dataList"
        v-loading="listLoading"
        border
        stripe
        size="small"
      >
        <el-table-column
          prop="recordTime"
          label="时间"
          width="170"
          align="center"
        />
        <el-table-column
          prop="waterUsage"
          label="用水量(L)"
          width="110"
          align="center"
        />
        <el-table-column
          prop="electricUsage"
          label="用电量(kWh)"
          width="120"
          align="center"
        />
        <el-table-column prop="source" label="来源" width="90" align="center">
          <template #default="{ row }">
            <el-tag
              :type="row.source === 'real' ? 'success' : 'info'"
              size="small"
            >
              {{ row.source === "real" ? "实际" : "模拟" }}
            </el-tag>
          </template>
        </el-table-column>
      </el-table>
      <Pagination
        v-show="dataTotal > 0"
        :total="dataTotal"
        v-model:page="listQuery.pageNum"
        v-model:limit="listQuery.pageSize"
        @pagination="loadDataList"
      />
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, nextTick, watch } from "vue";
import { ElMessage } from "element-plus";
import * as echarts from "echarts";
import {
  getAloneElders,
  getUtilityList,
  getUtilityRecent,
  utilityCheck,
  simulateNormalData,
  simulateAnomalyData,
} from "@/api/elderAi";

const aloneElders = ref([]);
const selectedElder = ref(null);
const checkLoading = ref(false);
const checkResult = ref(null);
const listLoading = ref(false);
const dataList = ref([]);
const dataTotal = ref(0);
const listQuery = reactive({ pageNum: 1, pageSize: 20 });
const simLoading = ref(false);
const chartRef = ref(null);
let chartInstance = null;

const resultTagType = computed(() => {
  if (!checkResult.value) return "info";
  if (checkResult.value.status === "normal") return "success";
  return "danger";
});
const resultStatusText = computed(() => {
  if (!checkResult.value) return "";
  if (checkResult.value.status === "normal") return "正常";
  return `异常(${checkResult.value.anomalyCount}项)`;
});
const resultCardClass = computed(() => {
  if (!checkResult.value) return "";
  return checkResult.value.status === "normal"
    ? "result-normal"
    : "result-alert";
});

async function loadElders() {
  try {
    const res = await getAloneElders();
    aloneElders.value = res.data || [];
  } catch {
    /* ignore */
  }
}

function onElderChange() {
  checkResult.value = null;
  loadDataList();
  loadChartData();
}

async function loadDataList() {
  if (!selectedElder.value) return;
  listLoading.value = true;
  try {
    const res = await getUtilityList({
      residentId: selectedElder.value,
      ...listQuery,
    });
    dataList.value = res.data.rows || [];
    dataTotal.value = res.data.total || 0;
  } finally {
    listLoading.value = false;
  }
}

async function loadChartData() {
  if (!selectedElder.value) return;
  try {
    const res = await getUtilityRecent(selectedElder.value, 48);
    const data = res.data || [];
    renderChart(data);
  } catch {
    /* ignore */
  }
}

function renderChart(data) {
  if (!chartRef.value) return;
  if (!chartInstance) {
    chartInstance = echarts.init(chartRef.value);
  }
  const times = data.map((d) => {
    const t = d.recordTime || "";
    return t.substring(5, 16); // MM-DD HH:mm
  });
  const waterData = data.map((d) => d.waterUsage || 0);
  const electricData = data.map((d) => d.electricUsage || 0);

  chartInstance.setOption(
    {
      tooltip: { trigger: "axis" },
      legend: { data: ["用水量(L)", "用电量(kWh)"] },
      grid: { left: 50, right: 30, top: 40, bottom: 40 },
      xAxis: {
        type: "category",
        data: times,
        axisLabel: { rotate: 45, fontSize: 10 },
      },
      yAxis: [
        { type: "value", name: "用水量(L)", position: "left" },
        { type: "value", name: "用电量(kWh)", position: "right" },
      ],
      series: [
        {
          name: "用水量(L)",
          type: "line",
          data: waterData,
          smooth: true,
          yAxisIndex: 0,
          itemStyle: { color: "#409EFF" },
        },
        {
          name: "用电量(kWh)",
          type: "line",
          data: electricData,
          smooth: true,
          yAxisIndex: 1,
          itemStyle: { color: "#E6A23C" },
        },
      ],
    },
    true,
  );
}

async function handleCheck() {
  if (!selectedElder.value) return;
  checkLoading.value = true;
  try {
    const res = await utilityCheck(selectedElder.value);
    checkResult.value = res.data;
    ElMessage.success("检测完成");
    loadDataList();
  } finally {
    checkLoading.value = false;
  }
}

async function handleSimulateNormal() {
  if (!selectedElder.value) return;
  simLoading.value = true;
  try {
    const res = await simulateNormalData(selectedElder.value, 7);
    ElMessage.success(res.data || "模拟数据已生成");
    loadDataList();
    loadChartData();
  } finally {
    simLoading.value = false;
  }
}

async function handleSimulateAnomaly() {
  if (!selectedElder.value) return;
  simLoading.value = true;
  try {
    // 随机选择异常类型
    const types = ["no_usage", "surge", "night_high"];
    const randomType = types[Math.floor(Math.random() * types.length)];
    const res = await simulateAnomalyData(selectedElder.value, randomType);
    ElMessage.success(res.data || "异常数据已生成");
    loadDataList();
    loadChartData();
  } finally {
    simLoading.value = false;
  }
}

onMounted(() => {
  loadElders();
});
</script>

<style scoped lang="scss">
.utility-monitor {
  padding: 16px;
}
.toolbar-card {
  margin-bottom: 16px;
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
.ai-analysis {
  margin-top: 12px;
  padding: 10px 14px;
  background: #f5f7fa;
  border-radius: 6px;
  border-left: 3px solid #409eff;
  .ai-title {
    font-weight: 600;
    color: #303133;
    margin-bottom: 6px;
  }
  .ai-text {
    font-size: 13px;
    line-height: 1.6;
    color: #606266;
    white-space: pre-wrap;
  }
}
.chart-card,
.table-card {
  margin-bottom: 16px;
}
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: 600;
}
</style>
