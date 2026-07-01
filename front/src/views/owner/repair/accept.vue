<template>
  <div class="app-container">
    <el-card v-loading="loading">
      <template #header>
        <span>工单验收</span>
      </template>

      <el-descriptions :column="2" border>
        <el-descriptions-item label="工单号">{{ order.orderNo }}</el-descriptions-item>
        <el-descriptions-item label="状态">{{ statusMap[order.status] || order.status }}</el-descriptions-item>
        <el-descriptions-item label="故障描述" :span="2">{{ order.description }}</el-descriptions-item>
        <el-descriptions-item label="紧急程度">{{ urgencyMap[order.urgency] || order.urgency }}</el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ order.createTime }}</el-descriptions-item>
      </el-descriptions>

      <el-divider>维修评价</el-divider>

      <el-form label-width="80px">
        <OrderEvaluate v-model="evaluateData" />

        <el-form-item label="签名确认">
          <SignatureBoard @confirm="onSignatureConfirm" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="submitting" @click="handleSubmit">确认验收</el-button>
          <el-button @click="$router.back()">返回</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import { getOrderDetail, ownerAccept, submitEvaluate } from "@/api/repair";
import SignatureBoard from "./components/SignatureBoard.vue";
import OrderEvaluate from "./components/OrderEvaluate.vue";

const route = useRoute();
const router = useRouter();
const orderId = route.params.orderId;

const loading = ref(false);
const submitting = ref(false);
const order = ref({});
const evaluateData = ref({ score: 5, tags: [], content: "" });
const signImage = ref("");

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

onMounted(async () => {
  loading.value = true;
  try {
    const res = await getOrderDetail(orderId);
    order.value = res.data.order || {};
  } catch (e) {
    ElMessage.error("加载工单详情失败");
  } finally {
    loading.value = false;
  }
});

function onSignatureConfirm(base64) {
  signImage.value = base64;
  ElMessage.success("签名已确认");
}

async function handleSubmit() {
  if (!signImage.value) {
    ElMessage.warning("请先签名");
    return;
  }
  submitting.value = true;
  try {
    await ownerAccept(orderId, {
      signImage: signImage.value,
      score: evaluateData.value.score,
      tags: evaluateData.value.tags.join(","),
    });
    await submitEvaluate({
      orderId,
      score: evaluateData.value.score,
      tags: evaluateData.value.tags.join(","),
      content: evaluateData.value.content,
    });
    ElMessage.success("验收成功");
    router.push("/owner/repair");
  } finally {
    submitting.value = false;
  }
}
</script>
