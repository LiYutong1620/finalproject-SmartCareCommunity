<template>
  <div>
    <el-card class="mb-16"><el-button type="primary" @click="openDlg()">发布活动</el-button></el-card>
    <el-table :data="list" v-loading="loading">
      <el-table-column prop="title" label="活动" />
      <el-table-column prop="location" label="地点" width="120" />
      <el-table-column prop="deadline" label="报名截止" width="170" />
      <el-table-column prop="maxCount" label="上限" width="70" />
      <el-table-column prop="status" label="状态" width="80">
        <template #default="{ row }">{{ row.status === '1' ? '上架' : '下架' }}</template>
      </el-table-column>
      <el-table-column label="操作" width="240">
        <template #default="{ row }">
          <el-button link @click="openDlg(row)">编辑</el-button>
          <el-button link @click="showRegs(row)">报名名单</el-button>
          <el-button link @click="doExport(row)">导出Excel</el-button>
          <el-button v-if="row.status === '1'" link type="danger" @click="offline(row)">下架</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="dlg" :title="form.activityId ? '编辑活动' : '发布活动'" width="560px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="标题"><el-input v-model="form.title" /></el-form-item>
        <el-form-item label="详情"><el-input v-model="form.content" type="textarea" rows="4" /></el-form-item>
        <el-form-item label="地点"><el-input v-model="form.location" /></el-form-item>
        <el-form-item label="开始时间"><el-date-picker v-model="form.startTime" type="datetime" value-format="YYYY-MM-DD HH:mm:ss" style="width:100%" /></el-form-item>
        <el-form-item label="报名截止"><el-date-picker v-model="form.deadline" type="datetime" value-format="YYYY-MM-DD HH:mm:ss" style="width:100%" /></el-form-item>
        <el-form-item label="人数上限"><el-input-number v-model="form.maxCount" :min="0" /></el-form-item>
      </el-form>
      <template #footer><el-button type="primary" @click="save">保存</el-button></template>
    </el-dialog>

    <el-drawer v-model="regDrawer" :title="'报名名单 - ' + curTitle" size="560px">
      <el-table :data="regs" size="small">
        <el-table-column prop="name" label="姓名" />
        <el-table-column prop="houseNo" label="房号" />
        <el-table-column prop="phone" label="手机" />
        <el-table-column prop="createTime" label="报名时间" width="170" />
      </el-table>
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { listContentActivity, publishActivity, updateContentActivity, offlineActivity, listActivityRegs, exportActivityRegs } from '@/api/propertyContent'

const loading = ref(false)
const list = ref([])
const dlg = ref(false)
const regDrawer = ref(false)
const regs = ref([])
const curTitle = ref('')
const form = reactive({ activityId: null, title: '', content: '', location: '', startTime: '', deadline: '', maxCount: 50, status: '1' })

async function load() {
  loading.value = true
  try { list.value = (await listContentActivity()).data } finally { loading.value = false }
}
function openDlg(row) {
  if (row) Object.assign(form, row)
  else Object.assign(form, { activityId: null, title: '', content: '', location: '', startTime: '', deadline: '', maxCount: 50, status: '1' })
  dlg.value = true
}
async function save() {
  if (form.activityId) await updateContentActivity(form)
  else await publishActivity(form)
  ElMessage.success('已保存')
  dlg.value = false
  load()
}
async function offline(row) {
  await ElMessageBox.confirm('确认下架？')
  await offlineActivity(row.activityId)
  load()
}
async function showRegs(row) {
  curTitle.value = row.title
  regs.value = (await listActivityRegs(row.activityId)).data
  regDrawer.value = true
}
async function doExport(row) {
  await exportActivityRegs(row.activityId)
  ElMessage.success('已导出 CSV（可用 Excel 打开）')
}
onMounted(load)
</script>

<style scoped>.mb-16{margin-bottom:16px}</style>
