<template>
  <div class="app-container">
    <el-form :inline="true" class="search-form">
      <el-form-item label="状态">
        <el-select v-model="query.status" clearable placeholder="全部" style="width:120px">
          <el-option label="已发布" value="1" />
          <el-option label="待发布" value="2" />
          <el-option label="下架" value="0" />
        </el-select>
      </el-form-item>
      <el-form-item label="标题">
        <el-input v-model="query.title" placeholder="请输入标题" clearable style="width:180px" />
      </el-form-item>
      <el-form-item label="发布时间">
        <el-date-picker
          v-model="query.publishTimeRange"
          type="datetimerange"
          range-separator="至"
          start-placeholder="开始时间"
          end-placeholder="结束时间"
          value-format="YYYY-MM-DD HH:mm:ss"
          style="width:360px"
        />
      </el-form-item>
      <el-form-item>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="openPublish">
          发布{{ noticeTab === 'outage' ? '通知' : '公告' }}
        </el-button>
      </el-col>
    </el-row>

    <el-card shadow="never" class="table-card">
      <el-table v-loading="loading" :data="list" border stripe>
        <el-table-column type="index" label="序号" width="60" align="center" />
        <el-table-column prop="title" label="标题" min-width="180" show-overflow-tooltip />
        <el-table-column v-if="noticeTab === 'outage'" prop="restoreTime" label="预计恢复" width="170" align="center" />
        <el-table-column prop="pinned" label="置顶" width="70" align="center">
          <template #default="{ row }">
            <el-tag v-if="row.status !== '0' && row.pinned" type="danger" size="small">置顶</el-tag>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="statusTagType(row.status)" size="small">{{ statusLabel(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="发布时间" width="170" align="center" />
        <el-table-column prop="offlineTime" label="下架时间" width="170" align="center">
          <template #default="{ row }">{{ row.offlineTime || '-' }}</template>
        </el-table-column>
        <el-table-column label="操作" width="220" align="center" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.status !== '0'" link type="primary" icon="Edit" @click="openEdit(row)">编辑</el-button>
            <el-button link type="primary" icon="View" @click="showReadStats(row)">阅读统计</el-button>
            <el-button v-if="row.status === '1' || row.status === '2'" link type="danger" icon="Delete" @click="offline(row)">下架</el-button>
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

    <el-dialog v-model="dlg" :title="form.noticeId ? '编辑' : '发布'" width="640px" append-to-body destroy-on-close @opened="onDialogOpened">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="标题" prop="title">
          <el-input v-model="form.title" placeholder="请输入标题" maxlength="128" show-word-limit />
        </el-form-item>
        <el-form-item label="正文" prop="content">
          <el-input v-model="form.content" type="textarea" :rows="5" placeholder="请输入正文" />
        </el-form-item>
        <el-form-item label="附件链接">
          <el-input v-model="form.attachment" placeholder="选填" />
        </el-form-item>
        <el-form-item label="置顶">
          <el-switch v-model="form.pinned" :active-value="1" :inactive-value="0" />
        </el-form-item>
        <el-form-item label="发布时间" prop="createTime">
          <el-date-picker
            v-model="form.createTime"
            type="datetime"
            placeholder="选择发布时间"
            value-format="YYYY-MM-DD HH:mm:ss"
            :disabled-date="disabledPublishDate"
            style="width:100%"
            @change="onPublishTimeChange"
          />
          <div v-if="isScheduledPublish" class="form-tip">将定时发布，业主端在到达该时间后可查看</div>
        </el-form-item>
        <el-form-item label="下架时间" prop="offlineTime">
          <el-date-picker
            v-model="form.offlineTime"
            type="datetime"
            placeholder="选填，到达时间后自动下架"
            value-format="YYYY-MM-DD HH:mm:ss"
            :disabled-date="disabledOfflineDate"
            clearable
            style="width:100%"
          />
          <div v-if="form.offlineTime" class="form-tip">到达下架时间后将自动下架并取消置顶</div>
        </el-form-item>
        <template v-if="noticeTab === 'outage'">
          <el-form-item label="影响范围">
            <el-input v-model="form.scope" placeholder="如：1栋全体住户" />
          </el-form-item>
          <el-form-item label="恢复时间" prop="restoreTime">
            <el-date-picker
              v-model="form.restoreTime"
              type="datetime"
              placeholder="选择恢复时间"
              value-format="YYYY-MM-DD HH:mm:ss"
              :disabled-date="disabledRestoreDate"
              style="width:100%"
              @change="onRestoreTimeChange"
            />
          </el-form-item>
        </template>
      </el-form>
      <template #footer>
        <el-button @click="dlg = false">取 消</el-button>
        <el-button type="primary" @click="save">确 定</el-button>
      </template>
    </el-dialog>

    <el-drawer v-model="statsDrawer" title="阅读统计" size="520px" append-to-body>
      <p class="stats-summary">
        阅读率：<strong>{{ readStats.readRate }}%</strong>
        （{{ readStats.readCount }}/{{ readStats.totalOwners }}）
      </p>
      <el-tabs>
        <el-tab-pane label="已读">
          <el-table :data="readStats.readList" size="small" border max-height="320">
            <el-table-column prop="nickName" label="用户" />
            <el-table-column prop="phone" label="手机" />
          </el-table>
        </el-tab-pane>
        <el-tab-pane label="未读">
          <el-table :data="readStats.unreadList" size="small" border max-height="320">
            <el-table-column prop="nickName" label="用户" />
            <el-table-column prop="phone" label="手机" />
            <el-table-column label="操作" width="100" align="center">
              <template #default="{ row }">
                <el-button link type="primary" size="small" @click="forceRead(row)">标为已读</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>
      </el-tabs>
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { listContentNotice, publishNotice, updateContentNotice, offlineNotice, noticeReadStats, forceNoticeRead } from '@/api/propertyContent'
import { useAutoQuery } from '@/composables/useAutoQuery'

const route = useRoute()
const noticeTab = computed(() => route.meta.noticeType || 'announce')
const list = ref([])
const total = ref(0)
const query = reactive({ pageNum: 1, pageSize: 10, title: '', status: '', publishTimeRange: null })
const dlg = ref(false)
const statsDrawer = ref(false)
const formRef = ref(null)
const readStats = ref({ readRate: 0, readCount: 0, totalOwners: 0, readList: [], unreadList: [] })
const curNoticeId = ref(null)
const form = reactive({
  noticeId: null, noticeType: 'announce', title: '', content: '', attachment: '',
  pinned: 0, scope: '', restoreTime: null, offlineTime: null, status: '1', createTime: '', originalCreateTime: null
})

const statusMap = { '0': '下架', '1': '已发布', '2': '待发布' }
const statusTagMap = { '0': 'info', '1': 'success', '2': 'warning' }

function statusLabel(status) { return statusMap[status] || status }
function statusTagType(status) { return statusTagMap[status] || 'info' }

function nowStr() {
  const d = new Date()
  const p = n => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())} ${p(d.getHours())}:${p(d.getMinutes())}:${p(d.getSeconds())}`
}

function parseTime(str) {
  if (!str) return null
  return new Date(str.replace(/-/g, '/')).getTime()
}

const isScheduledPublish = computed(() => {
  if (!form.createTime) return false
  return parseTime(form.createTime) > Date.now()
})

function validatePublishTime(rule, value, callback) {
  if (!value) return callback(new Error('请选择发布时间'))
  const t = parseTime(value)
  const now = Date.now()
  if (!form.noticeId) {
    if (t < now - 1000) return callback(new Error('发布时间不能早于当前时间'))
  } else if (form.originalCreateTime && value < form.originalCreateTime) {
    return callback(new Error('发布时间不能早于原发布时间'))
  }
  callback()
}

function validateRestoreTime(rule, value, callback) {
  if (noticeTab.value !== 'outage') return callback()
  if (!value) return callback(new Error('请选择预计恢复时间'))
  const now = nowStr()
  const pub = form.createTime || now
  if (value < now) return callback(new Error('预计恢复时间不能早于当前时间'))
  if (value < pub) return callback(new Error('预计恢复时间不能早于发布时间'))
  callback()
}

function validateOfflineTime(rule, value, callback) {
  if (!value) return callback()
  const now = nowStr()
  const pub = form.createTime || now
  if (value < now) return callback(new Error('下架时间不能早于当前时间'))
  if (value < pub) return callback(new Error('下架时间不能早于发布时间'))
  if (noticeTab.value === 'outage' && form.restoreTime && value < form.restoreTime) {
    return callback(new Error('下架时间不能早于预计恢复时间'))
  }
  callback()
}

const rules = {
  title: [{ required: true, message: '请输入标题', trigger: 'blur' }],
  content: [{ required: true, message: '请输入正文', trigger: 'blur' }],
  createTime: [{ validator: validatePublishTime, trigger: 'change' }],
  restoreTime: [{ validator: validateRestoreTime, trigger: 'change' }],
  offlineTime: [{ validator: validateOfflineTime, trigger: 'change' }]
}

function disabledPublishDate(date) {
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  const d = new Date(date)
  d.setHours(0, 0, 0, 0)
  if (!form.noticeId && d.getTime() < today.getTime()) return true
  if (form.originalCreateTime) {
    const min = new Date(form.originalCreateTime.replace(/-/g, '/'))
    min.setHours(0, 0, 0, 0)
    if (d.getTime() < min.getTime()) return true
  }
  return false
}

function disabledRestoreDate(date) {
  const now = new Date()
  now.setHours(0, 0, 0, 0)
  let min = now.getTime()
  if (form.createTime) {
    const pub = new Date(form.createTime.replace(/-/g, '/'))
    pub.setHours(0, 0, 0, 0)
    min = Math.max(min, pub.getTime())
  }
  const d = new Date(date)
  d.setHours(0, 0, 0, 0)
  return d.getTime() < min
}

function disabledOfflineDate(date) {
  const now = new Date()
  now.setHours(0, 0, 0, 0)
  let min = now.getTime()
  if (form.createTime) {
    const pub = new Date(form.createTime.replace(/-/g, '/'))
    pub.setHours(0, 0, 0, 0)
    min = Math.max(min, pub.getTime())
  }
  if (noticeTab.value === 'outage' && form.restoreTime) {
    const restore = new Date(form.restoreTime.replace(/-/g, '/'))
    restore.setHours(0, 0, 0, 0)
    min = Math.max(min, restore.getTime())
  }
  const d = new Date(date)
  d.setHours(0, 0, 0, 0)
  return d.getTime() < min
}

function onPublishTimeChange() {
  if (noticeTab.value === 'outage' && form.restoreTime) {
    formRef.value?.validateField('restoreTime')
  }
  if (form.offlineTime) {
    formRef.value?.validateField('offlineTime')
  }
}

function onRestoreTimeChange() {
  if (form.offlineTime) {
    formRef.value?.validateField('offlineTime')
  }
}

function onDialogOpened() {
  if (!form.noticeId) {
    form.createTime = nowStr()
  }
  formRef.value?.clearValidate()
}

async function fetchList() {
  const params = {
    pageNum: query.pageNum,
    pageSize: query.pageSize,
    noticeType: noticeTab.value
  }
  if (query.title?.trim()) params.title = query.title.trim()
  if (query.status) params.status = query.status
  if (query.publishTimeRange?.length === 2) {
    params.publishTimeStart = query.publishTimeRange[0]
    params.publishTimeEnd = query.publishTimeRange[1]
  }
  const res = await listContentNotice(params)
  list.value = res.data.rows
  total.value = res.data.total
}

const { loading, load, reset: resetAuto } = useAutoQuery(fetchList,
  () => [noticeTab.value, query.title, query.status, query.publishTimeRange],
  { beforeLoad: () => { query.pageNum = 1 } }
)

async function loadList() {
  await load()
}

function resetQuery() {
  resetAuto(() => {
    query.title = ''
    query.status = ''
    query.publishTimeRange = null
    query.pageNum = 1
  })
}

function openPublish() {
  Object.assign(form, {
    noticeId: null, noticeType: noticeTab.value, title: '', content: '', attachment: '',
    pinned: 0, scope: '', restoreTime: null, offlineTime: null, status: '1', createTime: nowStr(), originalCreateTime: null
  })
  dlg.value = true
}

function openEdit(row) {
  if (row.status === '0') {
    ElMessage.warning('已下架的公告不支持编辑')
    return
  }
  Object.assign(form, {
    ...row,
    restoreTime: row.restoreTime || null,
    offlineTime: row.offlineTime || null,
    createTime: row.createTime || nowStr(),
    originalCreateTime: row.createTime || null
  })
  dlg.value = true
}

async function save() {
  if (!form.noticeId) {
    const t = parseTime(form.createTime)
    if (!t || t < Date.now() - 1000) {
      form.createTime = nowStr()
    }
  }
  await formRef.value.validate()
  form.noticeType = noticeTab.value
  const payload = { ...form }
  delete payload.originalCreateTime
  if (form.noticeId) await updateContentNotice(payload)
  else await publishNotice(payload)
  ElMessage.success(isScheduledPublish.value && !form.noticeId ? '已保存，将定时发布' : '保存成功')
  dlg.value = false
  loadList()
}

async function offline(row) {
  await ElMessageBox.confirm('确认下架？业主端将不再显示', '提示', { type: 'warning' })
  await offlineNotice(row.noticeId)
  ElMessage.success('已下架')
  loadList()
}

async function showReadStats(row) {
  curNoticeId.value = row.noticeId
  readStats.value = (await noticeReadStats(row.noticeId)).data
  statsDrawer.value = true
}

async function forceRead(row) {
  await forceNoticeRead(curNoticeId.value, row.userId)
  ElMessage.success('已标记')
  readStats.value = (await noticeReadStats(curNoticeId.value)).data
}
</script>

<style scoped>
.stats-summary {
  margin-bottom: 12px;
  color: #606266;
}
.form-tip {
  margin-top: 4px;
  font-size: 12px;
  color: #e6a23c;
  line-height: 1.4;
}
</style>
