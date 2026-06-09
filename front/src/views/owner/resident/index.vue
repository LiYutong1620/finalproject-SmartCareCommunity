<template>
  <div>
    <el-card v-loading="loading">
      <el-descriptions title="个人住户档案" :column="2" border>
        <el-descriptions-item label="姓名">{{ profile.name }}</el-descriptions-item>
        <el-descriptions-item label="楼栋房号">{{ profile.buildingNo }} {{ profile.houseNo }}</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ profile.phone }}</el-descriptions-item>
        <el-descriptions-item label="紧急联系人">
          <el-input v-model="emergency" style="max-width:200px" />
          <el-button link type="primary" class="ml-8" @click="saveEmergency">保存</el-button>
        </el-descriptions-item>
      </el-descriptions>
      <h4 class="mt-16">家庭成员（亲情绑定）</h4>
      <el-table :data="profile.familyList || []">
        <el-table-column prop="familyPhone" label="亲属手机" />
        <el-table-column label="共享工单"><template #default="{ row }">{{ row.shareOrder ? '是' : '否' }}</template></el-table-column>
        <el-table-column label="预警授权"><template #default="{ row }">{{ row.shareAlert ? '是' : '否' }}</template></el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getResidentMe, updateEmergency } from '@/api/owner'

const loading = ref(false)
const profile = ref({})
const emergency = ref('')

async function load() {
  loading.value = true
  try {
    profile.value = (await getResidentMe()).data
    emergency.value = profile.value.emergencyContact || ''
  } finally { loading.value = false }
}

async function saveEmergency() {
  await updateEmergency(emergency.value)
  ElMessage.success('已保存')
  load()
}

onMounted(load)
</script>

<style scoped>.mt-16{margin-top:16px}.ml-8{margin-left:8px}</style>
