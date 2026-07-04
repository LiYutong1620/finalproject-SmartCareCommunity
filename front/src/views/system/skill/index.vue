<template>
  <div class="app-container">
    <el-form :inline="true" class="search-form">
      <el-form-item label="姓名">
        <el-input
          v-model="query.keyword"
          clearable
          placeholder="维修工姓名"
          style="width: 180px"
        />
      </el-form-item>
    </el-form>

    <el-table :data="list" v-loading="loading" border stripe>
      <el-table-column type="index" label="序号" width="60" align="center" />
      <el-table-column label="姓名" min-width="120">
        <template #default="{ row }">
          <el-button link type="primary" @click="openDrawer(row, 'view')">{{ row.name }}</el-button>
        </template>
      </el-table-column>
      <el-table-column prop="workerLevel" label="职级" width="100" align="center">
        <template #default="{ row }">
          <el-tag size="small" effect="plain">{{ row.workerLevel || '初级' }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="入职时间" width="170" align="center">
        <template #default="{ row }">{{ formatTime(row.hireTime) }}</template>
      </el-table-column>
      <el-table-column label="审核状态" width="130" align="center">
        <template #default="{ row }">
          <el-tag :type="workerSummaryAuditTagType(row.auditStatus)" size="small" effect="plain">
            {{ workerSummaryAuditLabel(row.auditStatus) }}
            <template v-if="row.pendingCount > 0">({{ row.pendingCount }})</template>
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="160" align="center" fixed="right">
        <template #default="{ row }">
          <el-button
            v-if="row.pendingCount > 0"
            link
            type="warning"
            size="small"
            @click="openDrawer(row, 'audit')"
          >审核</el-button>
          <el-button link type="primary" size="small" @click="openDrawer(row, 'edit')">编辑</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-drawer
      v-model="drawerVisible"
      :title="drawerTitle"
      size="560px"
      append-to-body
      destroy-on-close
      @closed="onDrawerClosed"
    >
      <div v-loading="detailLoading" class="qual-drawer">
        <template v-if="detail">
          <el-descriptions :column="1" border size="small" class="base-desc">
            <el-descriptions-item label="姓名">{{ detail.name }}</el-descriptions-item>
            <el-descriptions-item label="工号">{{ detail.workerNo || '—' }}</el-descriptions-item>
            <el-descriptions-item label="职级">
              <template v-if="drawerMode === 'edit'">
                <el-select v-model="editLevel" style="width: 140px">
                  <el-option v-for="lv in WORKER_LEVELS" :key="lv" :label="lv" :value="lv" />
                </el-select>
                <el-button type="primary" link class="ml8" :loading="savingLevel" @click="saveLevel">保存职级</el-button>
              </template>
              <el-tag v-else size="small" effect="plain">{{ detail.workerLevel || '初级' }}</el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="入职时间">{{ formatTime(currentRow?.hireTime) }}</el-descriptions-item>
          </el-descriptions>

          <!-- 审核模式：仅待审项 -->
          <template v-if="drawerMode === 'audit'">
            <div v-if="!pendingSkills.length && !pendingCerts.length" class="empty-block">
              暂无待审核项
            </div>
            <section v-if="pendingSkills.length" class="drawer-section">
              <div class="section-title">待审核技能</div>
              <div v-for="s in pendingSkills" :key="s.skillId" class="audit-card">
                <div class="audit-card-head">
                  <span class="audit-name">{{ s.skillName }}</span>
                  <el-tag size="small" type="warning" effect="plain">待审核</el-tag>
                </div>
                <p v-if="s.applyRemark" class="audit-remark"><span>说明证明：</span>{{ s.applyRemark }}</p>
                <div class="audit-actions">
                  <el-button type="success" size="small" :loading="auditingKey === 'skill-' + s.skillId" @click="handleSkillAudit(s, true)">通过</el-button>
                  <el-button type="danger" size="small" plain @click="openReject('skill', s)">驳回</el-button>
                </div>
              </div>
            </section>
            <section v-if="pendingCerts.length" class="drawer-section">
              <div class="section-title">待审核证书</div>
              <div v-for="c in pendingCerts" :key="c.certId" class="audit-card">
                <div class="audit-card-head">
                  <span class="audit-name">{{ c.certName }}</span>
                  <el-tag size="small" type="warning" effect="plain">待审核</el-tag>
                </div>
                <p class="audit-meta">有效期 {{ c.certExpire || '—' }}<template v-if="c.relatedSkill"> · 关联 {{ c.relatedSkill }}</template></p>
                <p v-if="c.applyRemark" class="audit-remark"><span>说明证明：</span>{{ c.applyRemark }}</p>
                <div class="audit-actions">
                  <el-button type="success" size="small" :loading="auditingKey === 'cert-' + c.certId" @click="handleCertAudit(c, true)">通过</el-button>
                  <el-button type="danger" size="small" plain @click="openReject('cert', c)">驳回</el-button>
                </div>
              </div>
            </section>
          </template>

          <!-- 查看 / 编辑：技能与证书 -->
          <template v-else>
            <section class="drawer-section">
              <div class="section-head">
                <div class="section-title">专业技能</div>
                <el-button v-if="drawerMode === 'edit'" type="primary" link icon="Plus" @click="openSkillForm()">新增</el-button>
              </div>
              <el-table :data="detail.skills || []" border size="small" empty-text="暂无技能标签">
                <el-table-column prop="skillName" label="技能名称" min-width="100" />
                <el-table-column prop="skillLevel" label="等级" width="80" align="center" />
                <el-table-column label="状态" width="90" align="center">
                  <template #default="{ row }">
                    <el-tag :type="auditTagType(row.auditStatus)" size="small" effect="plain">
                      {{ auditStatusLabel(row.auditStatus) }}
                    </el-tag>
                  </template>
                </el-table-column>
                <el-table-column v-if="drawerMode === 'view'" prop="applyRemark" label="说明" min-width="120" show-overflow-tooltip />
                <el-table-column v-if="drawerMode === 'view'" prop="auditRemark" label="审核意见" min-width="100" show-overflow-tooltip>
                  <template #default="{ row }">{{ row.auditRemark || '—' }}</template>
                </el-table-column>
                <el-table-column v-if="drawerMode === 'edit'" label="操作" width="120" align="center">
                  <template #default="{ row }">
                    <el-button link type="primary" size="small" @click="openSkillForm(row)">编辑</el-button>
                    <el-button link type="danger" size="small" @click="removeSkill(row)">删除</el-button>
                  </template>
                </el-table-column>
              </el-table>
            </section>

            <section class="drawer-section">
              <div class="section-head">
                <div class="section-title">证书信息</div>
                <el-button v-if="drawerMode === 'edit'" type="primary" link icon="Plus" @click="openCertForm()">新增</el-button>
              </div>
              <el-table :data="detail.certificates || []" border size="small" empty-text="暂无证书">
                <el-table-column prop="certName" label="证书名称" min-width="110" />
                <el-table-column prop="certExpire" label="有效期" width="110" />
                <el-table-column prop="relatedSkill" label="关联技能" width="100">
                  <template #default="{ row }">{{ row.relatedSkill || '—' }}</template>
                </el-table-column>
                <el-table-column label="状态" width="90" align="center">
                  <template #default="{ row }">
                    <el-tag :type="auditTagType(row.auditStatus)" size="small" effect="plain">
                      {{ auditStatusLabel(row.auditStatus) }}
                    </el-tag>
                  </template>
                </el-table-column>
                <el-table-column v-if="drawerMode === 'view'" prop="auditRemark" label="审核意见" min-width="100" show-overflow-tooltip>
                  <template #default="{ row }">{{ row.auditRemark || '—' }}</template>
                </el-table-column>
                <el-table-column v-if="drawerMode === 'edit'" label="操作" width="120" align="center">
                  <template #default="{ row }">
                    <el-button link type="primary" size="small" @click="openCertForm(row)">编辑</el-button>
                    <el-button link type="danger" size="small" @click="removeCert(row)">删除</el-button>
                  </template>
                </el-table-column>
              </el-table>
            </section>
          </template>
        </template>
      </div>
    </el-drawer>

    <!-- 技能表单 -->
    <el-dialog v-model="skillDialogVisible" :title="skillForm.skillId ? '编辑技能' : '新增技能'" width="440px" append-to-body :close-on-click-modal="false">
      <el-form :model="skillForm" label-width="88px">
        <el-form-item label="技能名称" required>
          <el-select v-model="skillForm.skillName" filterable placeholder="请选择" style="width: 100%">
            <el-option-group v-for="cat in SKILL_CATEGORIES" :key="cat.name" :label="cat.name">
              <el-option v-for="name in cat.skills" :key="name" :label="name" :value="name" />
            </el-option-group>
          </el-select>
        </el-form-item>
        <el-form-item label="技能等级">
          <el-select v-model="skillForm.skillLevel" style="width: 100%">
            <el-option label="初级" value="初级" />
            <el-option label="中级" value="中级" />
            <el-option label="高级" value="高级" />
            <el-option label="专家" value="专家" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="skillDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="savingSkill" @click="saveSkill">保存</el-button>
      </template>
    </el-dialog>

    <!-- 证书表单 -->
    <el-dialog v-model="certDialogVisible" :title="certForm.certId ? '编辑证书' : '新增证书'" width="440px" append-to-body :close-on-click-modal="false">
      <el-form :model="certForm" label-width="88px">
        <el-form-item label="证书名称" required>
          <el-input v-model="certForm.certName" placeholder="如：电工操作证" />
        </el-form-item>
        <el-form-item label="有效期">
          <el-date-picker v-model="certForm.certExpire" type="date" value-format="YYYY-MM-DD" placeholder="选择日期" style="width: 100%" />
        </el-form-item>
        <el-form-item label="关联技能">
          <el-select v-model="certForm.relatedSkill" clearable filterable placeholder="可选" style="width: 100%">
            <el-option v-for="name in skillNameOptions" :key="name" :label="name" :value="name" />
          </el-select>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="certForm.applyRemark" type="textarea" :rows="2" maxlength="500" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="certDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="savingCert" @click="saveCert">保存</el-button>
      </template>
    </el-dialog>

    <!-- 驳回原因 -->
    <el-dialog v-model="rejectDialogVisible" title="填写驳回原因" width="420px" append-to-body :close-on-click-modal="false">
      <el-input
        v-model="rejectReason"
        type="textarea"
        :rows="4"
        maxlength="500"
        show-word-limit
        placeholder="请说明驳回原因，将反馈给维修工（至少2字）"
      />
      <template #footer>
        <el-button @click="rejectDialogVisible = false">取消</el-button>
        <el-button type="danger" :loading="auditingKey !== ''" @click="confirmReject">确认驳回</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useAutoQuery } from '@/composables/useAutoQuery'
import {
  listWorkerProfileSummaries,
  getWorkerQualification,
  updateWorkerLevel,
  auditWorkerSkill,
  auditWorkerCert,
  addWorkerSkill,
  editWorkerSkill,
  deleteWorkerSkill,
  addWorkerCert,
  editWorkerCert,
  deleteWorkerCert
} from '@/api/system'
import {
  SKILL_CATEGORIES,
  WORKER_LEVELS,
  auditStatusLabel,
  auditTagType,
  workerSummaryAuditLabel,
  workerSummaryAuditTagType
} from '@/utils/workerQualification'

const query = reactive({ keyword: '' })
const list = ref([])

async function fetchList() {
  const res = await listWorkerProfileSummaries({
    keyword: query.keyword || undefined
  })
  list.value = res.data || []
}

const { loading, load } = useAutoQuery(fetchList, () => ({ keyword: query.keyword }), { debounce: 300 })

const drawerVisible = ref(false)
const drawerMode = ref('view')
const currentRow = ref(null)
const detail = ref(null)
const detailLoading = ref(false)
const editLevel = ref('初级')
const savingLevel = ref(false)

const skillDialogVisible = ref(false)
const certDialogVisible = ref(false)
const savingSkill = ref(false)
const savingCert = ref(false)
const skillForm = reactive({ skillId: null, skillName: '', skillLevel: '初级' })
const certForm = reactive({ certId: null, certName: '', certExpire: '', relatedSkill: '', applyRemark: '' })

const rejectDialogVisible = ref(false)
const rejectReason = ref('')
const rejectTarget = ref(null)
const auditingKey = ref('')

const drawerTitle = computed(() => {
  const name = currentRow.value?.name || ''
  if (drawerMode.value === 'audit') return `资质审核 · ${name}`
  if (drawerMode.value === 'edit') return `编辑资质 · ${name}`
  return `资质详情 · ${name}`
})

const pendingSkills = computed(() =>
  (detail.value?.skills || []).filter(s => s.auditStatus === '0')
)
const pendingCerts = computed(() =>
  (detail.value?.certificates || []).filter(c => c.auditStatus === '0')
)
const skillNameOptions = computed(() => {
  const fromDetail = (detail.value?.skills || []).map(s => s.skillName)
  const fromCatalog = SKILL_CATEGORIES.flatMap(c => c.skills)
  return [...new Set([...fromDetail, ...fromCatalog])]
})

function formatTime(t) {
  if (!t) return '—'
  return String(t).replace('T', ' ').slice(0, 19)
}

async function loadDetail(workerId) {
  detailLoading.value = true
  try {
    const res = await getWorkerQualification(workerId)
    detail.value = res.data
    editLevel.value = res.data?.workerLevel || '初级'
  } finally {
    detailLoading.value = false
  }
}

async function openDrawer(row, mode) {
  currentRow.value = row
  drawerMode.value = mode
  drawerVisible.value = true
  await loadDetail(row.workerId)
}

function onDrawerClosed() {
  currentRow.value = null
  detail.value = null
  load()
}

async function saveLevel() {
  if (!currentRow.value) return
  savingLevel.value = true
  try {
    await updateWorkerLevel(currentRow.value.workerId, editLevel.value)
    ElMessage.success('职级已更新')
    await loadDetail(currentRow.value.workerId)
    const row = list.value.find(r => r.workerId === currentRow.value.workerId)
    if (row) row.workerLevel = editLevel.value
  } finally {
    savingLevel.value = false
  }
}

function openSkillForm(row) {
  if (row) {
    Object.assign(skillForm, {
      skillId: row.skillId,
      skillName: row.skillName,
      skillLevel: row.skillLevel || '初级'
    })
  } else {
    Object.assign(skillForm, { skillId: null, skillName: '', skillLevel: '初级' })
  }
  skillDialogVisible.value = true
}

async function saveSkill() {
  if (!skillForm.skillName) {
    ElMessage.warning('请选择技能名称')
    return
  }
  savingSkill.value = true
  try {
    const payload = {
      workerId: currentRow.value.workerId,
      skillName: skillForm.skillName,
      skillLevel: skillForm.skillLevel,
      auditStatus: '1'
    }
    if (skillForm.skillId) {
      await editWorkerSkill({ ...payload, skillId: skillForm.skillId })
    } else {
      await addWorkerSkill(payload)
    }
    ElMessage.success('保存成功')
    skillDialogVisible.value = false
    await loadDetail(currentRow.value.workerId)
  } finally {
    savingSkill.value = false
  }
}

async function removeSkill(row) {
  await ElMessageBox.confirm(`确认删除技能「${row.skillName}」？`, '提示', { type: 'warning' })
  await deleteWorkerSkill(row.skillId)
  ElMessage.success('已删除')
  await loadDetail(currentRow.value.workerId)
}

function openCertForm(row) {
  if (row) {
    Object.assign(certForm, {
      certId: row.certId,
      certName: row.certName,
      certExpire: row.certExpire || '',
      relatedSkill: row.relatedSkill || '',
      applyRemark: row.applyRemark || ''
    })
  } else {
    Object.assign(certForm, { certId: null, certName: '', certExpire: '', relatedSkill: '', applyRemark: '' })
  }
  certDialogVisible.value = true
}

async function saveCert() {
  if (!certForm.certName?.trim()) {
    ElMessage.warning('请填写证书名称')
    return
  }
  savingCert.value = true
  try {
    const payload = {
      certName: certForm.certName.trim(),
      certExpire: certForm.certExpire || null,
      relatedSkill: certForm.relatedSkill || null,
      applyRemark: certForm.applyRemark || ''
    }
    if (certForm.certId) {
      await editWorkerCert(certForm.certId, payload)
    } else {
      await addWorkerCert(currentRow.value.workerId, payload)
    }
    ElMessage.success('保存成功')
    certDialogVisible.value = false
    await loadDetail(currentRow.value.workerId)
  } finally {
    savingCert.value = false
  }
}

async function removeCert(row) {
  await ElMessageBox.confirm(`确认删除证书「${row.certName}」？`, '提示', { type: 'warning' })
  await deleteWorkerCert(row.certId)
  ElMessage.success('已删除')
  await loadDetail(currentRow.value.workerId)
}

async function handleSkillAudit(skill, approved) {
  auditingKey.value = 'skill-' + skill.skillId
  try {
    await auditWorkerSkill(skill.skillId, approved)
    ElMessage.success('已通过')
    await loadDetail(currentRow.value.workerId)
    syncPendingCount()
  } finally {
    auditingKey.value = ''
  }
}

async function handleCertAudit(cert, approved) {
  auditingKey.value = 'cert-' + cert.certId
  try {
    await auditWorkerCert(cert.certId, approved)
    ElMessage.success('已通过')
    await loadDetail(currentRow.value.workerId)
    syncPendingCount()
  } finally {
    auditingKey.value = ''
  }
}

function openReject(type, item) {
  rejectTarget.value = { type, item }
  rejectReason.value = ''
  rejectDialogVisible.value = true
}

async function confirmReject() {
  const reason = rejectReason.value?.trim()
  if (!reason || reason.length < 2) {
    ElMessage.warning('请填写至少2字的驳回原因')
    return
  }
  const { type, item } = rejectTarget.value
  auditingKey.value = type + '-' + (type === 'skill' ? item.skillId : item.certId)
  try {
    if (type === 'skill') {
      await auditWorkerSkill(item.skillId, false, reason)
    } else {
      await auditWorkerCert(item.certId, false, reason)
    }
    ElMessage.success('已驳回')
    rejectDialogVisible.value = false
    await loadDetail(currentRow.value.workerId)
    syncPendingCount()
  } finally {
    auditingKey.value = ''
  }
}

function syncPendingCount() {
  const pending = pendingSkills.value.length + pendingCerts.value.length
  const row = list.value.find(r => r.workerId === currentRow.value?.workerId)
  if (row) {
    row.pendingCount = pending
    row.auditStatus = pending > 0 ? '0' : '1'
  }
  if (drawerMode.value === 'audit' && pending === 0) {
    ElMessage.info('该维修工已无待审核项')
  }
}
</script>

<style scoped>
.search-form {
  margin-bottom: 12px;
}

.qual-drawer {
  min-height: 200px;
}

.base-desc {
  margin-bottom: 16px;
}

.drawer-section {
  margin-top: 20px;
}

.section-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 10px;
}

.section-title {
  font-size: 15px;
  font-weight: 600;
  color: var(--el-text-color-primary);
}

.audit-card {
  padding: 12px;
  margin-bottom: 10px;
  border: 1px solid var(--el-border-color-lighter);
  border-radius: 8px;
  background: var(--el-fill-color-blank);
}

.audit-card-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 8px;
}

.audit-name {
  font-weight: 600;
}

.audit-meta {
  margin: 0 0 6px;
  font-size: 13px;
  color: var(--el-text-color-secondary);
}

.audit-remark {
  margin: 0 0 10px;
  font-size: 13px;
  line-height: 1.5;
  color: var(--el-text-color-regular);
}

.audit-remark span {
  color: var(--el-text-color-secondary);
}

.audit-actions {
  display: flex;
  gap: 8px;
}

.empty-block {
  padding: 24px;
  text-align: center;
  color: var(--el-text-color-secondary);
}

.ml8 {
  margin-left: 8px;
}
</style>
