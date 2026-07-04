<template>
  <div class="eval-list-wrap">
    <div
      v-for="item in items"
      :key="item.orderId + '-' + item.createTime"
      class="eval-item"
      :class="'type-' + item.type"
      @click="emit('select', item.orderId)"
    >
      <div class="eval-head">
        <span class="eval-order">{{ formatOrderNo(item.orderNo) }}</span>
        <el-rate :model-value="item.score || 0" disabled size="small" />
      </div>
      <div v-if="tagList(item.tags).length" class="eval-tags">
        <el-tag v-for="tag in tagList(item.tags)" :key="tag" size="small" effect="plain" round>{{ tag }}</el-tag>
      </div>
      <p v-if="item.content" class="eval-text">{{ item.content }}</p>
      <p v-else class="eval-text muted">未填写文字评价</p>
      <span class="eval-time">{{ item.createTime }}</span>
    </div>
    <el-empty v-if="!items.length" :description="emptyText" :image-size="64" />
  </div>
</template>

<script setup>
import { formatOrderNo } from '@/utils/orderFormat'

defineProps({
  items: { type: Array, default: () => [] },
  emptyText: { type: String, default: '暂无评价' }
})

const emit = defineEmits(['select'])

function tagList(tags) {
  if (!tags) return []
  return tags.split(/[,，]/).map(t => t.trim()).filter(Boolean)
}
</script>

<style scoped>
.eval-list-wrap {
  max-height: calc(100vh - 320px);
  overflow-y: auto;
  padding-right: 4px;
}

.eval-item {
  padding: 12px 14px;
  margin-bottom: 10px;
  border-radius: 10px;
  border: 1px solid #eef2f6;
  background: #fafbfc;
  cursor: pointer;
  transition: background 0.2s, box-shadow 0.2s;
}

.eval-item:hover {
  background: #f5f9ff;
  box-shadow: 0 2px 8px rgba(72, 152, 202, 0.08);
}

.eval-item.type-good {
  border-left: 3px solid #52c41a;
}

.eval-item.type-bad {
  border-left: 3px solid #ff4d4f;
}

.eval-item.type-neutral {
  border-left: 3px solid #faad14;
}

.eval-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}

.eval-order {
  font-size: 13px;
  font-weight: 600;
  color: #345568;
}

.eval-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  margin-top: 8px;
}

.eval-text {
  margin: 8px 0 0;
  font-size: 13px;
  line-height: 1.55;
  color: #606266;
}

.eval-text.muted {
  color: #909399;
}

.eval-time {
  display: block;
  margin-top: 8px;
  font-size: 11px;
  color: #909399;
}
</style>
