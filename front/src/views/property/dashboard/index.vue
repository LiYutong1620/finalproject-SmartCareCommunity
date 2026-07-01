<template>
  <div class="app-container">
    <!-- 顶部KPI统计卡片 -->
    <el-row :gutter="16">
      <el-col :span="4" v-for="card in kpiCards" :key="card.label">
        <el-card shadow="hover" class="kpi-card">
          <div class="kpi-value" :style="{ color: card.color }">
            {{ card.value }}
          </div>
          <div class="kpi-label">{{ card.label }}</div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 指令一：工单完成率（折线图+柱状图，双Y轴，日/周/月切换） -->
    <el-row :gutter="16" class="chart-row">
      <el-col :span="24">
        <el-card shadow="never">
          <template #header>
            <div class="chart-header">
              <span>工单完成率趋势</span>
              <el-radio-group
                v-model="ratePeriod"
                size="small"
                @change="loadCompletionRate"
              >
                <el-radio-button label="day">日</el-radio-button>
                <el-radio-button label="week">周</el-radio-button>
                <el-radio-button label="month">月</el-radio-button>
              </el-radio-group>
            </div>
          </template>
          <div ref="rateChartRef" class="chart-box"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 指令二：报修分布（饼图+柱状图，左右并排） -->
    <el-row :gutter="16" class="chart-row">
      <el-col :span="12">
        <el-card shadow="never">
          <template #header>报修分布（按故障类型）</template>
          <div ref="repairTypeRef" class="chart-box"></div>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card shadow="never">
          <template #header>报修分布（按楼栋）</template>
          <div ref="repairBuildingRef" class="chart-box"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 指令三：预警次数趋势图（双折线图+面积填充+日期选择） -->
    <el-row :gutter="16" class="chart-row">
      <el-col :span="24">
        <el-card shadow="never">
          <template #header>
            <div class="chart-header">
              <span>预警次数趋势</span>
              <el-date-picker
                v-model="alertDateRange"
                type="daterange"
                range-separator="~"
                start-placeholder="开始日期"
                end-placeholder="结束日期"
                size="small"
                value-format="YYYY-MM-DD"
                :shortcuts="dateShortcuts"
                @change="onAlertDateChange"
              />
            </div>
          </template>
          <div ref="alertChartRef" class="chart-box"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 底部表格区 -->
    <el-row :gutter="16" class="table-row">
      <el-col :span="12">
        <el-card shadow="never">
          <template #header>高风险老人 TOP10</template>
          <el-table
            :data="riskResidents"
            stripe
            size="small"
            style="width: 100%"
          >
            <el-table-column type="index" label="排名" width="60" />
            <el-table-column prop="name" label="姓名" />
            <el-table-column prop="age" label="年龄" width="70" />
            <el-table-column prop="alertCount" label="预警次数" width="90" />
            <el-table-column
              prop="lastAlertTime"
              label="最近预警时间"
              min-width="150"
            />
          </el-table>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card shadow="never">
          <template #header>关怀人员绩效</template>
          <el-table
            :data="staffPerformance"
            stripe
            size="small"
            style="width: 100%"
          >
            <el-table-column type="index" label="序号" width="60" />
            <el-table-column prop="name" label="姓名" />
            <el-table-column
              prop="totalCareOrders"
              label="关怀工单数"
              width="100"
            />
            <el-table-column prop="completedOrders" label="完成数" width="80" />
            <el-table-column
              prop="completionRate"
              label="完成率(%)"
              width="100"
            >
              <template #default="{ row }">
                <el-tag
                  :type="
                    row.completionRate >= 80
                      ? 'success'
                      : row.completionRate >= 50
                        ? 'warning'
                        : 'danger'
                  "
                >
                  {{ row.completionRate }}%
                </el-tag>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount, nextTick } from "vue";
import * as echarts from "echarts";
import {
  getSummary,
  getElderStats,
  getStaffPerformance,
  getRiskResidents,
  getCompletionRate,
  getRepairDistribution,
  getAlertTrendByType,
} from "@/api/dashboard";

const summary = ref({});
const elderStats = ref({});
const riskResidents = ref([]);
const staffPerformance = ref([]);
const ratePeriod = ref("day");

const rateChartRef = ref(null);
const repairTypeRef = ref(null);
const repairBuildingRef = ref(null);
const alertChartRef = ref(null);

let rateChart = null;
let repairTypeChart = null;
let repairBuildingChart = null;
let alertChart = null;

// 预警日期范围
const now = new Date();
const thirtyDaysAgo = new Date(now.getTime() - 29 * 86400000);
function fmtDate(d) {
  return (
    d.getFullYear() +
    "-" +
    String(d.getMonth() + 1).padStart(2, "0") +
    "-" +
    String(d.getDate()).padStart(2, "0")
  );
}
const alertDateRange = ref([fmtDate(thirtyDaysAgo), fmtDate(now)]);
const dateShortcuts = [
  {
    text: "近7天",
    value: () => {
      const e = new Date();
      return [new Date(e.getTime() - 6 * 86400000), e];
    },
  },
  {
    text: "近30天",
    value: () => {
      const e = new Date();
      return [new Date(e.getTime() - 29 * 86400000), e];
    },
  },
  {
    text: "近90天",
    value: () => {
      const e = new Date();
      return [new Date(e.getTime() - 89 * 86400000), e];
    },
  },
];

const kpiCards = ref([
  { label: "工单完成率", value: "-", color: "#409eff" },
  { label: "老人总数", value: "-", color: "#67c23a" },
  { label: "待处理预警", value: "-", color: "#f56c6c" },
  { label: "本月关怀率", value: "-", color: "#e6a23c" },
  { label: "独居老人数", value: "-", color: "#909399" },
  { label: "高风险预警", value: "-", color: "#f56c6c" },
]);

function updateKpi() {
  kpiCards.value[0].value = (summary.value.completionRate ?? 0) + "%";
  kpiCards.value[1].value = summary.value.elderTotal ?? 0;
  kpiCards.value[2].value = summary.value.pendingAlerts ?? 0;
  kpiCards.value[3].value = (summary.value.monthlyCareRate ?? 0) + "%";
  kpiCards.value[4].value = elderStats.value.livingAloneCount ?? 0;
  kpiCards.value[5].value = elderStats.value.highRiskAlertCount ?? 0;
}

function renderRateChart(trendData) {
  if (!rateChartRef.value) return;
  if (!rateChart) rateChart = echarts.init(rateChartRef.value);
  rateChart.setOption(
    {
      tooltip: {
        trigger: "axis",
        axisPointer: { type: "cross" },
        formatter(params) {
          let s = params[0].axisValue + "<br/>";
          params.forEach((p) => {
            if (p.seriesName === "完成率")
              s += p.marker + p.seriesName + ": " + p.data + "%<br/>";
            else s += p.marker + p.seriesName + ": " + p.data + "<br/>";
          });
          return s;
        },
      },
      legend: { data: ["完成率", "总工单数"], top: 5 },
      grid: { left: 60, right: 60, top: 50, bottom: 35 },
      xAxis: {
        type: "category",
        data: trendData.map((d) => d.label),
        axisLabel: { fontSize: 11 },
      },
      yAxis: [
        {
          type: "value",
          name: "完成率",
          min: 0,
          max: 100,
          axisLabel: { formatter: "{value}%" },
          splitLine: { lineStyle: { type: "dashed" } },
        },
        {
          type: "value",
          name: "工单数",
          min: 0,
          minInterval: 1,
          axisLabel: { formatter: "{value}" },
          splitLine: { show: false },
        },
      ],
      series: [
        {
          name: "总工单数",
          type: "bar",
          yAxisIndex: 1,
          data: trendData.map((d) => d.total),
          itemStyle: {
            color: "rgba(180,180,180,0.5)",
            borderRadius: [3, 3, 0, 0],
          },
          barMaxWidth: 30,
        },
        {
          name: "完成率",
          type: "line",
          yAxisIndex: 0,
          data: trendData.map((d) => d.rate),
          smooth: true,
          itemStyle: { color: "#409eff" },
          lineStyle: { width: 3 },
          symbol: "circle",
          symbolSize: 8,
          areaStyle: { opacity: 0.08 },
        },
      ],
    },
    true,
  );
}

function renderRepairTypeChart(data) {
  if (!repairTypeRef.value || !data || data.length === 0) return;
  if (!repairTypeChart) repairTypeChart = echarts.init(repairTypeRef.value);
  repairTypeChart.setOption(
    {
      tooltip: { trigger: "item", formatter: "{b}: {c} ({d}%)" },
      legend: { orient: "vertical", right: 10, top: "center" },
      color: ["#5470c6", "#91cc75", "#fac858", "#ee6666", "#73c0de"],
      series: [
        {
          type: "pie",
          radius: ["35%", "65%"],
          center: ["40%", "50%"],
          label: { show: true, formatter: "{b}\n{d}%" },
          emphasis: { label: { fontSize: 14, fontWeight: "bold" } },
          itemStyle: { borderRadius: 6, borderColor: "#fff", borderWidth: 2 },
          data: data.map((d) => ({ name: d.name || "未分类", value: d.value })),
        },
      ],
    },
    true,
  );
}

function renderRepairBuildingChart(data) {
  if (!repairBuildingRef.value || !data || data.length === 0) return;
  if (!repairBuildingChart)
    repairBuildingChart = echarts.init(repairBuildingRef.value);
  repairBuildingChart.setOption(
    {
      tooltip: { trigger: "axis", formatter: "{b}: {c} 单" },
      grid: { left: 50, right: 20, top: 20, bottom: 35 },
      xAxis: {
        type: "category",
        data: data.map((d) => d.name || "未知"),
        axisLabel: { fontSize: 11 },
      },
      yAxis: { type: "value", minInterval: 1 },
      series: [
        {
          type: "bar",
          data: data.map((d) => d.value),
          itemStyle: { color: "#e6a23c", borderRadius: [4, 4, 0, 0] },
          barMaxWidth: 40,
        },
      ],
    },
    true,
  );
}

function renderAlertChart(alertData) {
  if (!alertChartRef.value) return;
  if (!alertChart) alertChart = echarts.init(alertChartRef.value);
  let dates = alertData.dates || [];
  let elderSafety = alertData.elderSafety || [];
  let deviceAlert = alertData.deviceAlert || [];
  if (alertDateRange.value && alertDateRange.value.length === 2) {
    const [start, end] = alertDateRange.value;
    const idx = [];
    dates.forEach((d, i) => {
      if (d >= start && d <= end) idx.push(i);
    });
    if (idx.length > 0) {
      dates = idx.map((i) => dates[i]);
      elderSafety = idx.map((i) => elderSafety[i]);
      deviceAlert = idx.map((i) => deviceAlert[i]);
    }
  }
  const xLabels = dates.map((d) => d.substring(5));
  alertChart.setOption(
    {
      tooltip: {
        trigger: "axis",
        formatter(params) {
          let s = params[0].axisValue + "<br/>";
          params.forEach((p) => {
            s += p.marker + p.seriesName + ": " + p.data + " 次<br/>";
          });
          return s;
        },
      },
      legend: { data: ["老人安全预警", "设备预警"], top: 5 },
      grid: { left: 50, right: 20, top: 50, bottom: 35 },
      xAxis: {
        type: "category",
        data: xLabels,
        boundaryGap: false,
        axisLabel: { fontSize: 10 },
      },
      yAxis: { type: "value", minInterval: 1, name: "预警次数" },
      series: [
        {
          name: "老人安全预警",
          type: "line",
          data: elderSafety,
          smooth: true,
          symbol: "circle",
          symbolSize: 5,
          itemStyle: { color: "#f56c6c" },
          lineStyle: { width: 2.5 },
          areaStyle: {
            color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
              { offset: 0, color: "rgba(245,108,108,0.3)" },
              { offset: 1, color: "rgba(245,108,108,0.02)" },
            ]),
          },
        },
        {
          name: "设备预警",
          type: "line",
          data: deviceAlert,
          smooth: true,
          symbol: "circle",
          symbolSize: 5,
          itemStyle: { color: "#e6a23c" },
          lineStyle: { width: 2.5 },
          areaStyle: {
            color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
              { offset: 0, color: "rgba(230,162,60,0.3)" },
              { offset: 1, color: "rgba(230,162,60,0.02)" },
            ]),
          },
        },
      ],
    },
    true,
  );
}

let alertRawData = {};
function onAlertDateChange() {
  renderAlertChart(alertRawData);
}

async function loadCompletionRate() {
  const res = await getCompletionRate(ratePeriod.value);
  await nextTick();
  renderRateChart((res.data || {}).trendData || []);
}

function handleResize() {
  rateChart?.resize();
  repairTypeChart?.resize();
  repairBuildingChart?.resize();
  alertChart?.resize();
}

onMounted(async () => {
  const [sumRes, elderRes, staffRes, riskRes, rateRes, distRes, alertRes] =
    await Promise.all([
      getSummary(),
      getElderStats(),
      getStaffPerformance(),
      getRiskResidents(),
      getCompletionRate(ratePeriod.value),
      getRepairDistribution(),
      getAlertTrendByType(),
    ]);
  summary.value = sumRes.data || {};
  elderStats.value = elderRes.data || {};
  riskResidents.value = riskRes.data || [];
  staffPerformance.value = staffRes.data || [];
  updateKpi();
  await nextTick();
  renderRateChart((rateRes.data || {}).trendData || []);
  renderRepairTypeChart((distRes.data || {}).byType || []);
  renderRepairBuildingChart((distRes.data || {}).byBuilding || []);
  alertRawData = alertRes.data || {};
  renderAlertChart(alertRawData);
  window.addEventListener("resize", handleResize);
});

onBeforeUnmount(() => {
  window.removeEventListener("resize", handleResize);
  rateChart?.dispose();
  repairTypeChart?.dispose();
  repairBuildingChart?.dispose();
  alertChart?.dispose();
});
</script>

<style scoped>
.kpi-card {
  text-align: center;
  margin-bottom: 16px;
}
.kpi-value {
  font-size: 28px;
  font-weight: bold;
}
.kpi-label {
  margin-top: 6px;
  color: #909399;
  font-size: 13px;
}
.chart-row {
  margin-bottom: 16px;
}
.chart-box {
  height: 320px;
}
.table-row {
  margin-bottom: 16px;
}
.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
