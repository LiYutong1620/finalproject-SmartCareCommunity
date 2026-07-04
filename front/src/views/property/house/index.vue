<template>
  <div class="app-container property-table-page">
    <div class="filter-panel">
      <el-form :inline="true" class="search-form">
        <el-form-item label="所属楼栋">
          <el-select v-model="houseQuery.buildingId" clearable placeholder="全部楼栋" style="width:140px">
            <el-option v-for="b in buildingOptions" :key="b.buildingId" :label="b.buildingNo" :value="b.buildingId" />
          </el-select>
        </el-form-item>
        <el-form-item label="房号">
          <el-input v-model="houseQuery.houseNo" clearable placeholder="房号" style="width:120px" />
        </el-form-item>
        <el-form-item label="户型">
          <el-input v-model="houseQuery.layout" clearable placeholder="如：两室" style="width:120px" />
        </el-form-item>
        <el-form-item>
          <el-button icon="Refresh" @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
      <div class="filter-actions">
        <el-button type="success" :disabled="!houseQuery.buildingId" @click="openHouse()">新增房屋</el-button>
      </div>
    </div>

    <el-card shadow="never" class="table-card">
      <el-table :data="houses" v-loading="loading" stripe class="data-table house-table">
        <el-table-column type="index" label="序号" width="64" align="center" />
        <el-table-column label="楼栋" width="96" align="center">
          <template #default="{ row }">
            <el-tag size="small" effect="plain" round>{{ row.buildingNo || buildingName(row.buildingId) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="houseNo" label="房号" width="88" align="center">
          <template #default="{ row }">
            <span class="cell-link">{{ row.houseNo }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="area" label="面积(㎡)" width="96" align="center" />
        <el-table-column prop="layout" label="户型" width="100" align="center" show-overflow-tooltip>
          <template #default="{ row }">{{ row.layout || '—' }}</template>
        </el-table-column>
        <el-table-column prop="residentName" label="在住住户" width="110" align="center">
          <template #default="{ row }">
            <el-button v-if="row.residentId" link type="primary" @click="openResidentDetail(row.residentId)">
              {{ row.residentName }}
            </el-button>
            <span v-else class="empty-cell">—</span>
          </template>
        </el-table-column>
        <el-table-column prop="remark" label="备注" min-width="140" show-overflow-tooltip>
          <template #default="{ row }">{{ row.remark || '—' }}</template>
        </el-table-column>
        <el-table-column label="操作" width="140" align="center" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" class="btn-action" @click="openHouse(row)">编辑</el-button>
            <el-button link type="danger" class="btn-action" @click="delHouse(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <Pagination
        v-show="houseTotal > 0"
        :total="houseTotal"
        v-model:page="houseQuery.pageNum"
        v-model:limit="houseQuery.pageSize"
        @pagination="loadList"
      />
    </el-card>

    <ResidentDetailDrawer v-model="detailVisible" :resident-id="detailResidentId" />

    <el-dialog v-model="houseDlg" :title="houseForm.houseId ? '编辑房屋' : '新增房屋'" width="480px" append-to-body>
      <el-form :model="houseForm" label-width="90px">
        <el-form-item label="所属楼栋">
          <el-select v-model="houseForm.buildingId" style="width:100%">
            <el-option v-for="b in buildingOptions" :key="b.buildingId" :label="b.buildingNo" :value="b.buildingId" />
          </el-select>
        </el-form-item>
        <el-form-item label="房号"><el-input v-model="houseForm.houseNo" /></el-form-item>
        <el-form-item label="面积"><el-input v-model="houseForm.area" /></el-form-item>
        <el-form-item label="户型"><el-input v-model="houseForm.layout" /></el-form-item>
        <el-form-item label="备注"><el-input v-model="houseForm.remark" type="textarea" :rows="3" placeholder="选填" /></el-form-item>
      </el-form>
      <template #footer><el-button type="primary" @click="saveHouse">保存</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { listBuildingAll, listHouse, addHouse, updateHouse, deleteHouse } from '@/api/property'
import ResidentDetailDrawer from '@/components/ResidentDetailDrawer/index.vue'
import { useAutoQuery } from '@/composables/useAutoQuery'
import '@/styles/property-table-page.css'

const route = useRoute()
const buildingOptions = ref([])
const houses = ref([])
const houseTotal = ref(0)
const detailVisible = ref(false)
const detailResidentId = ref(null)
const houseQuery = reactive({
  pageNum: 1,
  pageSize: 10,
  buildingId: route.query.buildingId ? Number(route.query.buildingId) : null,
  houseNo: '',
  layout: ''
})
const houseDlg = ref(false)
const houseForm = reactive({ houseId: null, buildingId: null, houseNo: '', area: 0, layout: '', ownerName: '', remark: '' })

function buildingName(id) {
  return buildingOptions.value.find(b => b.buildingId === id)?.buildingNo || '—'
}

function openResidentDetail(residentId) {
  detailResidentId.value = residentId
  detailVisible.value = true
}

async function loadBuildingOptions() {
  buildingOptions.value = (await listBuildingAll()).data
}

async function fetchList() {
  const res = await listHouse(houseQuery)
  houses.value = res.data.rows
  houseTotal.value = res.data.total
}

const { loading, load: loadList, reset: resetAuto } = useAutoQuery(fetchList,
  () => [houseQuery.buildingId, houseQuery.houseNo, houseQuery.layout],
  { beforeLoad: () => { houseQuery.pageNum = 1 } }
)

function resetQuery() {
  resetAuto(() => {
    houseQuery.buildingId = null
    houseQuery.houseNo = ''
    houseQuery.layout = ''
    houseQuery.pageNum = 1
  })
}

function openHouse(row) {
  if (row) Object.assign(houseForm, row)
  else Object.assign(houseForm, {
    houseId: null,
    buildingId: houseQuery.buildingId || buildingOptions.value[0]?.buildingId || null,
    houseNo: '', area: 89, layout: '', ownerName: '', remark: ''
  })
  houseDlg.value = true
}

async function saveHouse() {
  if (!houseForm.buildingId) {
    ElMessage.warning('请选择所属楼栋')
    return
  }
  const payload = { ...houseForm }
  delete payload.residentId
  delete payload.residentName
  delete payload.livingStatus
  delete payload.livingStatusLabel
  delete payload.buildingNo
  if (houseForm.houseId) await updateHouse(payload)
  else await addHouse(payload)
  ElMessage.success('已保存')
  houseDlg.value = false
  loadList()
}

async function delHouse(row) {
  await ElMessageBox.confirm(`确认删除房屋「${row.houseNo}」？`, '提示', { type: 'warning' })
  await deleteHouse(row.houseId)
  ElMessage.success('已删除')
  loadList()
}

onMounted(loadBuildingOptions)
</script>

<style scoped>
.house-table :deep(.el-table__body),
.house-table :deep(.el-table__header) {
  table-layout: fixed;
}
</style>
