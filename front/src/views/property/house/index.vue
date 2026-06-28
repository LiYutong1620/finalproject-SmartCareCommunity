<template>
  <div class="app-container">
    <div class="page-toolbar">
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
      <el-button type="success" :disabled="!houseQuery.buildingId" @click="openHouse()">新增房屋</el-button>
    </div>

    <el-card shadow="never">
      <el-table :data="houses" v-loading="loading" border stripe>
        <el-table-column type="index" label="序号" width="60" align="center" />
        <el-table-column label="楼栋" width="90" align="center">
          <template #default="{ row }">{{ buildingName(row.buildingId) }}</template>
        </el-table-column>
        <el-table-column prop="houseNo" label="房号" width="90" align="center" />
        <el-table-column prop="area" label="面积(㎡)" width="100" align="center" />
        <el-table-column prop="layout" label="户型" min-width="110" show-overflow-tooltip />
        <el-table-column prop="ownerName" label="业主" width="90" />
        <el-table-column prop="remark" label="备注" min-width="160" show-overflow-tooltip />
        <el-table-column label="操作" width="140" align="center" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="openHouse(row)">编辑</el-button>
            <el-button link type="danger" @click="delHouse(row)">删除</el-button>
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
        <el-form-item label="业主"><el-input v-model="houseForm.ownerName" /></el-form-item>
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
import { useAutoQuery } from '@/composables/useAutoQuery'

const route = useRoute()
const buildingOptions = ref([])
const houses = ref([])
const houseTotal = ref(0)
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
  return buildingOptions.value.find(b => b.buildingId === id)?.buildingNo || '-'
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
  if (houseForm.houseId) await updateHouse(houseForm)
  else await addHouse(houseForm)
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

onMounted(async () => {
  await loadBuildingOptions()
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
</style>
