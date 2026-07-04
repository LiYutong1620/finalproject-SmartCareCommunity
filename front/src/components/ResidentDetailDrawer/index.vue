<template>
  <el-drawer
    :model-value="modelValue"
    title="住户档案详情"
    size="420px"
    append-to-body
    @update:model-value="$emit('update:modelValue', $event)"
    @open="loadDetail"
  >
    <div v-loading="loading">
      <template v-if="detail">
        <el-descriptions :column="1" border size="small">
          <el-descriptions-item label="姓名">{{ detail.name }}</el-descriptions-item>
          <el-descriptions-item label="业主账号">{{ detail.ownerUsername || '—' }}</el-descriptions-item>
          <el-descriptions-item label="性别">{{ genderLabel(detail.gender) }}</el-descriptions-item>
          <el-descriptions-item label="年龄">{{ detail.age ?? '—' }}</el-descriptions-item>
          <el-descriptions-item label="电话">{{ detail.phone || '—' }}</el-descriptions-item>
          <el-descriptions-item label="房屋">{{ houseText }}</el-descriptions-item>
          <el-descriptions-item label="居住状态">{{ detail.livingStatusLabel || '—' }}</el-descriptions-item>
          <el-descriptions-item label="入住日期">{{ detail.moveInDate || '—' }}</el-descriptions-item>
          <el-descriptions-item label="产权人">{{ ownerText }}</el-descriptions-item>
          <el-descriptions-item label="紧急联系人">{{ detail.emergencyContact || '—' }}</el-descriptions-item>
          <el-descriptions-item label="标签">
            <el-tag
              v-for="t in displayTags"
              :key="t"
              size="small"
              :type="careTagType(t)"
              effect="plain"
              round
              style="margin:2px"
            >{{ t }}</el-tag>
            <span v-if="!displayTags.length">—</span>
          </el-descriptions-item>
          <el-descriptions-item label="老人关怀">
            {{ detail.elderCareTarget ? '已纳入' : '未纳入' }}
          </el-descriptions-item>
          <el-descriptions-item label="备注">{{ detail.remark || '—' }}</el-descriptions-item>
        </el-descriptions>
        <div v-if="showEdit" class="drawer-actions">
          <el-button type="primary" @click="onEdit">编辑档案</el-button>
        </div>
      </template>
    </div>
  </el-drawer>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { getResident } from '@/api/property'

const props = defineProps({
  modelValue: { type: Boolean, default: false },
  residentId: { type: [Number, String], default: null },
  showEdit: { type: Boolean, default: false }
})

const emit = defineEmits(['update:modelValue', 'edit'])

const loading = ref(false)
const detail = ref(null)

const displayTags = computed(() => {
  const d = detail.value
  if (!d) return []
  return d.careTags || [...(d.systemTags || []), ...(d.manualTags || [])]
})

const houseText = computed(() => {
  const d = detail.value
  if (!d) return '—'
  if (d.buildingNo && d.houseNo) return `${d.buildingNo}-${d.houseNo}`
  if (d.address) return d.address
  return '—'
})

const ownerText = computed(() => {
  const d = detail.value
  if (!d) return '—'
  if (d.isOwner === 0) {
    return `${d.ownerName || ''} ${d.ownerPhone || ''}（${d.ownerRelation || '—'}）`.trim()
  }
  return '本人'
})

watch(() => props.residentId, () => {
  if (props.modelValue) loadDetail()
})

function genderLabel(gender) {
  if (gender === '0') return '男'
  if (gender === '1') return '女'
  return '—'
}

function careTagType(name) {
  if (name === '独居老人') return 'danger'
  if (name === '高龄老人') return 'success'
  if (name === '重点关注') return 'warning'
  return 'primary'
}

async function loadDetail() {
  if (!props.residentId) {
    detail.value = null
    return
  }
  loading.value = true
  try {
    const res = await getResident(props.residentId)
    detail.value = res.data
  } finally {
    loading.value = false
  }
}

function onEdit() {
  emit('edit', detail.value)
  emit('update:modelValue', false)
}
</script>

<style scoped>
.drawer-actions {
  margin-top: 16px;
  text-align: right;
}
</style>
