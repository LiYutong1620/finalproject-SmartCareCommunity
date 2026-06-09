<template>
  <div>
    <el-row :gutter="16" class="mb-16">
      <el-col :span="16">
        <el-form inline>
          <el-form-item label="状态">
            <el-select v-model="q.status" clearable style="width:110px">
              <el-option label="待处理" value="pending" /><el-option label="处理中" value="processing" /><el-option label="已回复" value="replied" />
            </el-select>
          </el-form-item>
          <el-form-item label="分类">
            <el-select v-model="q.category" clearable style="width:100px">
              <el-option label="噪音" value="noise" /><el-option label="卫生" value="hygiene" /><el-option label="治安" value="security" /><el-option label="其他" value="other" />
            </el-select>
          </el-form-item>
          <el-button type="primary" @click="load">查询</el-button>
        </el-form>
      </el-col>
      <el-col :span="8">
        <el-card shadow="never" header="分类统计">
          <div v-for="s in stats.filter(x => x.dimension === 'category')" :key="s.name" class="stat-line">
            {{ catMap[s.name] || s.name }}：{{ s.count }}
          </div>
        </el-card>
      </el-col>
    </el-row>
    <el-table :data="list" v-loading="loading" @row-click="openDetail">
      <el-table-column prop="complaintNo" label="编号" width="170" />
      <el-table-column prop="title" label="标题" />
      <el-table-column prop="category" label="分类" width="80">
        <template #default="{ row }">{{ catMap[row.category] }}</template>
      </el-table-column>
      <el-table-column prop="status" label="状态" width="90">
        <template #default="{ row }">{{ statusMap[row.status] }}</template>
      </el-table-column>
      <el-table-column prop="handlerName" label="负责人" width="90" />
      <el-table-column prop="createTime" label="提交时间" width="170" />
      <el-table-column label="操作" width="140" @click.stop>
        <template #default="{ row }">
          <el-button v-if="row.status === 'pending'" link @click.stop="accept(row)">受理</el-button>
          <el-button v-if="row.status === 'processing'" link type="primary" @click.stop="openReply(row)">回复</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-drawer v-model="detailDrawer" title="投诉详情" size="520px">
      <p><b>编号：</b>{{ detail.complaintNo }}</p>
      <p><b>标题：</b>{{ detail.title }}</p>
      <p><b>内容：</b>{{ detail.content }}</p>
      <p v-if="detail.reply"><b>回复：</b>{{ detail.reply }}</p>
      <h4>处理记录</h4>
      <el-timeline>
        <el-timeline-item v-for="log in detail.logs" :key="log.logId" :timestamp="log.createTime">
          {{ log.handlerName }} - {{ actionMap[log.action] }}：{{ log.content }}
        </el-timeline-item>
      </el-timeline>
    </el-drawer>

    <el-dialog v-model="replyDlg" title="回复投诉" width="480px">
      <el-input v-model="replyText" type="textarea" rows="4" />
      <template #footer><el-button type="primary" @click="submitReply">提交并通知业主</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { listContentComplaint, getComplaintDetail, complaintStats, acceptComplaint, replyContentComplaint } from '@/api/propertyContent'

const loading = ref(false)
const list = ref([])
const stats = ref([])
const q = reactive({ status: '', category: '' })
const detailDrawer = ref(false)
const detail = ref({ logs: [] })
const replyDlg = ref(false)
const replyText = ref('')
const replyId = ref(null)
const catMap = { noise: '噪音', hygiene: '卫生', security: '治安', other: '其他' }
const statusMap = { pending: '待处理', processing: '处理中', replied: '已回复' }
const actionMap = { accept: '受理', reply: '回复', assign: '指派' }

async function load() {
  loading.value = true
  try {
    const [l, s] = await Promise.all([
      listContentComplaint({ pageNum: 1, pageSize: 50, ...q }),
      complaintStats({})
    ])
    list.value = l.data.rows
    stats.value = s.data
  } finally { loading.value = false }
}
async function openDetail(row) {
  detail.value = (await getComplaintDetail(row.complaintId)).data
  detailDrawer.value = true
}
async function accept(row) {
  await acceptComplaint({ complaintId: row.complaintId })
  ElMessage.success('已受理')
  load()
}
function openReply(row) {
  replyId.value = row.complaintId
  replyText.value = ''
  replyDlg.value = true
}
async function submitReply() {
  await replyContentComplaint({ complaintId: replyId.value, reply: replyText.value })
  ElMessage.success('已回复并通知业主')
  replyDlg.value = false
  load()
}
onMounted(load)
</script>

<style scoped>
.mb-16 { margin-bottom: 16px; }
.stat-line { font-size: 13px; line-height: 1.8; }
</style>
