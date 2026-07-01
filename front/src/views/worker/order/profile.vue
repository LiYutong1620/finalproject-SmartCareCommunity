<template>
  <el-card>
    <template #header>
      <div class="header-wrap">
        <span>个人状态</span>
        <el-button size="small" @click="$router.back()">返回</el-button>
      </div>
    </template>
    <el-descriptions :column="2" border v-if="profile">
      <el-descriptions-item label="姓名">{{ profile.name || '-' }}</el-descriptions-item>
      <el-descriptions-item label="工号">{{ profile.workerNo || '-' }}</el-descriptions-item>
      <el-descriptions-item label="联系方式">{{ profile.virtualPhone || '-' }}</el-descriptions-item>
      <el-descriptions-item label="当前状态">{{ statusLabel }}</el-descriptions-item>
      <el-descriptions-item label="证书名称">{{ profile.certName || '-' }}</el-descriptions-item>
      <el-descriptions-item label="证书有效期">{{ profile.certExpire || '-' }}</el-descriptions-item>
      <el-descriptions-item label="平均评分">{{ profile.avgScore ?? '-' }}</el-descriptions-item>
      <el-descriptions-item label="评价数">{{ profile.evalCount ?? 0 }}</el-descriptions-item>
    </el-descriptions>
    <el-divider />
    <el-form inline>
      <el-form-item label="忙闲状态">
        <el-select v-model="statusForm.workStatus" style="width: 180px">
          <el-option label="可接单" value="available" />
          <el-option label="忙线中" value="busy" />
          <el-option label="休息" value="rest" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" :loading="saving" @click="saveStatus">保存</el-button>
      </el-form-item>
    </el-form>
  </el-card>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import request from '@/utils/request'

const profile = ref(null)
const saving = ref(false)
const statusForm = reactive({ workStatus: 'available' })

const statusLabel = computed(() => {
  const map = { available: '可接单', busy: '忙线中', rest: '休息' }
  return map[statusForm.workStatus] || statusForm.workStatus
})

async function loadProfile() {
  const res = await request({ url: '/worker/repair/profile', method: 'get' })
  profile.value = res.data
  statusForm.workStatus = res.data?.workStatus || 'available'
}

async function saveStatus() {
  saving.value = true
  try {
    await request({ url: '/worker/repair/profile/status', method: 'put', data: { workStatus: statusForm.workStatus } })
    ElMessage.success('状态已保存')
  } finally {
    saving.value = false
  }
}

onMounted(loadProfile)
</script>

<style scoped>
.header-wrap {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
</style>
