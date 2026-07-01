<template>
  <div class="app-container">
    <el-card>
      <template #header>
        <div class="header-wrap">
          <span>维修知识库检索</span>
          <el-button size="small" @click="$router.back()">返回</el-button>
        </div>
      </template>

      <el-form inline @submit.prevent>
        <el-form-item label="关键词">
          <el-input
            v-model="keyword"
            placeholder="如：水管漏水、电路跳闸"
            style="width: 280px"
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="loading" @click="handleSearch">搜索</el-button>
        </el-form-item>
      </el-form>

      <el-empty v-if="!loading && searched && results.length === 0" description="未找到匹配方案" />

      <div v-for="item in results" :key="item.articleId" class="article-card">
        <div class="article-title">{{ item.title }}</div>
        <div class="article-keywords" v-if="item.keywords">关键词：{{ item.keywords }}</div>
        <div class="article-content">{{ item.content }}</div>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import { searchWorkerKnowledge } from '@/api/repair'

const keyword = ref('')
const results = ref([])
const loading = ref(false)
const searched = ref(false)

async function handleSearch() {
  if (!keyword.value.trim()) {
    ElMessage.warning('请输入搜索关键词')
    return
  }
  loading.value = true
  searched.value = true
  try {
    const res = await searchWorkerKnowledge(keyword.value.trim())
    results.value = res.data || []
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.header-wrap {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.article-card {
  border: 1px solid #ebeef5;
  border-radius: 8px;
  padding: 16px;
  margin-bottom: 12px;
}
.article-title {
  font-size: 16px;
  font-weight: 600;
  margin-bottom: 8px;
}
.article-keywords {
  color: #909399;
  font-size: 13px;
  margin-bottom: 8px;
}
.article-content {
  white-space: pre-wrap;
  line-height: 1.6;
  color: #606266;
}
</style>
