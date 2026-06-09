<template>
  <el-card>
    <el-table :data="list" v-loading="loading" @row-click="openDetail">
      <el-table-column prop="title" label="标题" />
      <el-table-column prop="pinned" label="置顶" width="70">
        <template #default="{ row }"><el-tag v-if="row.pinned" size="small">置顶</el-tag></template>
      </el-table-column>
      <el-table-column label="已读" width="70">
        <template #default="{ row }">
          <el-tag :type="row.read ? 'info' : 'warning'" size="small">{{ row.read ? '已读' : '未读' }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="createTime" label="发布时间" width="170" />
    </el-table>
    <el-dialog v-model="visible" :title="detail.title" width="520px">
      <p>{{ detail.content }}</p>
    </el-dialog>
  </el-card>
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
    const res = await listNoticeV2({ noticeType: 'announce' })
    list.value = res.data
  } finally { loading.value = false }
}

async function openDetail(row) {
  detail.value = (await getNoticeDetail(row.noticeId)).data
  visible.value = true
  row.read = true
}

onMounted(load)
</script>
