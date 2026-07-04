<template>
  <div class="image-uploader">
    <div class="upload-list">
      <div
        v-for="(url, index) in modelValue"
        :key="index"
        class="upload-item"
      >
        <img :src="url" alt="报修图片" />
        <div class="mask">
          <el-icon class="delete-icon" @click="removeImage(index)">
            <Delete />
          </el-icon>
        </div>
      </div>
      <div
        v-if="modelValue.length < maxCount"
        class="upload-trigger"
        @click="triggerUpload"
      >
        <el-icon><Plus /></el-icon>
        <span>上传图片</span>
      </div>
    </div>
    <input
      ref="fileInput"
      type="file"
      accept="image/*"
      multiple
      style="display: none"
      @change="handleFileChange"
    />
    <div v-if="modelValue.length > 0" class="count-tip">
      已选 {{ modelValue.length }} / {{ maxCount }} 张
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { Plus, Delete } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'

const props = defineProps({
  modelValue: {
    type: Array,
    default: () => []
  },
  maxCount: {
    type: Number,
    default: 9
  },
  storageKey: {
    type: String,
    default: '__repairFiles'
  }
})

const emit = defineEmits(['update:modelValue'])
const fileInput = ref(null)

function getFileStore() {
  if (!window[props.storageKey]) {
    window[props.storageKey] = []
  }
  return window[props.storageKey]
}

watch(
  () => props.modelValue.length,
  (len) => {
    const store = getFileStore()
    if (len < store.length) {
      store.splice(len)
    }
  }
)

const triggerUpload = () => {
  fileInput.value?.click()
}

const handleFileChange = (e) => {
  const files = Array.from(e.target.files)
  const remaining = props.maxCount - props.modelValue.length
  const validFiles = files.slice(0, remaining)

  if (files.length > remaining) {
    ElMessage.warning(`最多上传 ${props.maxCount} 张图片`)
  }

  const readers = validFiles.map((file) => {
    return new Promise((resolve) => {
      const reader = new FileReader()
      reader.onload = (ev) => {
        resolve({
          file: file,
          dataUrl: ev.target.result
        })
      }
      reader.readAsDataURL(file)
    })
  })

  Promise.all(readers).then((results) => {
    const urls = results.map(r => r.dataUrl)
    emit('update:modelValue', [...props.modelValue, ...urls])
    const store = getFileStore()
    results.forEach(r => store.push(r.file))
  })

  e.target.value = ''
}

const removeImage = (index) => {
  const newList = [...props.modelValue]
  newList.splice(index, 1)
  emit('update:modelValue', newList)
  const store = getFileStore()
  store.splice(index, 1)
}
</script>

<style scoped>
.image-uploader {
  width: 100%;
}
.upload-list {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}
.upload-item {
  position: relative;
  width: 80px;
  height: 80px;
  border-radius: 6px;
  overflow: hidden;
  border: 1px solid #ddd;
  flex-shrink: 0;
}
.upload-item img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.upload-item .mask {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.2s;
}
.upload-item:hover .mask {
  opacity: 1;
}
.delete-icon {
  color: #fff;
  font-size: 20px;
  cursor: pointer;
}
.upload-trigger {
  width: 80px;
  height: 80px;
  border: 2px dashed #d9d9d9;
  border-radius: 6px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #999;
  cursor: pointer;
  transition: border-color 0.2s;
}
.upload-trigger:hover {
  border-color: #409eff;
  color: #409eff;
}
.upload-trigger .el-icon {
  font-size: 28px;
}
.upload-trigger span {
  font-size: 12px;
  margin-top: 4px;
}
.count-tip {
  margin-top: 8px;
  font-size: 12px;
  color: #909399;
}
</style>
