<template>
  <div class="app-container">
    <div class="page-toolbar">
      <el-form :inline="true" class="search-form">
        <el-form-item label="楼栋号">
          <el-input v-model="buildingQuery.buildingNo" clearable placeholder="楼栋号" style="width:140px" />
        </el-form-item>
        <el-form-item>
          <el-button icon="Refresh" @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
      <el-button type="success" @click="openBuilding()">新增楼栋</el-button>
    </div>

    <el-card shadow="never">
      <el-table
        :data="buildings"
        v-loading="loading"
        border
        stripe
        class="clickable-table"
        @row-click="goHousePage"
      >
        <el-table-column type="index" label="序号" width="60" align="center" />
        <el-table-column prop="buildingNo" label="楼栋号" width="100">
          <template #default="{ row }">
            <el-link type="primary" :underline="false" @click.stop="goHousePage(row)">{{ row.buildingNo }}</el-link>
          </template>
        </el-table-column>
        <el-table-column prop="totalFloors" label="总层数" width="90" align="center" />
        <el-table-column prop="unitsPerFloor" label="每层户数" width="100" align="center" />
        <el-table-column prop="remark" label="备注" min-width="160" show-overflow-tooltip />
        <el-table-column label="操作" width="140" align="center" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click.stop="openBuilding(row)">编辑</el-button>
            <el-button link type="danger" @click.stop="delBuilding(row)">删除</el-button>
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

const router = useRouter()
const buildings = ref([])
const buildingTotal = ref(0)
const buildingQuery = reactive({ pageNum: 1, pageSize: 10, buildingNo: '' })
const buildingDlg = ref(false)
const buildingForm = reactive({ buildingId: null, buildingNo: '', totalFloors: 18, unitsPerFloor: 4, remark: '' })

async function fetchList() {
  const res = await listBuilding(buildingQuery)
  buildings.value = res.data.rows
  buildingTotal.value = res.data.total
}

const { loading, load: loadList, reset: resetAuto } = useAutoQuery(fetchList,
  () => [buildingQuery.buildingNo],
  { beforeLoad: () => { buildingQuery.pageNum = 1 } }
)

function resetQuery() {
  resetAuto(() => {
    buildingQuery.buildingNo = ''
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
.clickable-table :deep(.el-table__row) { cursor: pointer; }
</style>
