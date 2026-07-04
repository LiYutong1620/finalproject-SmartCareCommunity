<template>
  <div class="task-layout app-container">
    <div class="page-header">
      <h2 class="page-title">{{ pageTitle }}</h2>
    </div>

    <router-view v-slot="{ Component }">
      <component :is="Component" ref="listRef" />
    </router-view>
  </div>
</template>

<script setup>
import { ref, computed, provide, onMounted, watch, nextTick } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const listRef = ref(null)
const pendingOrderId = ref(null)

const pageTitle = computed(() => route.meta.title || '任务中心')

provide('taskCenter', {
  pendingOrderId,
  refreshUnread() {
    listRef.value?.refreshUnread?.()
  },
  openOrder(orderId) {
    pendingOrderId.value = orderId
    listRef.value?.openOrderById?.(orderId)
  }
})

onMounted(async () => {
  if (route.query.orderId) {
    await nextTick()
    listRef.value?.openOrderById?.(route.query.orderId)
  }
})

watch(
  () => route.query.orderId,
  async id => {
    if (id) {
      await nextTick()
      listRef.value?.openOrderById?.(id)
    }
  }
)
</script>

<style scoped>
.task-layout {
  max-width: 1100px;
}

.page-header {
  margin-bottom: 16px;
}

.page-title {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
  color: #1a1a2e;
}
</style>
