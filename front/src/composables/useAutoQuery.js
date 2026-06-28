import { ref, watch, onMounted } from 'vue'

/**
 * 列表自动查询：防抖 + 重置防重复请求 + 丢弃过期响应
 */
export function useAutoQuery(fetchFn, watchSources, options = {}) {
  const loading = ref(false)
  const debounceMs = options.debounce ?? 150
  let timer = null
  let seq = 0
  let suppressWatch = false

  async function load() {
    const current = ++seq
    loading.value = true
    try {
      await fetchFn()
    } finally {
      if (current === seq) {
        loading.value = false
      }
    }
  }

  function reset(resetFn) {
    suppressWatch = true
    clearTimeout(timer)
    resetFn()
    load().finally(() => {
      suppressWatch = false
    })
  }

  if (watchSources) {
    watch(watchSources, () => {
      if (suppressWatch) return
      clearTimeout(timer)
      timer = setTimeout(() => {
        options.beforeLoad?.()
        load()
      }, debounceMs)
    }, { deep: true })
  }

  onMounted(load)

  return { loading, load, reset }
}
