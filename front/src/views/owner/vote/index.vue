<template>
  <div>
    <el-table :data="list" v-loading="loading" @row-click="openDetail">
      <el-table-column prop="title" label="议题" />
      <el-table-column prop="endTime" label="截止" width="170" />
      <el-table-column label="状态" width="100">
        <template #default="{ row }">{{ row.ended ? '已结束' : '进行中' }}</template>
      </el-table-column>
      <el-table-column label="投票" width="90">
        <template #default="{ row }">{{ row.voted ? '已投' : '未投' }}</template>
      </el-table-column>
    </el-table>
    <el-dialog v-model="visible" :title="detail.title" width="560px">
      <p>{{ detail.content }}</p>
      <el-radio-group v-if="!detail.voted && !detail.ended" v-model="selected" class="mt-16">
        <el-radio v-for="o in detail.options" :key="o" :label="o">{{ o }}</el-radio>
      </el-radio-group>
      <div v-if="detail.stats" class="mt-16">
        <p v-for="(cnt, opt) in detail.stats" :key="opt">{{ opt }}：{{ cnt }} 票</p>
        <p>总票数：{{ detail.totalVotes }}</p>
      </div>
      <template #footer>
        <el-button v-if="!detail.voted && !detail.ended" type="primary" @click="submit">匿名投票</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { listVote, getVote, castVote } from '@/api/owner'

const loading = ref(false)
const list = ref([])
const visible = ref(false)
const detail = ref({})
const selected = ref('')

async function load() {
  loading.value = true
  try {
    list.value = (await listVote()).data
  } finally { loading.value = false }
}

async function openDetail(row) {
  detail.value = (await getVote(row.voteId)).data
  selected.value = detail.value.options?.[0] || ''
  visible.value = true
}

async function submit() {
  await castVote(detail.value.voteId, selected.value)
  ElMessage.success('投票成功')
  visible.value = false
  load()
}

onMounted(load)
</script>

<style scoped>.mt-16{margin-top:16px}</style>
