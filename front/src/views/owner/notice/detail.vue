<template>
  <div class="app-container">
    <el-card v-loading="loading" shadow="never">
      <template #header>
        <div class="detail-header">
          <span class="detail-title">{{ detail.title || '公告详情' }}</span>
          <el-button icon="Back" @click="goBack">返回</el-button>
        </div>
      </template>
      <el-descriptions :column="1" border>
        <el-descriptions-item label="发布时间">{{ detail.createTime || '-' }}</el-descriptions-item>
        <el-descriptions-item v-if="detail.scope" label="影响范围">{{ detail.scope }}</el-descriptions-item>
        <el-descriptions-item v-if="detail.restoreTime" label="预计恢复">{{ detail.restoreTime }}</el-descriptions-item>
        <el-descriptions-item v-if="detail.attachment" label="附件">
          <a :href="detail.attachment" target="_blank" rel="noopener">{{ detail.attachment }}</a>
        </el-descriptions-item>
        <el-descriptions-item label="正文">
          <div class="content-body">{{ detail.content }}</div>
        </el-descriptions-item>
      </el-descriptions>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getNoticeDetail } from '@/api/owner'

const props = defineProps({
  backPath: { type: String, default: '/owner/notice' }
})

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const detail = ref({})

async function loadDetail() {
  loading.value = true
  try {
    detail.value = (await getNoticeDetail(route.params.id)).data
  } finally { loading.value = false }
}

function goBack() {
  router.push(props.backPath)
}

onMounted(loadDetail)
</script>

<style scoped>
.detail-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.detail-title {
  font-size: 16px;
  font-weight: 600;
}
.content-body {
  white-space: pre-wrap;
  line-height: 1.8;
  color: #303133;
}
</style>
