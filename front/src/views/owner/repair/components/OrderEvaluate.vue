<template>
  <div class="order-evaluate">
    <el-form label-width="80px">
      <el-form-item label="评分">
        <el-rate
          v-model="localScore"
          :colors="['#99a9bf', '#f7ba2a', '#ff9900']"
        />
      </el-form-item>
      <el-form-item label="标签">
        <el-checkbox-group v-model="localTags">
          <el-checkbox label="态度好" />
          <el-checkbox label="技术专业" />
          <el-checkbox label="响应迅速" />
          <el-checkbox label="需要改进" />
        </el-checkbox-group>
      </el-form-item>
      <el-form-item label="评价内容">
        <el-input
          v-model="localContent"
          type="textarea"
          :rows="2"
          placeholder="请补充评价内容（选填）"
        />
      </el-form-item>
    </el-form>
  </div>
</template>

<script setup>
import { ref, watch } from "vue";

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({ score: 5, tags: [], content: "" }),
  },
});
const emit = defineEmits(["update:modelValue"]);

const localScore = ref(props.modelValue.score);
const localTags = ref([...props.modelValue.tags]);
const localContent = ref(props.modelValue.content);

watch(
  [localScore, localTags, localContent],
  () => {
    emit("update:modelValue", {
      score: localScore.value,
      tags: localTags.value,
      content: localContent.value,
    });
  },
  { deep: true },
);
</script>
