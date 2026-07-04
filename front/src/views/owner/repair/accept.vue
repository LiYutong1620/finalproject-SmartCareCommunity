<template>
  <RepairAcceptDrawer
    v-model:visible="visible"
    :order-id="orderId"
    @success="goBack"
  />
</template>

<script setup>
import { ref, watch, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import RepairAcceptDrawer from './components/RepairAcceptDrawer.vue'

const route = useRoute()
const router = useRouter()
const orderId = route.params.orderId
const visible = ref(false)

onMounted(() => {
  visible.value = true
})

watch(visible, val => {
  if (!val) goBack()
})

function goBack() {
  router.replace('/owner/repair')
}
</script>
