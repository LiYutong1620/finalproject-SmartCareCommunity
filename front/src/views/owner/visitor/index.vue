<template>
  <div>
    <el-card class="mb-16"><el-button type="primary" @click="openAdd">访客预约登记</el-button></el-card>
    <el-table :data="list" v-loading="loading">
      <el-table-column prop="visitorName" label="访客" width="100" />
      <el-table-column prop="phone" label="手机" width="120" />
      <el-table-column prop="visitStart" label="来访开始" width="170" />
      <el-table-column prop="visitEnd" label="来访结束" width="170" />
      <el-table-column prop="plateNo" label="车牌" width="100" />
      <el-table-column label="通行码" width="120">
        <template #default="{ row }">
          <el-button link type="primary" @click="showQr(row)">查看二维码</el-button>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="100">
        <template #default="{ row }">
          <el-button link @click="openEdit(row)">修改</el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-dialog v-model="formVisible" :title="editId ? '修改预约' : '访客预约'" width="480px">
      <el-form :model="form" label-width="90px">
        <el-form-item label="访客姓名"><el-input v-model="form.visitorName" /></el-form-item>
        <el-form-item label="手机号"><el-input v-model="form.phone" /></el-form-item>
        <el-form-item label="来访开始"><el-date-picker v-model="form.visitStart" type="datetime" value-format="YYYY-MM-DD HH:mm:ss" style="width:100%" /></el-form-item>
        <el-form-item label="来访结束"><el-date-picker v-model="form.visitEnd" type="datetime" value-format="YYYY-MM-DD HH:mm:ss" style="width:100%" /></el-form-item>
        <el-form-item label="车牌号"><el-input v-model="form.plateNo" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="formVisible = false">取消</el-button>
        <el-button type="primary" @click="submit">保存</el-button>
      </template>
    </el-dialog>
    <el-dialog v-model="qrVisible" title="临时通行二维码" width="360px" align-center>
      <div class="qr-box">
        <img v-if="qrImg" :src="qrImg" alt="qrcode" style="width:200px;height:200px" />
        <p class="qr-text">{{ qrContent }}</p>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { listVisitor, addVisitor, updateVisitor } from '@/api/owner'

const loading = ref(false)
const list = ref([])
const formVisible = ref(false)
const qrVisible = ref(false)
const qrContent = ref('')
const qrImg = ref('')
const editId = ref(null)
const form = reactive({ visitorId: null, visitorName: '', phone: '', visitStart: '', visitEnd: '', plateNo: '' })

async function load() {
  loading.value = true
  try {
    const res = await listVisitor()
    list.value = res.data
  } finally { loading.value = false }
}

function resetForm() {
  Object.assign(form, { visitorId: null, visitorName: '', phone: '', visitStart: '', visitEnd: '', plateNo: '' })
}

function openAdd() {
  editId.value = null
  resetForm()
  formVisible.value = true
}

function openEdit(row) {
  editId.value = row.visitorId
  Object.assign(form, row)
  formVisible.value = true
}

async function submit() {
  if (editId.value) await updateVisitor(form)
  else await addVisitor(form)
  ElMessage.success('保存成功')
  formVisible.value = false
  load()
}

function showQr(row) {
  qrContent.value = row.qrcode
  qrImg.value = `https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${encodeURIComponent(row.qrcode)}`
  qrVisible.value = true
}

onMounted(load)
</script>

<style scoped>
.mb-16 { margin-bottom: 16px; }
.qr-box { text-align: center; }
.qr-text { font-size: 12px; color: #909399; word-break: break-all; margin-top: 8px; }
</style>
