<template>
  <div>
    <el-card class="mb-16">
      <el-button type="primary" @click="showAdd = true">新增住户</el-button>
    </el-card>
    <el-card>
      <el-table :data="list" v-loading="loading">
        <el-table-column prop="name" label="姓名" />
        <el-table-column prop="phone" label="电话" />
        <el-table-column prop="houseId" label="房屋ID" />
        <el-table-column prop="residentType" label="类型">
          <template #default="{ row }">{{ row.residentType === '0' ? '业主' : '租客' }}</template>
        </el-table-column>
        <el-table-column prop="moveInDate" label="入住日期" />
      </el-table>
    </el-card>
    <el-dialog v-model="showAdd" title="新增住户" width="480px">
      <el-form :model="form" label-width="90px">
        <el-form-item label="姓名"><el-input v-model="form.name" /></el-form-item>
        <el-form-item label="电话"><el-input v-model="form.phone" /></el-form-item>
        <el-form-item label="房屋ID"><el-input v-model="form.houseId" /></el-form-item>
        <el-form-item label="类型">
          <el-select v-model="form.residentType"><el-option label="业主" value="0" /><el-option label="租客" value="1" /></el-select>
        </el-form-item>
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
import { listResident, addResident } from '@/api/property'

const loading = ref(false)
const list = ref([])
const showAdd = ref(false)
const form = reactive({ name: '', phone: '', houseId: 1, residentType: '0' })

async function load() {
  loading.value = true
  try {
    const res = await listResident({ pageNum: 1, pageSize: 20 })
    list.value = res.data.rows
  } finally { loading.value = false }
}

async function handleAdd() {
  await addResident(form)
  ElMessage.success('添加成功')
  showAdd.value = false
  load()
}

onMounted(load)
</script>

<style scoped>.mb-16{margin-bottom:16px}</style>
