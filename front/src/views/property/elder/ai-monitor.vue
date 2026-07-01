<template>
  <div class="app-container ai-monitor">
    <!-- 顶部统计卡片 -->
    <el-row :gutter="16" class="stat-row">
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon blue">
              <el-icon><User /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ status.aloneElderCount ?? 0 }}</div>
              <div class="stat-label">监测中老人</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon green">
              <el-icon><Monitor /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ status.todayCheckCount ?? 0 }}</div>
              <div class="stat-label">今日检查次数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon red">
              <el-icon><Warning /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ status.todayAlertCount ?? 0 }}</div>
              <div class="stat-label">今日预警数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-content">
            <div class="stat-icon orange">
              <el-icon><Clock /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value stat-time">
                {{ status.latestAlert ? status.latestAlert.checkTime : "暂无" }}
              </div>
              <div class="stat-label">最近预警时间</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 主内容区 -->
    <div v-if="!showDetail">
      <el-tabs v-model="activeTab">
        <!-- Tab 1: 预警消息 -->
        <el-tab-pane label="预警消息" name="alert">
          <div class="toolbar">
            <div class="toolbar-left">
              <el-input
                v-model="alertQuery.keyword"
                placeholder="搜索内容"
                clearable
                style="width: 200px"
                @keyup.enter="searchAlerts"
              >
                <template #prefix
                  ><el-icon><Search /></el-icon
                ></template>
              </el-input>
              <el-select
                v-model="alertQuery.status"
                clearable
                placeholder="状态"
                style="width: 120px"
                @change="searchAlerts"
              >
                <el-option label="全部" value="" />
                <el-option label="待处置" value="pending" />
                <el-option label="已处置" value="handled" />
                <el-option label="已闭环" value="closed" />
              </el-select>
              <el-button type="primary" @click="searchAlerts">搜索</el-button>
            </div>
            <div class="toolbar-right">
              <el-select
                v-model="alertQuery.orderDir"
                style="width: 110px"
                @change="searchAlerts"
              >
                <el-option label="最新优先" value="desc" />
                <el-option label="最早优先" value="asc" />
              </el-select>
            </div>
          </div>

          <!-- 预警卡片列表 -->
          <div v-loading="alertLoading" class="alert-card-list">
            <div
              v-for="item in alertList"
              :key="item.alertId"
              class="alert-card"
              :class="{
                'alert-level-1': item.alertLevel === 1,
                'alert-level-2': item.alertLevel === 2,
              }"
              @click="openDetail(item)"
            >
              <div class="alert-card-header">
                <span
                  class="alert-level-badge"
                  :class="item.alertLevel === 1 ? 'badge-red' : 'badge-orange'"
                >
                  {{ item.alertLevel === 1 ? "🔴一级" : "🟠二级" }}
                </span>
                <span class="alert-elder-name"
                  >{{ item.residentName || "未知" }}（{{
                    item.address || "未知地址"
                  }}）</span
                >
                <el-tag
                  :type="statusTagType(item.status)"
                  size="small"
                  class="alert-status-tag"
                  >{{ statusLabel(item.status) }}</el-tag
                >
              </div>
              <div class="alert-card-body">
                <div class="alert-content">异常：{{ item.content }}</div>
                <div class="alert-time">触发：{{ item.createTime }}</div>
              </div>
              <div class="alert-card-footer">
                <el-button
                  type="primary"
                  link
                  size="small"
                  @click.stop="openDetail(item)"
                  >查看详情</el-button
                >
              </div>
            </div>
            <el-empty
              v-if="!alertLoading && alertList.length === 0"
              description="暂无预警消息"
            />
          </div>
          <Pagination
            v-show="alertTotal > 0"
            :total="alertTotal"
            v-model:page="alertQuery.pageNum"
            v-model:limit="alertQuery.pageSize"
            @pagination="loadAlerts"
          />
        </el-tab-pane>

        <!-- Tab 2: 关怀工单 -->
        <el-tab-pane label="关怀工单" name="order">
          <div class="toolbar">
            <div class="toolbar-left">
              <el-select
                v-model="orderQuery.status"
                clearable
                placeholder="工单状态"
                style="width: 130px"
                @change="loadOrders"
              >
                <el-option label="全部" value="" />
                <el-option label="待指派" value="pending" />
                <el-option label="进行中" value="assigned" />
                <el-option label="已完成" value="completed" />
              </el-select>
            </div>
            <div class="toolbar-right">
              <el-button type="success" icon="Plus" @click="openOrderDialog"
                >手动创建工单</el-button
              >
            </div>
          </div>
          <el-card shadow="never">
            <el-table :data="orderList" v-loading="orderLoading" border stripe>
              <el-table-column
                type="index"
                label="序号"
                width="60"
                align="center"
              />
              <el-table-column prop="elderName" label="老人姓名" width="110">
                <template #default="{ row }">{{
                  row.elderName || row.residentId
                }}</template>
              </el-table-column>
              <el-table-column
                prop="careItem"
                label="关怀事项"
                min-width="180"
                show-overflow-tooltip
              />
              <el-table-column
                prop="assigneeName"
                label="指派人员"
                width="110"
                align="center"
              >
                <template #default="{ row }">{{
                  row.assigneeName || "-"
                }}</template>
              </el-table-column>
              <el-table-column
                prop="status"
                label="状态"
                width="100"
                align="center"
              >
                <template #default="{ row }">
                  <el-tag :type="orderStatusTagType(row.status)" size="small">{{
                    orderStatusLabel(row.status)
                  }}</el-tag>
                </template>
              </el-table-column>
              <el-table-column
                prop="createTime"
                label="创建时间"
                width="170"
                align="center"
              />
              <el-table-column
                label="操作"
                width="160"
                align="center"
                fixed="right"
              >
                <template #default="{ row }">
                  <el-button
                    v-if="row.status === 'pending'"
                    link
                    type="primary"
                    @click="openAssignDialog(row)"
                    >指派</el-button
                  >
                  <el-button
                    v-if="row.status === 'assigned'"
                    link
                    type="success"
                    @click="openCompleteDialog(row)"
                    >闭环</el-button
                  >
                  <span v-if="row.status === 'completed'" class="text-muted"
                    >已完成</span
                  >
                </template>
              </el-table-column>
            </el-table>
            <Pagination
              v-show="orderTotal > 0"
              :total="orderTotal"
              v-model:page="orderQuery.pageNum"
              v-model:limit="orderQuery.pageSize"
              @pagination="loadOrders"
            />
          </el-card>
        </el-tab-pane>
      </el-tabs>
    </div>

    <!-- ========== 预警详情视图 ========== -->
    <div v-if="showDetail" class="detail-view">
      <div class="detail-back">
        <el-button icon="ArrowLeft" @click="closeDetail"
          >返回预警列表</el-button
        >
      </div>

      <el-card shadow="never" class="detail-info-card">
        <div class="elder-info-row">
          <div class="info-item">
            <span class="info-label">老人：</span>
            <span class="info-value"
              >{{ detailData.alert?.residentName }}（{{
                detailData.alert?.address || "未知"
              }}）</span
            >
          </div>
          <div class="info-item">
            <span class="info-label">电话：</span>
            <span class="info-value">{{
              detailData.alert?.elderPhone || "-"
            }}</span>
          </div>
          <div class="info-item">
            <span class="info-label">家属：</span>
            <span class="info-value">{{
              detailData.alert?.familyPhone || "-"
            }}</span>
          </div>
        </div>
        <div class="elder-info-row" style="margin-top: 12px">
          <div class="info-item">
            <span class="info-label">异常：</span>
            <span class="info-value alert-text">{{
              detailData.alert?.content
            }}</span>
          </div>
          <div class="info-item">
            <span class="info-label">触发：</span>
            <span class="info-value">{{ detailData.alert?.createTime }}</span>
          </div>
        </div>
        <div class="elder-info-row" style="margin-top: 12px">
          <div class="info-item">
            <span class="info-label">处置等级：</span>
            <el-tag
              :type="detailData.alert?.alertLevel === 1 ? 'danger' : 'warning'"
              effect="dark"
            >
              {{
                detailData.alert?.alertLevel === 1
                  ? "一级 立即上门"
                  : "二级 电话确认后上门"
              }}
            </el-tag>
          </div>
          <div class="info-item">
            <span class="info-label">状态：</span>
            <el-tag :type="statusTagType(detailData.alert?.status)">{{
              statusLabel(detailData.alert?.status)
            }}</el-tag>
          </div>
        </div>
      </el-card>

      <!-- 水电趋势图 -->
      <el-card shadow="never" class="detail-chart-card">
        <template #header>
          <div class="card-header">
            <span>水电趋势（最近7天）</span>
            <el-button icon="Refresh" size="small" @click="loadChartData"
              >刷新</el-button
            >
          </div>
        </template>
        <div ref="chartRef" style="height: 280px; width: 100%"></div>
      </el-card>

      <!-- 处置记录 -->
      <el-card shadow="never" class="detail-records-card">
        <template #header><span>处置记录</span></template>
        <div
          v-if="detailData.records && detailData.records.length > 0"
          class="records-timeline"
        >
          <div
            v-for="rec in detailData.records"
            :key="rec.recordId"
            class="record-item"
          >
            <div class="record-time">{{ rec.handleTime }}</div>
            <div class="record-handler">{{ rec.handlerName || "系统" }}</div>
            <div class="record-content">
              <span v-if="rec.checkResult">核查：{{ rec.checkResult }}</span>
              <span v-if="rec.supportMeasure">
                | 帮扶：{{ rec.supportMeasure }}</span
              >
              <span v-if="rec.disposalResult">
                | 结果：{{ rec.disposalResult }}</span
              >
            </div>
          </div>
        </div>
        <el-empty v-else description="暂无处置记录" :image-size="60" />
      </el-card>

      <!-- 闭环表单 -->
      <el-card
        v-if="detailData.alert?.status !== 'closed'"
        shadow="never"
        class="detail-close-card"
      >
        <template #header><span>完成闭环</span></template>
        <el-form :model="closeForm" label-width="90px">
          <el-form-item label="核查结果">
            <el-input
              v-model="closeForm.checkResult"
              type="textarea"
              :rows="2"
              placeholder="请输入上门核查结果"
            />
          </el-form-item>
          <el-form-item label="帮扶措施">
            <el-input
              v-model="closeForm.supportMeasure"
              type="textarea"
              :rows="2"
              placeholder="请输入帮扶措施"
            />
          </el-form-item>
          <el-form-item label="处置结果">
            <el-input
              v-model="closeForm.disposalResult"
              type="textarea"
              :rows="2"
              placeholder="请输入处置结果"
            />
          </el-form-item>
          <el-form-item>
            <el-button
              type="primary"
              :loading="closeLoading"
              @click="submitClose"
              >完成闭环</el-button
            >
          </el-form-item>
        </el-form>
      </el-card>
    </div>

    <!-- ===== 新建工单对话框 ===== -->
    <el-dialog
      v-model="orderDlg"
      title="手动创建关怀工单"
      width="520px"
      append-to-body
    >
      <el-form
        ref="orderFormRef"
        :model="orderForm"
        :rules="orderRules"
        label-width="90px"
      >
        <el-form-item label="选择老人" prop="residentId">
          <el-select
            v-model="orderForm.residentId"
            placeholder="请选择老人"
            filterable
            style="width: 100%"
          >
            <el-option
              v-for="e in elderOptions"
              :key="e.residentId"
              :label="`${e.name}（${e.address || ''}）`"
              :value="e.residentId"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="关怀事项" prop="careItem">
          <el-input
            v-model="orderForm.careItem"
            type="textarea"
            :rows="3"
            placeholder="请输入关怀事项"
          />
        </el-form-item>
        <el-form-item label="指派人员">
          <el-select
            v-model="orderForm.assigneeId"
            placeholder="选择指派人员（可选）"
            filterable
            clearable
            style="width: 100%"
          >
            <el-option
              v-for="s in staffOptions"
              :key="s.staffId"
              :label="`${s.name}（${s.staffType}）`"
              :value="s.staffId"
            />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="orderDlg = false">取消</el-button>
        <el-button type="primary" @click="submitOrder">创建</el-button>
      </template>
    </el-dialog>

    <!-- ===== 指派对话框 ===== -->
    <el-dialog
      v-model="assignDlg"
      title="指派关怀人员"
      width="440px"
      append-to-body
    >
      <el-form :model="assignForm" label-width="90px">
        <el-form-item label="关怀事项"
          ><span>{{ assignForm.careItem }}</span></el-form-item
        >
        <el-form-item label="关怀人员">
          <el-select
            v-model="assignForm.staffId"
            placeholder="请选择"
            filterable
            style="width: 100%"
          >
            <el-option
              v-for="s in staffOptions"
              :key="s.staffId"
              :label="`${s.name}（${s.staffType}）`"
              :value="s.staffId"
            />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="assignDlg = false">取消</el-button>
        <el-button type="primary" @click="submitAssign">确定</el-button>
      </template>
    </el-dialog>

    <!-- ===== 工单闭环对话框 ===== -->
    <el-dialog
      v-model="completeDlg"
      title="工单闭环"
      width="560px"
      append-to-body
    >
      <el-form :model="completeForm" label-width="90px">
        <el-form-item label="关怀事项"
          ><span>{{ completeForm.careItem }}</span></el-form-item
        >
        <el-form-item label="核查结果">
          <el-input
            v-model="completeForm.checkResult"
            type="textarea"
            :rows="2"
            placeholder="请输入核查结果"
          />
        </el-form-item>
        <el-form-item label="帮扶措施">
          <el-input
            v-model="completeForm.supportMeasure"
            type="textarea"
            :rows="2"
            placeholder="请输入帮扶措施"
          />
        </el-form-item>
        <el-form-item label="处置结果">
          <el-input
            v-model="completeForm.disposalResult"
            type="textarea"
            :rows="2"
            placeholder="请输入处置结果"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="completeDlg = false">取消</el-button>
        <el-button type="primary" @click="submitComplete">完成闭环</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, nextTick } from "vue";
import { ElMessage } from "element-plus";
import { Search } from "@element-plus/icons-vue";
import * as echarts from "echarts";
import Pagination from "@/components/Pagination/index.vue";
import {
  listAlerts,
  getAlertDetail,
  closeAlert,
  listCareOrders,
  createCareOrder,
  assignCareOrder,
  completeCareOrder,
  listCareStaff,
} from "@/api/elder";
import {
  getMonitorStatus,
  getAloneElders,
  getUtilityRecent,
} from "@/api/elderAi";

/* ===== 辅助函数 ===== */
function statusTagType(status) {
  if (status === "pending") return "danger";
  if (status === "handled") return "warning";
  if (status === "closed") return "success";
  return "info";
}
function statusLabel(status) {
  const map = { pending: "待处置", handled: "已处置", closed: "已闭环" };
  return map[status] || status;
}
function orderStatusLabel(status) {
  const map = { pending: "待指派", assigned: "进行中", completed: "已完成" };
  return map[status] || status;
}
function orderStatusTagType(status) {
  if (status === "pending") return "info";
  if (status === "assigned") return "warning";
  if (status === "completed") return "success";
  return "";
}

/* ===== 统计 ===== */
const status = ref({});
async function loadStatus() {
  try {
    const res = await getMonitorStatus();
    status.value = res.data || {};
  } catch {}
}

/* ===== Tab ===== */
const activeTab = ref("alert");

/* ===== 预警列表 ===== */
const alertLoading = ref(false);
const alertList = ref([]);
const alertTotal = ref(0);
const alertQuery = reactive({
  pageNum: 1,
  pageSize: 10,
  keyword: "",
  orderDir: "desc",
  status: "",
});

async function loadAlerts() {
  alertLoading.value = true;
  try {
    const res = await listAlerts(alertQuery);
    alertList.value = res.data?.rows || [];
    alertTotal.value = res.data?.total || 0;
  } finally {
    alertLoading.value = false;
  }
}
function searchAlerts() {
  alertQuery.pageNum = 1;
  loadAlerts();
}

/* ===== 预警详情 ===== */
const showDetail = ref(false);
const detailData = ref({ alert: null, records: [] });
const chartRef = ref(null);
let chartInstance = null;
const closeForm = reactive({
  checkResult: "",
  supportMeasure: "",
  disposalResult: "",
});
const closeLoading = ref(false);

async function openDetail(item) {
  try {
    const res = await getAlertDetail(item.alertId);
    detailData.value = res.data || { alert: item, records: [] };
    showDetail.value = true;
    closeForm.checkResult = "";
    closeForm.supportMeasure = "";
    closeForm.disposalResult = "";
    await nextTick();
    loadChartData();
  } catch {
    ElMessage.error("加载详情失败");
  }
}

function closeDetail() {
  showDetail.value = false;
  loadAlerts();
}

async function loadChartData() {
  if (!detailData.value.alert?.residentId) return;
  try {
    const res = await getUtilityRecent(detailData.value.alert.residentId, 168);
    renderChart(res.data || []);
  } catch {}
}

function renderChart(data) {
  if (!chartRef.value) return;
  if (!chartInstance) chartInstance = echarts.init(chartRef.value);
  const times = data.map((d) => (d.recordTime || "").substring(5, 13));
  const waterData = data.map((d) => d.waterUsage || 0);
  const electricData = data.map((d) => d.electricUsage || 0);
  chartInstance.setOption(
    {
      tooltip: { trigger: "axis" },
      legend: { data: ["用水量(L)", "用电量(kWh)"] },
      grid: { left: 50, right: 50, top: 40, bottom: 40 },
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
          areaStyle: { color: "rgba(64,158,255,0.1)" },
        },
        {
          name: "用电量(kWh)",
          type: "line",
          data: electricData,
          smooth: true,
          yAxisIndex: 1,
          itemStyle: { color: "#E6A23C" },
          areaStyle: { color: "rgba(230,162,60,0.1)" },
        },
      ],
    },
    true,
  );
}

async function submitClose() {
  if (!closeForm.checkResult && !closeForm.disposalResult) {
    ElMessage.warning("请至少填写核查结果或处置结果");
    return;
  }
  closeLoading.value = true;
  try {
    await closeAlert(detailData.value.alert.alertId, closeForm);
    ElMessage.success("已闭环");
    const res = await getAlertDetail(detailData.value.alert.alertId);
    detailData.value = res.data;
  } finally {
    closeLoading.value = false;
  }
}

/* ===== 关怀工单 ===== */
const orderLoading = ref(false);
const orderList = ref([]);
const orderTotal = ref(0);
const orderQuery = reactive({ pageNum: 1, pageSize: 10, status: "" });

async function loadOrders() {
  orderLoading.value = true;
  try {
    const res = await listCareOrders(orderQuery);
    orderList.value = res.data?.rows || [];
    orderTotal.value = res.data?.total || 0;
  } finally {
    orderLoading.value = false;
  }
}

/* ===== 新建工单 ===== */
const orderDlg = ref(false);
const orderFormRef = ref(null);
const orderForm = reactive({ residentId: "", careItem: "", assigneeId: "" });
const orderRules = {
  residentId: [{ required: true, message: "请选择老人", trigger: "change" }],
  careItem: [{ required: true, message: "请输入关怀事项", trigger: "blur" }],
};
const elderOptions = ref([]);
const staffOptions = ref([]);

async function openOrderDialog() {
  Object.assign(orderForm, { residentId: "", careItem: "", assigneeId: "" });
  try {
    const [elderRes, staffRes] = await Promise.all([
      getAloneElders(),
      listCareStaff({ pageNum: 1, pageSize: 100 }),
    ]);
    elderOptions.value = elderRes.data || [];
    staffOptions.value = staffRes.data?.rows || [];
  } catch {}
  orderDlg.value = true;
}

async function submitOrder() {
  await orderFormRef.value.validate();
  const data = { ...orderForm };
  if (data.assigneeId) data.status = "assigned";
  await createCareOrder(data);
  ElMessage.success("工单已创建");
  orderDlg.value = false;
  loadOrders();
}

/* ===== 指派 ===== */
const assignDlg = ref(false);
const assignForm = reactive({ orderId: null, careItem: "", staffId: "" });

async function openAssignDialog(row) {
  assignForm.orderId = row.careId;
  assignForm.careItem = row.careItem;
  assignForm.staffId = "";
  if (staffOptions.value.length === 0) {
    const res = await listCareStaff({ pageNum: 1, pageSize: 100 });
    staffOptions.value = res.data?.rows || [];
  }
  assignDlg.value = true;
}

async function submitAssign() {
  if (!assignForm.staffId) {
    ElMessage.warning("请选择人员");
    return;
  }
  await assignCareOrder(assignForm.orderId, { staffId: assignForm.staffId });
  ElMessage.success("指派成功");
  assignDlg.value = false;
  loadOrders();
}

/* ===== 工单闭环 ===== */
const completeDlg = ref(false);
const completeForm = reactive({
  orderId: null,
  careItem: "",
  checkResult: "",
  supportMeasure: "",
  disposalResult: "",
});

function openCompleteDialog(row) {
  completeForm.orderId = row.careId;
  completeForm.careItem = row.careItem;
  completeForm.checkResult = "";
  completeForm.supportMeasure = "";
  completeForm.disposalResult = "";
  completeDlg.value = true;
}

async function submitComplete() {
  if (!completeForm.checkResult && !completeForm.disposalResult) {
    ElMessage.warning("请至少填写核查结果或处置结果");
    return;
  }
  await completeCareOrder(completeForm.orderId, {
    checkResult: completeForm.checkResult,
    supportMeasure: completeForm.supportMeasure,
    disposalResult: completeForm.disposalResult,
  });
  ElMessage.success("工单已闭环");
  completeDlg.value = false;
  loadOrders();
}

/* ===== 初始化 ===== */
onMounted(() => {
  loadStatus();
  loadAlerts();
  loadOrders();
});
</script>

<style scoped lang="scss">
.ai-monitor {
  padding: 16px;
}
.stat-row {
  margin-bottom: 16px;
}
.stat-card {
  :deep(.el-card__body) {
    padding: 20px;
  }
}
.stat-content {
  display: flex;
  align-items: center;
  gap: 16px;
}
.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  color: #fff;
  &.blue {
    background: linear-gradient(135deg, #36a3eb, #1a73e8);
  }
  &.green {
    background: linear-gradient(135deg, #36d399, #16a34a);
  }
  &.red {
    background: linear-gradient(135deg, #f87171, #dc2626);
  }
  &.orange {
    background: linear-gradient(135deg, #fbbf24, #f59e0b);
  }
}
.stat-info {
  flex: 1;
}
.stat-value {
  font-size: 24px;
  font-weight: 700;
  color: #303133;
  line-height: 1.2;
}
.stat-time {
  font-size: 14px;
  font-weight: 600;
}
.stat-label {
  font-size: 13px;
  color: #909399;
  margin-top: 4px;
}

.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  flex-wrap: wrap;
  gap: 10px;
  .toolbar-left {
    display: flex;
    gap: 10px;
    align-items: center;
  }
  .toolbar-right {
    display: flex;
    gap: 10px;
    align-items: center;
  }
}

/* 预警卡片 */
.alert-card-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.alert-card {
  border: 1px solid #ebeef5;
  border-radius: 8px;
  padding: 16px 20px;
  cursor: pointer;
  transition: all 0.2s;
  background: #fff;
  &:hover {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
    transform: translateY(-1px);
  }
  &.alert-level-1 {
    border-left: 4px solid #f56c6c;
  }
  &.alert-level-2 {
    border-left: 4px solid #e6a23c;
  }
}
.alert-card-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 8px;
}
.alert-level-badge {
  font-size: 13px;
  font-weight: 600;
  &.badge-red {
    color: #f56c6c;
  }
  &.badge-orange {
    color: #e6a23c;
  }
}
.alert-elder-name {
  font-size: 15px;
  font-weight: 600;
  color: #303133;
}
.alert-status-tag {
  margin-left: auto;
}
.alert-card-body {
  .alert-content {
    font-size: 13px;
    color: #606266;
    margin-bottom: 4px;
  }
  .alert-time {
    font-size: 12px;
    color: #909399;
  }
}
.alert-card-footer {
  margin-top: 8px;
  text-align: right;
}

/* 详情视图 */
.detail-back {
  margin-bottom: 16px;
}
.detail-info-card {
  margin-bottom: 16px;
}
.elder-info-row {
  display: flex;
  flex-wrap: wrap;
  gap: 24px;
}
.info-item {
  display: flex;
  align-items: center;
}
.info-label {
  color: #909399;
  font-size: 13px;
  white-space: nowrap;
}
.info-value {
  color: #303133;
  font-size: 14px;
  font-weight: 500;
}
.alert-text {
  color: #f56c6c;
}
.detail-chart-card {
  margin-bottom: 16px;
}
.detail-records-card {
  margin-bottom: 16px;
}
.detail-close-card {
  margin-bottom: 16px;
}
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: 600;
}

.record-item {
  display: flex;
  gap: 12px;
  padding: 10px 0;
  border-bottom: 1px solid #f0f0f0;
  font-size: 13px;
  &:last-child {
    border-bottom: none;
  }
}
.record-time {
  color: #909399;
  white-space: nowrap;
  min-width: 140px;
}
.record-handler {
  color: #409eff;
  font-weight: 500;
  min-width: 60px;
}
.record-content {
  color: #606266;
  flex: 1;
}
.text-muted {
  color: #909399;
  font-size: 13px;
}
</style>
