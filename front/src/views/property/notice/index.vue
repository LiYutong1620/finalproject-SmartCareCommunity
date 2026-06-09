<template>
  <div>
    <el-tabs v-model="noticeTab">
      <el-tab-pane label="社区公告" name="announce" />
      <el-tab-pane label="停水停电" name="outage" />
    </el-tabs>
    <el-card class="mb-16">
      <el-button type="primary" @click="openPublish">发布{{ noticeTab === 'outage' ? '通知' : '公告' }}</el-button>
    </el-card>
    <el-table :data="list" v-loading="loading">
      <el-table-column prop="title" label="标题" />
      <el-table-column prop="pinned" label="置顶" width="60">
        <template #default="{ row }"><el-tag v-if="row.pinned" size="small">置顶</el-tag></template>
      </el-table-column>
      <el-table-column prop="status" label="状态" width="80">
        <template #default="{ row }">{{ row.status === '1' ? '上架' : '下架' }}</template>
      </el-table-column>
      <el-table-column prop="validStart" label="有效期起" width="110" />
      <el-table-column prop="validEnd" label="有效期止" width="110" />
      <el-table-column prop="createTime" label="发布时间" width="170" />
      <el-table-column label="操作" width="220">
        <template #default="{ row }">
          <el-button link @click="openEdit(row)">编辑</el-button>
          <el-button link @click="showReadStats(row)">阅读统计</el-button>
          <el-button v-if="row.status === '1'" link type="danger" @click="offline(row)">下架</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="dlg" :title="form.noticeId ? '编辑' : '发布'" width="600px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="标题"><el-input v-model="form.title" /></el-form-item>
        <el-form-item label="正文"><el-input v-model="form.content" type="textarea" rows="5" /></el-form-item>
        <el-form-item label="附件链接"><el-input v-model="form.attachment" /></el-form-item>
        <el-form-item label="置顶"><el-switch v-model="form.pinned" :active-value="1" :inactive-value="0" /></el-form-item>
        <el-form-item label="有效期起"><el-date-picker v-model="form.validStart" type="datetime" value-format="YYYY-MM-DD HH:mm:ss" style="width:100%" /></el-form-item>
        <el-form-item label="有效期止"><el-date-picker v-model="form.validEnd" type="datetime" value-format="YYYY-MM-DD HH:mm:ss" style="width:100%" /></el-form-item>
        <template v-if="noticeTab === 'outage'">
          <el-form-item label="影响范围"><el-input v-model="form.scope" /></el-form-item>
          <el-form-item label="恢复时间"><el-date-picker v-model="form.restoreTime" type="datetime" value-format="YYYY-MM-DD HH:mm:ss" style="width:100%" /></el-form-item>
        </template>
      </el-form>
      <template #footer><el-button type="primary" @click="save">保存</el-button></template>
    </el-dialog>

    <el-drawer v-model="statsDrawer" title="阅读统计" size="520px">
      <p>阅读率：{{ readStats.readRate }}%（{{ readStats.readCount }}/{{ readStats.totalOwners }}）</p>
      <el-tabs>
        <el-tab-pane label="已读">
          <el-table :data="readStats.readList" size="small" max-height="300">
            <el-table-column prop="nickName" label="用户" />
            <el-table-column prop="phone" label="手机" />
            <el-table-column label="操作" width="100">
              <template #default="{ row }">
                <el-button link disabled size="small">已读</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-tab-pane>
        <el-tab-pane label="未读">
          <el-table :data="readStats.unreadList" size="small" max-height="300">
            <el-table-column prop="nickName" label="用户" />
            <el-table-column prop="phone" label="手机" />
            <el-table-column label="操作" width="100">
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
import { ref, reactive, watch, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { listContentNotice, publishNotice, updateContentNotice, offlineNotice, noticeReadStats, forceNoticeRead } from '@/api/propertyContent'

const noticeTab = ref('announce')
const loading = ref(false)
const list = ref([])
const dlg = ref(false)
const statsDrawer = ref(false)
const readStats = ref({ readRate: 0, readCount: 0, totalOwners: 0, readList: [], unreadList: [] })
const curNoticeId = ref(null)
const form = reactive({
  noticeId: null, noticeType: 'announce', title: '', content: '', attachment: '',
  pinned: 0, validStart: '', validEnd: '', scope: '', restoreTime: '', status: '1'
})

async function load() {
  loading.value = true
  try {
    const res = await listContentNotice({ pageNum: 1, pageSize: 50, noticeType: noticeTab.value })
    list.value = res.data.rows
  } finally { loading.value = false }
}

watch(noticeTab, load)

function openPublish() {
  Object.assign(form, { noticeId: null, noticeType: noticeTab.value, title: '', content: '', attachment: '', pinned: 0, validStart: '', validEnd: '', scope: '', restoreTime: '', status: '1' })
  dlg.value = true
}
function openEdit(row) {
  Object.assign(form, row)
  dlg.value = true
}
async function save() {
  form.noticeType = noticeTab.value
  if (form.noticeId) await updateContentNotice(form)
  else await publishNotice(form)
  ElMessage.success('已保存')
  dlg.value = false
  load()
}
async function offline(row) {
  await ElMessageBox.confirm('确认下架？业主端将不再显示')
  await offlineNotice(row.noticeId)
  load()
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

onMounted(load)
</script>

<style scoped>.mb-16{margin-bottom:16px}</style>
