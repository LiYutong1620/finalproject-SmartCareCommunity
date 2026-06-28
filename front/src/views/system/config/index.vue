<template>
  <div class="app-container">
    <el-form :inline="true" class="search-form">
      <el-form-item label="参数名">
        <el-input v-model="searchName" placeholder="请输入参数名" clearable style="width:180px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-card shadow="never" class="table-card">
      <el-table :data="pageList" v-loading="loading" border stripe>
        <el-table-column type="index" label="序号" width="60" align="center" />
        <el-table-column prop="configName" label="参数名" min-width="140" />
        <el-table-column prop="configKey" label="键" min-width="140" />
        <el-table-column prop="configValue" label="值" min-width="120" />
        <el-table-column prop="remark" label="说明" min-width="160" show-overflow-tooltip />
        <el-table-column label="操作" width="80" align="center" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="openEdit(row)">编辑</el-button>
          </template>
        </el-table-column>
      </el-table>
      <Pagination
        v-show="total > 0"
        :total="total"
        v-model:page="pageNum"
        v-model:limit="limit"
        @pagination="onPagination"
      />
    </el-card>

    <el-dialog v-model="visible" title="修改参数" width="420px" append-to-body>
      <el-input v-model="editRow.configValue" />
      <template #footer>
        <el-button @click="visible = false">取消</el-button>
        <el-button type="primary" @click="save">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { listConfig, updateConfig } from '@/api/system'
import { useClientPagination } from '@/utils/pagination'

const loading = ref(false)
const allList = ref([])
const searchName = ref('')
const visible = ref(false)
const editRow = ref({})
const { pageNum, limit, onPagination } = useClientPagination(10)

const filteredList = computed(() => {
  if (!searchName.value) return allList.value
  const kw = searchName.value.trim().toLowerCase()
  return allList.value.filter(item =>
    (item.configName || '').toLowerCase().includes(kw) ||
    (item.configKey || '').toLowerCase().includes(kw)
  )
})

const total = computed(() => filteredList.value.length)

const pageList = computed(() => {
  const start = (pageNum.value - 1) * limit.value
  return filteredList.value.slice(start, start + limit.value)
})

async function load() {
  loading.value = true
  try {
    const res = await listConfig()
    allList.value = res.data || []
  } finally { loading.value = false }
}

function handleQuery() {
  pageNum.value = 1
}

function resetQuery() {
  searchName.value = ''
  pageNum.value = 1
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
