<template>
  <div class="notice-page app-container" :class="isOutage ? 'theme-outage' : 'theme-announce'">
    <div class="page-header">
      <h2 class="page-title">{{ pageTitle }}</h2>
      <p v-if="pageDesc" class="page-desc">{{ pageDesc }}</p>
    </div>

    <el-form :inline="true" class="search-form">
      <el-form-item label="标题">
        <el-input
          v-model="query.title"
          placeholder="请输入标题"
          clearable
          style="width: 200px"
        />
      </el-form-item>
      <el-form-item label="状态">
        <el-radio-group v-model="readTab">
          <el-radio-button value="">全部</el-radio-button>
          <el-radio-button value="0">未读</el-radio-button>
          <el-radio-button value="1">已读</el-radio-button>
        </el-radio-group>
      </el-form-item>
      <el-form-item label="发布时间">
        <el-date-picker
          v-model="query.publishTimeRange"
          type="datetimerange"
          range-separator="至"
          start-placeholder="开始时间"
          end-placeholder="结束时间"
          value-format="YYYY-MM-DD HH:mm:ss"
          style="width: 360px"
          clearable
        />
      </el-form-item>
      <el-form-item>
        <el-button class="btn-reset" icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-card shadow="never" class="table-card">
      <el-table
        v-loading="loading"
        :data="list"
        border
        class="notice-table"
        @row-click="openDetail"
      >
        <el-table-column type="index" label="序号" width="64" align="center" />
        <el-table-column prop="title" label="标题" min-width="220" show-overflow-tooltip>
          <template #default="{ row }">
            <span class="title-cell">{{ row.title }}</span>
          </template>
        </el-table-column>
        <el-table-column v-if="isOutage" prop="scope" label="影响范围" min-width="120" align="center" show-overflow-tooltip>
          <template #default="{ row }">
            <span class="scope-cell">{{ row.scope || '—' }}</span>
          </template>
        </el-table-column>
        <el-table-column v-if="isOutage" prop="restoreTime" label="预计恢复" width="170" align="center">
          <template #default="{ row }">
            <span v-if="row.restoreTime" class="restore-time">{{ row.restoreTime }}</span>
            <span v-else class="text-muted">—</span>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="88" align="center">
          <template #default="{ row }">
            <el-tag
              :class="row.read ? 'tag-read' : 'tag-unread'"
              size="small"
              effect="plain"
              round
            >
              {{ row.read ? '已读' : '未读' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="发布时间" width="170" align="center" />
        <el-table-column label="操作" width="88" align="center" fixed="right">
          <template #default="{ row }">
            <el-button link class="btn-detail" @click.stop="openDetail(row)">详情</el-button>
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

    <NoticeDetailDrawer
      v-model:visible="detailVisible"
      :notice-id="detailId"
      :notice-type="noticeType"
      @read="onDetailRead"
    />
  </div>
</template>

<script setup>
import { computed, reactive, ref, watch } from 'vue'
import { listNoticeV2 } from '@/api/owner'
import { useAutoQuery } from '@/composables/useAutoQuery'
import NoticeDetailDrawer from './NoticeDetailDrawer.vue'

const props = defineProps({
  noticeType: { type: String, required: true },
  pageTitle: { type: String, required: true },
  pageDesc: { type: String, default: '' },
  emptyText: { type: String, default: '暂无通知' }
})

const isOutage = computed(() => props.noticeType === 'outage')

const list = ref([])
const total = ref(0)
const readTab = ref('')
const detailVisible = ref(false)
const detailId = ref(null)

const query = reactive({
  pageNum: 1,
  pageSize: 10,
  title: '',
  publishTimeRange: null
})

async function fetchList() {
  const params = {
    pageNum: query.pageNum,
    pageSize: query.pageSize,
    noticeType: props.noticeType
  }
  if (query.title?.trim()) params.title = query.title.trim()
  if (readTab.value !== '') params.readStatus = readTab.value
  if (query.publishTimeRange?.length === 2) {
    params.publishTimeStart = query.publishTimeRange[0]
    params.publishTimeEnd = query.publishTimeRange[1]
  }
  const res = await listNoticeV2(params)
  list.value = res.data.rows || []
  total.value = res.data.total || 0
}

const { loading, load, reset: resetAuto } = useAutoQuery(
  fetchList,
  () => [props.noticeType, query.title, readTab.value, query.publishTimeRange],
  { beforeLoad: () => { query.pageNum = 1 } }
)

function resetQuery() {
  resetAuto(() => {
    query.title = ''
    readTab.value = ''
    query.publishTimeRange = null
    query.pageNum = 1
  })
}

function openDetail(row) {
  detailId.value = row.noticeId
  detailVisible.value = true
}

function onDetailRead(detail) {
  const item = list.value.find(r => r.noticeId === detail.noticeId)
  if (item) item.read = true
}

watch(detailVisible, val => {
  if (!val) detailId.value = null
})
</script>

<style scoped>
.notice-page {
  max-width: 1100px;
}

.page-header {
  margin-bottom: 16px;
}

.page-title {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
  color: #1a1a2e;
}

.page-desc {
  margin: 6px 0 0;
  font-size: 13px;
  color: #909399;
}

.search-form :deep(.el-radio-button__original-radio:checked + .el-radio-button__inner) {
  background-color: #409eff;
  border-color: #409eff;
  color: #fff;
  box-shadow: -1px 0 0 0 #409eff;
}

.theme-outage .search-form :deep(.el-radio-button__original-radio:checked + .el-radio-button__inner) {
  background-color: #e6a23c;
  border-color: #e6a23c;
  color: #fff;
  box-shadow: -1px 0 0 0 #e6a23c;
}

.btn-reset {
  color: #606266;
  border-color: #dcdfe6;
}

.theme-announce .btn-reset:hover {
  color: #409eff;
  border-color: #c6e2ff;
  background-color: #ecf5ff;
}

.theme-outage .btn-reset:hover {
  color: #e6a23c;
  border-color: #f5dab1;
  background-color: #fdf6ec;
}

.table-card {
  border-radius: 8px;
  border: 1px solid #ebeef5;
  overflow: hidden;
}

.notice-table {
  width: 100%;
  --el-table-border-color: #ebeef5;
  --el-table-header-text-color: #303133;
}

.notice-table :deep(.el-table__header th) {
  background: #f8fafc !important;
  color: #303133 !important;
  font-weight: 600;
  font-size: 13px;
  padding: 12px 0;
}

.notice-table :deep(.el-table__body td) {
  color: #606266;
  font-size: 13px;
  padding: 11px 0;
}

.notice-table :deep(.el-table__row) {
  cursor: pointer;
  background-color: #fff !important;
}

.notice-table :deep(.el-table__row:hover > td) {
  background-color: #f5f9ff !important;
}

.theme-outage .notice-table :deep(.el-table__row:hover > td) {
  background-color: #fffbf5 !important;
}

.title-cell {
  color: #303133;
}

.scope-cell {
  color: #606266;
}

.tag-unread {
  --el-tag-bg-color: #fff7e6;
  --el-tag-border-color: #ffd591;
  --el-tag-text-color: #d48806;
}

.tag-read {
  --el-tag-bg-color: #f4f4f5;
  --el-tag-border-color: #dcdfe6;
  --el-tag-text-color: #909399;
}

.btn-detail {
  color: #409eff !important;
  font-weight: 500;
}

.btn-detail:hover {
  color: #66b1ff !important;
}

.theme-outage .btn-detail {
  color: #e6a23c !important;
}

.theme-outage .btn-detail:hover {
  color: #f0c78a !important;
}

.restore-time {
  color: #d48806;
  font-weight: 500;
}

.text-muted {
  color: #c0c4cc;
}

.table-card :deep(.pagination-container) {
  margin-top: 12px;
}
</style>
