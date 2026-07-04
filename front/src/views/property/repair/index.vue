<template>
  <div class="app-container property-table-page repair-supervision">
    <div class="page-head">
      <h2 class="page-title">工单监管</h2>
      <div class="page-actions">
        <div class="auto-dispatch-switch">
          <span class="switch-label">AI 自动派单</span>
          <el-switch
            v-model="autoDispatchEnabled"
            :loading="configLoading"
            inline-prompt
            active-text="开"
            inactive-text="关"
            @change="onAutoDispatchChange"
          />
          <el-tooltip content="开启后，AI 分析完成且非高风险/非重复报修时将自动派单" placement="top">
            <el-icon class="hint-icon"><QuestionFilled /></el-icon>
          </el-tooltip>
        </div>
        <el-button type="primary" plain :loading="batchLoading" @click="handleBatchDispatch">
          批量 AI 派单
        </el-button>
      </div>
    </div>

    <div class="filter-panel">
      <el-form :inline="true" class="search-form">
        <el-form-item label="状态">
          <el-select v-model="query.status" clearable placeholder="全部" style="width: 120px">
            <el-option v-for="(label, val) in REPAIR_STATUS_MAP" :key="val" :label="label" :value="val" />
          </el-select>
        </el-form-item>
        <el-form-item label="紧急程度">
          <el-select v-model="query.urgency" clearable placeholder="全部" style="width: 100px">
            <el-option v-for="(label, val) in REPAIR_URGENCY_MAP" :key="val" :label="label" :value="val" />
          </el-select>
        </el-form-item>
        <el-form-item label="故障类型">
          <el-select v-model="query.typeId" clearable filterable placeholder="全部" style="width: 160px">
            <el-option v-for="t in leafRepairTypes" :key="t.typeId" :label="t.label" :value="t.typeId" />
          </el-select>
        </el-form-item>
        <el-form-item label="时间段">
          <el-date-picker
            v-model="query.dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始"
            end-placeholder="结束"
            value-format="YYYY-MM-DD"
            style="width: 240px"
          />
        </el-form-item>
        <el-form-item>
          <el-button icon="Refresh" @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
    </div>

    <el-card shadow="never" class="table-card">
      <el-table :data="list" v-loading="loading" border stripe class="data-table">
        <el-table-column type="index" label="序号" width="56" align="center" />
        <el-table-column label="工单号" width="168">
          <template #default="{ row }">
            <el-button link type="primary" class="cell-link" @click="openDetail(row)">
              {{ formatOrderNo(row.orderNo) }}
            </el-button>
          </template>
        </el-table-column>
        <el-table-column prop="ownerName" label="业主" width="90" show-overflow-tooltip />
        <el-table-column label="故障类型" width="130" show-overflow-tooltip>
          <template #default="{ row }">{{ row.typeName || '—' }}</template>
        </el-table-column>
        <el-table-column label="状态" width="92" align="center">
          <template #default="{ row }">
            <el-tag
              :type="repairStatusTagType(row.status) || undefined"
              :class="repairStatusTagClass(row.status)"
              size="small"
              effect="plain"
              round
            >{{ REPAIR_STATUS_MAP[row.status] || row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="紧急" width="72" align="center">
          <template #default="{ row }">
            <el-tag
              :type="urgencyTagType(row.urgency) || undefined"
              :class="urgencyTagClass(row.urgency)"
              size="small"
              effect="plain"
              round
            >{{ REPAIR_URGENCY_MAP[row.urgency] || row.urgency }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="维修工" width="90" show-overflow-tooltip>
          <template #default="{ row }">{{ row.workerName || '未指派' }}</template>
        </el-table-column>
        <el-table-column label="报修时间" width="158" align="center">
          <template #default="{ row }">{{ formatDateTime(row.createTime) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="80" align="center" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" class="btn-action" @click="openDetail(row)">详情</el-button>
          </template>
        </el-table-column>
      </el-table>
      <Pagination
        v-show="total > 0"
        :total="total"
        v-model:page="query.pageNum"
        v-model:limit="query.pageSize"
        @pagination="loadList"
      />
    </el-card>

    <PropertyRepairDetailDrawer
      v-model="detailVisible"
      :order-id="currentOrderId"
      @changed="loadList"
    />
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { QuestionFilled } from '@element-plus/icons-vue'
import {
  listPropertyRepair,
  listRepairTypes,
  getAutoDispatchConfig,
  setAutoDispatchConfig,
  batchAiAutoDispatch
} from '@/api/repair'
import PropertyRepairDetailDrawer from './components/PropertyRepairDetailDrawer.vue'
import { useAutoQuery } from '@/composables/useAutoQuery'
import {
  formatOrderNo,
  formatDateTime,
  urgencyTagType,
  urgencyTagClass,
  REPAIR_STATUS_MAP,
  REPAIR_URGENCY_MAP,
  repairStatusTagType,
  repairStatusTagClass
} from '@/utils/orderFormat'
import '@/styles/property-table-page.css'

const list = ref([])
const total = ref(0)
const repairTypes = ref([])
const detailVisible = ref(false)
const currentOrderId = ref(null)
const autoDispatchEnabled = ref(false)
const configLoading = ref(false)
const batchLoading = ref(false)

const query = reactive({
  pageNum: 1,
  pageSize: 10,
  status: '',
  urgency: '',
  typeId: null,
  dateRange: []
})

const leafRepairTypes = computed(() => {
  const flat = repairTypes.value
  return flat
    .filter(t => (t.parentId || 0) > 0)
    .map(t => {
      const parent = flat.find(p => p.typeId === t.parentId)
      return { typeId: t.typeId, label: parent ? `${parent.typeName} / ${t.typeName}` : t.typeName }
    })
})

async function loadTypes() {
  const res = await listRepairTypes()
  repairTypes.value = res.data || []
}

async function fetchList() {
  const params = { pageNum: query.pageNum, pageSize: query.pageSize }
  if (query.status) params.status = query.status
  if (query.urgency) params.urgency = query.urgency
  if (query.typeId) params.typeId = query.typeId
  if (query.dateRange?.length === 2) {
    params.startTime = query.dateRange[0] + 'T00:00:00'
    params.endTime = query.dateRange[1] + 'T23:59:59'
  }
  const res = await listPropertyRepair(params)
  list.value = res.data?.rows || []
  total.value = res.data?.total || 0
}

const { loading, load: loadList, reset: resetAuto } = useAutoQuery(
  fetchList,
  () => [query.status, query.urgency, query.typeId, query.dateRange],
  { debounce: 300, beforeLoad: () => { query.pageNum = 1 } }
)

function resetQuery() {
  resetAuto(() => {
    query.status = ''
    query.urgency = ''
    query.typeId = null
    query.dateRange = []
    query.pageNum = 1
  })
}

function openDetail(row) {
  currentOrderId.value = row.orderId
  detailVisible.value = true
}

async function loadAutoDispatchConfig() {
  configLoading.value = true
  try {
    const res = await getAutoDispatchConfig()
    autoDispatchEnabled.value = !!res.data?.enabled
  } finally {
    configLoading.value = false
  }
}

async function onAutoDispatchChange(val) {
  configLoading.value = true
  try {
    await setAutoDispatchConfig(val)
    ElMessage.success(val ? '已开启 AI 自动派单' : '已关闭 AI 自动派单')
  } catch {
    autoDispatchEnabled.value = !val
  } finally {
    configLoading.value = false
  }
}

async function handleBatchDispatch() {
  try {
    await ElMessageBox.confirm(
      '将对所有待派单、非高风险且非重复报修的工单执行 AI 批量派单，是否继续？',
      '批量 AI 派单',
      { type: 'info', confirmButtonText: '开始派单', cancelButtonText: '取消' }
    )
  } catch {
    return
  }
  batchLoading.value = true
  try {
    const res = await batchAiAutoDispatch()
    const d = res.data || {}
    ElMessage.success(`派单完成：成功 ${d.success ?? 0}，跳过 ${d.skipped ?? 0}，失败 ${d.failed ?? 0}`)
    loadList()
  } finally {
    batchLoading.value = false
  }
}

onMounted(() => {
  loadTypes()
  loadAutoDispatchConfig()
})
</script>

<style scoped>
.repair-supervision {
  max-width: 1280px;
}

.page-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 12px;
  margin-bottom: 16px;
}

.page-actions {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
}

.auto-dispatch-switch {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 12px;
  background: var(--el-bg-color);
  border: 1px solid var(--el-border-color-lighter);
  border-radius: 8px;
}

.switch-label {
  font-size: 14px;
  color: var(--el-text-color-regular);
}

.hint-icon {
  color: var(--el-text-color-secondary);
  cursor: help;
}

.page-title {
  margin: 0;
  font-size: 22px;
  font-weight: 600;
}
</style>
