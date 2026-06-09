<template>
  <div>
    <el-tabs v-model="tab" @tab-change="load">
      <el-tab-pane label="邻里话题" name="all">
        <el-button type="primary" class="mb-16" @click="openNewPost">发帖</el-button>
        <el-card v-for="p in posts" :key="p.postId" class="post-card">
          <p>{{ p.content }}</p>
          <div v-if="parseImages(p.images).length" class="imgs">
            <el-image v-for="(img, i) in parseImages(p.images)" :key="i" :src="imgUrl(img)" fit="cover" style="width:80px;height:80px;margin-right:8px" />
          </div>
          <el-button link type="primary" @click="openComments(p)">留言</el-button>
        </el-card>
      </el-tab-pane>
      <el-tab-pane label="我的帖子" name="mine">
        <el-table :data="myPosts">
          <el-table-column prop="content" label="内容" show-overflow-tooltip />
          <el-table-column prop="auditStatus" label="审核" width="80">
            <template #default="{ row }">{{ auditMap[row.auditStatus] }}</template>
          </el-table-column>
          <el-table-column label="操作" width="140">
            <template #default="{ row }">
              <el-button link @click="editPost(row)">编辑</el-button>
              <el-button link type="danger" @click="delPost(row)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>
    </el-tabs>
    <el-dialog v-model="showPost" title="发布帖子" width="520px">
      <el-input v-model="postForm.content" type="textarea" rows="4" />
      <el-upload class="mt-8" :http-request="uploadOne" :show-file-list="false" accept="image/*">
        <el-button>上传图片(最多9张)</el-button>
      </el-upload>
      <template #footer><el-button type="primary" @click="submitPost">发布</el-button></template>
    </el-dialog>
    <el-dialog v-model="commentVisible" title="留言" width="480px">
      <div v-for="c in comments" :key="c.commentId" class="comment-item">{{ c.content }}</div>
      <el-input v-model="commentText" class="mt-8" />
      <template #footer><el-button type="primary" @click="submitComment">发送</el-button></template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { listForumPost, listMyPosts, addForumPost, deleteForumPost, listForumComment, addForumComment, uploadImage } from '@/api/owner'

const tab = ref('all')
const posts = ref([])
const myPosts = ref([])
const showPost = ref(false)
const postForm = reactive({ content: '', imageList: [] })
const commentVisible = ref(false)
const comments = ref([])
const commentText = ref('')
const currentPostId = ref(null)
const auditMap = { '0': '待审', '1': '通过', '2': '驳回' }

function imgUrl(path) { return path?.startsWith('http') ? path : '/api' + path }
function parseImages(json) { try { return json ? JSON.parse(json) : [] } catch { return [] } }

async function load() {
  const all = await listForumPost({ pageNum: 1, pageSize: 50 })
  posts.value = all.data.rows || []
  const mine = await listMyPosts()
  myPosts.value = mine.data
}

function openNewPost() {
  postForm.content = ''
  postForm.imageList = []
  showPost.value = true
}

async function uploadOne({ file }) {
  if (postForm.imageList.length >= 9) return ElMessage.warning('最多9张')
  const res = await uploadImage(file)
  postForm.imageList.push(res.data.url)
}

async function submitPost() {
  await addForumPost({ content: postForm.content, images: JSON.stringify(postForm.imageList) })
  ElMessage.success('已提交')
  showPost.value = false
  load()
}

async function openComments(p) {
  currentPostId.value = p.postId
  comments.value = (await listForumComment(p.postId)).data
  commentVisible.value = true
}

async function submitComment() {
  await addForumComment({ postId: currentPostId.value, content: commentText.value })
  commentText.value = ''
  comments.value = (await listForumComment(currentPostId.value)).data
}

async function delPost(row) {
  await deleteForumPost(row.postId)
  ElMessage.success('已删除')
  load()
}

function editPost(row) {
  postForm.content = row.content
  postForm.imageList = parseImages(row.images)
  showPost.value = true
}

onMounted(load)
</script>

<style scoped>
.mb-16 { margin-bottom: 16px; }
.mt-8 { margin-top: 8px; }
.post-card { margin-bottom: 12px; }
.comment-item { padding: 8px 0; border-bottom: 1px solid #eee; }
</style>
