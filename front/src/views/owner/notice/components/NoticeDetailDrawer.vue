<template>
  <el-drawer
    :model-value="visible"
    :title="drawerTitle"
    direction="rtl"
    size="520px"
    destroy-on-close
    @update:model-value="emit('update:visible', $event)"
    @closed="handleClosed"
  >
    <div v-loading="loading" class="drawer-body">
      <template v-if="detail.noticeId">
        <div class="detail-banner" :class="bannerClass">
          <el-tag
            :class="detail.read ? 'tag-read' : 'tag-unread'"
            size="small"
            effect="plain"
            round
          >
            {{ detail.read ? '已读' : '未读' }}
          </el-tag>
          <span v-if="detail.scope" class="scope-text">{{ detail.scope }}</span>
        </div>

        <h3 class="detail-title">{{ detail.title }}</h3>

        <dl class="meta-list">
          <div class="meta-row">
            <dt>发布时间</dt>
            <dd>{{ detail.createTime || '—' }}</dd>
          </div>
          <div v-if="detail.restoreTime" class="meta-row highlight">
            <dt>预计恢复</dt>
            <dd>{{ detail.restoreTime }}</dd>
          </div>
          <div v-if="detail.scope" class="meta-row">
            <dt>影响范围</dt>
            <dd>{{ detail.scope }}</dd>
          </div>
        </dl>

        <section class="content-block">
          <h4>正文</h4>
          <div class="content-body">{{ detail.content || '暂无内容' }}</div>
        </section>

        <section v-if="detail.attachment" class="content-block">
          <h4>附件</h4>
          <el-link
            :class="noticeType === 'outage' ? 'link-outage' : 'link-announce'"
            :href="resolveUrl(detail.attachment)"
            target="_blank"
            :underline="false"
          >
            查看附件
          </el-link>
        </section>
      </template>
    </div>
  </el-drawer>
</template>

<script setup>
import { ref, watch, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { getNoticeDetail } from '@/api/owner'

const props = defineProps({
  visible: { type: Boolean, default: false },
  noticeId: { type: [Number, String], default: null },
  noticeType: { type: String, default: 'announce' }
})

const emit = defineEmits(['update:visible', 'read'])

const loading = ref(false)
const detail = ref({})

const drawerTitle = computed(() =>
  props.noticeType === 'outage' ? '停水停电详情' : '公告详情'
)

const bannerClass = computed(() =>
  props.noticeType === 'outage' ? 'banner-outage' : 'banner-announce'
)

watch(
  () => [props.visible, props.noticeId],
  ([vis, id]) => {
    if (vis && id) loadDetail(id)
  },
  { immediate: true }
)

async function loadDetail(noticeId) {
  loading.value = true
  try {
    detail.value = (await getNoticeDetail(noticeId)).data || {}
    emit('read', detail.value)
  } catch {
    ElMessage.error('加载详情失败')
    emit('update:visible', false)
  } finally {
    loading.value = false
  }
}

function handleClosed() {
  detail.value = {}
}

function resolveUrl(url) {
  if (!url) return ''
  if (/^https?:\/\//i.test(url)) return url
  const base = import.meta.env.VITE_APP_BASE_API || ''
  return `${base}${url.startsWith('/') ? url : `/${url}`}`
}
</script>

<style scoped>
.drawer-body {
  min-height: 200px;
  padding-bottom: 16px;
}

.detail-banner {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 14px;
  border-radius: 10px;
  margin-bottom: 16px;
}

.banner-announce {
  background: linear-gradient(135deg, #ecf5ff 0%, #f5f9ff 100%);
  border: 1px solid #d9ecff;
}

.banner-outage {
  background: linear-gradient(135deg, #fdf6ec 0%, #fff9f0 100%);
  border: 1px solid #faecd8;
}

.scope-text {
  font-size: 13px;
  color: #606266;
}

.detail-title {
  margin: 0 0 16px;
  font-size: 18px;
  font-weight: 600;
  line-height: 1.4;
  color: #1a1a2e;
}

.meta-list {
  margin: 0 0 20px;
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

.meta-row.highlight dd {
  color: #d48806;
  font-weight: 600;
}

.tag-unread {
  --el-tag-bg-color: #fff7e6;
  --el-tag-border-color: #ffd591;
  --el-tag-text-color: #d48806;
}

.tag-read {
  --el-tag-bg-color: #f4f4f5;
  --el-tag-border-color: #dcdfe6;
  --el-tag-text-color: #909399;
}

.link-announce {
  color: #409eff;
  font-weight: 500;
}

.link-outage {
  color: #e6a23c;
  font-weight: 500;
}

.meta-row dt {
  color: #909399;
  margin: 0;
  flex-shrink: 0;
}

.meta-row dd {
  margin: 0;
  color: #303133;
  text-align: right;
}

.content-block {
  margin-bottom: 20px;
}

.content-block h4 {
  margin: 0 0 10px;
  font-size: 14px;
  font-weight: 600;
  color: #303133;
}

.content-body {
  padding: 14px 16px;
  background: #fff;
  border: 1px solid #ebeef5;
  border-radius: 10px;
  white-space: pre-wrap;
  line-height: 1.8;
  font-size: 14px;
  color: #303133;
}
</style>
