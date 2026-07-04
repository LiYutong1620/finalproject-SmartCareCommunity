<template>
  <el-drawer
    :model-value="visible"
    title="累计评价详情"
    direction="rtl"
    size="480px"
    destroy-on-close
    @update:model-value="emit('update:visible', $event)"
    @closed="handleClosed"
  >
    <div v-loading="loading" class="eval-drawer-body">
      <template v-if="loaded">
        <section class="stats-block">
          <div class="stat-item good">
            <div class="stat-num">{{ stats.goodRate }}%</div>
            <div class="stat-name">好评率</div>
            <div class="stat-desc">4-5 星</div>
          </div>
          <div class="stat-item bad">
            <div class="stat-num">{{ stats.badRate }}%</div>
            <div class="stat-name">差评率</div>
            <div class="stat-desc">1-2 星</div>
          </div>
          <div class="stat-item overall">
            <div class="stat-num">{{ stats.comprehensiveGoodRate }}%</div>
            <div class="stat-name">综合好评率</div>
            <div class="stat-desc">4 星及以上</div>
          </div>
        </section>
        <p class="stats-tip">
          共 {{ stats.evalCount }} 条评价 · 平均 {{ stats.avgScore }} 分
          <span class="stats-note">（3 星仅在「全部」中展示，不计入好评/差评率）</span>
        </p>

        <el-tabs v-model="activeTab" class="eval-tabs">
          <el-tab-pane label="全部" name="all">
            <EvalList :items="allEvals" @select="emit('select-order', $event)" />
          </el-tab-pane>
          <el-tab-pane :label="`好评 (${goodEvals.length})`" name="good">
            <EvalList :items="goodEvals" empty-text="暂无好评" @select="emit('select-order', $event)" />
          </el-tab-pane>
          <el-tab-pane :label="`差评 (${badEvals.length})`" name="bad">
            <EvalList :items="badEvals" empty-text="暂无差评" @select="emit('select-order', $event)" />
          </el-tab-pane>
        </el-tabs>
      </template>
    </div>
  </el-drawer>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { getWorkerEvaluations } from '@/api/repair'
import EvalList from './WorkerEvalList.vue'

const props = defineProps({
  visible: { type: Boolean, default: false }
})

const emit = defineEmits(['update:visible', 'select-order'])

const loading = ref(false)
const loaded = ref(false)
const activeTab = ref('all')
const stats = ref({
  evalCount: 0,
  avgScore: 0,
  goodRate: 0,
  badRate: 0,
  comprehensiveGoodRate: 0
})
const allEvals = ref([])

const goodEvals = computed(() => allEvals.value.filter(e => e.type === 'good'))
const badEvals = computed(() => allEvals.value.filter(e => e.type === 'bad'))

watch(
  () => props.visible,
  val => { if (val) loadData() },
  { immediate: true }
)

async function loadData() {
  loading.value = true
  loaded.value = false
  try {
    const res = await getWorkerEvaluations()
    stats.value = res.data?.stats ?? stats.value
    allEvals.value = res.data?.evaluations ?? []
    loaded.value = true
  } finally {
    loading.value = false
  }
}

function handleClosed() {
  activeTab.value = 'all'
  allEvals.value = []
  loaded.value = false
}
</script>

<style scoped>
.eval-drawer-body {
  min-height: 200px;
  padding-bottom: 16px;
}

.stats-block {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
  margin-bottom: 10px;
}

.stat-item {
  text-align: center;
  padding: 14px 8px;
  border-radius: 10px;
  border: 1px solid #eef2f6;
}

.stat-item.good {
  background: linear-gradient(135deg, #f0faf5 0%, #e8f8ef 100%);
  border-color: #b7e4cc;
  color: #389e6a;
}

.stat-item.bad {
  background: linear-gradient(135deg, #fff5f5 0%, #ffecec 100%);
  border-color: #ffccc7;
  color: #cf1322;
}

.stat-item.overall {
  background: linear-gradient(135deg, #fffbf0 0%, #fff3d6 100%);
  border-color: #ffe7a3;
  color: #d48806;
}

.stat-num {
  font-size: 22px;
  font-weight: 700;
  line-height: 1.2;
}

.stat-name {
  margin-top: 6px;
  font-size: 13px;
  font-weight: 600;
}

.stat-desc {
  margin-top: 2px;
  font-size: 11px;
  opacity: 0.75;
}

.stats-tip {
  margin: 0 0 16px;
  font-size: 12px;
  color: #909399;
  text-align: center;
  line-height: 1.6;
}

.stats-note {
  display: block;
  margin-top: 4px;
  font-size: 11px;
  color: #b0b3b8;
}

.eval-tabs :deep(.el-tabs__header) {
  margin-bottom: 12px;
}
</style>
