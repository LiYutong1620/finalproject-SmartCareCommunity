<template>
  <NoticeDetailDrawer
    v-model:visible="visible"
    :notice-id="noticeId"
    notice-type="outage"
  />
</template>

<script setup>
import { ref, watch, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import NoticeDetailDrawer from '../notice/components/NoticeDetailDrawer.vue'

const route = useRoute()
const router = useRouter()
const noticeId = route.params.id
const visible = ref(false)

onMounted(() => {
  visible.value = true
})

watch(visible, val => {
  if (!val) router.replace('/owner/outage')
})
</script>
