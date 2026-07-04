<template>
  <div class="qualification-page app-container">
    <div class="page-head">
      <h2 class="page-title">我的资质</h2>
    </div>

    <div v-loading="loading" class="qual-body">
      <section class="qual-card">
        <h3 class="card-title">个人信息</h3>
        <dl class="info-grid">
          <div class="info-item"><dt>姓名</dt><dd>{{ profile.name || '—' }}</dd></div>
          <div class="info-item"><dt>工号</dt><dd>{{ profile.workerNo || '—' }}</dd></div>
          <div class="info-item"><dt>联系方式</dt><dd>{{ profile.virtualPhone || '—' }}</dd></div>
        </dl>
      </section>

      <section class="qual-card">
        <h3 class="card-title">当前状态</h3>
        <el-form inline class="status-form">
          <el-form-item label="忙闲状态">
            <el-select v-model="statusForm.workStatus" style="width: 140px">
              <el-option v-for="o in WORK_STATUS_OPTIONS" :key="o.value" :label="o.label" :value="o.value" />
            </el-select>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" :loading="savingStatus" @click="saveStatus">保存</el-button>
          </el-form-item>
        </el-form>
      </section>

      <section class="qual-card">
        <div class="card-head">
          <h3 class="card-title">专业技能</h3>
          <div class="level-badge">
            职级：<el-tag type="primary" effect="plain">{{ profile.workerLevel || '初级' }}</el-tag>
          </div>
        </div>
        <div class="skill-tags-wrap">
          <div v-if="(profile.skills || []).length" class="skill-tags">
            <el-tag
              v-for="s in profile.skills"
              :key="s.skillId"
              :type="skillTagType(s.auditStatus)"
              effect="plain"
              round
              class="skill-tag"
            >
              {{ s.skillName }}
              <span v-if="s.auditStatus === '0'" class="tag-status">· 待审核</span>
              <span v-else-if="s.auditStatus === '2'" class="tag-status">· 已驳回</span>
            </el-tag>
          </div>
          <p v-else class="empty-hint">暂无技能标签</p>
          <div v-if="skillsWithRemark.length" class="skill-remarks">
            <p v-for="s in skillsWithRemark" :key="'r-' + s.skillId" class="skill-remark-line">
              <span class="remark-name">{{ s.skillName }}</span>{{ s.applyRemark }}
            </p>
          </div>
        </div>
        <el-divider content-position="left">申请新技能</el-divider>
        <el-form label-width="88px" class="apply-form">
          <el-form-item label="技能标签" required>
            <el-select v-model="skillForm.skillName" filterable placeholder="请选择" style="width: 100%; max-width: 320px" clearable>
              <el-option-group v-for="cat in SKILL_CATEGORIES" :key="cat.name" :label="cat.name">
                <el-option
                  v-for="name in cat.skills"
                  :key="name"
                  :label="name"
                  :value="name"
                  :disabled="ownedSkillNames.has(name)"
                />
              </el-option-group>
            </el-select>
          </el-form-item>
          <el-form-item label="说明证明" required>
            <el-input
              v-model="skillForm.applyRemark"
              type="textarea"
              :rows="3"
              maxlength="500"
              show-word-limit
              placeholder="请说明相关从业经历、培训或项目经验，便于物业审核（至少10字）"
            />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" plain :loading="applyingSkill" @click="handleApplySkill">提交审核</el-button>
          </el-form-item>
        </el-form>
      </section>

      <section class="qual-card">
        <h3 class="card-title">证书信息</h3>
        <p class="section-tip">可登记多张证书；新增不会覆盖已有记录。可选填关联技能，便于与上方专业技能对照审核。</p>
        <div v-if="(profile.certificates || []).length" class="cert-list">
          <div
            v-for="c in profile.certificates"
            :key="c.certId"
            class="cert-item"
            :class="{ 'is-pending': c.auditStatus === '0', 'is-rejected': c.auditStatus === '2' }"
          >
            <div class="cert-row">
              <span class="cert-name">{{ c.certName }}</span>
              <el-tag :type="auditTagType(c.auditStatus)" size="small" effect="plain" round>
                {{ auditStatusLabel(c.auditStatus) }}
              </el-tag>
              <span class="cert-expire-inline">有效期 {{ c.certExpire || '—' }}</span>
              <span v-if="c.relatedSkill" class="cert-related">关联 {{ c.relatedSkill }}</span>
            </div>
            <p v-if="c.applyRemark && (c.auditStatus === '0' || c.auditStatus === '2')" class="cert-remark">{{ c.applyRemark }}</p>
          </div>
        </div>
        <p v-else class="empty-hint">暂未登记证书</p>
        <el-divider content-position="left">新增证书</el-divider>
        <el-form label-width="88px" class="apply-form">
          <el-form-item label="证书名称" required>
            <el-input v-model="certForm.certName" placeholder="如：电工操作证" style="max-width: 320px" />
          </el-form-item>
          <el-form-item label="有效期" required>
            <el-date-picker v-model="certForm.certExpire" type="date" value-format="YYYY-MM-DD" placeholder="选择日期" />
          </el-form-item>
          <el-form-item label="关联技能">
            <el-select v-model="certForm.relatedSkill" clearable placeholder="可选，便于对照审核" style="width: 100%; max-width: 320px">
              <el-option v-for="name in SKILL_CATALOG_FLAT" :key="name" :label="name" :value="name" />
            </el-select>
          </el-form-item>
          <el-form-item label="说明证明" required>
            <el-input
              v-model="certForm.applyRemark"
              type="textarea"
              :rows="3"
              maxlength="500"
              show-word-limit
              placeholder="请说明证书取得途径、适用工种等（至少10字）"
            />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" plain :loading="applyingCert" @click="handleApplyCert">提交审核</el-button>
          </el-form-item>
        </el-form>
      </section>

      <section class="qual-card">
        <h3 class="card-title">服务数据</h3>
        <dl class="info-grid">
          <div class="info-item"><dt>平均评分</dt><dd>{{ profile.avgScore ?? '—' }}</dd></div>
          <div class="info-item"><dt>评价数</dt><dd>{{ profile.evalCount ?? 0 }}</dd></div>
        </dl>
      </section>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import {
  getWorkerProfile, updateWorkerStatus, applyWorkerSkill, applyWorkerCert
} from '@/api/repair'
import {
  SKILL_CATEGORIES, WORK_STATUS_OPTIONS,
  auditStatusLabel, auditTagType
} from '@/utils/workerQualification'

const SKILL_CATALOG_FLAT = SKILL_CATEGORIES.flatMap(c => c.skills)

const loading = ref(false)
const savingStatus = ref(false)
const applyingSkill = ref(false)
const applyingCert = ref(false)
const profile = ref({ skills: [], certificates: [] })
const statusForm = reactive({ workStatus: 'available' })
const skillForm = reactive({ skillName: '', applyRemark: '' })
const certForm = reactive({ certName: '', certExpire: '', relatedSkill: '', applyRemark: '' })

const ownedSkillNames = computed(() => {
  const set = new Set()
  for (const s of profile.value.skills || []) {
    if (s.auditStatus === '0' || s.auditStatus === '1') {
      set.add(s.skillName)
    }
  }
  return set
})

const skillsWithRemark = computed(() =>
  (profile.value.skills || []).filter(s => s.applyRemark && (s.auditStatus === '0' || s.auditStatus === '2'))
)

function skillTagType(auditStatus) {
  if (auditStatus === '0') return 'warning'
  if (auditStatus === '2') return 'danger'
  return 'success'
}

async function loadProfile() {
  loading.value = true
  try {
    const res = await getWorkerProfile()
    profile.value = res.data || { skills: [], certificates: [] }
    statusForm.workStatus = res.data?.workStatus || 'available'
  } finally {
    loading.value = false
  }
}

async function saveStatus() {
  savingStatus.value = true
  try {
    await updateWorkerStatus({ workStatus: statusForm.workStatus })
    ElMessage.success('状态已保存')
  } finally {
    savingStatus.value = false
  }
}

async function handleApplySkill() {
  if (!skillForm.skillName) {
    ElMessage.warning('请选择技能标签')
    return
  }
  if (!skillForm.applyRemark?.trim() || skillForm.applyRemark.trim().length < 10) {
    ElMessage.warning('请填写至少10字的说明或证明')
    return
  }
  applyingSkill.value = true
  try {
    await applyWorkerSkill({
      skillName: skillForm.skillName,
      applyRemark: skillForm.applyRemark.trim()
    })
    ElMessage.success('技能申请已提交，等待物业审核')
    skillForm.skillName = ''
    skillForm.applyRemark = ''
    await loadProfile()
  } finally {
    applyingSkill.value = false
  }
}

async function handleApplyCert() {
  if (!certForm.certName?.trim()) {
    ElMessage.warning('请填写证书名称')
    return
  }
  if (!certForm.certExpire) {
    ElMessage.warning('请选择证书有效期')
    return
  }
  if (!certForm.applyRemark?.trim() || certForm.applyRemark.trim().length < 10) {
    ElMessage.warning('请填写至少10字的证书说明')
    return
  }
  applyingCert.value = true
  try {
    await applyWorkerCert({
      certName: certForm.certName.trim(),
      certExpire: certForm.certExpire,
      relatedSkill: certForm.relatedSkill || undefined,
      applyRemark: certForm.applyRemark.trim()
    })
    ElMessage.success('证书已提交，等待物业审核')
    certForm.certName = ''
    certForm.certExpire = ''
    certForm.relatedSkill = ''
    certForm.applyRemark = ''
    await loadProfile()
  } finally {
    applyingCert.value = false
  }
}

onMounted(loadProfile)
</script>

<style scoped>
.qualification-page { max-width: 880px; }
.page-head { margin-bottom: 20px; }
.page-title { margin: 0; font-size: 20px; font-weight: 600; color: #1a1a2e; }

.qual-card {
  margin-bottom: 16px;
  padding: 18px 20px;
  background: #fff;
  border: 1px solid #e8edf3;
  border-radius: 10px;
}

.card-head {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  margin-bottom: 12px;
}

.card-title {
  margin: 0 0 12px;
  font-size: 15px;
  font-weight: 600;
  color: #303133;
  padding-left: 10px;
  border-left: 3px solid #409eff;
  line-height: 1.2;
}

.card-head .card-title { margin-bottom: 0; }

.section-tip {
  margin: 0 0 12px;
  font-size: 12px;
  color: #909399;
  line-height: 1.6;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 12px 24px;
  margin: 0;
}

.info-item {
  display: flex;
  justify-content: space-between;
  font-size: 13px;
  padding: 8px 0;
  border-bottom: 1px solid #f0f2f5;
}

.info-item dt { margin: 0; color: #909399; }
.info-item dd { margin: 0; color: #303133; font-weight: 500; }

.level-badge { display: flex; align-items: center; gap: 6px; font-size: 13px; }

.skill-tags-wrap { margin-bottom: 8px; }

.skill-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.skill-tag { font-size: 13px; }

.tag-status {
  margin-left: 2px;
  font-size: 11px;
  opacity: 0.9;
}

.skill-remarks {
  margin-top: 10px;
  padding: 10px 12px;
  background: #fafbfc;
  border-radius: 8px;
  border: 1px solid #eef2f6;
}

.skill-remark-line {
  margin: 0;
  font-size: 12px;
  color: #606266;
  line-height: 1.55;
}

.skill-remark-line + .skill-remark-line { margin-top: 6px; }

.remark-name {
  font-weight: 600;
  color: #303133;
  margin-right: 4px;
}

.cert-list { display: flex; flex-direction: column; gap: 8px; margin-bottom: 8px; }

.cert-item {
  padding: 10px 12px;
  background: #fafbfc;
  border-radius: 8px;
  border: 1px solid #eef2f6;
}

.cert-item.is-pending {
  background: #fffbe6;
  border-color: #ffe58f;
}

.cert-item.is-rejected {
  background: #fff2f0;
  border-color: #ffccc7;
}

.cert-row {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px 12px;
}

.cert-name { font-weight: 600; color: #303133; font-size: 13px; }

.cert-expire-inline,
.cert-related {
  font-size: 12px;
  color: #909399;
}

.cert-remark {
  margin: 8px 0 0;
  font-size: 12px;
  color: #606266;
  line-height: 1.55;
}

.apply-form :deep(.el-form-item) { margin-bottom: 14px; }
.empty-hint { font-size: 13px; color: #909399; }
</style>
