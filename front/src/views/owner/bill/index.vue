<template>
  <el-card>
    <el-form inline class="mb-16">
      <el-form-item label="房屋ID"><el-input v-model="houseId" placeholder="如 1" style="width:120px" /></el-form-item>
      <el-button type="primary" @click="load">查询</el-button>
    </el-form>
    <el-table :data="list" v-loading="loading">
      <el-table-column prop="period" label="账期" />
      <el-table-column prop="amount" label="应缴" />
      <el-table-column prop="paidAmount" label="已缴" />
      <el-table-column prop="lateFee" label="滞纳金" />
      <el-table-column prop="status" label="状态">
        <template #default="{ row }">{{ row.status === '1' ? '已缴' : '未缴' }}</template>
      </el-table-column>
      <el-table-column prop="dueDate" label="截止日" />
    </el-table>
  </el-card>
</template>

<script setup>
import { ref } from 'vue'
import request from '@/utils/request'

const houseId = ref('1')
const loading = ref(false)
const list = ref([])

async function load() {
  if (!houseId.value) return
  loading.value = true
  try {
    const res = await request({ url: '/owner/bill/list', params: { houseId: houseId.value, pageNum: 1, pageSize: 20 } })
    list.value = res.data.rows
  } finally { loading.value = false }
}
</script>

<style scoped>.mb-16{margin-bottom:16px}</style>
