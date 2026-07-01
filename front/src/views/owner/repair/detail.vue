<template>
  <div class="app-container">
    <el-card v-loading="loading">
      <template #header>
        <div class="header-wrap">
          <span>工单进度</span>
          <div class="header-actions">
            <el-button
              v-if="canSupplement"
              type="warning"
              size="small"
              @click="openSupplement"
            >
              补充报修
            </el-button>
            <el-button size="small" @click="$router.back()">返回</el-button>
          </div>
        </div>
      </template>

      <el-descriptions :column="2" border>
        <el-descriptions-item label="工单号">{{ order.orderNo }}</el-descriptions-item>
        <el-descriptions-item label="状态">{{ statusMap[order.status] || order.status }}</el-descriptions-item>
        <el-descriptions-item label="故障描述" :span="2">{{ order.description }}</el-descriptions-item>
        <el-descriptions-item label="紧急程度">{{ urgencyMap[order.urgency] || order.urgency }}</el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ order.createTime }}</el-descriptions-item>
      </el-descriptions>

      <template v-if="worker">
        <el-divider>维修人员</el-divider>
        <el-descriptions :column="2" border>
          <el-descriptions-item label="姓名">{{ worker.name }}</el-descriptions-item>
          <el-descriptions-item label="工号">{{ worker.workerNo }}</el-descriptions-item>
          <el-descriptions-item label="联系方式">{{ worker.virtualPhone }}</el-descriptions-item>
          <el-descriptions-item label="平均评分">{{ worker.avgScore ?? '-' }}</el-descriptions-item>
        </el-descriptions>
      </template>

      <template v-if="images.length">
        <el-divider>报修配图</el-divider>
        <div class="image-list">
          <el-image
            v-for="(img, index) in images"
            :key="index"
            :src="img.imageUrl"
            :preview-src-list="imageUrls"
            fit="cover"
            class="repair-image"
          />
        </div>
      </template>

      <el-divider>处理进度</el-divider>

      <el-timeline v-if="progressList.length > 0">
        <el-timeline-item
          v-for="(item, index) in progressList"
          :key="index"
          :timestamp="item.createTime"
          :type="index === progressList.length - 1 ? 'primary' : ''"
        >
          <div class="progress-node">
            <span class="node-name">{{ item.nodeName }}</span>
            <span class="node-operator" v-if="item.operator">操作人：{{ item.operator }}</span>
            <span class="node-remark" v-if="item.remark">{{ item.remark }}</span>
          </div>
        </el-timeline-item>
      </el-timeline>
      <el-empty v-else description="暂无进度记录" />
    </el-card>

    <el-dialog v-model="showSupplement" title="补充报修" width="560px" append-to-body>
      <el-form :model="supplementForm" label-width="80px">
        <el-form-item label="补充描述">
          <el-input
            v-model="supplementForm.description"
            type="textarea"
            :rows="4"
            placeholder="补充说明当前工单的更多信息"
          />
        </el-form-item>
        <el-form-item label="追加图片">
          <ImageUploader v-model="supplementForm.images" :max-count="9" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showSupplement = false">取消</el-button>
        <el-button type="primary" :loading="supplementing" @click="handleSupplement">
          确认补充
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount, reactive } from "vue";
import { useRoute } from "vue-router";
import { ElMessage } from "element-plus";
import { getOrderDetail, supplementRepair } from "@/api/repair";
import ImageUploader from "./components/ImageUploader.vue";

const route = useRoute();
const orderId = route.params.orderId;

const loading = ref(false);
const supplementing = ref(false);
const showSupplement = ref(false);
const order = ref({});
const progressList = ref([]);
const worker = ref(null);
const images = ref([]);
const supplementForm = reactive({
  description: "",
  images: [],
});

const imageUrls = computed(() => images.value.map((item) => item.imageUrl));
const canSupplement = computed(
  () => order.value.status === "pending" && !order.value.workerId,
);

const statusMap = {
  pending: "待分配",
  processing: "处理中",
  wait_accept: "待验收",
  completed: "已完成",
  cancelled: "已取消",
};
const urgencyMap = {
  normal: "普通",
  urgent: "较急",
  emergency: "紧急",
};

onMounted(loadDetail);

onBeforeUnmount(() => {
  window.__repairFiles = [];
});

async function loadDetail() {
  loading.value = true;
  try {
    const res = await getOrderDetail(orderId);
    order.value = res.data.order || {};
    progressList.value = res.data.progress || [];
    worker.value = res.data.worker || null;
    images.value = res.data.images || [];
  } catch (e) {
    ElMessage.error("加载工单详情失败");
  } finally {
    loading.value = false;
  }
}

function openSupplement() {
  supplementForm.description = "";
  supplementForm.images = [];
  window.__repairFiles = [];
  showSupplement.value = true;
}

async function handleSupplement() {
  if (
    !supplementForm.description?.trim() &&
    (!window.__repairFiles || window.__repairFiles.length === 0)
  ) {
    ElMessage.warning("请填写补充内容或上传图片");
    return;
  }
  supplementing.value = true;
  try {
    await supplementRepair(orderId, {
      description: supplementForm.description,
      files: window.__repairFiles || [],
    });
    ElMessage.success("补充成功");
    showSupplement.value = false;
    await loadDetail();
  } finally {
    supplementing.value = false;
  }
}
</script>

<style scoped>
.header-wrap {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.header-actions {
  display: flex;
  gap: 8px;
}
.progress-node {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.node-name {
  font-weight: 600;
  font-size: 14px;
}
.node-operator {
  font-size: 12px;
  color: #909399;
}
.node-remark {
  font-size: 13px;
  color: #606266;
}
.image-list {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}
.repair-image {
  width: 120px;
  height: 120px;
  border-radius: 6px;
}
</style>
