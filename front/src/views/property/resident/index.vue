<template>
  <div class="app-container property-table-page">
    <div class="filter-panel">
      <el-form inline class="search-form">
        <el-form-item label="楼栋">
          <el-select v-model="q.buildingId" clearable placeholder="全部楼栋" style="width:120px">
            <el-option v-for="b in buildingOptions" :key="b.buildingId" :label="b.buildingNo" :value="b.buildingId" />
          </el-select>
        </el-form-item>
        <el-form-item label="标签">
          <el-select v-model="q.tagId" clearable placeholder="全部标签" style="width:130px">
            <el-option v-for="t in filterTagOptions" :key="t.tagId" :label="t.tagName" :value="t.tagId" />
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
      <div class="filter-actions">
        <el-button type="success" @click="openResident()">创建档案</el-button>
        <el-button @click="openTagMgr">标签管理</el-button>
      </div>
    </div>

    <el-card shadow="never" class="table-card">
      <el-table :data="residents" v-loading="loading" stripe class="data-table">
        <el-table-column type="index" label="序号" width="64" align="center" />
        <el-table-column prop="buildingNo" label="楼栋" width="80" align="center">
          <template #default="{ row }">
            <el-tag v-if="row.buildingNo" size="small" effect="plain" round>{{ row.buildingNo }}</el-tag>
            <span v-else class="empty-cell">—</span>
          </template>
        </el-table-column>
        <el-table-column prop="houseNo" label="房号" width="80" align="center">
          <template #default="{ row }">
            <span class="cell-link">{{ row.houseNo || '—' }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="name" label="姓名" width="96" align="center">
          <template #default="{ row }">
            <el-button link type="primary" @click="openDetail(row)">{{ row.name }}</el-button>
          </template>
        </el-table-column>
        <el-table-column label="性别" width="72" align="center">
          <template #default="{ row }">{{ genderLabel(row.gender) }}</template>
        </el-table-column>
        <el-table-column prop="age" label="年龄" width="72" align="center">
          <template #default="{ row }">{{ row.age ?? '—' }}</template>
        </el-table-column>
        <el-table-column prop="phone" label="电话" width="128" align="center" />
        <el-table-column label="标签" min-width="180">
          <template #default="{ row }">
            <div v-if="displayTags(row).length" class="tag-list">
              <el-tag
                v-for="t in displayTags(row)"
                :key="t"
                size="small"
                :type="careTagType(t)"
                effect="plain"
                round
              >{{ t }}</el-tag>
            </div>
            <span v-else class="empty-cell">—</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="140" align="center" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" class="btn-action" @click="openResident(row)">编辑</el-button>
            <el-button link type="danger" class="btn-action" @click="delResident(row)">删除</el-button>
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

    <ResidentDetailDrawer
      v-model="detailDrawer"
      :resident-id="detailResidentId"
      show-edit
      @edit="openResident"
    />

    <el-dialog v-model="residentDlg" :title="residentForm.residentId ? '编辑住户档案' : '创建住户档案'" width="580px" append-to-body>
      <el-form ref="residentRef" :model="residentForm" :rules="residentRules" label-width="110px">
        <el-form-item label="姓名" prop="name">
          <el-input v-model="residentForm.name" maxlength="20" placeholder="2-20个字符，与业主管理姓名一致" />
        </el-form-item>
        <el-form-item label="联系电话" prop="phone">
          <el-input v-model="residentForm.phone" maxlength="11" placeholder="11位手机号，与业主账号一致" />
          <p class="field-hint">保存后按手机号自动关联业主管理中的账号</p>
        </el-form-item>
        <el-form-item label="性别" prop="gender">
          <el-select v-model="residentForm.gender" placeholder="请选择" style="width:100%">
            <el-option label="男" value="0" />
            <el-option label="女" value="1" />
          </el-select>
        </el-form-item>
        <el-form-item label="年龄" prop="age">
          <el-input-number v-model="residentForm.age" :min="1" :max="120" controls-position="right" style="width:100%" />
        </el-form-item>
        <el-form-item label="房屋" prop="houseId">
          <el-select v-model="residentForm.houseId" filterable style="width:100%" placeholder="一屋一条档案">
            <el-option
              v-for="h in availableHouses"
              :key="h.houseId"
              :label="`${h.buildingNo}-${h.houseNo}`"
              :value="h.houseId"
              :disabled="occupiedHouseIds.includes(h.houseId)"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="居住状态">
          <el-select v-model="residentForm.livingStatus" style="width:100%">
            <el-option label="在住" value="1" />
            <el-option label="空置" value="2" />
            <el-option label="出租" value="3" />
          </el-select>
        </el-form-item>
        <el-form-item label="是否产权人">
          <el-radio-group v-model="residentForm.isOwner">
            <el-radio :value="1">是（本人）</el-radio>
            <el-radio :value="0">否</el-radio>
          </el-radio-group>
        </el-form-item>
        <template v-if="residentForm.isOwner === 0">
          <el-form-item label="产权人姓名" prop="ownerName">
            <el-input v-model="residentForm.ownerName" maxlength="20" />
          </el-form-item>
          <el-form-item label="产权人电话" prop="ownerPhone">
            <el-input v-model="residentForm.ownerPhone" maxlength="11" />
          </el-form-item>
          <el-form-item label="与产权人关系">
            <el-select v-model="residentForm.ownerRelation" style="width:100%">
              <el-option v-for="r in OWNER_RELATIONS" :key="r" :label="r" :value="r" />
            </el-select>
          </el-form-item>
        </template>
        <el-form-item label="入住日期">
          <el-date-picker v-model="residentForm.moveInDate" type="date" value-format="YYYY-MM-DD" style="width:100%" />
        </el-form-item>
        <el-divider content-position="left">紧急联系人（选填）</el-divider>
        <el-form-item label="联系人姓名">
          <el-input v-model="residentForm.emergencyName" maxlength="20" />
        </el-form-item>
        <el-form-item label="联系人电话">
          <el-input v-model="residentForm.emergencyPhone" maxlength="11" />
        </el-form-item>
        <el-form-item label="与住户关系">
          <el-select v-model="residentForm.emergencyRelation" clearable style="width:100%">
            <el-option v-for="r in EMERGENCY_RELATIONS" :key="r" :label="r" :value="r" />
          </el-select>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="residentForm.remark" type="textarea" :rows="2" maxlength="512" show-word-limit />
        </el-form-item>
        <el-form-item label="系统标签">
          <div class="care-tag-block">
            <div v-if="previewAutoTags.length" class="tag-list">
              <el-tag
                v-for="t in previewAutoTags"
                :key="t"
                size="small"
                :type="careTagType(t)"
                effect="plain"
                round
              >{{ t }}</el-tag>
            </div>
            <span v-else class="empty-cell">根据年龄与居住状态自动判定</span>
            <p class="care-tag-hint">独居老人：在住且年龄≥60岁；高龄老人：在住且年龄≥80岁</p>
          </div>
        </el-form-item>
        <el-form-item label="重点关注">
          <el-checkbox v-model="focusChecked" :disabled="!canApplyFocus">
            纳入重点关注（残障人士等特殊情况，不纳入老人关怀）
          </el-checkbox>
          <p v-if="!canApplyFocus" class="field-hint">独居或高龄老人已自动纳入老人关怀，无需设置重点关注</p>
        </el-form-item>
        <el-form-item v-if="extraManualTagOptions.length" label="其他标签">
          <el-select v-model="extraManualTagIds" multiple placeholder="可选自定义标签" style="width:100%">
            <el-option
              v-for="t in extraManualTagOptions"
              :key="t.tagId"
              :label="t.tagName"
              :value="t.tagId"
            />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer><el-button type="primary" @click="saveResident">保存</el-button></template>
    </el-dialog>

    <el-dialog v-model="tagDlg" title="标签管理" width="520px" append-to-body @open="loadTagList">
      <div class="tag-mgr-add">
        <el-input v-model="newTagName" maxlength="20" placeholder="新标签名称" style="width:200px" />
        <el-button type="primary" :disabled="!newTagName.trim()" @click="submitAddTag">添加</el-button>
      </div>
      <el-table :data="allTags" border stripe size="small" v-loading="tagLoading">
        <el-table-column prop="tagName" label="标签名称" />
        <el-table-column label="类型" width="90" align="center">
          <template #default="{ row }">
            <el-tag size="small" :type="row.tagType === 'auto' ? 'info' : 'primary'" effect="plain">
              {{ row.tagType === 'auto' ? '系统' : '自定义' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="80" align="center">
          <template #default="{ row }">
            <el-button
              v-if="row.tagType !== 'auto'"
              link
              type="danger"
              @click="removeTag(row)"
            >删除</el-button>
            <span v-else class="empty-cell">—</span>
          </template>
        </el-table-column>
      </el-table>
      <p class="care-tag-hint">系统标签由规则自动计算；「重点关注」适用于非独居、非高龄住户；自定义标签可在档案中勾选。</p>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  listBuildingAll, listHouse, listOccupiedHouses,
  listResident, addResident, updateResident, deleteResident,
  listTag, addTag, deleteTag
} from '@/api/property'
import ResidentDetailDrawer from '@/components/ResidentDetailDrawer/index.vue'
import { useAutoQuery } from '@/composables/useAutoQuery'
import '@/styles/property-table-page.css'

const FOCUS_TAG_ID = 3

const route = useRoute()
const OWNER_RELATIONS = ['配偶', '子女', '父母', '兄弟姐妹', '亲属', '租客', '其他']
const EMERGENCY_RELATIONS = ['配偶', '子女', '父母', '兄弟姐妹', '亲属', '邻居', '朋友', '其他']

const buildingOptions = ref([])
const houseOptions = ref([])
const occupiedHouseIds = ref([])
const residents = ref([])
const detailDrawer = ref(false)
const detailResidentId = ref(null)
const resTotal = ref(0)
const resQuery = reactive({ pageNum: 1, pageSize: 10 })
const q = reactive({ buildingId: null, tagId: null, name: '', gender: '', ageMin: null, ageMax: null })

const allTags = ref([])
const tagLoading = ref(false)
const newTagName = ref('')
const filterTagOptions = computed(() => allTags.value)

const residentDlg = ref(false)
const residentRef = ref()
const residentForm = reactive({
  residentId: null, name: '', gender: '', age: null, phone: '', houseId: null,
  livingStatus: '1', isOwner: 1, ownerName: '', ownerPhone: '', ownerRelation: '',
  moveInDate: '', emergencyName: '', emergencyPhone: '', emergencyRelation: '', remark: ''
})
const focusChecked = ref(false)
const extraManualTagIds = ref([])

const residentRules = {
  name: [
    { required: true, message: '请输入姓名', trigger: 'blur' },
    { min: 2, max: 20, message: '姓名长度应为2-20个字符', trigger: 'blur' }
  ],
  gender: [{ required: true, message: '请选择性别', trigger: 'change' }],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1\d{10}$/, message: '手机号格式不正确', trigger: 'blur' }
  ],
  houseId: [{ required: true, message: '请选择房屋', trigger: 'change' }],
  age: [{ required: true, type: 'number', min: 1, max: 120, message: '请填写年龄', trigger: 'blur' }]
}

const tagDlg = ref(false)
const availableHouses = computed(() => houseOptions.value)

const extraManualTagOptions = computed(() =>
  allTags.value.filter(t => t.tagType === 'manual' && t.tagId !== FOCUS_TAG_ID)
)

const previewAutoTags = computed(() => {
  const tags = []
  const age = residentForm.age
  const living = residentForm.livingStatus === '1'
  if (living && age != null && age >= 60) tags.push('独居老人')
  if (living && age != null && age >= 80) tags.push('高龄老人')
  return tags
})

const canApplyFocus = computed(() => previewAutoTags.value.length === 0)

watch(canApplyFocus, (ok) => {
  if (!ok) focusChecked.value = false
})

function careTagType(name) {
  if (name === '独居老人') return 'danger'
  if (name === '高龄老人') return 'success'
  if (name === '重点关注') return 'warning'
  return 'primary'
}

function displayTags(row) {
  return row.careTags || [...(row.systemTags || []), ...(row.manualTags || [])]
}

function genderLabel(gender) {
  if (gender === '0') return '男'
  if (gender === '1') return '女'
  return '-'
}

function buildTagIds() {
  const ids = [...extraManualTagIds.value]
  if (focusChecked.value) ids.unshift(FOCUS_TAG_ID)
  return ids
}

async function loadTags() {
  allTags.value = (await listTag()).data || []
}

async function loadTagList() {
  tagLoading.value = true
  try {
    await loadTags()
  } finally {
    tagLoading.value = false
  }
}

async function loadBuildingOptions() {
  buildingOptions.value = (await listBuildingAll()).data
}

async function loadHouseOptions() {
  const list = []
  for (const b of buildingOptions.value) {
    const res = await listHouse({ buildingId: b.buildingId, pageNum: 1, pageSize: 200 })
    res.data.rows.forEach(h => list.push({ ...h, buildingNo: b.buildingNo }))
  }
  houseOptions.value = list
}

async function openDetail(row) {
  detailResidentId.value = row.residentId
  detailDrawer.value = true
}

async function loadOccupied(excludeId) {
  occupiedHouseIds.value = (await listOccupiedHouses(excludeId)).data || []
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
    Object.assign(residentForm, {
      residentId: row.residentId,
      name: row.name,
      gender: row.gender || '',
      age: row.age ?? null,
      phone: row.phone,
      houseId: row.houseId,
      livingStatus: row.livingStatus || '1',
      isOwner: row.isOwner ?? 1,
      ownerName: row.ownerName || '',
      ownerPhone: row.ownerPhone || '',
      ownerRelation: row.ownerRelation || '',
      moveInDate: row.moveInDate || '',
      emergencyName: row.emergencyName || '',
      emergencyPhone: row.emergencyPhone || '',
      emergencyRelation: row.emergencyRelation || '',
      remark: row.remark || ''
    })
    const manualIds = row.manualTagIds || []
    focusChecked.value = manualIds.includes(FOCUS_TAG_ID)
    extraManualTagIds.value = manualIds.filter(id => id !== FOCUS_TAG_ID)
    await loadOccupied(row.residentId)
  } else {
    Object.assign(residentForm, {
      residentId: null, name: '', gender: '', age: null, phone: '', houseId: null,
      livingStatus: '1', isOwner: 1, ownerName: '', ownerPhone: '', ownerRelation: '',
      moveInDate: '', emergencyName: '', emergencyPhone: '', emergencyRelation: '', remark: ''
    })
    focusChecked.value = false
    extraManualTagIds.value = []
    await loadOccupied(null)
  }
  residentDlg.value = true
}

async function saveResident() {
  const valid = await residentRef.value?.validate().catch(() => false)
  if (!valid) return
  if (focusChecked.value && !canApplyFocus.value) {
    ElMessage.warning('独居或高龄老人不能设置重点关注')
    return
  }
  const payload = { ...residentForm, tagIds: buildTagIds() }
  if (payload.isOwner === 1) {
    payload.ownerName = ''
    payload.ownerPhone = ''
    payload.ownerRelation = '本人'
  }
  if (residentForm.residentId) await updateResident(payload)
  else await addResident(payload)
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
  tagDlg.value = true
}

async function submitAddTag() {
  const name = newTagName.value.trim()
  if (!name) return
  await addTag({ tagName: name, tagType: 'manual' })
  ElMessage.success('标签已添加')
  newTagName.value = ''
  await loadTags()
}

async function removeTag(row) {
  await ElMessageBox.confirm(`确认删除标签「${row.tagName}」？`, '提示', { type: 'warning' })
  await deleteTag(row.tagId)
  ElMessage.success('已删除')
  await loadTags()
}

onMounted(async () => {
  try {
    await loadTags()
    await loadBuildingOptions()
    await loadHouseOptions()
  } catch (e) {
    console.error('住户档案页初始化失败', e)
  }
  const rid = route.query.residentId
  if (rid) {
    detailResidentId.value = Number(rid)
    detailDrawer.value = true
  }
})
</script>

<style scoped>
.care-tag-hint {
  margin: 8px 0 0;
  font-size: 12px;
  color: var(--el-text-color-secondary);
  line-height: 1.5;
}
.care-tag-block {
  width: 100%;
}
.field-hint {
  margin: 4px 0 0;
  font-size: 12px;
  color: var(--el-text-color-secondary);
}
.tag-mgr-add {
  display: flex;
  gap: 8px;
  margin-bottom: 12px;
}
</style>
