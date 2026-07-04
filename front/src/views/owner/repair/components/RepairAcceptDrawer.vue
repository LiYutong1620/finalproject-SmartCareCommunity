<template>
  <el-drawer
    :model-value="visible"
    title="工单验收"
    direction="rtl"
    size="520px"
    destroy-on-close
    @update:model-value="emit('update:visible', $event)"
    @closed="handleClosed"
  >
    <div v-loading="loading" class="accept-body">
      <template v-if="order.orderId">
        <section class="info-block">
          <h4>工单信息</h4>
          <dl class="meta-list">
            <div class="meta-row">
              <dt>状态</dt>
              <dd>{{ repairStatusLabel(order.status) }}</dd>
            </div>
            <div class="meta-row">
              <dt>报修时间</dt>
              <dd>{{ order.createTime || '—' }}</dd>
            </div>
            <div class="meta-row">
              <dt>维修完成时间</dt>
              <dd>{{ order.repairCompleteTime || '—' }}</dd>
            </div>
            <div class="meta-row desc-row">
              <dt>故障描述</dt>
              <dd>{{ order.description || '—' }}</dd>
            </div>
          </dl>
        </section>

        <section class="info-block">
          <h4>维修评价</h4>
          <OrderEvaluate v-model="evaluateData" />
        </section>

        <section class="info-block">
          <h4>签名确认</h4>
          <SignatureBoard @confirm="onSignatureConfirm" />
          <p v-if="signImage" class="sign-tip">签名已确认</p>
        </section>
      </template>
    </div>

    <template v-if="order.orderId" #footer>
      <div class="drawer-footer">
        <el-button @click="emit('update:visible', false)">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">确认验收</el-button>
      </div>
    </template>
  </el-drawer>
</template>

<script setup>
import { ref, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { getOrderDetail, ownerAccept } from '@/api/repair'
import { repairStatusLabel } from '@/utils/repairLabels'
import SignatureBoard from './SignatureBoard.vue'
import OrderEvaluate from './OrderEvaluate.vue'

const props = defineProps({
  visible: { type: Boolean, default: false },
  orderId: { type: [Number, String], default: null }
})

const emit = defineEmits(['update:visible', 'success'])

const loading = ref(false)
const submitting = ref(false)
const order = ref({})
const evaluateData = ref({ score: 5, tags: [], content: '' })
const signImage = ref('')

watch(
  () => [props.visible, props.orderId],
  ([vis, id]) => {
    if (vis && id) loadDetail(id)
  },
  { immediate: true }
)

async function loadDetail(orderId) {
  loading.value = true
  try {
    const res = await getOrderDetail(orderId)
    order.value = res.data.order || {}
    if (order.value.status !== 'wait_accept') {
      ElMessage.warning('当前工单不可验收')
      emit('update:visible', false)
    }
  } catch {
    ElMessage.error('加载工单详情失败')
    emit('update:visible', false)
  } finally {
    loading.value = false
  }
}

function onSignatureConfirm(base64) {
  signImage.value = base64
  ElMessage.success('签名已确认')
}

async function handleSubmit() {
  if (!signImage.value) {
    ElMessage.warning('请先签名')
    return
  }
  submitting.value = true
  try {
    await ownerAccept(props.orderId, {
      signImage: signImage.value,
      score: evaluateData.value.score,
      tags: evaluateData.value.tags.join(','),
      content: evaluateData.value.content
    })
    ElMessage.success('验收成功')
    emit('update:visible', false)
    emit('success')
  } catch {
    // 错误已由 request 拦截器提示
  } finally {
    submitting.value = false
  }
}

function handleClosed() {
  order.value = {}
  evaluateData.value = { score: 5, tags: [], content: '' }
  signImage.value = ''
}
</script>

<style scoped>
.accept-body {
  min-height: 200px;
  padding-bottom: 16px;
}

.info-block {
  margin-bottom: 24px;
}

.info-block h4 {
  margin: 0 0 12px;
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}

.meta-list {
  margin: 0;
  padding: 12px 14px;
  background: #fafbfc;
  border-radius: 10px;
  border: 1px solid #ebeef5;
}

.meta-row {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  padding: 8px 0;
  border-bottom: 1px solid #f0f2f5;
  font-size: 13px;
}

.meta-row:last-child {
  border-bottom: none;
}

.meta-row.desc-row {
  flex-direction: column;
  align-items: flex-start;
}

.meta-row dt {
  color: #909399;
  margin: 0;
  flex-shrink: 0;
}

.meta-row dd {
  margin: 0;
  color: #303133;
  line-height: 1.5;
  word-break: break-word;
}

.sign-tip {
  margin: 8px 0 0;
  font-size: 12px;
  color: #67c23a;
}

.drawer-footer {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}
</style>
