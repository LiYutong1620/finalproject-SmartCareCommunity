<template>
  <div class="app-container property-table-page">
    <div class="filter-panel">
      <el-form :inline="true" class="search-form">
        <el-form-item label="楼栋号">
          <el-input v-model="buildingQuery.buildingNo" clearable placeholder="楼栋号" style="width:140px" />
        </el-form-item>
        <el-form-item label="总层数">
          <el-input-number v-model="buildingQuery.totalFloors" :min="1" :max="99" controls-position="right" placeholder="层数" style="width:120px" />
        </el-form-item>
        <el-form-item>
          <el-button icon="Refresh" @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
      <div class="filter-actions">
        <el-button type="success" @click="openBuilding()">新增楼栋</el-button>
      </div>
    </div>

    <el-card shadow="never" class="table-card">
      <el-table
        :data="buildings"
        v-loading="loading"
        stripe
        class="data-table clickable-table"
        @row-click="goHousePage"
      >
        <el-table-column type="index" label="序号" width="64" align="center" />
        <el-table-column prop="buildingNo" label="楼栋号" width="110" align="center">
          <template #default="{ row }">
            <el-link type="primary" :underline="false" class="cell-link" @click.stop="goHousePage(row)">
              {{ row.buildingNo }}
            </el-link>
          </template>
        </el-table-column>
        <el-table-column prop="totalFloors" label="总层数" width="96" align="center">
          <template #default="{ row }">
            <el-tag size="small" effect="plain" round>{{ row.totalFloors }} 层</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="unitsPerFloor" label="每层户数" width="104" align="center">
          <template #default="{ row }">{{ row.unitsPerFloor }} 户</template>
        </el-table-column>
        <el-table-column prop="houseCount" label="房屋数" width="88" align="center">
          <template #default="{ row }">{{ row.houseCount ?? '—' }}</template>
        </el-table-column>
        <el-table-column prop="residentCount" label="已建档" width="88" align="center">
          <template #default="{ row }">{{ row.residentCount ?? '—' }}</template>
        </el-table-column>
        <el-table-column prop="remark" label="备注" min-width="180" show-overflow-tooltip>
          <template #default="{ row }">{{ row.remark || '—' }}</template>
        </el-table-column>
        <el-table-column label="操作" width="140" align="center" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" class="btn-action" @click.stop="openBuilding(row)">编辑</el-button>
            <el-button link type="danger" class="btn-action" @click.stop="delBuilding(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <Pagination
        v-show="buildingTotal > 0"
        :total="buildingTotal"
        v-model:page="buildingQuery.pageNum"
        v-model:limit="buildingQuery.pageSize"
        @pagination="loadList"
      />
    </el-card>

    <el-dialog v-model="buildingDlg" :title="buildingForm.buildingId ? '编辑楼栋' : '新增楼栋'" width="480px" append-to-body>
      <el-form :model="buildingForm" label-width="90px">
        <el-form-item label="楼栋号"><el-input v-model="buildingForm.buildingNo" /></el-form-item>
        <el-form-item label="总层数"><el-input-number v-model="buildingForm.totalFloors" :min="1" /></el-form-item>
        <el-form-item label="每层户数"><el-input-number v-model="buildingForm.unitsPerFloor" :min="1" /></el-form-item>
        <el-form-item label="备注"><el-input v-model="buildingForm.remark" type="textarea" :rows="3" placeholder="选填" /></el-form-item>
      </el-form>
      <template #footer><el-button type="primary" @click="saveBuilding">保存</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { listBuilding, addBuilding, updateBuilding, deleteBuilding } from '@/api/property'
import { useAutoQuery } from '@/composables/useAutoQuery'
import '@/styles/property-table-page.css'

const router = useRouter()
const buildings = ref([])
const buildingTotal = ref(0)
const buildingQuery = reactive({ pageNum: 1, pageSize: 10, buildingNo: '', totalFloors: null })
const buildingDlg = ref(false)
const buildingForm = reactive({ buildingId: null, buildingNo: '', totalFloors: 18, unitsPerFloor: 4, remark: '' })

async function fetchList() {
  const res = await listBuilding(buildingQuery)
  buildings.value = res.data.rows
  buildingTotal.value = res.data.total
}

const { loading, load: loadList, reset: resetAuto } = useAutoQuery(fetchList,
  () => [buildingQuery.buildingNo, buildingQuery.totalFloors],
  { beforeLoad: () => { buildingQuery.pageNum = 1 } }
)

function resetQuery() {
  resetAuto(() => {
    buildingQuery.buildingNo = ''
    buildingQuery.totalFloors = null
    buildingQuery.pageNum = 1
  })
}

function goHousePage(row) {
  router.push({ path: '/property/house', query: { buildingId: row.buildingId } })
}

function openBuilding(row) {
  if (row) Object.assign(buildingForm, row)
  else Object.assign(buildingForm, { buildingId: null, buildingNo: '', totalFloors: 18, unitsPerFloor: 4, remark: '' })
  buildingDlg.value = true
}

async function saveBuilding() {
  if (buildingForm.buildingId) await updateBuilding(buildingForm)
  else await addBuilding(buildingForm)
  ElMessage.success('已保存')
  buildingDlg.value = false
  loadList()
}

async function delBuilding(row) {
  await ElMessageBox.confirm(`确认删除楼栋「${row.buildingNo}」？`, '提示', { type: 'warning' })
  await deleteBuilding(row.buildingId)
  ElMessage.success('已删除')
  loadList()
}
</script>
