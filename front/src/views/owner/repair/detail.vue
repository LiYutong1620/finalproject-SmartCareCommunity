<template>
  <RepairOrderDrawer
    v-model:visible="visible"
    :order-id="orderId"
    @edit="goBack"
    @append="goBack"
    @accept="openAccept"
    @cancel="goBack"
  />
  <RepairAcceptDrawer
    v-model:visible="acceptVisible"
    :order-id="acceptOrderId"
    @success="goBack"
  />
</template>

<script setup>
import { ref, watch, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import RepairOrderDrawer from './components/RepairOrderDrawer.vue'
import RepairAcceptDrawer from './components/RepairAcceptDrawer.vue'

const route = useRoute()
const router = useRouter()
const orderId = route.params.orderId
const visible = ref(false)
const acceptVisible = ref(false)
const acceptOrderId = ref(null)

onMounted(() => {
  visible.value = true
})

watch(visible, val => {
  if (!val && !acceptVisible.value) goBack()
})

function goBack() {
  router.replace('/owner/repair')
}

function openAccept(order) {
  visible.value = false
  acceptOrderId.value = order.orderId
  acceptVisible.value = true
}
</script>
