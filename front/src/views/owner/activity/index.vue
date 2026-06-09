<template>
  <div>
    <el-tabs v-model="tab">
      <el-tab-pane label="活动列表" name="list">
        <el-table :data="activities" v-loading="loading">
          <el-table-column prop="title" label="活动" />
          <el-table-column prop="location" label="地点" width="120" />
          <el-table-column prop="startTime" label="开始时间" width="170" />
          <el-table-column label="名额" width="100">
            <template #default="{ row }">{{ row.remainCount >= 0 ? `剩${row.remainCount}` : '不限' }}</template>
          </el-table-column>
          <el-table-column label="操作" width="160">
            <template #default="{ row }">
              <el-button link type="primary" @click="openDetail(row)">详情</el-button>
              <el-button link type="success" @click="openReg(row)">报名</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>
      <el-tab-pane label="我的报名" name="mine">
        <el-table :data="regs">
          <el-table-column prop="voucherNo" label="凭证号" width="180" />
          <el-table-column prop="name" label="姓名" width="80" />
          <el-table-column prop="houseNo" label="房号" width="80" />
          <el-table-column prop="status" label="状态" width="100">
            <template #default="{ row }">{{ statusMap[row.status] || row.status }}</template>
          </el-table-column>
          <el-table-column prop="createTime" label="报名时间" width="170" />
          <el-table-column label="操作" width="100">
            <template #default="{ row }">
              <el-button v-if="row.status !== 'cancelled'" link type="danger" @click="handleCancel(row)">取消</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>
    </el-tabs>
    <el-dialog v-model="detailVisible" title="活动详情" width="520px">
      <p><b>地点：</b>{{ detail.location }}</p>
      <p><b>时间：</b>{{ detail.startTime }}</p>
      <p><b>截止：</b>{{ detail.deadline }}</p>
      <p>{{ detail.content }}</p>
    </el-dialog>
    <el-dialog v-model="regVisible" title="活动报名" width="440px">
      <el-form :model="regForm" label-width="80px">
        <el-form-item label="姓名"><el-input v-model="regForm.name" /></el-form-item>
        <el-form-item label="房号"><el-input v-model="regForm.houseNo" /></el-form-item>
        <el-form-item label="电话"><el-input v-model="regForm.phone" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="regVisible = false">取消</el-button>
        <el-button type="primary" @click="submitReg">提交并生成凭证</el-button>
      </template>
    </el-dialog>
    <el-dialog v-model="voucherVisible" title="报名凭证" width="400px">
      <el-result icon="success" title="报名成功">
        <template #sub-title>凭证号：{{ voucherNo }}</template>
      </el-result>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { listActivity, registerActivity, listMyActivityReg, cancelActivityReg } from '@/api/owner'

const tab = ref('list')
const loading = ref(false)
const activities = ref([])
const regs = ref([])
const detail = ref({})
const detailVisible = ref(false)
const regVisible = ref(false)
const voucherVisible = ref(false)
const voucherNo = ref('')
const currentActivityId = ref(null)
const regForm = reactive({ name: '', houseNo: '', phone: '' })
const statusMap = { pending: '待参与', joined: '已参与', cancelled: '已取消' }

async function load() {
  loading.value = true
  try {
    const [a, r] = await Promise.all([listActivity(), listMyActivityReg()])
    activities.value = a.data
    regs.value = r.data
  } finally { loading.value = false }
}

function openDetail(row) {
  detail.value = row
  detailVisible.value = true
}

function openReg(row) {
  currentActivityId.value = row.activityId
  regVisible.value = true
}

async function submitReg() {
  const res = await registerActivity({ ...regForm, activityId: currentActivityId.value })
  voucherNo.value = res.data.voucherNo
  regVisible.value = false
  voucherVisible.value = true
  ElMessage.success('报名成功')
  load()
}

async function handleCancel(row) {
  await ElMessageBox.confirm('确定取消报名？', '提示')
  await cancelActivityReg(row.regId)
  ElMessage.success('已取消')
  load()
}

onMounted(load)
</script>
