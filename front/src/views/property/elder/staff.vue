<template>
  <div class="app-container">
    <el-form :inline="true" class="search-form">
      <el-form-item label="人员类型">
        <el-select v-model="query.staffType" clearable placeholder="全部" style="width: 140px" @change="load">
          <el-option v-for="t in staffTypes" :key="t.typeId" :label="t.typeName" :value="t.typeName" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button @click="openTypeMgr">人员类型管理</el-button>
        <el-button type="success" icon="Plus" @click="openAdd">新增关怀人员</el-button>
      </el-form-item>
    </el-form>

    <el-card shadow="never">
      <el-table :data="list" v-loading="loading" border stripe>
        <el-table-column type="index" label="序号" width="60" align="center" />
        <el-table-column prop="name" label="姓名" width="120" />
        <el-table-column prop="phone" label="联系电话" width="140" />
        <el-table-column prop="staffType" label="类型" width="100" align="center" />
        <el-table-column label="负责楼栋" min-width="160" show-overflow-tooltip>
          <template #default="{ row }">{{ formatBuildingText(row.buildingIds) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="150" align="center" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="openEdit(row)">编辑</el-button>
            <el-button link type="danger" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <Pagination
        v-show="total > 0"
        :total="total"
        v-model:page="query.pageNum"
        v-model:limit="query.pageSize"
        @pagination="load"
      />
    </el-card>

    <el-dialog v-model="dialogVisible" :title="isEdit ? '编辑关怀人员' : '新增关怀人员'" width="520px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="姓名" required>
          <el-input v-model="form.name" />
        </el-form-item>
        <el-form-item label="联系电话" required>
          <el-input v-model="form.phone" />
        </el-form-item>
        <el-form-item label="人员类型" required>
          <el-select v-model="form.staffType" style="width: 100%">
            <el-option v-for="t in staffTypes" :key="t.typeId" :label="t.typeName" :value="t.typeName" />
          </el-select>
        </el-form-item>
        <el-form-item label="负责楼栋">
          <el-select
            v-model="selectedBuildingIds"
            multiple
            collapse-tags
            collapse-tags-tooltip
            clearable
            placeholder="请选择负责楼栋"
            style="width: 100%"
          >
            <el-option
              v-for="b in buildingOptions"
              :key="b.buildingId"
              :label="b.buildingNo"
              :value="b.buildingId"
            />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSave">保存</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="typeDlg" title="人员类型管理" width="480px" append-to-body @open="loadTypeList">
      <div class="type-mgr-add">
        <el-input v-model="newTypeName" maxlength="20" placeholder="新类型名称" style="width:200px" />
        <el-button type="primary" :disabled="!newTypeName.trim()" @click="submitAddType">添加</el-button>
      </div>
      <el-table :data="staffTypes" border stripe size="small" v-loading="typeLoading">
        <el-table-column prop="typeName" label="类型名称" />
        <el-table-column label="操作" width="80" align="center">
          <template #default="{ row }">
            <el-button link type="danger" @click="removeType(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <p class="type-hint">删除类型前请先移除或调整该类型下的关怀人员。</p>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { listBuildingAll } from '@/api/property'
import {
  listCareStaff, addCareStaff, updateCareStaff, deleteCareStaff,
  listCareStaffTypes, addCareStaffType, deleteCareStaffType
} from '@/api/elder'

const loading = ref(false)
const list = ref([])
const total = ref(0)
const staffTypes = ref([])
const buildingOptions = ref([])
const selectedBuildingIds = ref([])
const query = reactive({ pageNum: 1, pageSize: 10, staffType: '' })
const dialogVisible = ref(false)
const isEdit = ref(false)
const form = reactive({ staffId: null, name: '', phone: '', staffType: '', buildingIds: '' })

const typeDlg = ref(false)
const typeLoading = ref(false)
const newTypeName = ref('')

const buildingNameMap = ref({})

function parseBuildingIds(value) {
  if (!value) return []
  return String(value)
    .split(',')
    .map(s => s.trim())
    .filter(Boolean)
    .map(Number)
    .filter(n => !Number.isNaN(n))
}

function formatBuildingText(buildingIds) {
  const ids = parseBuildingIds(buildingIds)
  if (!ids.length) return '—'
  const names = ids.map(id => buildingNameMap.value[id] || `楼栋${id}`)
  return names.join('、')
}

async function loadBuildingOptions() {
  const res = await listBuildingAll()
  buildingOptions.value = res.data || []
  const map = {}
  buildingOptions.value.forEach(b => {
    map[b.buildingId] = b.buildingNo
  })
  buildingNameMap.value = map
}

async function loadTypes() {
  const res = await listCareStaffTypes()
  staffTypes.value = res.data || []
  if (!form.staffType && staffTypes.value.length) {
    form.staffType = staffTypes.value[0].typeName
  }
}

async function loadTypeList() {
  typeLoading.value = true
  try {
    await loadTypes()
  } finally {
    typeLoading.value = false
  }
}

function openTypeMgr() {
  newTypeName.value = ''
  typeDlg.value = true
}

async function submitAddType() {
  const name = newTypeName.value.trim()
  if (!name) return
  await addCareStaffType({ typeName: name })
  ElMessage.success('已添加')
  newTypeName.value = ''
  await loadTypes()
}

async function removeType(row) {
  await ElMessageBox.confirm(`确认删除类型「${row.typeName}」？`, '提示', { type: 'warning' })
  await deleteCareStaffType(row.typeId)
  ElMessage.success('已删除')
  if (query.staffType === row.typeName) {
    query.staffType = ''
  }
  await loadTypes()
  load()
}

async function load() {
  loading.value = true
  try {
    const params = { pageNum: query.pageNum, pageSize: query.pageSize }
    if (query.staffType) params.staffType = query.staffType
    const res = await listCareStaff(params)
    list.value = res.data.rows || []
    total.value = res.data.total || 0
  } finally {
    loading.value = false
  }
}

function resetForm() {
  form.staffId = null
  form.name = ''
  form.phone = ''
  form.staffType = staffTypes.value[0]?.typeName || ''
  form.buildingIds = ''
  selectedBuildingIds.value = []
}

function openAdd() {
  if (!staffTypes.value.length) {
    ElMessage.warning('请先添加人员类型')
    openTypeMgr()
    return
  }
  isEdit.value = false
  resetForm()
  dialogVisible.value = true
}

function openEdit(row) {
  isEdit.value = true
  Object.assign(form, row)
  selectedBuildingIds.value = parseBuildingIds(row.buildingIds)
  dialogVisible.value = true
}

async function handleSave() {
  if (!form.name?.trim() || !form.phone?.trim()) {
    ElMessage.warning('请填写姓名和电话')
    return
  }
  if (!form.staffType) {
    ElMessage.warning('请选择人员类型')
    return
  }
  form.buildingIds = selectedBuildingIds.value.join(',')
  const payload = { ...form }
  if (isEdit.value) {
    await updateCareStaff(payload)
    ElMessage.success('更新成功')
  } else {
    await addCareStaff(payload)
    ElMessage.success('新增成功')
  }
  dialogVisible.value = false
  load()
}

async function handleDelete(row) {
  await ElMessageBox.confirm('确认删除该关怀人员？', '提示', { type: 'warning' })
  await deleteCareStaff(row.staffId)
  ElMessage.success('已删除')
  load()
}

onMounted(async () => {
  await Promise.all([loadTypes(), loadBuildingOptions()])
  load()
})
</script>

<style scoped>
.type-mgr-add {
  display: flex;
  gap: 8px;
  margin-bottom: 12px;
}
.type-hint {
  margin: 12px 0 0;
  font-size: 12px;
  color: var(--el-text-color-secondary);
}
</style>
