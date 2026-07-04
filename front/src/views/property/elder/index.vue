<template>
  <div class="app-container elder-archive property-table-page">
    <div class="filter-panel">
      <el-form inline class="search-form">
        <el-form-item label="姓名">
          <el-input v-model="q.name" clearable placeholder="姓名模糊查询" style="width:140px" />
        </el-form-item>
        <el-form-item label="性别">
          <el-select v-model="q.gender" clearable placeholder="全部" style="width:90px">
            <el-option label="男" value="0" />
            <el-option label="女" value="1" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button icon="Refresh" @click="resetQuery">重置</el-button>
          <el-button icon="Refresh" @click="loadList" :loading="elderLoading">刷新</el-button>
        </el-form-item>
      </el-form>
    </div>

    <el-card shadow="never" class="table-card">
      <el-table :data="elderList" v-loading="elderLoading" border stripe class="data-table">
        <el-table-column type="index" label="序号" width="60" align="center" />
        <el-table-column prop="name" label="姓名" width="100">
          <template #default="{ row }">
            <el-button link type="primary" @click="openDetail(row.residentId)">{{ row.name }}</el-button>
          </template>
        </el-table-column>
        <el-table-column prop="age" label="年龄" width="70" align="center" />
        <el-table-column prop="gender" label="性别" width="70" align="center">
          <template #default="{ row }">{{ row.gender === '0' ? '男' : '女' }}</template>
        </el-table-column>
        <el-table-column prop="phone" label="联系电话" width="130" />
        <el-table-column prop="emergencyContact" label="紧急联系人" width="130" show-overflow-tooltip />
        <el-table-column prop="address" label="住址" min-width="160" show-overflow-tooltip />
        <el-table-column label="关怀标签" min-width="140">
          <template #default="{ row }">
            <el-tag
              v-for="t in row.careTags || []"
              :key="t"
              size="small"
              :type="careTagType(t)"
              effect="plain"
              round
              style="margin:2px"
            >{{ t }}</el-tag>
            <span v-if="!(row.careTags || []).length" class="empty-cell">—</span>
          </template>
        </el-table-column>
      </el-table>
      <Pagination
        v-show="elderTotal > 0"
        :total="elderTotal"
        v-model:page="elderQuery.pageNum"
        v-model:limit="elderQuery.pageSize"
        @pagination="loadList"
      />
    </el-card>

    <ResidentDetailDrawer v-model="detailVisible" :resident-id="detailResidentId" />
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { getAloneElders } from '@/api/elderAi'
import ResidentDetailDrawer from '@/components/ResidentDetailDrawer/index.vue'
import { useAutoQuery } from '@/composables/useAutoQuery'
import '@/styles/property-table-page.css'

const elderList = ref([])
const elderTotal = ref(0)
const elderQuery = reactive({ pageNum: 1, pageSize: 10 })
const q = reactive({ name: '', gender: '' })
const detailVisible = ref(false)
const detailResidentId = ref(null)

function careTagType(name) {
  if (name === '独居老人') return 'danger'
  if (name === '高龄老人') return 'success'
  if (name === '重点关注') return 'warning'
  return 'primary'
}

function openDetail(residentId) {
  detailResidentId.value = residentId
  detailVisible.value = true
}

async function fetchList() {
  const res = await getAloneElders({ ...elderQuery, ...q })
  elderList.value = res.data?.rows || []
  elderTotal.value = res.data?.total || 0
}

const { loading: elderLoading, load: loadList, reset: resetAuto } = useAutoQuery(fetchList,
  () => [q.name, q.gender],
  { beforeLoad: () => { elderQuery.pageNum = 1 } }
)

function resetQuery() {
  resetAuto(() => {
    q.name = ''
    q.gender = ''
    elderQuery.pageNum = 1
  })
}
</script>

<style scoped lang="scss">
.elder-archive {
  padding: 16px;
}
</style>
