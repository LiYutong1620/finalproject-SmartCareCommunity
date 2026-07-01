<template>
  <div class="app-container">
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="showAdd = true">
          提交报修
        </el-button>
      </el-col>
    </el-row>

    <el-card shadow="never" class="table-card">
      <el-table :data="list" v-loading="loading" border stripe>
        <el-table-column type="index" label="序号" width="60" align="center" />
        <el-table-column prop="orderNo" label="工单号" width="180" />
        <el-table-column
          prop="description"
          label="描述"
          min-width="200"
          show-overflow-tooltip
        />
        <el-table-column prop="status" label="状态" width="100" align="center">
          <template #default="{ row }">
            {{ statusMap[row.status] || row.status }}
          </template>
        </el-table-column>
        <el-table-column prop="urgency" label="紧急程度" width="90" align="center">
          <template #default="{ row }">
            {{ urgencyMap[row.urgency] || row.urgency }}
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="170" align="center" />
        <el-table-column label="操作" width="320" align="center" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" @click="goDetail(row)">进度</el-button>
            <el-button
              v-if="row.status === 'pending' && !row.workerId"
              link
              type="warning"
              @click="openSupplement(row)"
            >
              补充
            </el-button>
            <el-button
              v-if="row.status === 'pending' && !row.workerId"
              link
              type="danger"
              @click="handleCancel(row)"
            >
              撤销
            </el-button>
            <el-button
              v-if="!['completed', 'cancelled'].includes(row.status)"
              link
              type="primary"
              @click="handleUrge(row)"
            >
              催单
            </el-button>
            <el-button
              v-if="row.status === 'wait_accept'"
              link
              type="success"
              @click="goAccept(row)"
            >
              去验收
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <Pagination
        v-show="total > 0"
        :total="total"
        v-model:page="query.pageNum"
        v-model:limit="query.pageSize"
        @pagination="load"
      />
    </el-card>

    <el-dialog
      v-model="showAdd"
      title="提交报修"
      width="580px"
      append-to-body
      @closed="onSubmitDialogClosed"
    >
      <el-form :model="submitForm" label-width="80px">
        <el-form-item label="故障描述">
          <div class="desc-field">
            <el-input
              v-model="submitForm.description"
              type="textarea"
              :rows="4"
              placeholder="请描述故障情况，或点击麦克风语音输入"
            />
            <el-button
              class="voice-btn"
              :type="listening ? 'danger' : 'default'"
              circle
              :title="listening ? '停止录音' : '语音输入'"
              @click="toggleVoice"
            >
              <el-icon><Microphone /></el-icon>
            </el-button>
          </div>
          <div v-if="listening" class="voice-tip">正在聆听，请说话…</div>
        </el-form-item>
        <el-form-item label="紧急程度">
          <el-select v-model="submitForm.urgency" style="width: 100%">
            <el-option label="普通" value="normal" />
            <el-option label="较急" value="urgent" />
            <el-option label="紧急" value="emergency" />
          </el-select>
        </el-form-item>
        <el-form-item label="现场图片">
          <ImageUploader v-model="submitForm.images" :max-count="9" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showAdd = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">
          提交
        </el-button>
      </template>
    </el-dialog>

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
import { ref, reactive, onMounted, onBeforeUnmount, toRef } from "vue";
import { useRouter } from "vue-router";
import { ElMessage, ElMessageBox } from "element-plus";
import { Microphone } from "@element-plus/icons-vue";
import {
  listOwnerRepair,
  submitRepairWithImages,
  supplementRepair,
  cancelRepair,
  urgeRepair,
} from "@/api/repair";
import { useSpeechInput } from "@/composables/useSpeechInput";
import ImageUploader from "./components/ImageUploader.vue";

const router = useRouter();

const loading = ref(false);
const submitting = ref(false);
const supplementing = ref(false);
const list = ref([]);
const total = ref(0);
const showAdd = ref(false);
const showSupplement = ref(false);
const currentSupplementOrderId = ref(null);
const query = reactive({ pageNum: 1, pageSize: 10 });
const submitForm = reactive({
  description: "",
  urgency: "normal",
  images: [],
  houseId: null,
  typeId: null,
});
const supplementForm = reactive({
  description: "",
  images: [],
});

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

const { listening, toggleVoice, stopVoice, initSpeech } = useSpeechInput(
  toRef(submitForm, "description"),
  {
    successMessage: "语音已填入描述框，请核对后提交",
  },
);

onMounted(() => {
  initSpeech();
  load();
});

onBeforeUnmount(() => {
  stopVoice();
  window.__repairFiles = [];
});

async function load() {
  loading.value = true;
  try {
    const res = await listOwnerRepair(query);
    list.value = res.data.rows || [];
    total.value = res.data.total || 0;
  } finally {
    loading.value = false;
  }
}

function goDetail(row) {
  router.push(`/owner/repair/detail/${row.orderId}`);
}

function goAccept(row) {
  router.push(`/owner/repair/accept/${row.orderId}`);
}

function openSupplement(row) {
  currentSupplementOrderId.value = row.orderId;
  supplementForm.description = "";
  supplementForm.images = [];
  window.__repairFiles = [];
  showSupplement.value = true;
}

function onSubmitDialogClosed() {
  stopVoice();
  submitForm.description = "";
  submitForm.urgency = "normal";
  submitForm.images = [];
  submitForm.houseId = null;
  submitForm.typeId = null;
  window.__repairFiles = [];
}

async function handleSubmit() {
  if (!submitForm.description?.trim()) {
    ElMessage.warning("请填写故障描述");
    return;
  }
  submitting.value = true;
  try {
    await submitRepairWithImages({
      description: submitForm.description,
      urgency: submitForm.urgency,
      houseId: submitForm.houseId,
      typeId: submitForm.typeId,
      files: window.__repairFiles || [],
    });
    ElMessage.success("提交成功，待分配状态下可点击「补充」追加描述或图片");
    showAdd.value = false;
    query.pageNum = 1;
    await load();
  } finally {
    submitting.value = false;
  }
}

async function handleSupplement() {
  if (!currentSupplementOrderId.value) {
    return;
  }
  if (!supplementForm.description?.trim() && (!window.__repairFiles || window.__repairFiles.length === 0)) {
    ElMessage.warning("请填写补充内容或上传图片");
    return;
  }
  supplementing.value = true;
  try {
    await supplementRepair(currentSupplementOrderId.value, {
      description: supplementForm.description,
      files: window.__repairFiles || [],
    });
    ElMessage.success("补充成功");
    showSupplement.value = false;
    await load();
  } finally {
    supplementing.value = false;
  }
}

async function handleCancel(row) {
  await ElMessageBox.confirm("确认撤销该报修？", "提示", { type: "warning" });
  await cancelRepair(row.orderId);
  ElMessage.success("已撤销");
  await load();
}

async function handleUrge(row) {
  await urgeRepair(row.orderId);
  ElMessage.success("催单成功");
  await load();
}
</script>

<style scoped>
.desc-field {
  display: flex;
  gap: 8px;
  width: 100%;
  align-items: flex-start;
}
.desc-field .el-textarea {
  flex: 1;
}
.voice-btn {
  flex-shrink: 0;
  margin-top: 4px;
}
.voice-tip {
  margin-top: 6px;
  font-size: 12px;
  color: #e6a23c;
}
</style>
