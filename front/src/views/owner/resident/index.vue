<template>
  <div v-loading="loading" class="resident-page app-container">
    <!-- 顶部档案卡片 -->
    <div class="profile-hero">
      <div class="hero-main">
        <div class="avatar">{{ avatarText }}</div>
        <div class="hero-info">
          <div class="name-row">
            <h2 class="name">{{ profile.name || '—' }}</h2>
            <el-tag v-if="profile.residentTypeLabel" type="primary" size="small" effect="plain" round>
              {{ profile.residentTypeLabel }}
            </el-tag>
            <el-tag v-if="profile.elderCareTarget" type="success" size="small" effect="plain" round>老人关怀</el-tag>
            <el-tag
              v-for="t in (profile.careTags || []).filter(x => x !== '独居老人' && x !== '高龄老人')"
              :key="t"
              type="warning"
              size="small"
              effect="plain"
              round
            >{{ t }}</el-tag>
            <el-tag v-if="profile.gender" size="small" effect="plain" round>
              {{ genderLabel(profile.gender) }}
            </el-tag>
          </div>
          <p class="account-line">
            <el-icon><User /></el-icon>
            系统账号 {{ profile.username || '—' }}
          </p>
          <p class="address-line">
            <el-icon><Location /></el-icon>
            {{ fullAddress }}
          </p>
        </div>
      </div>
    </div>

    <!-- 概览数据 -->
    <div class="stat-row">
      <div class="stat-card">
        <span class="stat-label">入住日期</span>
        <span class="stat-value">{{ profile.moveInDate || '—' }}</span>
      </div>
      <div class="stat-card">
        <span class="stat-label">居住时长</span>
        <span class="stat-value">{{ stayText }}</span>
      </div>
      <div class="stat-card">
        <span class="stat-label">房屋面积</span>
        <span class="stat-value">{{ areaText }}</span>
      </div>
      <div class="stat-card">
        <span class="stat-label">户型</span>
        <span class="stat-value">{{ profile.houseLayout || '—' }}</span>
      </div>
    </div>

    <div class="content-grid">
      <!-- 基本信息 -->
      <el-card shadow="never" class="info-card">
        <template #header>
          <div class="card-head">
            <el-icon><Postcard /></el-icon>
            <span>基本信息</span>
          </div>
        </template>
        <ul class="info-list">
          <li><span class="label">姓名</span><span class="value">{{ profile.name || '—' }}</span></li>
          <li><span class="label">性别</span><span class="value">{{ genderLabel(profile.gender) }}</span></li>
          <li><span class="label">年龄</span><span class="value">{{ ageText }}</span></li>
          <li><span class="label">居住状态</span><span class="value">{{ profile.livingStatusLabel || '—' }}</span></li>
          <li v-if="profile.isOwner === 0"><span class="label">产权人</span><span class="value">{{ profile.ownerName }} {{ profile.ownerPhone }}（{{ profile.ownerRelation }}）</span></li>
          <li><span class="label">档案登记</span><span class="value">{{ profile.archiveTime || '—' }}</span></li>
        </ul>
      </el-card>

      <!-- 房屋信息 -->
      <el-card shadow="never" class="info-card">
        <template #header>
          <div class="card-head">
            <el-icon><House /></el-icon>
            <span>房屋信息</span>
          </div>
        </template>
        <ul class="info-list">
          <li><span class="label">楼栋</span><span class="value">{{ profile.buildingNo || '—' }}</span></li>
          <li><span class="label">房号</span><span class="value">{{ profile.houseNo || '—' }}</span></li>
          <li><span class="label">户型</span><span class="value">{{ profile.houseLayout || '—' }}</span></li>
          <li><span class="label">建筑面积</span><span class="value">{{ areaText }}</span></li>
          <li><span class="label">入住日期</span><span class="value">{{ profile.moveInDate || '—' }}</span></li>
        </ul>
      </el-card>

      <!-- 联系信息 -->
      <el-card shadow="never" class="info-card span-full">
        <template #header>
          <div class="card-head">
            <el-icon><Phone /></el-icon>
            <span>联系信息</span>
          </div>
        </template>
        <div class="contact-grid">
          <div class="contact-item">
            <span class="contact-label">联系电话</span>
            <span class="contact-value phone">{{ profile.phone || '—' }}</span>
          </div>
          <div class="contact-item emergency-item">
            <span class="contact-label">紧急联系人</span>
            <div class="emergency-field">
              <el-input v-model="emergencyForm.name" placeholder="姓名" maxlength="20" style="max-width:120px" />
              <el-input v-model="emergencyForm.phone" placeholder="手机号" maxlength="11" style="max-width:160px" />
              <el-select v-model="emergencyForm.relation" placeholder="关系" clearable style="width:100px">
                <el-option v-for="r in ['配偶','子女','父母','兄弟姐妹','亲属','邻居','朋友','其他']" :key="r" :label="r" :value="r" />
              </el-select>
              <el-button type="primary" :loading="saving" @click="saveEmergency">保存</el-button>
            </div>
            <p class="field-tip">用于突发情况时物业或维修人员联系您的备用联系人</p>
          </div>
        </div>
      </el-card>

      <!-- 档案备注 -->
      <el-card v-if="profile.remark" shadow="never" class="info-card span-full">
        <template #header>
          <div class="card-head">
            <el-icon><Document /></el-icon>
            <span>档案备注</span>
          </div>
        </template>
        <p class="remark-text">{{ profile.remark }}</p>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { User, Location, Postcard, House, Phone, Document } from '@element-plus/icons-vue'
import { getResidentMe, updateEmergency } from '@/api/owner'

const loading = ref(false)
const saving = ref(false)
const profile = ref({})
const emergencyForm = ref({ name: '', phone: '', relation: '' })

const avatarText = computed(() => {
  const name = profile.value.name || ''
  return name ? name.charAt(0) : '户'
})

const fullAddress = computed(() => {
  const b = profile.value.buildingNo
  const h = profile.value.houseNo
  if (b && h) return `${b} ${h}`
  if (b) return b
  if (h) return h
  return '暂未绑定房屋'
})

const ageText = computed(() =>
  profile.value.age != null ? `${profile.value.age} 岁` : '—'
)

const areaText = computed(() =>
  profile.value.houseArea != null ? `${profile.value.houseArea} ㎡` : '—'
)

const stayText = computed(() => {
  const days = profile.value.stayDays
  if (days == null) return '—'
  if (days < 30) return `${days} 天`
  if (days < 365) return `${Math.floor(days / 30)} 个月`
  const years = Math.floor(days / 365)
  const months = Math.floor((days % 365) / 30)
  return months > 0 ? `${years} 年 ${months} 个月` : `${years} 年`
})

function genderLabel(gender) {
  if (gender === '0') return '男'
  if (gender === '1') return '女'
  return '—'
}

async function load() {
  loading.value = true
  try {
    profile.value = (await getResidentMe()).data || {}
    emergencyForm.value = {
      name: profile.value.emergencyName || '',
      phone: profile.value.emergencyPhone || '',
      relation: profile.value.emergencyRelation || ''
    }
  } finally {
    loading.value = false
  }
}

async function saveEmergency() {
  saving.value = true
  try {
    await updateEmergency({
      emergencyName: emergencyForm.value.name?.trim() || '',
      emergencyPhone: emergencyForm.value.phone?.trim() || '',
      emergencyRelation: emergencyForm.value.relation || ''
    })
    ElMessage.success('紧急联系人已保存')
    await load()
  } finally {
    saving.value = false
  }
}

onMounted(load)
</script>

<style scoped>
.resident-page {
  max-width: 960px;
}

.profile-hero {
  padding: 24px 28px;
  margin-bottom: 16px;
  border-radius: 12px;
  background: linear-gradient(135deg, #f0f7ff 0%, #ecf5ff 55%, #e8f4ff 100%);
  color: #303133;
  border: 1px solid #d9ecff;
  box-shadow: 0 4px 14px rgba(64, 158, 255, 0.08);
}

.hero-main {
  display: flex;
  align-items: center;
  gap: 20px;
}

.avatar {
  width: 72px;
  height: 72px;
  border-radius: 50%;
  background: #fff;
  border: 2px solid #c6e2ff;
  color: #409eff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  font-weight: 700;
  flex-shrink: 0;
}

.hero-info {
  min-width: 0;
}

.name-row {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 8px;
}

.name {
  margin: 0;
  font-size: 24px;
  font-weight: 700;
}

.name-row :deep(.el-tag) {
  border-color: #d9ecff;
  background: #fff;
  color: #409eff;
}

.account-line,
.address-line {
  display: flex;
  align-items: center;
  gap: 6px;
  margin: 4px 0 0;
  font-size: 13px;
  color: #606266;
}

.stat-row {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
  margin-bottom: 16px;
}

.stat-card {
  padding: 14px 16px;
  background: #fff;
  border: 1px solid #ebeef5;
  border-radius: 10px;
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.stat-label {
  font-size: 12px;
  color: #909399;
}

.stat-value {
  font-size: 15px;
  font-weight: 600;
  color: #303133;
}

.content-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.info-card {
  border-radius: 10px;
  border: 1px solid #ebeef5;
}

.info-card.span-full {
  grid-column: 1 / -1;
}

.card-head {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 15px;
  font-weight: 600;
  color: #303133;
}

.info-list {
  list-style: none;
  margin: 0;
  padding: 0;
}

.info-list li {
  display: flex;
  justify-content: space-between;
  gap: 16px;
  padding: 10px 0;
  border-bottom: 1px solid #f0f2f5;
  font-size: 14px;
}

.info-list li:last-child {
  border-bottom: none;
}

.info-list .label {
  color: #909399;
  flex-shrink: 0;
}

.info-list .value {
  color: #303133;
  text-align: right;
  word-break: break-word;
}

.contact-grid {
  display: grid;
  grid-template-columns: 240px 1fr;
  gap: 24px;
}

.contact-item {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.contact-label {
  font-size: 13px;
  color: #909399;
}

.contact-value {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.contact-value.phone {
  color: #409eff;
  letter-spacing: 0.5px;
}

.emergency-field {
  display: flex;
  gap: 10px;
  align-items: flex-start;
}

.emergency-field .el-input {
  flex: 1;
  max-width: 420px;
}

.field-tip {
  margin: 6px 0 0;
  font-size: 12px;
  color: #909399;
}

.remark-text {
  margin: 0;
  padding: 12px 14px;
  background: #fafbfc;
  border-radius: 8px;
  font-size: 14px;
  line-height: 1.7;
  color: #606266;
}

@media (max-width: 768px) {
  .stat-row {
    grid-template-columns: repeat(2, 1fr);
  }

  .content-grid {
    grid-template-columns: 1fr;
  }

  .contact-grid {
    grid-template-columns: 1fr;
  }

  .hero-main {
    flex-direction: column;
    align-items: flex-start;
  }
}
</style>
