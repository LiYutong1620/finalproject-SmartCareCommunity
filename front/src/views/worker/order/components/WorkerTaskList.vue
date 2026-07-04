<template>

  <div class="task-list-page">

    <el-form :inline="true" class="search-form">

      <el-form-item v-if="mode === 'todo'" label="状态">

        <el-select v-model="query.status" clearable placeholder="全部" style="width: 120px">

          <el-option label="待接单" value="assigned" />

          <el-option label="处理中" value="processing" />

          <el-option label="待验收" value="wait_accept" />

        </el-select>

      </el-form-item>

      <el-form-item label="紧急程度">

        <el-select v-model="query.urgency" clearable placeholder="全部" style="width: 110px">

          <el-option label="普通" value="normal" />

          <el-option label="较急" value="urgent" />

          <el-option label="紧急" value="emergency" />

        </el-select>

      </el-form-item>

      <el-form-item v-if="mode === 'history'" label="完成时间">

        <el-date-picker

          v-model="query.dateRange"

          type="daterange"

          range-separator="至"

          start-placeholder="开始"

          end-placeholder="结束"

          value-format="YYYY-MM-DD"

          style="width: 240px"

          clearable

        />

      </el-form-item>

      <el-form-item>

        <el-button icon="Refresh" @click="resetQuery">重置</el-button>

      </el-form-item>

      <el-form-item v-if="mode === 'todo'" class="toolbar-item">

        <el-popover ref="msgPopoverRef" placement="bottom-end" :width="400" trigger="click" @show="loadMessages">

          <template #reference>

            <el-badge :value="unreadCount" :hidden="!unreadCount" :max="99">

              <el-button circle class="msg-btn">

                <el-icon :size="18"><Bell /></el-icon>

              </el-button>

            </el-badge>

          </template>

          <div class="msg-panel">

            <div class="msg-panel-head">

              <span class="head-title">工单消息</span>

              <span v-if="unreadCount" class="head-unread">{{ unreadCount }} 条未读</span>

            </div>

            <div class="msg-tabs">

              <button

                type="button"

                class="msg-tab"

                :class="{ active: msgFilter === 'all' }"

                @click="msgFilter = 'all'"

              >

                全部

              </button>

              <button

                type="button"

                class="msg-tab"

                :class="{ active: msgFilter === 'unread' }"

                @click="msgFilter = 'unread'"

              >

                未读

              </button>

            </div>

            <div v-if="msgLoading" class="msg-loading">加载中…</div>

            <ul v-else-if="filteredMessages.length" class="msg-list">

              <li

                v-for="item in filteredMessages"

                :key="item.messageId"

                class="msg-item"

                :class="isMsgUnread(item) ? 'is-unread' : 'is-read'"

              >

                <div class="msg-item-main">

                  <div class="msg-item-top">

                    <span v-if="isMsgUnread(item)" class="unread-dot" />

                    <span class="msg-title">{{ item.title }}</span>

                    <el-tag

                      :type="isMsgUnread(item) ? 'warning' : 'info'"

                      size="small"

                      effect="plain"

                      round

                      class="read-tag"

                    >

                      {{ isMsgUnread(item) ? '未读' : '已读' }}

                    </el-tag>

                  </div>

                  <div class="msg-content">{{ item.content }}</div>

                  <div class="msg-time">{{ item.createTime }}</div>

                </div>

                <el-button

                  v-if="item.bizId"

                  link

                  type="primary"

                  size="small"

                  class="msg-detail-btn"

                  @click="openMessageDetail(item)"

                >

                  详情

                </el-button>

                <span v-else class="msg-no-link">—</span>

              </li>

            </ul>

            <el-empty v-else :description="msgFilter === 'unread' ? '暂无未读消息' : '暂无消息'" :image-size="64" />

          </div>

        </el-popover>

      </el-form-item>

    </el-form>



    <el-card shadow="never" class="table-card">

      <el-table

        v-loading="loading"

        :data="list"

        stripe

        class="task-table"

        :row-class-name="tableRowClassName"

      >

        <el-table-column type="index" label="序号" width="64" align="center" />

        <el-table-column label="工单号" width="160" show-overflow-tooltip>

          <template #default="{ row }">

            <span class="order-no-cell">{{ formatOrderNo(row.orderNo) }}</span>

          </template>

        </el-table-column>

        <el-table-column prop="description" label="故障描述" min-width="180" show-overflow-tooltip />

        <el-table-column prop="urgency" label="紧急程度" width="100" align="center">

          <template #default="{ row }">

            <el-tag :type="urgencyTagType(row.urgency)" size="small" effect="plain" round>

              {{ workerUrgencyLabel(row.urgency) }}

            </el-tag>

          </template>

        </el-table-column>

        <el-table-column label="状态" width="140" align="center">

          <template #default="{ row }">

            <div class="status-cell">

              <el-tag

                :type="workerStatusTagType(row.status) || undefined"

                :class="workerStatusTagClass(row.status)"

                size="small"

                effect="plain"

                round

              >

                {{ workerStatusLabel(row.status) }}

              </el-tag>

              <el-tag v-if="mode === 'todo' && row.appendPending" class="tag-append" size="small" effect="plain" round>补充</el-tag>

            </div>

          </template>

        </el-table-column>

        <el-table-column v-if="mode === 'todo'" label="报修时间" width="168" align="center">

          <template #default="{ row }">{{ formatDateTime(row.createTime) }}</template>

        </el-table-column>

        <el-table-column v-if="mode === 'history'" label="完成时间" width="168" align="center">

          <template #default="{ row }">{{ formatDateTime(row.repairCompleteTime || row.updateTime) }}</template>

        </el-table-column>

        <el-table-column label="操作" width="88" align="center" fixed="right">

          <template #default="{ row }">

            <el-button link class="btn-detail" @click="openDetail(row)">详情</el-button>

          </template>

        </el-table-column>

      </el-table>



      <el-empty v-if="!loading && list.length === 0" :description="emptyText" :image-size="80" />



      <Pagination

        v-show="total > 0"

        :total="total"

        v-model:page="query.pageNum"

        v-model:limit="query.pageSize"

        @pagination="load"

      />

    </el-card>



    <WorkerOrderDrawer

      v-model:visible="detailVisible"

      :order-id="detailOrderId"

      @changed="onDetailChanged"

      @reject="openRejectFromDrawer"

    />



    <WorkerRejectDialog
      v-model="rejectVisible"
      :order="rejectTarget"
      @success="onRejectSuccess"
    />
  </div>

</template>



<script setup>

import { ref, reactive, computed, inject, watch, onMounted, onBeforeUnmount, nextTick } from 'vue'

import { ElMessage } from 'element-plus'

import { Bell } from '@element-plus/icons-vue'

import {

  listWorkerTodo, listWorkerHistory,

  getUnreadMessageCount, listRecentMessages, markMessageRead

} from '@/api/repair'

import { useAutoQuery } from '@/composables/useAutoQuery'

import { workerStatusLabel, workerStatusTagType, workerStatusTagClass, workerUrgencyLabel } from '@/utils/workerLabels'

import { formatOrderNo, formatDateTime, urgencyTagType } from '@/utils/orderFormat'

import WorkerOrderDrawer from './WorkerOrderDrawer.vue'
import WorkerRejectDialog from './WorkerRejectDialog.vue'



const props = defineProps({

  mode: { type: String, required: true, validator: v => ['todo', 'history'].includes(v) }

})



const taskCenter = inject('taskCenter', null)

const list = ref([])

const total = ref(0)

const detailVisible = ref(false)

const detailOrderId = ref(null)

const rejectVisible = ref(false)
const rejectTarget = ref(null)
const msgPopoverRef = ref(null)

const unreadCount = ref(0)

const recentMessages = ref([])

const msgLoading = ref(false)

const msgFilter = ref('all')



const query = reactive({

  pageNum: 1,

  pageSize: 10,

  status: '',

  urgency: '',

  dateRange: []

})



let pollTimer = null



const emptyText = computed(() =>

  props.mode === 'todo' ? '暂无待办任务' : '暂无历史记录'

)



const filteredMessages = computed(() => {

  if (msgFilter.value === 'unread') {

    return recentMessages.value.filter(isMsgUnread)

  }

  return recentMessages.value

})



function isMsgUnread(item) {

  return item?.readFlag === 0 || item?.readFlag === false

}



async function fetchList() {

  const params = { pageNum: query.pageNum, pageSize: query.pageSize }

  if (query.urgency) params.urgency = query.urgency

  if (props.mode === 'todo') {

    if (query.status) params.status = query.status

  } else if (query.dateRange?.length === 2) {

    params.startTime = query.dateRange[0] + 'T00:00:00'

    params.endTime = query.dateRange[1] + 'T23:59:59'

  }

  const res = props.mode === 'todo'

    ? await listWorkerTodo(params)

    : await listWorkerHistory(params)

  list.value = res.data.rows || []

  total.value = res.data.total || 0

}



const queryDeps = computed(() => {

  if (props.mode === 'history') {

    return [props.mode, query.urgency, query.dateRange?.[0], query.dateRange?.[1]]

  }

  return [props.mode, query.status, query.urgency]

})



const { load, reset: resetAuto, loading } = useAutoQuery(

  fetchList,

  () => queryDeps.value,

  { beforeLoad: () => { query.pageNum = 1 } }

)



async function refreshUnread() {

  if (props.mode !== 'todo') return

  try {

    const res = await getUnreadMessageCount({ msgType: 'order' })

    unreadCount.value = res.data || 0

  } catch { /* ignore */ }

}



async function loadMessages() {

  msgLoading.value = true

  try {

    const res = await listRecentMessages({ msgType: 'order', limit: 15, unreadOnly: false })

    recentMessages.value = res.data || []

  } finally {

    msgLoading.value = false

  }

}



async function openMessageDetail(item) {
  msgPopoverRef.value?.hide?.()

  if (isMsgUnread(item)) {

    await markMessageRead(item.messageId)

    item.readFlag = 1

    refreshUnread()

  }

  if (item.bizId) {
    openOrderById(item.bizId)
  } else {

    ElMessage.info('该消息未关联工单')

  }

}



function resetQuery() {

  resetAuto(() => {

    query.status = ''

    query.urgency = ''

    query.dateRange = []

    query.pageNum = 1

  })

}



function tableRowClassName() {

  return ''

}



function openDetail(row) {

  detailOrderId.value = row.orderId

  detailVisible.value = true

}



async function openRejectFromDrawer(order) {
  detailVisible.value = false
  rejectTarget.value = order
  await nextTick()
  rejectVisible.value = true
}

function onRejectSuccess() {
  load()
  refreshUnread()
}

function onDetailChanged() {

  load()

  refreshUnread()

}



function openOrderById(orderId) {
  detailOrderId.value = orderId != null ? Number(orderId) || orderId : null
  detailVisible.value = true
}



watch(() => taskCenter?.pendingOrderId?.value, id => {

  if (id) {

    openOrderById(id)

    taskCenter.pendingOrderId.value = null

  }

})



onMounted(() => {

  if (props.mode === 'todo') {

    refreshUnread()

    pollTimer = setInterval(refreshUnread, 15000)

  }

})



onBeforeUnmount(() => {

  if (pollTimer) clearInterval(pollTimer)

})



defineExpose({ openOrderById, load, refreshUnread })

</script>



<style scoped>

.search-form {

  display: flex;

  flex-wrap: wrap;

  align-items: flex-start;

  gap: 4px 0;

  margin-bottom: 12px;

  padding: 14px 16px 6px;

  background: #f8fafc;

  border: 1px solid #e8edf3;

  border-radius: 10px;

}



.search-form :deep(.el-form-item) {

  margin-bottom: 10px;

  margin-right: 16px;

}



.toolbar-item {

  margin-left: auto;

  margin-right: 0 !important;

}



.msg-btn {

  border-color: #dcdfe6;

}



.msg-panel-head {

  display: flex;

  align-items: center;

  justify-content: space-between;

  margin-bottom: 10px;

}



.head-title {

  font-weight: 600;

  font-size: 14px;

  color: #303133;

}



.head-unread {

  font-size: 12px;

  font-weight: 500;

  color: #d48806;

  background: #fff7e6;

  padding: 2px 8px;

  border-radius: 10px;

  border: 1px solid #ffd591;

}



.msg-tabs {

  display: flex;

  gap: 6px;

  margin-bottom: 10px;

  padding: 3px;

  background: #f5f7fa;

  border-radius: 8px;

}



.msg-tab {

  flex: 1;

  border: none;

  background: transparent;

  padding: 6px 0;

  font-size: 13px;

  color: #606266;

  border-radius: 6px;

  cursor: pointer;

  transition: background 0.2s, color 0.2s;

}



.msg-tab.active {

  background: #fff;

  color: #1677ff;

  font-weight: 600;

  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);

}



.msg-list {

  list-style: none;

  margin: 0;

  padding: 0;

  max-height: 360px;

  overflow-y: auto;

}



.msg-item {

  display: flex;

  align-items: center;

  justify-content: space-between;

  gap: 10px;

  padding: 12px 10px;

  border-bottom: 1px solid #f0f2f5;

  border-radius: 8px;

  margin-bottom: 6px;

  transition: background 0.2s;

}



.msg-item:last-child {

  border-bottom: none;

  margin-bottom: 0;

}



.msg-item.is-unread {

  background: linear-gradient(135deg, #fffbe6 0%, #fff7e6 100%);

  border: 1px solid #ffe7ba;

}



.msg-item.is-read {

  background: #fafbfc;

  border: 1px solid #ebeef5;

}



.msg-item-main {

  flex: 1;

  min-width: 0;

}



.msg-item-top {

  display: flex;

  align-items: center;

  gap: 6px;

  flex-wrap: wrap;

}



.unread-dot {

  flex-shrink: 0;

  width: 7px;

  height: 7px;

  border-radius: 50%;

  background: #fa8c16;

  box-shadow: 0 0 0 2px rgba(250, 140, 22, 0.25);

}



.msg-title {

  font-size: 13px;

  font-weight: 600;

  color: #303133;

}



.msg-item.is-unread .msg-title {

  color: #d48806;

}



.read-tag {

  flex-shrink: 0;

  height: 20px;

  line-height: 18px;

  padding: 0 6px;

}



.msg-content {

  margin-top: 6px;

  font-size: 12px;

  line-height: 1.5;

  color: #606266;

  display: -webkit-box;

  -webkit-line-clamp: 2;

  -webkit-box-orient: vertical;

  overflow: hidden;

}



.msg-item.is-read .msg-content {

  color: #909399;

}



.msg-time {

  margin-top: 6px;

  font-size: 11px;

  color: #909399;

}



.msg-detail-btn {

  flex-shrink: 0;

  font-weight: 600;

  padding: 4px 8px;

}



.msg-no-link {

  flex-shrink: 0;

  color: #c0c4cc;

  font-size: 12px;

}



.msg-loading { padding: 20px; text-align: center; color: #909399; }



.table-card {

  border-radius: 10px;

  border: 1px solid #e8edf3;

  overflow: hidden;

}



.table-card :deep(.el-card__body) {

  padding: 0;

}



.task-table :deep(.el-table__header th) {

  background: #f4f7fb !important;

  color: #303133 !important;

  font-weight: 600;

  font-size: 13px;

}



.task-table :deep(.el-table__row) {

  font-size: 13px;

}



.task-table :deep(.el-table__body tr:hover > td) {

  background: #f5f9ff !important;

}



.order-no-cell {

  font-family: ui-monospace, 'Cascadia Code', Consolas, monospace;

  font-size: 12px;

  color: #1a1a2e;

  letter-spacing: 0.01em;

}



.status-cell {

  display: flex;

  flex-wrap: wrap;

  gap: 4px;

  justify-content: center;

}



.tag-append {

  --el-tag-bg-color: #fff7e6;

  --el-tag-border-color: #ffd591;

  --el-tag-text-color: #d48806;

}



:deep(.tag-wait-accept) {

  --el-tag-bg-color: #f9f0ff;

  --el-tag-border-color: #d3adf7;

  --el-tag-text-color: #722ed1;

}



.btn-detail {

  color: #409eff !important;

  font-weight: 500;

}



.task-table + .el-empty {

  padding: 24px 0;

}



.reject-form :deep(.el-form-item) {

  margin-bottom: 16px;

}

</style>


