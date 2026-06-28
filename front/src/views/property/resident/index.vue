<template>
  <div class="app-container">
    <el-form inline class="search-form">
      <el-form-item label="楼栋">
        <el-select v-model="q.buildingId" clearable style="width:120px">
          <el-option v-for="b in buildingOptions" :key="b.buildingId" :label="b.buildingNo" :value="b.buildingId" />
        </el-select>
      </el-form-item>
      <el-form-item label="标签">
        <el-select v-model="q.tagId" clearable style="width:120px">
          <el-option v-for="t in tags" :key="t.tagId" :label="t.tagName" :value="t.tagId" />
        </el-select>
      </el-form-item>
      <el-form-item label="姓名">
        <el-input v-model="q.name" clearable style="width:120px" />
      </el-form-item>
      <el-form-item>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
      <el-button type="success" @click="openResident()">创建档案</el-button>
      <el-button @click="openTag()">自定义标签</el-button>
    </el-form>
    <el-table :data="residents" v-loading="loading" border stripe>
      <el-table-column prop="buildingNo" label="楼栋" width="70" />
      <el-table-column prop="houseNo" label="房号" width="70" />
      <el-table-column prop="name" label="姓名" width="90" />
      <el-table-column prop="phone" label="电话" width="120" />
      <el-table-column prop="residentType" label="类型" width="70">
        <template #default="{ row }">{{ row.residentType === '0' ? '业主' : '租客' }}</template>
      </el-table-column>
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

    <el-dialog v-model="residentDlg" :title="residentForm.residentId ? '编辑住户' : '创建住户'" width="520px" append-to-body>
      <el-form :model="residentForm" label-width="100px">
        <el-form-item label="姓名"><el-input v-model="residentForm.name" /></el-form-item>
        <el-form-item label="身份证"><el-input v-model="residentForm.idCard" /></el-form-item>
        <el-form-item label="电话"><el-input v-model="residentForm.phone" /></el-form-item>
        <el-form-item label="房屋">
          <el-select v-model="residentForm.houseId" filterable style="width:100%">
            <el-option v-for="h in houseOptions" :key="h.houseId" :label="`${h.buildingNo}-${h.houseNo}`" :value="h.houseId" />
          </el-select>
        </el-form-item>
        <el-form-item label="类型">
          <el-select v-model="residentForm.residentType"><el-option label="业主" value="0" /><el-option label="租客" value="1" /></el-select>
        </el-form-item>
        <el-form-item label="入住日期"><el-date-picker v-model="residentForm.moveInDate" type="date" value-format="YYYY-MM-DD" style="width:100%" /></el-form-item>
        <el-form-item label="紧急联系人"><el-input v-model="residentForm.emergencyContact" /></el-form-item>
        <el-form-item label="家庭成员"><el-input v-model="residentForm.familyMembers" type="textarea" rows="2" /></el-form-item>
        <el-form-item label="标签">
          <el-select v-model="residentForm.tagIds" multiple style="width:100%">
            <el-option v-for="t in tags" :key="t.tagId" :label="t.tagName" :value="t.tagId" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer><el-button type="primary" @click="saveResident">保存</el-button></template>
    </el-dialog>

    <el-dialog v-model="tagDlg" title="新增标签" width="360px" append-to-body>
      <el-form :model="tagForm" label-width="80px">
        <el-form-item label="名称"><el-input v-model="tagForm.tagName" /></el-form-item>
        <el-form-item label="类型">
          <el-select v-model="tagForm.tagType">
            <el-option label="老人" value="elder" /><el-option label="残疾" value="disabled" /><el-option label="自定义" value="custom" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer><el-button type="primary" @click="saveTag">保存</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  listBuildingAll, listHouse, listTag, addTag,
  listResident, addResident, updateResident, deleteResident
} from '@/api/property'
import { useAutoQuery } from '@/composables/useAutoQuery'

const buildingOptions = ref([])
const houseOptions = ref([])
const tags = ref([])
const residents = ref([])
const resTotal = ref(0)
const resQuery = reactive({ pageNum: 1, pageSize: 10 })
const q = reactive({ buildingId: null, tagId: null, name: '' })

const residentDlg = ref(false)
const residentForm = reactive({ residentId: null, name: '', idCard: '', phone: '', houseId: null, residentType: '0', moveInDate: '', emergencyContact: '', familyMembers: '', tagIds: [] })
const tagDlg = ref(false)
const tagForm = reactive({ tagName: '', tagType: 'custom' })

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
  () => [q.buildingId, q.tagId, q.name],
  { beforeLoad: () => { resQuery.pageNum = 1 } }
)

function resetQuery() {
  resetAuto(() => {
    q.buildingId = null
    q.tagId = null
    q.name = ''
    resQuery.pageNum = 1
  })
}

function openResident(row) {
  if (row) Object.assign(residentForm, { ...row, tagIds: row.tagIds || [] })
  else Object.assign(residentForm, { residentId: null, name: '', idCard: '', phone: '', houseId: houseOptions.value[0]?.houseId || null, residentType: '0', moveInDate: '', emergencyContact: '', familyMembers: '', tagIds: [] })
  residentDlg.value = true
}

async function saveResident() {
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

function openTag() {
  tagForm.tagName = ''
  tagDlg.value = true
}

async function saveTag() {
  await addTag(tagForm)
  tagDlg.value = false
  loadTags()
}

onMounted(async () => {
  await loadBuildingOptions()
  await loadHouseOptions()
  await loadTags()
})
</script>
