<template>
  <div>
    <el-table :data="list" v-loading="loading" @row-click="openDetail">
      <el-table-column prop="title" label="标题" />
      <el-table-column prop="scope" label="影响范围" show-overflow-tooltip />
      <el-table-column prop="restoreTime" label="预计恢复" width="170" />
      <el-table-column label="已读" width="70">
        <template #default="{ row }"><el-tag :type="row.read ? 'info' : 'warning'" size="small">{{ row.read ? '已读' : '未读' }}</el-tag></template>
      </el-table-column>
    </el-table>
    <el-dialog v-model="visible" :title="detail.title" width="520px">
      <p><b>影响范围：</b>{{ detail.scope }}</p>
      <p><b>预计恢复：</b>{{ detail.restoreTime }}</p>
      <p>{{ detail.content }}</p>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { listNoticeV2, getNoticeDetail } from '@/api/owner'

const loading = ref(false)
const list = ref([])
const visible = ref(false)
const detail = ref({})

async function load() {
  loading.value = true
  try {
    list.value = (await listNoticeV2({ noticeType: 'outage' })).data
  } finally { loading.value = false }
}

async function openDetail(row) {
  detail.value = (await getNoticeDetail(row.noticeId)).data
  visible.value = true
  load()
}

onMounted(load)
</script>
