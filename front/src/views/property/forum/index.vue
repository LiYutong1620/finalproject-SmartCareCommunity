<template>
  <div>
    <el-tabs v-model="tab">
      <el-tab-pane label="待审帖子" name="post">
        <el-table :data="posts">
          <el-table-column prop="postId" label="ID" width="70" />
          <el-table-column prop="content" label="内容" show-overflow-tooltip />
          <el-table-column prop="auditStatus" label="状态" width="80">
            <template #default="{ row }">{{ auditMap[row.auditStatus] }}</template>
          </el-table-column>
          <el-table-column prop="createTime" label="时间" width="170" />
          <el-table-column label="操作" width="200">
            <template #default="{ row }">
              <el-button link type="success" @click="auditPostRow(row, '1')">通过</el-button>
              <el-button link type="warning" @click="auditPostRow(row, '2')">驳回</el-button>
              <el-button link type="danger" @click="delPost(row)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>
      <el-tab-pane label="待审留言" name="comment">
        <el-table :data="comments">
          <el-table-column prop="commentId" label="ID" width="70" />
          <el-table-column prop="postId" label="帖子ID" width="80" />
          <el-table-column prop="content" label="内容" show-overflow-tooltip />
          <el-table-column label="操作" width="200">
            <template #default="{ row }">
              <el-button link type="success" @click="auditCommentRow(row, '1')">通过</el-button>
              <el-button link type="danger" @click="delComment(row)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup>
import { ref, watch, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { listPendingPosts, listPendingComments, auditPost, auditComment, deleteForumPost, deleteForumComment } from '@/api/propertyContent'

const tab = ref('post')
const posts = ref([])
const comments = ref([])
const auditMap = { '0': '待审', '1': '通过', '2': '驳回' }

async function loadPosts() {
  posts.value = (await listPendingPosts()).data
}
async function loadComments() {
  comments.value = (await listPendingComments()).data
}
async function auditPostRow(row, status) {
  await auditPost({ postId: row.postId, auditStatus: status })
  ElMessage.success('已审核')
  loadPosts()
}
async function delPost(row) {
  await ElMessageBox.confirm('确认删除该违规帖子？')
  await deleteForumPost(row.postId)
  loadPosts()
}
async function auditCommentRow(row, status) {
  await auditComment({ commentId: row.commentId, auditStatus: status })
  loadComments()
}
async function delComment(row) {
  await deleteForumComment(row.commentId)
  loadComments()
}
watch(tab, t => { if (t === 'post') loadPosts(); else loadComments() })
onMounted(loadPosts)
</script>
