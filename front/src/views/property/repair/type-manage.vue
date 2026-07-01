<template>
  <el-card>
    <template #header>
      <div class="header-wrap">
        <span>报修类型管理</span>
        <el-button type="primary" @click="openCreate(null)">新增一级类型</el-button>
      </div>
    </template>

    <el-tree
      :data="treeData"
      node-key="typeId"
      :props="treeProps"
      default-expand-all
      :expand-on-click-node="false"
    >
      <template #default="{ data }">
        <div class="tree-node">
          <span>{{ data.typeName }}</span>
          <el-space>
            <el-button link type="primary" @click.stop="openCreate(data)">新增子类</el-button>
            <el-button link type="warning" @click.stop="openEdit(data)">编辑</el-button>
            <el-button link type="danger" @click.stop="handleDelete(data)">删除</el-button>
          </el-space>
        </div>
      </template>
    </el-tree>

    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="420px">
      <el-form :model="form" label-width="90px">
        <el-form-item label="上级类型">
          <el-input :model-value="parentLabel" disabled />
        </el-form-item>
        <el-form-item label="类型名称">
          <el-input v-model="form.typeName" />
        </el-form-item>
        <el-form-item label="排序">
          <el-input-number v-model="form.orderNum" :min="1" :max="999" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">保存</el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup>
import { computed, onMounted, ref, reactive } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { listRepairTypes, addRepairType, updateRepairType, deleteRepairType } from '@/api/repair'

const treeData = ref([])
const dialogVisible = ref(false)
const editTarget = ref(null)
const parentTarget = ref(null)
const form = reactive({ typeId: null, parentId: 0, typeName: '', orderNum: 1 })
const treeProps = { children: 'children', label: 'typeName' }

const dialogTitle = computed(() => (editTarget.value ? '编辑报修类型' : '新增报修类型'))
const parentLabel = computed(() => parentTarget.value?.typeName || '顶级分类')

function buildTree(list, parentId = 0) {
  return list
    .filter((item) => (item.parentId || 0) === parentId)
    .sort((a, b) => (a.orderNum || 0) - (b.orderNum || 0))
    .map((item) => ({ ...item, children: buildTree(list, item.typeId) }))
}

async function load() {
  const res = await listRepairTypes()
  const flat = Array.isArray(res.data) ? res.data : []
  treeData.value = buildTree(flat)
}

function openCreate(parent) {
  editTarget.value = null
  parentTarget.value = parent || null
  form.typeId = null
  form.parentId = parent?.typeId || 0
  form.typeName = ''
  form.orderNum = 1
  dialogVisible.value = true
}

function openEdit(row) {
  editTarget.value = row
  parentTarget.value = { typeName: row.parentId ? `上级ID：${row.parentId}` : '顶级分类' }
  form.typeId = row.typeId
  form.parentId = row.parentId || 0
  form.typeName = row.typeName
  form.orderNum = row.orderNum || 1
  dialogVisible.value = true
}

async function handleSubmit() {
  const payload = { ...form }
  if (editTarget.value) {
    await updateRepairType(payload)
  } else {
    await addRepairType(payload)
  }
  ElMessage.success('保存成功')
  dialogVisible.value = false
  await load()
}

async function handleDelete(row) {
  await ElMessageBox.confirm(`确认删除类型「${row.typeName}」吗？`, '提示', { type: 'warning' })
  await deleteRepairType(row.typeId)
  ElMessage.success('删除成功')
  await load()
}

onMounted(load)
</script>

<style scoped>
.header-wrap {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.tree-node {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
  padding-right: 12px;
}
</style>
