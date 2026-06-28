import { computed, ref } from 'vue'

/** 前端分页：适用于后端返回全量列表的场景 */
export function useClientPagination(defaultLimit = 10) {
  const pageNum = ref(1)
  const limit = ref(defaultLimit)
  const allList = ref([])

  const total = computed(() => allList.value.length)

  const pageList = computed(() => {
    const start = (pageNum.value - 1) * limit.value
    return allList.value.slice(start, start + limit.value)
  })

  function setList(list) {
    allList.value = list || []
    pageNum.value = 1
  }

  function onPagination({ page, limit: size }) {
    pageNum.value = page
    limit.value = size
  }

  return { pageNum, limit, total, pageList, setList, onPagination }
}
