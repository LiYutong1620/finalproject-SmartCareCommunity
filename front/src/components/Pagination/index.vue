<template>
  <div v-show="total > 0" class="pagination-container">
    <el-pagination
      v-model:current-page="currentPage"
      v-model:page-size="pageSize"
      :background="background"
      :layout="layout"
      :page-sizes="pageSizes"
      :pager-count="pagerCount"
      :total="total"
      @size-change="handleSizeChange"
      @current-change="handleCurrentChange"
    />
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  total: { type: Number, default: 0 },
  page: { type: Number, default: 1 },
  limit: { type: Number, default: 10 },
  pageSizes: { type: Array, default: () => [10, 20, 30, 50] },
  layout: { type: String, default: 'total, sizes, prev, pager, next, jumper' },
  background: { type: Boolean, default: true },
  pagerCount: { type: Number, default: 7 }
})

const emit = defineEmits(['update:page', 'update:limit', 'pagination'])

const currentPage = computed({
  get: () => props.page,
  set: (val) => emit('update:page', val)
})

const pageSize = computed({
  get: () => props.limit,
  set: (val) => emit('update:limit', val)
})

function handleSizeChange(val) {
  emit('update:limit', val)
  emit('update:page', 1)
  emit('pagination', { page: 1, limit: val })
}

function handleCurrentChange(val) {
  emit('update:page', val)
  emit('pagination', { page: val, limit: props.limit })
}
</script>
