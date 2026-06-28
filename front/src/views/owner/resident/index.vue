<template>
  <div class="app-container">
    <el-card shadow="never" v-loading="loading">
      <el-descriptions title="个人住户档案" :column="2" border>
        <el-descriptions-item label="姓名">{{ profile.name }}</el-descriptions-item>
        <el-descriptions-item label="性别">{{ genderLabel(profile.gender) }}</el-descriptions-item>
        <el-descriptions-item label="年龄">{{ profile.age != null ? profile.age + ' 岁' : '-' }}</el-descriptions-item>
        <el-descriptions-item label="楼栋房号">{{ profile.buildingNo }} {{ profile.houseNo }}</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ profile.phone }}</el-descriptions-item>
        <el-descriptions-item label="紧急联系人">
          <el-input v-model="emergency" style="max-width:200px" />
          <el-button link type="primary" class="ml-8" @click="saveEmergency">保存</el-button>
        </el-descriptions-item>
      </el-descriptions>
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

function genderLabel(gender) {
  if (gender === '0') return '男'
  if (gender === '1') return '女'
  return '-'
}

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

<style scoped>.ml-8{margin-left:8px}</style>
