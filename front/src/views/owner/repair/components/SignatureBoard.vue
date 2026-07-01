<template>
  <div class="signature-board">
    <canvas
      ref="canvasRef"
      class="canvas"
      @mousedown="startDraw"
      @mousemove="drawing"
      @mouseup="endDraw"
      @mouseleave="endDraw"
      @touchstart="startDrawTouch"
      @touchmove="drawingTouch"
      @touchend="endDraw"
    ></canvas>
    <div class="toolbar">
      <el-button size="small" @click="clear">清空</el-button>
      <el-button size="small" @click="undo">撤销</el-button>
      <el-button size="small" type="primary" @click="confirm"
        >确认签名</el-button
      >
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from "vue";
import { ElMessage } from "element-plus";

const canvasRef = ref(null);
let ctx = null;
let isDrawing = false;
let lastX = 0;
let lastY = 0;
const history = []; // 存储每一步的 ImageData
let currentStep = -1;

const emit = defineEmits(["confirm"]);

onMounted(() => {
  nextTick(() => {
    const canvas = canvasRef.value;
    ctx = canvas.getContext("2d");
    // 设置画布尺寸（固定宽高，适应父容器）
    const rect = canvas.parentElement.getBoundingClientRect();
    const width = rect.width || 400;
    const height = 200;
    canvas.width = width;
    canvas.height = height;
    // 白色背景
    ctx.fillStyle = "#fff";
    ctx.fillRect(0, 0, width, height);
    // 保存初始状态
    saveHistory();
  });
});

function saveHistory() {
  if (!ctx) return;
  const imageData = ctx.getImageData(
    0,
    0,
    canvasRef.value.width,
    canvasRef.value.height,
  );
  // 删除后面的历史（如果撤销后再画新步骤）
  history.splice(currentStep + 1);
  history.push(imageData);
  currentStep = history.length - 1;
}

function startDraw(e) {
  const rect = canvasRef.value.getBoundingClientRect();
  isDrawing = true;
  lastX = e.clientX - rect.left;
  lastY = e.clientY - rect.top;
}

function drawing(e) {
  if (!isDrawing) return;
  const rect = canvasRef.value.getBoundingClientRect();
  const x = e.clientX - rect.left;
  const y = e.clientY - rect.top;
  ctx.beginPath();
  ctx.moveTo(lastX, lastY);
  ctx.lineTo(x, y);
  ctx.strokeStyle = "#000";
  ctx.lineWidth = 2;
  ctx.lineCap = "round";
  ctx.stroke();
  lastX = x;
  lastY = y;
}

function endDraw() {
  if (isDrawing) {
    isDrawing = false;
    saveHistory();
  }
}

// 触摸事件适配
function startDrawTouch(e) {
  e.preventDefault();
  const touch = e.touches[0];
  const rect = canvasRef.value.getBoundingClientRect();
  isDrawing = true;
  lastX = touch.clientX - rect.left;
  lastY = touch.clientY - rect.top;
}

function drawingTouch(e) {
  e.preventDefault();
  if (!isDrawing) return;
  const touch = e.touches[0];
  const rect = canvasRef.value.getBoundingClientRect();
  const x = touch.clientX - rect.left;
  const y = touch.clientY - rect.top;
  ctx.beginPath();
  ctx.moveTo(lastX, lastY);
  ctx.lineTo(x, y);
  ctx.strokeStyle = "#000";
  ctx.lineWidth = 2;
  ctx.lineCap = "round";
  ctx.stroke();
  lastX = x;
  lastY = y;
}

function clear() {
  if (!ctx) return;
  const width = canvasRef.value.width;
  const height = canvasRef.value.height;
  ctx.fillStyle = "#fff";
  ctx.fillRect(0, 0, width, height);
  saveHistory();
}

function undo() {
  if (currentStep <= 0) {
    ElMessage.warning("已无上一步");
    return;
  }
  currentStep--;
  ctx.putImageData(history[currentStep], 0, 0);
}

function confirm() {
  // 检查是否有签名（判断是否全白）
  const imageData = ctx.getImageData(
    0,
    0,
    canvasRef.value.width,
    canvasRef.value.height,
  );
  const data = imageData.data;
  let hasPixel = false;
  for (let i = 0; i < data.length; i += 4) {
    // 如果像素不是纯白 (255,255,255)
    if (data[i] < 255 || data[i + 1] < 255 || data[i + 2] < 255) {
      hasPixel = true;
      break;
    }
  }
  if (!hasPixel) {
    ElMessage.warning("请先签名再确认");
    return;
  }
  // 输出 Base64 图片（去掉 data:image/png;base64, 前缀，仅保留数据）
  const base64 = canvasRef.value.toDataURL("image/png");
  emit("confirm", base64);
}
</script>

<style scoped>
.signature-board {
  width: 100%;
}
.canvas {
  width: 100%;
  height: 200px;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  background: #fff;
  touch-action: none;
  cursor: crosshair;
}
.toolbar {
  margin-top: 8px;
  display: flex;
  gap: 10px;
  justify-content: flex-end;
}
</style>
