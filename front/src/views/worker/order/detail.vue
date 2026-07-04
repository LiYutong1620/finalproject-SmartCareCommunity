<template>
  <WorkerOrderDrawer
    v-model:visible="visible"
    :order-id="orderId"
    :show-actions="false"
  />
</template>

<script setup>
import { ref, watch, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import WorkerOrderDrawer from './components/WorkerOrderDrawer.vue'

const route = useRoute()
const router = useRouter()
const orderId = route.params.orderId
const visible = ref(false)

onMounted(() => {
  visible.value = true
})

watch(visible, val => {
  if (!val) router.replace('/worker/order/todo')
})
</script>
