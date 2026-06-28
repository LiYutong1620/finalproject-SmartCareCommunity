<template>
  <div class="app-container">
    <div class="page-toolbar">
      <el-form inline class="search-form">
        <el-form-item label="楼栋">
          <el-select v-model="q.buildingId" clearable placeholder="全部楼栋" style="width:120px">
            <el-option v-for="b in buildingOptions" :key="b.buildingId" :label="b.buildingNo" :value="b.buildingId" />
          </el-select>
        </el-form-item>
        <el-form-item label="标签">
          <el-select v-model="q.tagId" clearable placeholder="全部标签" style="width:120px">
            <el-option v-for="t in tags" :key="t.tagId" :label="t.tagName" :value="t.tagId" />
          </el-select>
        </el-form-item>
        <el-form-item label="姓名">
          <el-input v-model="q.name" clearable placeholder="姓名" style="width:120px" />
        </el-form-item>
        <el-form-item label="性别">
          <el-select v-model="q.gender" clearable placeholder="全部" style="width:90px">
            <el-option label="男" value="0" />
            <el-option label="女" value="1" />
          </el-select>
        </el-form-item>
        <el-form-item label="年龄">
          <el-input-number v-model="q.ageMin" :min="1" :max="120" controls-position="right" placeholder="最小" style="width:100px" />
          <span class="age-sep">-</span>
          <el-input-number v-model="q.ageMax" :min="1" :max="120" controls-position="right" placeholder="最大" style="width:100px" />
        </el-form-item>
        <el-form-item>
          <el-button icon="Refresh" @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
      <div class="toolbar-actions">
        <el-button type="success" @click="openResident()">创建档案</el-button>
        <el-button @click="openTagMgr">标签管理</el-button>
      </div>
    </div>

    <el-card shadow="never">
      <el-table :data="residents" v-loading="loading" border stripe>
        <el-table-column prop="buildingNo" label="楼栋" width="70" />
        <el-table-column prop="houseNo" label="房号" width="70" />
        <el-table-column prop="name" label="姓名" width="90" />
        <el-table-column label="性别" width="60" align="center">
          <template #default="{ row }">{{ genderLabel(row.gender) }}</template>
        </el-table-column>
        <el-table-column prop="age" label="年龄" width="60" align="center" />
        <el-table-column prop="phone" label="电话" width="120" />
        <el-table-column prop="emergencyContact" label="紧急联系人" min-width="120" show-overflow-tooltip />
        <el-table-column prop="remark" label="备注" min-width="140" show-overflow-tooltip />
        <el-table-column label="标签" show-overflow-tooltip>
          <template #default="{ row }">{{ tagNames(row.tagIds) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="140">
          <template #default="{ row }">
            <el-button link type="primary" @click="openResident(row)">编辑</el-button>
            <el-button link type="danger" @click="delResident(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <Pagination
        v-show="resTotal > 0"
        :total="resTotal"
        v-model:page="resQuery.pageNum"
        v-model:limit="resQuery.pageSize"
        @pagination="loadList"
      />
    </el-card>

    <el-dialog v-model="residentDlg" :title="residentForm.residentId ? '编辑住户' : '创建住户'" width="520px" append-to-body>
      <el-form ref="residentRef" :model="residentForm" :rules="residentRules" label-width="100px">
        <el-form-item label="姓名" prop="name">
          <el-input v-model="residentForm.name" maxlength="20" placeholder="2-20个字符" />
        </el-form-item>
        <el-form-item label="性别">
          <el-select v-model="residentForm.gender" clearable placeholder="选填" style="width:100%">
            <el-option label="男" value="0" />
            <el-option label="女" value="1" />
          </el-select>
        </el-form-item>
        <el-form-item label="年龄" prop="age">
          <el-input-number v-model="residentForm.age" :min="1" :max="120" controls-position="right" placeholder="选填" style="width:100%" />
        </el-form-item>
        <el-form-item label="电话" prop="phone">
          <el-input v-model="residentForm.phone" maxlength="11" placeholder="11位手机号" />
        </el-form-item>
        <el-form-item label="房屋" prop="houseId">
          <el-select v-model="residentForm.houseId" filterable style="width:100%" placeholder="请选择未绑定档案的房屋">
            <el-option v-for="h in availableHouseOptions" :key="h.houseId" :label="`${h.buildingNo}-${h.houseNo}`" :value="h.houseId" />
          </el-select>
        </el-form-item>
        <el-form-item label="入住日期">
          <el-date-picker v-model="residentForm.moveInDate" type="date" value-format="YYYY-MM-DD" style="width:100%" />
        </el-form-item>
        <el-form-item label="紧急联系人">
          <el-input v-model="residentForm.emergencyContact" placeholder="选填" maxlength="64" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="residentForm.remark" type="textarea" :rows="2" placeholder="选填，如沟通偏好、特殊需求等" maxlength="512" show-word-limit />
        </el-form-item>
        <el-form-item label="标签">
          <el-select v-model="residentForm.tagIds" multiple style="width:100%" placeholder="选填">
            <el-option v-for="t in tags" :key="t.tagId" :label="t.tagName" :value="t.tagId" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer><el-button type="primary" @click="saveResident">保存</el-button></template>
    </el-dialog>

    <el-dialog v-model="tagDlg" title="标签管理" width="480px" append-to-body>
      <el-table :data="tags" border stripe size="small" max-height="240">
        <el-table-column prop="tagName" label="标签名称" />
        <el-table-column label="分类" width="100">
          <template #default="{ row }">{{ tagTypeLabel(row.tagType) }}</template>
        </el-table-column>
        <el-table-column label="操作" width="80" align="center">
          <template #default="{ row }">
            <el-button link type="danger" @click="delTag(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-divider content-position="left">新增标签</el-divider>
      <el-form :model="tagForm" label-width="80px">
        <el-form-item label="名称">
          <el-input v-model="tagForm.tagName" placeholder="如：独居老人" maxlength="32" />
        </el-form-item>
        <el-form-item label="分类">
          <el-select v-model="tagForm.tagType" style="width:100%">
            <el-option label="老人关怀" value="elder" />
            <el-option label="特殊关怀" value="disabled" />
            <el-option label="普通标签" value="custom" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="tagDlg = false">关闭</el-button>
        <el-button type="primary" @click="saveTag">新增</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  listBuildingAll, listHouse, listTag, addTag, deleteTag,
  listResident, addResident, updateResident, deleteResident, listOccupiedHouses
} from '@/api/property'
import { useAutoQuery } from '@/composables/useAutoQuery'

const buildingOptions = ref([])
const houseOptions = ref([])
const tags = ref([])
const residents = ref([])
const resTotal = ref(0)
const resQuery = reactive({ pageNum: 1, pageSize: 10 })
const q = reactive({ buildingId: null, tagId: null, name: '', gender: '', ageMin: null, ageMax: null })

const residentDlg = ref(false)
const residentRef = ref()
const residentForm = reactive({
  residentId: null, name: '', gender: '', age: null, phone: '', houseId: null,
  moveInDate: '', emergencyContact: '', remark: '', tagIds: []
})
const occupiedHouseIds = ref(new Set())

const availableHouseOptions = computed(() => {
  const currentId = residentForm.houseId
  return houseOptions.value.filter(h => h.houseId === currentId || !occupiedHouseIds.value.has(h.houseId))
})
const residentRules = {
  name: [
    { required: true, message: '请输入姓名', trigger: 'blur' },
    { min: 2, max: 20, message: '姓名长度应为2-20个字符', trigger: 'blur' },
    { pattern: /^[\u4e00-\u9fa5·]{2,20}$/, message: '姓名应为中文', trigger: 'blur' }
  ],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1\d{10}$/, message: '手机号格式不正确', trigger: 'blur' }
  ],
  houseId: [{ required: true, message: '请选择房屋', trigger: 'change' }],
  age: [{ type: 'number', min: 1, max: 120, message: '年龄应在1-120之间', trigger: 'blur' }]
}

const tagDlg = ref(false)
const tagForm = reactive({ tagName: '', tagType: 'custom' })

const TAG_TYPE_MAP = { elder: '老人关怀', disabled: '特殊关怀', custom: '普通标签' }

function genderLabel(gender) {
  if (gender === '0') return '男'
  if (gender === '1') return '女'
  return '-'
}

function tagTypeLabel(type) {
  return TAG_TYPE_MAP[type] || '普通标签'
}

function tagNames(ids) {
  if (!ids?.length) return ''
  return ids.map(id => tags.value.find(t => t.tagId === id)?.tagName).filter(Boolean).join('、')
}

async function loadBuildingOptions() {
  buildingOptions.value = (await listBuildingAll()).data
}

async function loadHouseOptions() {
  const list = []
  for (const b of buildingOptions.value) {
    const res = await listHouse({ buildingId: b.buildingId, pageNum: 1, pageSize: 100 })
    res.data.rows.forEach(h => list.push({ ...h, buildingNo: b.buildingNo }))
  }
  houseOptions.value = list
}

async function loadTags() {
  tags.value = (await listTag()).data
}

async function fetchList() {
  const res = await listResident({ ...resQuery, ...q })
  residents.value = res.data.rows
  resTotal.value = res.data.total
}

const { loading, load: loadList, reset: resetAuto } = useAutoQuery(fetchList,
  () => [q.buildingId, q.tagId, q.name, q.gender, q.ageMin, q.ageMax],
  { beforeLoad: () => { resQuery.pageNum = 1 } }
)

async function loadOccupiedHouses(excludeResidentId) {
  const res = await listOccupiedHouses(excludeResidentId)
  occupiedHouseIds.value = new Set(res.data || [])
}

function resetQuery() {
  resetAuto(() => {
    q.buildingId = null
    q.tagId = null
    q.name = ''
    q.gender = ''
    q.ageMin = null
    q.ageMax = null
    resQuery.pageNum = 1
  })
}

async function openResident(row) {
  if (row) {
    await loadOccupiedHouses(row.residentId)
    Object.assign(residentForm, {
      residentId: row.residentId,
      name: row.name,
      gender: row.gender || '',
      age: row.age ?? null,
      phone: row.phone,
      houseId: row.houseId,
      moveInDate: row.moveInDate || '',
      emergencyContact: row.emergencyContact || '',
      remark: row.remark || '',
      tagIds: row.tagIds || []
    })
  } else {
    await loadOccupiedHouses(null)
    Object.assign(residentForm, {
      residentId: null, name: '', gender: '', age: null, phone: '',
      houseId: availableHouseOptions.value[0]?.houseId || null,
      moveInDate: '', emergencyContact: '', remark: '', tagIds: []
    })
  }
  residentDlg.value = true
}

async function saveResident() {
  const valid = await residentRef.value?.validate().catch(() => false)
  if (!valid) return
  if (residentForm.residentId) await updateResident(residentForm)
  else await addResident(residentForm)
  ElMessage.success('已保存')
  residentDlg.value = false
  loadList()
}

async function delResident(row) {
  await ElMessageBox.confirm('确认删除该住户档案？', '提示', { type: 'warning' })
  await deleteResident(row.residentId)
  ElMessage.success('已删除')
  loadList()
}

function openTagMgr() {
  tagForm.tagName = ''
  tagForm.tagType = 'custom'
  tagDlg.value = true
}

async function saveTag() {
  if (!tagForm.tagName?.trim()) {
    ElMessage.warning('请输入标签名称')
    return
  }
  await addTag({ tagName: tagForm.tagName.trim(), tagType: tagForm.tagType })
  ElMessage.success('标签已新增')
  tagForm.tagName = ''
  tagForm.tagType = 'custom'
  loadTags()
}

async function delTag(row) {
  await ElMessageBox.confirm(`确认删除标签「${row.tagName}」？`, '提示', { type: 'warning' })
  await deleteTag(row.tagId)
  ElMessage.success('已删除')
  loadTags()
  loadList()
}

onMounted(async () => {
  await loadBuildingOptions()
  await loadHouseOptions()
  await loadTags()
})
</script>

<style scoped>
.page-toolbar {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 12px;
  margin-bottom: 16px;
}
.page-toolbar .search-form {
  margin-bottom: 0;
}
.page-toolbar .search-form :deep(.el-form-item) {
  margin-bottom: 0;
}
.toolbar-actions {
  display: flex;
  gap: 8px;
  flex-shrink: 0;
}
.age-sep {
  margin: 0 6px;
  color: var(--el-text-color-secondary);
}
</style>
