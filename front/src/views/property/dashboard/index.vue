<template>
  <div class="app-container">
    <el-row :gutter="20">
      <el-col :span="6" v-for="item in cards" :key="item.label">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-value">{{ item.value }}</div>
          <div class="stat-label">{{ item.label }}</div>
        </el-card>
      </el-col>
    </el-row>
    <el-card shadow="never" class="mt-20">
      <template #header>运营概览</template>
      <p>工单完成率、预警待处理等核心指标一览。</p>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { dashboardStats } from '@/api/property'

const stats = ref({})

const cards = computed(() => [
  { label: '工单总量', value: stats.value.totalOrders ?? '-' },
  { label: '已完成', value: stats.value.completedOrders ?? '-' },
  { label: '完成率(%)', value: stats.value.completionRate ?? '-' },
  { label: '待处理预警', value: stats.value.pendingAlerts ?? '-' }
])

onMounted(async () => {
  const res = await dashboardStats()
  stats.value = res.data
})
</script>

<style scoped>
.stat-card { text-align: center; }
.stat-value { font-size: 32px; font-weight: bold; color: #409eff; }
.stat-label { margin-top: 8px; color: #909399; }
.mt-20 { margin-top: 20px; }
</style>
