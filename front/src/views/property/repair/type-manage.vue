<template>
  <div class="app-container repair-type-page">
    <div class="page-hero">
      <div class="hero-text">
        <h2 class="page-title">报修类型管理</h2>
        <p class="page-desc">
          维护一级/二级报修分类与典型关键词，供 AI 根据业主描述自动识别故障类型并辅助派单。
        </p>
      </div>
      <el-button type="primary" icon="Plus" @click="openCreate(null)">新增一级分类</el-button>
    </div>

    <div class="stats-row">
      <div v-for="s in statsCards" :key="s.label" class="stat-card">
        <span class="stat-value">{{ s.value }}</span>
        <span class="stat-label">{{ s.label }}</span>
      </div>
    </div>

    <div class="filter-bar">
      <el-input
        v-model="keyword"
        clearable
        placeholder="搜索分类名称或关键词"
        prefix-icon="Search"
        style="width: 280px"
      />
    </div>

    <div v-loading="loading" class="category-grid">
      <el-empty v-if="!filteredCategories.length && !loading" description="暂无报修类型" />
      <section
        v-for="cat in filteredCategories"
        :key="cat.typeId"
        class="category-card"
        :style="{ '--accent': categoryTheme(cat.typeName).color }"
      >
        <div class="category-head">
          <div class="category-icon" :class="categoryTheme(cat.typeName).className">
            <el-icon :size="22"><component :is="categoryTheme(cat.typeName).icon" /></el-icon>
          </div>
          <div class="category-meta">
            <div class="category-title-row">
              <h3 class="category-title">{{ cat.typeName }}</h3>
              <el-tag size="small" effect="plain" round>{{ (cat.children || []).length }} 个子类</el-tag>
            </div>
            <p class="category-tip">一级分类 · 排序 {{ cat.orderNum || 0 }}</p>
          </div>
          <el-dropdown trigger="click" @command="cmd => handleCategoryCommand(cmd, cat)">
            <el-button link type="primary" icon="MoreFilled" />
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="addChild">新增子类</el-dropdown-item>
                <el-dropdown-item command="edit">编辑分类</el-dropdown-item>
                <el-dropdown-item command="delete" divided>删除</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>

        <div v-if="parseKeywords(cat.keywords).length" class="keyword-block">
          <span class="block-label">典型关键词</span>
          <div class="keyword-tags">
            <el-tag
              v-for="kw in parseKeywords(cat.keywords)"
              :key="kw"
              size="small"
              effect="plain"
              round
              class="kw-tag"
            >{{ kw }}</el-tag>
          </div>
        </div>

        <div class="child-block">
          <span class="block-label">二级分类</span>
          <div v-if="cat.children?.length" class="child-list">
            <div v-for="child in cat.children" :key="child.typeId" class="child-item">
              <span class="child-name">{{ child.typeName }}</span>
              <el-space :size="4">
                <el-button link type="primary" size="small" @click="openEdit(child)">编辑</el-button>
                <el-button link type="danger" size="small" @click="handleDelete(child)">删除</el-button>
              </el-space>
            </div>
          </div>
          <p v-else class="empty-child">暂无子类，可点击右上角菜单新增</p>
        </div>
      </section>
    </div>

    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="480px"
      append-to-body
      :close-on-click-modal="false"
    >
      <el-form :model="form" label-width="96px">
        <el-form-item label="上级类型">
          <el-input :model-value="parentLabel" disabled />
        </el-form-item>
        <el-form-item label="类型名称" required>
          <el-input v-model="form.typeName" placeholder="如：水管漏水" maxlength="64" show-word-limit />
        </el-form-item>
        <el-form-item v-if="isTopLevelForm" label="典型关键词">
          <el-input
            v-model="form.keywords"
            type="textarea"
            :rows="3"
            maxlength="512"
            show-word-limit
            placeholder="多个关键词用中文或英文逗号分隔，如：漏水,滴水,堵塞"
          />
          <p class="form-hint">用于 AI 根据业主报修描述匹配该一级分类</p>
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="form.orderNum" :min="1" :max="999" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="handleSubmit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { computed, onMounted, ref, reactive } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  MoreFilled,
  Drizzling, Lightning, Refrigerator, House, OfficeBuilding
} from '@element-plus/icons-vue'
import { listRepairTypes, addRepairType, updateRepairType, deleteRepairType } from '@/api/repair'

const loading = ref(false)
const saving = ref(false)
const flatList = ref([])
const keyword = ref('')
const dialogVisible = ref(false)
const editTarget = ref(null)
const parentTarget = ref(null)
const form = reactive({ typeId: null, parentId: 0, typeName: '', orderNum: 1, keywords: '' })

const CATEGORY_THEMES = {
  水管问题: { icon: Drizzling, color: '#409eff', className: 'theme-water' },
  电路问题: { icon: Lightning, color: '#e6a23c', className: 'theme-electric' },
  家电问题: { icon: Refrigerator, color: '#9b59b6', className: 'theme-appliance' },
  房屋问题: { icon: House, color: '#67c23a', className: 'theme-house' },
  公共问题: { icon: OfficeBuilding, color: '#00bcd4', className: 'theme-public' }
}

const dialogTitle = computed(() => (editTarget.value ? '编辑报修类型' : '新增报修类型'))
const parentLabel = computed(() => parentTarget.value?.typeName || '顶级分类（一级）')
const isTopLevelForm = computed(() => !form.parentId || form.parentId === 0)

function categoryTheme(name) {
  return CATEGORY_THEMES[name] || { icon: House, color: '#909399', className: 'theme-default' }
}

function parseKeywords(text) {
  if (!text) return []
  return text.split(/[,，、]/).map(s => s.trim()).filter(Boolean)
}

function buildTree(list, parentId = 0) {
  return list
    .filter(item => (item.parentId || 0) === parentId)
    .sort((a, b) => (a.orderNum || 0) - (b.orderNum || 0))
    .map(item => ({ ...item, children: buildTree(list, item.typeId) }))
}

const categories = computed(() => buildTree(flatList.value))

const filteredCategories = computed(() => {
  const kw = keyword.value.trim().toLowerCase()
  if (!kw) return categories.value
  return categories.value.filter(cat => {
    const selfMatch = cat.typeName.toLowerCase().includes(kw)
      || (cat.keywords || '').toLowerCase().includes(kw)
    const childMatch = (cat.children || []).some(c => c.typeName.toLowerCase().includes(kw))
    return selfMatch || childMatch
  })
})

const statsCards = computed(() => {
  const parents = categories.value.length
  const children = flatList.value.filter(i => (i.parentId || 0) > 0).length
  const kwCount = categories.value.reduce((n, c) => n + parseKeywords(c.keywords).length, 0)
  return [
    { label: '一级分类', value: parents },
    { label: '二级分类', value: children },
    { label: '关键词总数', value: kwCount }
  ]
})

async function load() {
  loading.value = true
  try {
    const res = await listRepairTypes()
    flatList.value = Array.isArray(res.data) ? res.data : []
  } finally {
    loading.value = false
  }
}

function openCreate(parent) {
  editTarget.value = null
  parentTarget.value = parent || null
  form.typeId = null
  form.parentId = parent?.typeId || 0
  form.typeName = ''
  form.orderNum = parent ? ((parent.children?.length || 0) + 1) : (categories.value.length + 1)
  form.keywords = ''
  dialogVisible.value = true
}

function openEdit(row) {
  editTarget.value = row
  const parent = flatList.value.find(i => i.typeId === (row.parentId || 0))
  parentTarget.value = parent ? { typeName: parent.typeName } : { typeName: '顶级分类（一级）' }
  form.typeId = row.typeId
  form.parentId = row.parentId || 0
  form.typeName = row.typeName
  form.orderNum = row.orderNum || 1
  form.keywords = row.keywords || ''
  dialogVisible.value = true
}

function handleCategoryCommand(cmd, cat) {
  if (cmd === 'addChild') openCreate(cat)
  else if (cmd === 'edit') openEdit(cat)
  else if (cmd === 'delete') handleDelete(cat)
}

async function handleSubmit() {
  if (!form.typeName?.trim()) {
    ElMessage.warning('请填写类型名称')
    return
  }
  saving.value = true
  try {
    const payload = {
      typeId: form.typeId,
      parentId: form.parentId || 0,
      typeName: form.typeName.trim(),
      orderNum: form.orderNum,
      keywords: isTopLevelForm.value ? (form.keywords || '').trim() : ''
    }
    if (editTarget.value) {
      await updateRepairType(payload)
    } else {
      await addRepairType(payload)
    }
    ElMessage.success('保存成功')
    dialogVisible.value = false
    await load()
  } finally {
    saving.value = false
  }
}

async function handleDelete(row) {
  const hasChild = flatList.value.some(i => (i.parentId || 0) === row.typeId)
  if (hasChild) {
    ElMessage.warning('请先删除该分类下的子类')
    return
  }
  await ElMessageBox.confirm(`确认删除类型「${row.typeName}」吗？`, '提示', { type: 'warning' })
  await deleteRepairType(row.typeId)
  ElMessage.success('删除成功')
  await load()
}

onMounted(load)
</script>

<style scoped>
.repair-type-page {
  max-width: 1200px;
}

.page-hero {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 20px;
}

.page-title {
  margin: 0 0 6px;
  font-size: 22px;
  font-weight: 600;
  color: var(--el-text-color-primary);
}

.page-desc {
  margin: 0;
  font-size: 14px;
  line-height: 1.6;
  color: var(--el-text-color-secondary);
  max-width: 640px;
}

.stats-row {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
  margin-bottom: 16px;
}

.stat-card {
  display: flex;
  flex-direction: column;
  gap: 4px;
  padding: 14px 16px;
  border-radius: 10px;
  background: linear-gradient(135deg, var(--el-fill-color-blank) 0%, var(--el-fill-color-light) 100%);
  border: 1px solid var(--el-border-color-lighter);
}

.stat-value {
  font-size: 24px;
  font-weight: 700;
  color: var(--el-color-primary);
  line-height: 1.2;
}

.stat-label {
  font-size: 13px;
  color: var(--el-text-color-secondary);
}

.filter-bar {
  margin-bottom: 16px;
}

.category-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
  gap: 16px;
  min-height: 120px;
}

.category-card {
  border: 1px solid var(--el-border-color-lighter);
  border-radius: 12px;
  padding: 16px;
  background: var(--el-bg-color);
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.04);
  border-top: 3px solid var(--accent, #409eff);
  transition: box-shadow 0.2s;
}

.category-card:hover {
  box-shadow: 0 4px 14px rgba(0, 0, 0, 0.08);
}

.category-head {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  margin-bottom: 14px;
}

.category-icon {
  flex-shrink: 0;
  width: 44px;
  height: 44px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 10px;
  color: #fff;
}

.theme-water { background: linear-gradient(135deg, #409eff, #66b1ff); }
.theme-electric { background: linear-gradient(135deg, #e6a23c, #f3c677); }
.theme-appliance { background: linear-gradient(135deg, #9b59b6, #b07cc6); }
.theme-house { background: linear-gradient(135deg, #67c23a, #95d475); }
.theme-public { background: linear-gradient(135deg, #00bcd4, #4dd0e1); }
.theme-default { background: linear-gradient(135deg, #909399, #b1b3b8); }

.category-meta {
  flex: 1;
  min-width: 0;
}

.category-title-row {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.category-title {
  margin: 0;
  font-size: 17px;
  font-weight: 600;
}

.category-tip {
  margin: 4px 0 0;
  font-size: 12px;
  color: var(--el-text-color-secondary);
}

.block-label {
  display: block;
  margin-bottom: 8px;
  font-size: 12px;
  font-weight: 600;
  color: var(--el-text-color-secondary);
  letter-spacing: 0.02em;
}

.keyword-block {
  margin-bottom: 14px;
  padding: 10px 12px;
  border-radius: 8px;
  background: var(--el-fill-color-lighter);
}

.keyword-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.kw-tag {
  border-color: transparent;
  background: var(--el-bg-color);
}

.child-block {
  padding-top: 4px;
}

.child-list {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.child-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  padding: 8px 10px;
  border-radius: 8px;
  background: var(--el-fill-color-blank);
  border: 1px solid var(--el-border-color-extra-light);
}

.child-name {
  font-size: 14px;
  color: var(--el-text-color-primary);
}

.empty-child {
  margin: 0;
  font-size: 13px;
  color: var(--el-text-color-placeholder);
}

.form-hint {
  margin: 6px 0 0;
  font-size: 12px;
  color: var(--el-text-color-secondary);
  line-height: 1.4;
}

@media (max-width: 768px) {
  .stats-row {
    grid-template-columns: 1fr;
  }
  .page-hero {
    flex-direction: column;
  }
}
</style>
