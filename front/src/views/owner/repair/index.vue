<template>
  <div class="app-container">
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="showAdd = true">提交报修</el-button>
      </el-col>
    </el-row>

    <el-card shadow="never" class="table-card">
      <el-table :data="list" v-loading="loading" border stripe>
        <el-table-column type="index" label="序号" width="60" align="center" />
        <el-table-column prop="orderNo" label="工单号" width="180" />
        <el-table-column prop="description" label="描述" min-width="160" show-overflow-tooltip />
        <el-table-column prop="status" label="状态" width="100" align="center">
          <template #default="{ row }">{{ statusMap[row.status] || row.status }}</template>
        </el-table-column>
        <el-table-column prop="urgency" label="紧急程度" width="90" align="center" />
        <el-table-column prop="createTime" label="创建时间" width="170" align="center" />
        <el-table-column label="操作" width="160" align="center" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.status === 'pending'" link type="danger" @click="handleCancel(row)">撤销</el-button>
            <el-button v-if="!['completed','cancelled'].includes(row.status)" link type="primary" @click="handleUrge(row)">催单</el-button>
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

    <el-dialog v-model="showAdd" title="提交报修" width="520px" append-to-body @closed="stopVoice">
      <el-form :model="form" label-width="80px">
        <el-form-item label="故障描述">
          <div class="desc-field">
            <el-input v-model="form.description" type="textarea" :rows="4" placeholder="请描述故障情况，或点击麦克风语音输入" />
            <el-button
              class="voice-btn"
              :type="listening ? 'danger' : 'default'"
              circle
              :title="listening ? '停止录音' : '语音输入'"
              @click="toggleVoice"
            >
              <el-icon><Microphone /></el-icon>
            </el-button>
          </div>
          <div v-if="listening" class="voice-tip">正在聆听，请说话…</div>
        </el-form-item>
        <el-form-item label="紧急程度">
          <el-select v-model="form.urgency" style="width:100%">
            <el-option label="普通" value="normal" />
            <el-option label="较急" value="urgent" />
            <el-option label="紧急" value="emergency" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showAdd = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">提交</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, toRef } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { listOwnerRepair, submitRepair, cancelRepair, urgeRepair } from '@/api/repair'
import { useSpeechInput } from '@/composables/useSpeechInput'

const statusMap = { pending: '待分配', processing: '处理中', wait_accept: '待验收', completed: '已完成', cancelled: '已取消' }
const loading = ref(false)
const list = ref([])
const total = ref(0)
const showAdd = ref(false)
const query = reactive({ pageNum: 1, pageSize: 10 })
const form = reactive({ description: '', urgency: 'normal' })

const { listening, toggleVoice, stopVoice, initSpeech } = useSpeechInput(toRef(form, 'description'), {
  successMessage: '语音已填入描述框，请核对后提交'
})

onMounted(() => {
  load()
  initSpeech()
})

async function load() {
  loading.value = true
  try {
    const res = await listOwnerRepair(query)
    list.value = res.data.rows
    total.value = res.data.total
  } finally { loading.value = false }
}

async function handleSubmit() {
  if (!form.description?.trim()) {
    ElMessage.warning('请填写故障描述')
    return
  }
  await submitRepair(form)
  ElMessage.success('提交成功')
  showAdd.value = false
  form.description = ''
  query.pageNum = 1
  load()
}

async function handleCancel(row) {
  await ElMessageBox.confirm('确认撤销该报修？', '提示', { type: 'warning' })
  await cancelRepair(row.orderId)
  ElMessage.success('已撤销')
  load()
}

async function handleUrge(row) {
  await urgeRepair(row.orderId)
  ElMessage.success('催单成功')
  load()
}
</script>

<style scoped>
.desc-field {
  display: flex;
  gap: 8px;
  width: 100%;
  align-items: flex-start;
}
.desc-field .el-textarea {
  flex: 1;
}
.voice-btn {
  flex-shrink: 0;
  margin-top: 4px;
}
.voice-tip {
  margin-top: 6px;
  font-size: 12px;
  color: #e6a23c;
}
</style>
