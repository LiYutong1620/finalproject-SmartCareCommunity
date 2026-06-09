<template>
  <div>
    <el-card class="mb-16">
      <el-button type="primary" @click="showAdd = true">绑定亲情账号</el-button>
      <el-button @click="loadAlerts">查看授权预警</el-button>
    </el-card>
    <el-table :data="list" v-loading="loading">
      <el-table-column prop="familyPhone" label="亲属手机" />
      <el-table-column label="共享工单" width="100">
        <template #default="{ row }">{{ row.shareOrder ? '是' : '否' }}</template>
      </el-table-column>
      <el-table-column label="共享预警" width="120">
        <template #default="{ row }">
          <el-switch v-model="row.shareAlert" :active-value="1" :inactive-value="0" @change="onAlertChange(row)" />
        </template>
      </el-table-column>
      <el-table-column prop="createTime" label="绑定时间" width="170" />
      <el-table-column label="操作" width="100">
        <template #default="{ row }">
          <el-button link type="danger" @click="handleRemove(row)">解绑</el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-dialog v-model="showAdd" title="绑定亲情账号" width="420px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="亲属手机"><el-input v-model="form.familyPhone" /></el-form-item>
        <el-form-item label="共享工单"><el-switch v-model="form.shareOrder" :active-value="1" :inactive-value="0" /></el-form-item>
        <el-form-item label="共享预警"><el-switch v-model="form.shareAlert" :active-value="1" :inactive-value="0" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showAdd = false">取消</el-button>
        <el-button type="primary" @click="submit">绑定</el-button>
      </template>
    </el-dialog>
    <el-drawer v-model="alertDrawer" title="居家异常预警（授权）" size="480px">
      <el-table :data="alerts">
        <el-table-column prop="alertType" label="类型" width="100" />
        <el-table-column prop="content" label="内容" />
        <el-table-column prop="status" label="状态" width="90" />
        <el-table-column prop="createTime" label="时间" width="170" />
      </el-table>
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { listFamily, addFamily, updateFamilyAlert, removeFamily, listSharedAlerts } from '@/api/owner'

const loading = ref(false)
const list = ref([])
const showAdd = ref(false)
const alertDrawer = ref(false)
const alerts = ref([])
const form = reactive({ familyPhone: '', shareOrder: 1, shareAlert: 0 })

async function load() {
  loading.value = true
  try {
    const res = await listFamily()
    list.value = res.data
  } finally { loading.value = false }
}

async function submit() {
  await addFamily(form)
  ElMessage.success('绑定成功')
  showAdd.value = false
  load()
}

async function onAlertChange(row) {
  await updateFamilyAlert(row.bindId, row.shareAlert)
  ElMessage.success('已更新预警授权')
}

async function handleRemove(row) {
  await ElMessageBox.confirm('确定解绑？', '提示')
  await removeFamily(row.bindId)
  ElMessage.success('已解绑')
  load()
}

async function loadAlerts() {
  const res = await listSharedAlerts()
  alerts.value = res.data
  alertDrawer.value = true
}

onMounted(load)
</script>

<style scoped>.mb-16{margin-bottom:16px}</style>
