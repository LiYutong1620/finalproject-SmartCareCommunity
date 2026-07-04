<template>
  <el-dialog
    v-model="visible"
    class="worker-reject-dialog"
    title="拒单"
    width="480px"
    append-to-body
    destroy-on-close
    @closed="resetForm"
  >
    <el-form label-width="88px" class="reject-form">
      <el-form-item label="拒单原因" required>
        <el-select
          v-model="rejectReason"
          placeholder="请选择拒单原因"
          teleported
          popper-class="worker-reject-select-popper"
          style="width: 100%"
        >
          <el-option label="技能不匹配" value="技能不匹配" />
          <el-option label="当前工单已满" value="当前工单已满" />
          <el-option label="距离太远" value="距离太远" />
          <el-option label="设备不足" value="设备不足" />
          <el-option label="其他原因" value="其他原因" />
        </el-select>
      </el-form-item>
      <el-form-item label="补充说明" required>
        <el-input
          v-model="rejectRemark"
          type="textarea"
          :rows="4"
          maxlength="200"
          show-word-limit
          placeholder="请详细说明拒单情况，便于物业审核与重新派单"
        />
      </el-form-item>
    </el-form>
    <template #footer>
      <el-button @click="visible = false">取消</el-button>
      <el-button type="primary" :loading="submitting" @click="handleSubmit">确认拒单</el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import { rejectOrder } from '@/api/repair'

const visible = defineModel({ type: Boolean, default: false })

const props = defineProps({
  order: { type: Object, default: null }
})

const emit = defineEmits(['success'])

const rejectReason = ref('')
const rejectRemark = ref('')
const submitting = ref(false)

function resetForm() {
  rejectReason.value = ''
  rejectRemark.value = ''
}

async function handleSubmit() {
  if (!rejectReason.value) {
    ElMessage.warning('请选择拒单原因')
    return
  }
  if (!rejectRemark.value?.trim()) {
    ElMessage.warning('请填写拒单补充说明')
    return
  }
  const orderId = props.order?.orderId
  if (!orderId) {
    ElMessage.error('工单信息丢失，请关闭后重试')
    return
  }
  submitting.value = true
  try {
    await rejectOrder(orderId, {
      reason: rejectReason.value,
      remark: rejectRemark.value.trim()
    })
    ElMessage.success('已拒单')
    visible.value = false
    emit('success')
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped>
.reject-form :deep(.el-form-item) {
  margin-bottom: 18px;
}
</style>

<style>
.worker-reject-dialog .el-dialog__body {
  overflow: visible;
}

.worker-reject-select-popper {
  z-index: 6000 !important;
}
</style>
