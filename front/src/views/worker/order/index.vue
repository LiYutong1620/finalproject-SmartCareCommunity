<template>
  <div class="app-container">
    <el-form :inline="true" class="search-form">
      <el-form-item label="状态">
        <el-select v-model="query.status" clearable placeholder="全部状态" style="width: 120px">
          <el-option label="待处理" value="pending" />
          <el-option label="处理中" value="processing" />
          <el-option label="待验收" value="wait_accept" />
          <el-option label="已完成" value="completed" />
        </el-select>
      </el-form-item>
      <el-form-item label="紧急程度">
        <el-select v-model="query.urgency" clearable placeholder="全部紧急程度" style="width: 140px">
          <el-option label="普通" value="normal" />
          <el-option label="较急" value="urgent" />
          <el-option label="紧急" value="emergency" />
        </el-select>
      </el-form-item>
      <el-form-item label="开始日期">
        <el-date-picker v-model="query.startDate" type="date" value-format="YYYY-MM-DD" placeholder="开始日期" />
      </el-form-item>
      <el-form-item label="结束日期">
        <el-date-picker v-model="query.endDate" type="date" value-format="YYYY-MM-DD" placeholder="结束日期" />
      </el-form-item>
      <el-form-item label="关键词">
        <el-input v-model="query.keyword" placeholder="工单号/描述" style="width: 180px" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
        <el-button type="primary" plain @click="$router.push('/worker/order/profile')">我的状态</el-button>
        <el-button type="warning" plain @click="$router.push('/worker/order/messages')">
          消息通知
          <el-badge v-if="unreadCount > 0" :value="unreadCount" class="msg-badge" />
        </el-button>
        <el-button type="success" plain @click="$router.push('/worker/order/knowledge')">维修知识库</el-button>
      </el-form-item>
    </el-form>

    <el-card shadow="never" class="table-card">
      <el-table :data="list" v-loading="loading" border stripe>
        <el-table-column type="index" label="序号" width="60" align="center" />
        <el-table-column prop="orderNo" label="工单号" width="180" />
        <el-table-column prop="description" label="故障描述" min-width="180" show-overflow-tooltip />
        <el-table-column prop="urgency" label="紧急程度" width="90" align="center">
          <template #default="{ row }">{{ urgencyMap[row.urgency] || row.urgency }}</template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100" align="center">
          <template #default="{ row }">{{ statusMap[row.status] || row.status }}</template>
        </el-table-column>
        <el-table-column label="操作" width="360" align="center" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="openDetail(row)">详情</el-button>
            <el-button v-if="row.status === 'pending' && !row.workerId" link type="success" @click="handleAccept(row)">接单</el-button>
            <el-button v-if="row.workerId && (row.status === 'pending' || row.status === 'processing')" link type="warning" @click="openReject(row)">拒单</el-button>
            <el-button v-if="row.status === 'processing'" link type="primary" @click="handleComplete(row)">完成维修</el-button>
            <el-button v-if="row.status !== 'completed' && row.workerId" link type="info" @click="openUpload(row)">上传现场图</el-button>
          </template>
        </el-table-column>
      </el-table>
      <Pagination
        v-show="total > 0"
        :total="total"
        v-model:page="query.pageNum"
        v-model:limit="query.pageSize"
        @pagination="load"
      />
    </el-card>

    <el-dialog v-model="detailVisible" title="工单详情" width="760px">
      <el-descriptions v-if="detail" :column="2" border>
        <el-descriptions-item label="工单号">{{ detail.order?.orderNo }}</el-descriptions-item>
        <el-descriptions-item label="状态">{{ statusMap[detail.order?.status] || detail.order?.status }}</el-descriptions-item>
        <el-descriptions-item label="故障描述" :span="2">{{ detail.order?.description }}</el-descriptions-item>
        <el-descriptions-item label="紧急程度">{{ urgencyMap[detail.order?.urgency] || detail.order?.urgency }}</el-descriptions-item>
        <el-descriptions-item label="报修时间">{{ detail.order?.createTime }}</el-descriptions-item>
        <el-descriptions-item label="业主姓名">{{ detail.owner?.nickName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="业主电话">{{ detail.owner?.phone || '-' }}</el-descriptions-item>
        <el-descriptions-item label="业主地址" :span="2">{{ detail.houseAddress || '-' }}</el-descriptions-item>
        <el-descriptions-item label="拒单原因">{{ detail.order?.rejectReason || '-' }}</el-descriptions-item>
      </el-descriptions>
      <template v-if="detail?.repairSteps?.steps?.length">
        <el-divider>标准维修步骤（AI推荐）</el-divider>
        <el-alert :title="`故障类型：${detail.repairSteps.typeName || '通用维修'}`" type="success" :closable="false" style="margin-bottom: 12px" />
        <el-steps direction="vertical" :active="detail.repairSteps.steps.length">
          <el-step v-for="(step, index) in detail.repairSteps.steps" :key="index" :title="`步骤${index + 1}`" :description="step" />
        </el-steps>
      </template>
      <template v-if="detail?.images?.length">
        <el-divider>现场配图</el-divider>
        <div class="image-list">
          <el-image
            v-for="(img, index) in detail.images"
            :key="index"
            :src="img.imageUrl"
            :preview-src-list="detail.images.map((item) => item.imageUrl)"
            fit="cover"
            class="repair-image"
          />
        </div>
      </template>
      <template #footer>
        <el-button @click="detailVisible = false">关闭</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="rejectVisible" title="拒单确认" width="460px">
      <el-form :model="rejectForm" label-width="90px">
        <el-form-item label="拒单原因">
          <el-select v-model="rejectForm.reason" placeholder="请选择拒单原因" style="width: 100%">
            <el-option v-for="item in rejectReasons" :key="item" :label="item" :value="item" />
          </el-select>
        </el-form-item>
        <el-form-item v-if="rejectForm.reason === '其他原因'" label="补充说明">
          <el-input v-model="rejectForm.remark" type="textarea" :rows="3" placeholder="请补充说明" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="rejectVisible = false">取消</el-button>
        <el-button type="warning" @click="handleReject">确认拒单</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="uploadVisible" title="上传现场照片" width="540px">
      <el-alert type="info" :closable="false" title="最多上传9张，图片将自动添加时间戳水印" style="margin-bottom: 12px" />
      <el-form :model="uploadForm" label-width="90px">
        <el-form-item label="现场图片">
          <el-upload
            v-model:file-list="uploadForm.files"
            :auto-upload="false"
            :limit="9"
            multiple
            list-type="picture-card"
          >
            <el-icon><Plus /></el-icon>
          </el-upload>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="uploadVisible = false">取消</el-button>
        <el-button type="primary" @click="handleUpload">上传</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import {
  listWorkerOrder,
  getWorkerOrderDetail,
  acceptOrder,
  rejectOrder,
  completeOrder,
  uploadWorkerRepairImages,
  getWorkerRejectReasons,
  unreadMessageCount,
  listMessages
} from '@/api/repair'

const loading = ref(false)
const list = ref([])
const total = ref(0)
const detailVisible = ref(false)
const detail = ref(null)
const uploadVisible = ref(false)
const rejectVisible = ref(false)
const currentUploadRow = ref(null)
const currentRejectRow = ref(null)
const rejectReasons = ref([])
const unreadCount = ref(0)
const lastMessageId = ref(0)
let pollTimer = null

const query = reactive({ pageNum: 1, pageSize: 10, status: '', urgency: '', keyword: '', startDate: '', endDate: '' })
const uploadForm = reactive({ files: [] })
const rejectForm = reactive({ reason: '', remark: '' })

const statusMap = {
  pending: '待分配',
  processing: '处理中',
  wait_accept: '待验收',
  completed: '已完成',
  cancelled: '已取消'
}
const urgencyMap = {
  normal: '普通',
  urgent: '较急',
  emergency: '紧急'
}

async function load() {
  loading.value = true
  try {
    const res = await listWorkerOrder(query)
    list.value = res.data.rows || []
    total.value = res.data.total || 0
  } finally {
    loading.value = false
  }
}

async function loadRejectReasons() {
  const res = await getWorkerRejectReasons()
  rejectReasons.value = res.data || []
}

async function pollMessages() {
  try {
    const countRes = await unreadMessageCount()
    unreadCount.value = countRes.data || 0
    const listRes = await listMessages({ pageNum: 1, pageSize: 5, msgType: 'order' })
    const rows = listRes.data?.rows || []
    if (rows.length > 0) {
      const latestId = rows[0].messageId
      if (lastMessageId.value && latestId > lastMessageId.value) {
        ElMessage({
          type: 'warning',
          message: `新工单通知：${rows[0].title}`,
          duration: 5000,
          showClose: true
        })
        load()
      }
      lastMessageId.value = latestId
    }
  } catch (e) {
    // ignore polling errors
  }
}

function handleQuery() {
  query.pageNum = 1
  load()
}

function resetQuery() {
  query.status = ''
  query.urgency = ''
  query.keyword = ''
  query.startDate = ''
  query.endDate = ''
  query.pageNum = 1
  query.pageSize = 10
  load()
}

async function openDetail(row) {
  const res = await getWorkerOrderDetail(row.orderId)
  detail.value = res.data
  detailVisible.value = true
}

async function handleAccept(row) {
  await acceptOrder(row.orderId)
  ElMessage.success('接单成功')
  load()
}

function openReject(row) {
  currentRejectRow.value = row
  rejectForm.reason = ''
  rejectForm.remark = ''
  rejectVisible.value = true
}

async function handleReject() {
  if (!rejectForm.reason) {
    ElMessage.warning('请选择拒单原因')
    return
  }
  const reason = rejectForm.reason === '其他原因' && rejectForm.remark
    ? `其他原因：${rejectForm.remark}`
    : rejectForm.reason
  await rejectOrder(currentRejectRow.value.orderId, { reason })
  ElMessage.success('已拒单')
  rejectVisible.value = false
  load()
}

async function handleComplete(row) {
  await completeOrder(row.orderId)
  ElMessage.success('已提交待验收')
  load()
}

function openUpload(row) {
  currentUploadRow.value = row
  uploadForm.files = []
  uploadVisible.value = true
}

async function handleUpload() {
  const files = uploadForm.files.map((item) => item.raw).filter(Boolean)
  if (files.length === 0) {
    ElMessage.warning('请先选择图片')
    return
  }
  await uploadWorkerRepairImages(currentUploadRow.value.orderId, files)
  ElMessage.success('现场图片已提交')
  uploadVisible.value = false
}

onMounted(async () => {
  await loadRejectReasons()
  await load()
  await pollMessages()
  pollTimer = setInterval(pollMessages, 30000)
})

onUnmounted(() => {
  if (pollTimer) {
    clearInterval(pollTimer)
  }
})
</script>

<style scoped>
.image-list {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}
.repair-image {
  width: 100px;
  height: 100px;
  border-radius: 6px;
}
.msg-badge {
  margin-left: 6px;
}
</style>
