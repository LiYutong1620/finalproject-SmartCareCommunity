<template>
  <div>
    <el-card class="mb-16"><el-button type="primary" @click="showAdd = true">生成账单</el-button></el-card>
    <el-card>
      <el-table :data="list" v-loading="loading">
        <el-table-column prop="houseId" label="房屋ID" />
        <el-table-column prop="period" label="账期" />
        <el-table-column prop="amount" label="应缴" />
        <el-table-column prop="paidAmount" label="已缴" />
        <el-table-column prop="status" label="状态">
          <template #default="{ row }">{{ row.status === '1' ? '已缴' : '未缴' }}</template>
        </el-table-column>
      </el-table>
    </el-card>
    <el-dialog v-model="showAdd" title="生成账单" width="420px">
      <el-form :model="form" label-width="80px">
        <el-form-item label="房屋ID"><el-input v-model="form.houseId" /></el-form-item>
        <el-form-item label="费用项ID"><el-input v-model="form.itemId" /></el-form-item>
        <el-form-item label="账期"><el-input v-model="form.period" placeholder="2026-05" /></el-form-item>
        <el-form-item label="金额"><el-input v-model="form.amount" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showAdd = false">取消</el-button>
        <el-button type="primary" @click="handleAdd">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { listPropertyBill, createBill } from '@/api/property'

const loading = ref(false)
const list = ref([])
const showAdd = ref(false)
const form = reactive({ houseId: 1, itemId: 1, period: '2026-05', amount: 500 })

async function load() {
  loading.value = true
  try {
    const res = await listPropertyBill({ pageNum: 1, pageSize: 20 })
    list.value = res.data.rows
  } finally { loading.value = false }
}

async function handleAdd() {
  await createBill(form)
  ElMessage.success('账单已生成')
  showAdd.value = false
  load()
}

onMounted(load)
</script>

<style scoped>.mb-16{margin-bottom:16px}</style>
