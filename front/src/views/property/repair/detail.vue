<template>
  <el-card v-loading="loading">
    <template #header>
      <div class="header-wrap">
        <span>工单详情</span>
        <el-space>
          <el-button size="small" @click="$router.back()">返回</el-button>
        </el-space>
      </div>
    </template>

    <el-descriptions v-if="detail" :column="2" border>
      <el-descriptions-item label="工单号">{{ detail.orderNo }}</el-descriptions-item>
      <el-descriptions-item label="状态">{{ statusMap[detail.status] || detail.status }}</el-descriptions-item>
      <el-descriptions-item label="故障描述" :span="2">{{ detail.description }}</el-descriptions-item>
      <el-descriptions-item label="紧急程度">{{ urgencyMap[detail.urgency] || detail.urgency }}</el-descriptions-item>
      <el-descriptions-item label="业主ID">{{ detail.ownerId }}</el-descriptions-item>
      <el-descriptions-item label="维修工ID">{{ detail.workerId || '-' }}</el-descriptions-item>
      <el-descriptions-item label="签名凭证" :span="2">
        <el-image
          v-if="detail.signImage"
          :src="detail.signImage"
          style="width: 180px; height: 90px"
          fit="contain"
          :preview-src-list="[detail.signImage]"
        />
        <span v-else>-</span>
      </el-descriptions-item>
    </el-descriptions>

    <el-divider>操作时间轴</el-divider>
    <el-timeline v-if="progressList.length">
      <el-timeline-item
        v-for="(item, index) in progressList"
        :key="index"
        :timestamp="item.createTime"
        :type="index === progressList.length - 1 ? 'primary' : ''"
      >
        <div class="progress-node">
          <div class="node-name">{{ item.nodeName }}</div>
          <div class="node-operator" v-if="item.operator">操作人：{{ item.operator }}</div>
          <div class="node-remark" v-if="item.remark">{{ item.remark }}</div>
        </div>
      </el-timeline-item>
    </el-timeline>
    <el-empty v-else description="暂无进度记录" />
  </el-card>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getPropertyRepairDetail } from '@/api/repair'

const route = useRoute()
const loading = ref(false)
const detail = ref(null)
const progressList = ref([])
const statusMap = {
  pending: '待分配',
  processing: '处理中',
  wait_accept: '待验收',
  completed: '已完成',
  cancelled: '已取消'
}
const urgencyMap = {
  normal: '普通',
  urgent: '较急',
  emergency: '紧急'
}

async function load() {
  loading.value = true
  try {
    const res = await getPropertyRepairDetail(route.params.orderId)
    detail.value = res.data.order || res.data
    progressList.value = res.data.progress || []
  } catch (e) {
    ElMessage.error('加载工单详情失败')
  } finally {
    loading.value = false
  }
}

onMounted(load)
</script>

<style scoped>
.header-wrap {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.progress-node {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.node-name {
  font-weight: 600;
}
.node-operator,
.node-remark {
  color: #606266;
  font-size: 13px;
}
</style>
