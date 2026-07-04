<template>

  <el-drawer

    :model-value="visible"

    title="工单详情"

    direction="rtl"

    size="480px"

    destroy-on-close

    @update:model-value="emit('update:visible', $event)"

    @closed="handleClosed"

  >

    <div v-loading="loading" class="repair-detail-body">

      <template v-if="order.orderId">

        <header class="repair-detail-header">

          <span class="order-no">{{ formatOrderNo(order.orderNo) }}</span>

          <div class="header-tags">

            <el-tag

              :type="repairStatusTagType(order.status) || undefined"

              :class="repairStatusTagClass(order.status)"

              size="small"

              effect="plain"

              round

            >

              {{ repairStatusLabel(order.status) }}

            </el-tag>

            <el-tag v-if="order.aiTypeLabel" type="info" size="small" effect="plain" round>

              {{ order.aiTypeLabel }}

            </el-tag>

          </div>

        </header>



        <section class="repair-detail-section">

          <h4>故障信息</h4>

          <p class="repair-detail-desc">{{ order.description || '—' }}</p>

          <dl class="repair-detail-panel">

            <div class="repair-detail-row">

              <dt>报修时间</dt>

              <dd>{{ formatDateTime(order.createTime) }}</dd>

            </div>

            <div v-if="order.expectedTime" class="repair-detail-row">

              <dt>期望时间</dt>

              <dd>{{ formatDateTime(order.expectedTime) }}</dd>

            </div>

            <div v-if="order.status === 'completed'" class="repair-detail-row">

              <dt>完成时间</dt>

              <dd>{{ formatDateTime(order.repairCompleteTime) }}</dd>

            </div>

          </dl>

        </section>



        <section v-if="worker" class="repair-detail-section">

          <h4>维修人员</h4>

          <dl class="repair-detail-panel">

            <div class="repair-detail-row">

              <dt>姓名</dt>

              <dd>{{ worker.name || '—' }}</dd>

            </div>

            <div class="repair-detail-row">

              <dt>工号</dt>

              <dd>{{ worker.workerNo || '—' }}</dd>

            </div>

            <div class="repair-detail-row">

              <dt>联系方式</dt>

              <dd>{{ worker.virtualPhone || '—' }}</dd>

            </div>

          </dl>

        </section>



        <section v-if="images.length" class="repair-detail-section">

          <h4>报修配图</h4>

          <div class="repair-detail-images">

            <el-image

              v-for="(img, index) in images"

              :key="index"

              :src="resolveUrl(img.imageUrl)"

              :preview-src-list="imageUrls"

              fit="cover"

            />

          </div>

        </section>



        <section class="repair-detail-section repair-detail-timeline">

          <h4>处理进度</h4>

          <el-timeline v-if="progressList.length">

            <el-timeline-item

              v-for="(item, index) in progressList"

              :key="index"

              :timestamp="formatDateTime(item.createTime)"

              :type="index === progressList.length - 1 ? 'primary' : undefined"

            >

              <div class="progress-node">

                <span class="node-name">{{ item.nodeName }}</span>

                <span v-if="item.operator" class="node-operator">操作人：{{ item.operator }}</span>

                <span v-if="item.remark" class="node-remark">{{ item.remark }}</span>

              </div>

            </el-timeline-item>

          </el-timeline>

          <el-empty v-else description="暂无进度记录" :image-size="64" />

        </section>

      </template>

    </div>



    <template v-if="order.orderId" #footer>

      <div class="repair-detail-footer">

        <el-button v-if="canEditOrder(order)" type="warning" @click="emit('edit', order)">

          编辑

        </el-button>

        <el-button v-if="canAppendOrder(order)" type="warning" @click="emit('append', order)">

          补充

        </el-button>

        <el-button v-if="order.status === 'wait_accept'" type="success" @click="emit('accept', order)">

          去验收

        </el-button>

        <el-button v-if="canCancelOrder(order)" type="danger" plain @click="emit('cancel', order)">

          取消报修

        </el-button>

      </div>

    </template>

  </el-drawer>

</template>



<script setup>

import { ref, computed, watch } from 'vue'

import { getOrderDetail } from '@/api/repair'

import {

  repairStatusLabel, repairStatusTagType, repairStatusTagClass,

  canEditOrder, canAppendOrder, canCancelOrder

} from '@/utils/repairLabels'

import { formatOrderNo, formatDateTime } from '@/utils/orderFormat'

import '@/styles/repair-order-detail.css'



const props = defineProps({

  visible: { type: Boolean, default: false },

  orderId: { type: [Number, String], default: null }

})



const emit = defineEmits(['update:visible', 'edit', 'append', 'accept', 'cancel', 'refreshed'])



const loading = ref(false)

const order = ref({})

const progressList = ref([])

const worker = ref(null)

const images = ref([])



const imageUrls = computed(() => images.value.map(item => resolveUrl(item.imageUrl)))



function resolveUrl(url) {

  if (!url) return ''

  if (url.startsWith('http') || url.startsWith('data:')) return url

  return '/api' + url

}



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

    progressList.value = res.data.progress || []

    worker.value = res.data.worker || null

    images.value = res.data.images || []

    emit('refreshed')

  } finally {

    loading.value = false

  }

}



function handleClosed() {

  order.value = {}

  progressList.value = []

  worker.value = null

  images.value = []

}



defineExpose({ reload: () => props.orderId && loadDetail(props.orderId) })

</script>



<style scoped>

:deep(.tag-wait-accept) {

  --el-tag-bg-color: #f9f0ff;

  --el-tag-border-color: #d3adf7;

  --el-tag-text-color: #722ed1;

}

</style>


