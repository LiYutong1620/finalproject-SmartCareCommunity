<template>
  <el-card>
    <el-table :data="list" v-loading="loading">
      <el-table-column prop="configName" label="参数名" />
      <el-table-column prop="configKey" label="键" />
      <el-table-column prop="configValue" label="值" />
      <el-table-column prop="remark" label="说明" />
      <el-table-column label="操作" width="80">
        <template #default="{ row }">
          <el-button link type="primary" @click="openEdit(row)">编辑</el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-dialog v-model="visible" title="修改参数" width="420px">
      <el-input v-model="editRow.configValue" />
      <template #footer>
        <el-button @click="visible = false">取消</el-button>
        <el-button type="primary" @click="save">保存</el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { listConfig, updateConfig } from '@/api/system'

const loading = ref(false)
const list = ref([])
const visible = ref(false)
const editRow = ref({})

async function load() {
  loading.value = true
  try {
    const res = await listConfig()
    list.value = res.data
  } finally { loading.value = false }
}

function openEdit(row) {
  editRow.value = { ...row }
  visible.value = true
}

async function save() {
  await updateConfig(editRow.value)
  ElMessage.success('保存成功')
  visible.value = false
  load()
}

onMounted(load)
</script>
