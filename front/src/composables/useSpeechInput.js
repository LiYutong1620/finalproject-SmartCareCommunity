import { onBeforeUnmount, ref } from 'vue'
import { ElMessage } from 'element-plus'

/**
 * 浏览器 Web Speech API 语音输入，识别结果写入 targetRef
 */
export function useSpeechInput(targetRef, options = {}) {
  const listening = ref(false)
  const supported = ref(false)
  let recognition = null

  function initSpeech() {
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition
    if (!SpeechRecognition) {
      supported.value = false
      return
    }
    supported.value = true
    recognition = new SpeechRecognition()
    recognition.lang = options.lang || 'zh-CN'
    recognition.continuous = false
    recognition.interimResults = false
    recognition.onresult = (event) => {
      const text = event.results[0][0].transcript
      if (typeof targetRef === 'function') {
        targetRef(text)
      } else if (targetRef && 'value' in targetRef) {
        const prev = targetRef.value || ''
        targetRef.value = prev ? `${prev}${prev.endsWith('\n') ? '' : '\n'}${text}` : text
      }
      ElMessage.success(options.successMessage || '语音已填入，请核对后提交')
    }
    recognition.onerror = () => {
      listening.value = false
      ElMessage.warning(options.errorMessage || '语音识别失败，请重试或使用文字输入')
    }
    recognition.onend = () => {
      listening.value = false
    }
  }

  function toggleVoice() {
    if (!recognition) {
      initSpeech()
    }
    if (!supported.value || !recognition) {
      ElMessage.warning('当前浏览器不支持语音识别，请使用 Chrome 或 Edge')
      return
    }
    if (listening.value) {
      stopVoice()
      return
    }
    listening.value = true
    recognition.start()
  }

  function stopVoice() {
    if (recognition && listening.value) {
      recognition.stop()
    }
    listening.value = false
  }

  onBeforeUnmount(stopVoice)

  return { listening, supported, toggleVoice, stopVoice, initSpeech }
}
