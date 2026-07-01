<template>
  <div class="dashboard-container">
    <!-- 顶部KPI统计卡片 -->
    <el-row :gutter="20">
      <el-col :span="6" v-for="card in kpiCards" :key="card.label">
        <div class="kpi-card" :style="{ background: card.bg }">
          <div class="kpi-icon">
            <el-icon :size="28" color="#fff"
              ><component :is="card.icon"
            /></el-icon>
          </div>
          <div class="kpi-info">
            <div class="kpi-value">{{ card.value }}</div>
            <div class="kpi-label">{{ card.label }}</div>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 工单完成率趋势 -->
    <el-row :gutter="20" class="chart-row">
      <el-col :span="24">
        <el-card shadow="never" class="chart-card">
          <template #header>
            <div class="chart-header">
              <span class="chart-title">工单完成率趋势</span>
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

    <!-- 报修分布 -->
    <el-row :gutter="20" class="chart-row">
      <el-col :span="12">
        <el-card shadow="never" class="chart-card">
          <template #header
            ><span class="chart-title">报修类型分布</span></template
          >
          <div ref="repairTypeRef" class="chart-box"></div>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card shadow="never" class="chart-card">
          <template #header
            ><span class="chart-title">楼栋报修热力</span></template
          >
          <div ref="repairBuildingRef" class="chart-box"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 工单状态分布 + 维修工负载 -->
    <el-row :gutter="20" class="chart-row">
      <el-col :span="12">
        <el-card shadow="never" class="chart-card">
          <template #header
            ><span class="chart-title">工单状态分布</span></template
          >
          <div ref="statusChartRef" class="chart-box"></div>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card shadow="never" class="chart-card">
          <template #header
            ><span class="chart-title">维修工负载 TOP5</span></template
          >
          <div ref="workerLoadRef" class="chart-box"></div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 预警次数趋势 -->
    <el-row :gutter="20" class="chart-row">
      <el-col :span="24">
        <el-card shadow="never" class="chart-card">
          <template #header>
            <div class="chart-header">
              <span class="chart-title">预警次数趋势</span>
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
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount, nextTick, shallowRef } from "vue";
import * as echarts from "echarts";
import { Tickets, User, Bell, DataAnalysis } from "@element-plus/icons-vue";
import {
  getSummary,
  getElderStats,
  getCompletionRate,
  getRepairDistribution,
  getAlertTrendByType,
  getOrderStatusDistribution,
  getWorkerLoad,
} from "@/api/dashboard";

const summary = ref({});
const elderStats = ref({});
const ratePeriod = ref("day");

const rateChartRef = ref(null);
const repairTypeRef = ref(null);
const repairBuildingRef = ref(null);
const alertChartRef = ref(null);
const statusChartRef = ref(null);
const workerLoadRef = ref(null);

let rateChart = null;
let repairTypeChart = null;
let repairBuildingChart = null;
let alertChart = null;
let statusChart = null;
let workerLoadChart = null;

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
    text: "\u8FD17\u5929",
    value: () => {
      const e = new Date();
      return [new Date(e.getTime() - 6 * 86400000), e];
    },
  },
  {
    text: "\u8FD130\u5929",
    value: () => {
      const e = new Date();
      return [new Date(e.getTime() - 29 * 86400000), e];
    },
  },
  {
    text: "\u8FD190\u5929",
    value: () => {
      const e = new Date();
      return [new Date(e.getTime() - 89 * 86400000), e];
    },
  },
];

const kpiCards = ref([
  {
    label: "\u5DE5\u5355\u5B8C\u6210\u7387",
    value: "-",
    bg: "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
    icon: shallowRef(Tickets),
  },
  {
    label: "\u8001\u4EBA\u603B\u6570",
    value: "-",
    bg: "linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)",
    icon: shallowRef(User),
  },
  {
    label: "\u5F85\u5904\u7406\u9884\u8B66",
    value: "-",
    bg: "linear-gradient(135deg, #fa709a 0%, #fee140 100%)",
    icon: shallowRef(Bell),
  },
  {
    label: "\u72EC\u5C45\u8001\u4EBA\u6570",
    value: "-",
    bg: "linear-gradient(135deg, #a18cd1 0%, #fbc2eb 100%)",
    icon: shallowRef(DataAnalysis),
  },
]);

function updateKpi() {
  kpiCards.value[0].value = (summary.value.completionRate ?? 0) + "%";
  kpiCards.value[1].value = summary.value.elderTotal ?? 0;
  kpiCards.value[2].value = summary.value.pendingAlerts ?? 0;
  kpiCards.value[3].value = elderStats.value.livingAloneCount ?? 0;
}

function renderRateChart(trendData) {
  if (!rateChartRef.value) return;
  if (!rateChart) rateChart = echarts.init(rateChartRef.value);
  rateChart.setOption(
    {
      tooltip: {
        trigger: "axis",
        axisPointer: { type: "cross", crossStyle: { color: "#999" } },
        backgroundColor: "rgba(50,50,50,0.9)",
        borderColor: "transparent",
        textStyle: { color: "#fff" },
        formatter(params) {
          let s =
            '<div style="font-weight:600;margin-bottom:4px">' +
            params[0].axisValue +
            "</div>";
          params.forEach(function (p) {
            var unit = p.seriesName === "\u5B8C\u6210\u7387" ? "%" : " \u5355";
            s +=
              p.marker +
              " " +
              p.seriesName +
              ": <b>" +
              p.data +
              unit +
              "</b><br/>";
          });
          return s;
        },
      },
      legend: {
        data: ["\u5B8C\u6210\u7387", "\u603B\u5DE5\u5355\u6570"],
        top: 8,
        textStyle: { color: "#666" },
      },
      grid: { left: 60, right: 60, top: 55, bottom: 40 },
      xAxis: {
        type: "category",
        data: trendData.map(function (d) {
          return d.label;
        }),
        axisLabel: { color: "#888" },
        axisLine: { lineStyle: { color: "#e0e0e0" } },
      },
      yAxis: [
        {
          type: "value",
          name: "\u5B8C\u6210\u7387",
          min: 0,
          max: 100,
          axisLabel: { formatter: "{value}%", color: "#888" },
          splitLine: { lineStyle: { type: "dashed", color: "#f0f0f0" } },
        },
        {
          type: "value",
          name: "\u5DE5\u5355\u6570",
          min: 0,
          minInterval: 1,
          axisLabel: { color: "#888" },
          splitLine: { show: false },
        },
      ],
      series: [
        {
          name: "\u603B\u5DE5\u5355\u6570",
          type: "bar",
          yAxisIndex: 1,
          data: trendData.map(function (d) {
            return d.total;
          }),
          itemStyle: {
            borderRadius: [6, 6, 0, 0],
            color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
              { offset: 0, color: "rgba(102,126,234,0.6)" },
              { offset: 1, color: "rgba(102,126,234,0.15)" },
            ]),
          },
          barMaxWidth: 28,
        },
        {
          name: "\u5B8C\u6210\u7387",
          type: "line",
          yAxisIndex: 0,
          data: trendData.map(function (d) {
            return d.rate;
          }),
          smooth: true,
          symbol: "circle",
          symbolSize: 8,
          itemStyle: { color: "#764ba2", borderWidth: 2, borderColor: "#fff" },
          lineStyle: {
            width: 3,
            color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
              { offset: 0, color: "#667eea" },
              { offset: 1, color: "#764ba2" },
            ]),
          },
          areaStyle: {
            color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
              { offset: 0, color: "rgba(102,126,234,0.25)" },
              { offset: 1, color: "rgba(118,75,162,0.02)" },
            ]),
          },
        },
      ],
      animationDuration: 1000,
      animationEasing: "cubicOut",
    },
    true,
  );
}

function renderRepairTypeChart(data) {
  if (!repairTypeRef.value || !data || data.length === 0) return;
  if (!repairTypeChart) repairTypeChart = echarts.init(repairTypeRef.value);
  var colors = [
    "#667eea",
    "#764ba2",
    "#f093fb",
    "#4facfe",
    "#43e97b",
    "#fa709a",
    "#fee140",
  ];
  repairTypeChart.setOption(
    {
      tooltip: {
        trigger: "item",
        formatter: "{b}<br/>\u6570\u91CF: {c} ({d}%)",
        backgroundColor: "rgba(50,50,50,0.9)",
        borderColor: "transparent",
        textStyle: { color: "#fff" },
      },
      legend: {
        orient: "vertical",
        right: 15,
        top: "center",
        textStyle: { color: "#666" },
      },
      color: colors,
      series: [
        {
          type: "pie",
          roseType: "area",
          radius: ["20%", "70%"],
          center: ["40%", "50%"],
          label: {
            show: true,
            formatter: "{b}\n{d}%",
            color: "#555",
            fontSize: 11,
          },
          labelLine: { length: 12, length2: 16 },
          emphasis: {
            label: { fontSize: 14, fontWeight: "bold" },
            itemStyle: { shadowBlur: 20, shadowColor: "rgba(0,0,0,0.15)" },
          },
          itemStyle: { borderRadius: 8, borderColor: "#fff", borderWidth: 3 },
          data: data.map(function (d, i) {
            return {
              name: d.name || "\u672A\u5206\u7C7B",
              value: d.value,
              itemStyle: { color: colors[i % colors.length] },
            };
          }),
          animationType: "scale",
          animationEasing: "elasticOut",
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
  var sorted = data.slice().sort(function (a, b) {
    return a.value - b.value;
  });
  var maxVal = Math.max.apply(
    null,
    sorted
      .map(function (d) {
        return d.value;
      })
      .concat([1]),
  );
  repairBuildingChart.setOption(
    {
      tooltip: {
        trigger: "axis",
        axisPointer: { type: "shadow" },
        formatter: "{b}: {c} \u5355",
        backgroundColor: "rgba(50,50,50,0.9)",
        borderColor: "transparent",
        textStyle: { color: "#fff" },
      },
      grid: { left: 80, right: 40, top: 15, bottom: 20 },
      xAxis: {
        type: "value",
        minInterval: 1,
        axisLabel: { color: "#888" },
        splitLine: { lineStyle: { type: "dashed", color: "#f0f0f0" } },
      },
      yAxis: {
        type: "category",
        data: sorted.map(function (d) {
          return d.name || "\u672A\u77E5";
        }),
        axisLabel: { color: "#555", fontSize: 12 },
        axisLine: { show: false },
        axisTick: { show: false },
      },
      series: [
        {
          type: "bar",
          data: sorted.map(function (d) {
            return {
              value: d.value,
              itemStyle: {
                borderRadius: [0, 8, 8, 0],
                color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
                  {
                    offset: 0,
                    color:
                      "rgba(102,126,234," +
                      (0.4 + 0.6 * (d.value / maxVal)) +
                      ")",
                  },
                  {
                    offset: 1,
                    color:
                      "rgba(118,75,162," +
                      (0.4 + 0.6 * (d.value / maxVal)) +
                      ")",
                  },
                ]),
              },
            };
          }),
          barMaxWidth: 20,
          label: {
            show: true,
            position: "right",
            formatter: "{c}",
            color: "#666",
            fontSize: 12,
          },
        },
      ],
      animationDuration: 800,
      animationEasing: "cubicOut",
    },
    true,
  );
}

function renderStatusChart(data) {
  if (!statusChartRef.value || !data || data.length === 0) return;
  if (!statusChart) statusChart = echarts.init(statusChartRef.value);
  var colors = [
    "#43e97b",
    "#667eea",
    "#4facfe",
    "#fa709a",
    "#fee140",
    "#a18cd1",
    "#f093fb",
  ];
  var total = data.reduce(function (s, d) {
    return s + d.value;
  }, 0);
  statusChart.setOption(
    {
      tooltip: {
        trigger: "item",
        formatter: "{b}: {c} ({d}%)",
        backgroundColor: "rgba(50,50,50,0.9)",
        borderColor: "transparent",
        textStyle: { color: "#fff" },
      },
      legend: {
        orient: "horizontal",
        bottom: 10,
        textStyle: { color: "#666" },
      },
      color: colors,
      graphic: [
        {
          type: "group",
          left: "center",
          top: "center",
          children: [
            {
              type: "text",
              style: {
                text: String(total),
                fontSize: 28,
                fontWeight: "bold",
                fill: "#333",
                textAlign: "center",
                textVerticalAlign: "bottom",
              },
              left: "center",
              top: "38%",
            },
            {
              type: "text",
              style: {
                text: "\u5DE5\u5355\u603B\u6570",
                fontSize: 12,
                fill: "#999",
                textAlign: "center",
                textVerticalAlign: "top",
              },
              left: "center",
              top: "52%",
            },
          ],
        },
      ],
      series: [
        {
          type: "pie",
          radius: ["50%", "72%"],
          center: ["50%", "48%"],
          avoidLabelOverlap: true,
          label: { show: false },
          emphasis: {
            label: { show: true, fontSize: 14, fontWeight: "bold" },
            itemStyle: { shadowBlur: 20, shadowColor: "rgba(0,0,0,0.12)" },
          },
          itemStyle: { borderRadius: 6, borderColor: "#fff", borderWidth: 2 },
          data: data.map(function (d, i) {
            return {
              name: d.name,
              value: d.value,
              itemStyle: { color: colors[i % colors.length] },
            };
          }),
          animationType: "scale",
          animationEasing: "elasticOut",
        },
      ],
    },
    true,
  );
}

function renderWorkerLoadChart(data) {
  if (!workerLoadRef.value || !data || data.length === 0) return;
  if (!workerLoadChart) workerLoadChart = echarts.init(workerLoadRef.value);
  var sorted = data.slice().sort(function (a, b) {
    return a.value - b.value;
  });
  workerLoadChart.setOption(
    {
      tooltip: {
        trigger: "axis",
        axisPointer: { type: "shadow" },
        formatter: "{b}: {c} \u5355",
        backgroundColor: "rgba(50,50,50,0.9)",
        borderColor: "transparent",
        textStyle: { color: "#fff" },
      },
      grid: { left: 80, right: 40, top: 15, bottom: 20 },
      xAxis: {
        type: "value",
        minInterval: 1,
        axisLabel: { color: "#888" },
        splitLine: { lineStyle: { type: "dashed", color: "#f0f0f0" } },
      },
      yAxis: {
        type: "category",
        data: sorted.map(function (d) {
          return d.name;
        }),
        axisLabel: { color: "#555", fontSize: 12 },
        axisLine: { show: false },
        axisTick: { show: false },
      },
      series: [
        {
          type: "bar",
          data: sorted.map(function (d) {
            return {
              value: d.value,
              itemStyle: {
                borderRadius: [0, 8, 8, 0],
                color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
                  { offset: 0, color: "#43e97b" },
                  { offset: 1, color: "#38f9d7" },
                ]),
              },
            };
          }),
          barMaxWidth: 20,
          label: {
            show: true,
            position: "right",
            formatter: "{c}",
            color: "#666",
            fontSize: 12,
          },
        },
      ],
      animationDuration: 800,
      animationEasing: "cubicOut",
    },
    true,
  );
}

var alertRawData = {};
function onAlertDateChange() {
  renderAlertChart(alertRawData);
}

function renderAlertChart(alertData) {
  if (!alertChartRef.value) return;
  if (!alertChart) alertChart = echarts.init(alertChartRef.value);
  var dates = alertData.dates || [];
  var elderSafety = alertData.elderSafety || [];
  var deviceAlert = alertData.deviceAlert || [];
  if (alertDateRange.value && alertDateRange.value.length === 2) {
    var start = alertDateRange.value[0],
      end = alertDateRange.value[1];
    var idx = [];
    dates.forEach(function (d, i) {
      if (d >= start && d <= end) idx.push(i);
    });
    if (idx.length > 0) {
      dates = idx.map(function (i) {
        return dates[i];
      });
      elderSafety = idx.map(function (i) {
        return elderSafety[i];
      });
      deviceAlert = idx.map(function (i) {
        return deviceAlert[i];
      });
    }
  }
  var xLabels = dates.map(function (d) {
    return d.substring(5);
  });
  alertChart.setOption(
    {
      tooltip: {
        trigger: "axis",
        backgroundColor: "rgba(50,50,50,0.9)",
        borderColor: "transparent",
        textStyle: { color: "#fff" },
        formatter: function (params) {
          var s = "<b>" + params[0].axisValue + "</b><br/>";
          params.forEach(function (p) {
            s += p.marker + " " + p.seriesName + ": " + p.data + " \u6B21<br/>";
          });
          return s;
        },
      },
      legend: {
        data: [
          "\u8001\u4EBA\u5B89\u5168\u9884\u8B66",
          "\u8BBE\u5907\u9884\u8B66",
        ],
        top: 8,
        textStyle: { color: "#666" },
      },
      grid: { left: 50, right: 20, top: 50, bottom: 35 },
      xAxis: {
        type: "category",
        data: xLabels,
        boundaryGap: false,
        axisLabel: { color: "#888", fontSize: 10 },
        axisLine: { lineStyle: { color: "#e0e0e0" } },
      },
      yAxis: {
        type: "value",
        minInterval: 1,
        name: "\u9884\u8B66\u6B21\u6570",
        axisLabel: { color: "#888" },
        splitLine: { lineStyle: { type: "dashed", color: "#f0f0f0" } },
      },
      series: [
        {
          name: "\u8001\u4EBA\u5B89\u5168\u9884\u8B66",
          type: "line",
          data: elderSafety,
          smooth: true,
          symbol: "circle",
          symbolSize: 6,
          itemStyle: { color: "#fa709a" },
          lineStyle: { width: 2.5 },
          areaStyle: {
            color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
              { offset: 0, color: "rgba(250,112,154,0.3)" },
              { offset: 1, color: "rgba(250,112,154,0.02)" },
            ]),
          },
        },
        {
          name: "\u8BBE\u5907\u9884\u8B66",
          type: "line",
          data: deviceAlert,
          smooth: true,
          symbol: "circle",
          symbolSize: 6,
          itemStyle: { color: "#4facfe" },
          lineStyle: { width: 2.5 },
          areaStyle: {
            color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
              { offset: 0, color: "rgba(79,172,254,0.3)" },
              { offset: 1, color: "rgba(79,172,254,0.02)" },
            ]),
          },
        },
      ],
      animationDuration: 1000,
    },
    true,
  );
}

async function loadCompletionRate() {
  var res = await getCompletionRate(ratePeriod.value);
  await nextTick();
  renderRateChart((res.data || {}).trendData || []);
}

function handleResize() {
  rateChart && rateChart.resize();
  repairTypeChart && repairTypeChart.resize();
  repairBuildingChart && repairBuildingChart.resize();
  alertChart && alertChart.resize();
  statusChart && statusChart.resize();
  workerLoadChart && workerLoadChart.resize();
}

onMounted(async function () {
  var results = await Promise.all([
    getSummary(),
    getElderStats(),
    getCompletionRate(ratePeriod.value),
    getRepairDistribution(),
    getAlertTrendByType(),
    getOrderStatusDistribution(),
    getWorkerLoad(),
  ]);
  summary.value = results[0].data || {};
  elderStats.value = results[1].data || {};
  updateKpi();
  await nextTick();
  renderRateChart((results[2].data || {}).trendData || []);
  renderRepairTypeChart((results[3].data || {}).byType || []);
  renderRepairBuildingChart((results[3].data || {}).byBuilding || []);
  alertRawData = results[4].data || {};
  renderAlertChart(alertRawData);
  renderStatusChart(results[5].data || []);
  renderWorkerLoadChart(results[6].data || []);
  window.addEventListener("resize", handleResize);
});

onBeforeUnmount(function () {
  window.removeEventListener("resize", handleResize);
  rateChart && rateChart.dispose();
  repairTypeChart && repairTypeChart.dispose();
  repairBuildingChart && repairBuildingChart.dispose();
  alertChart && alertChart.dispose();
  statusChart && statusChart.dispose();
  workerLoadChart && workerLoadChart.dispose();
});
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
  padding: 20px 24px;
  border-radius: 14px;
  margin-bottom: 20px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
  transition:
    transform 0.3s,
    box-shadow 0.3s;
}
.kpi-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.12);
}
.kpi-icon {
  width: 52px;
  height: 52px;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.25);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 16px;
  flex-shrink: 0;
}
.kpi-info {
  flex: 1;
}
.kpi-value {
  font-size: 26px;
  font-weight: 700;
  color: #fff;
  line-height: 1.2;
}
.kpi-label {
  margin-top: 4px;
  color: rgba(255, 255, 255, 0.85);
  font-size: 13px;
}
.chart-row {
  margin-bottom: 20px;
}
.chart-card {
  border-radius: 12px;
  border: none;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
}
.chart-card :deep(.el-card__header) {
  padding: 16px 20px;
  border-bottom: 1px solid #f0f0f0;
}
.chart-title {
  font-size: 15px;
  font-weight: 600;
  color: #333;
}
.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.chart-box {
  height: 320px;
}
</style>
