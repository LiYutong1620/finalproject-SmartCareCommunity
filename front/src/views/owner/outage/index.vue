<template>
  <OwnerNoticeList
    notice-type="outage"
    page-title="停水停电"
    page-desc="查看停水、停电、停气等检修通知"
    empty-text="暂无停水停电通知"
  />
</template>

<script setup>
import OwnerNoticeList from '../notice/components/OwnerNoticeList.vue'
</script>
