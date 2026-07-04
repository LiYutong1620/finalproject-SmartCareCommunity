<template>
  <PropertyRepairDetailDrawer
    :model-value="true"
    :order-id="route.params.orderId"
    @update:model-value="goBack"
    @changed="() => {}"
  />
</template>

<script setup>
import { useRoute, useRouter } from 'vue-router'
import PropertyRepairDetailDrawer from './components/PropertyRepairDetailDrawer.vue'

const route = useRoute()
const router = useRouter()

function goBack() {
  router.push('/property/repair')
}
</script>
