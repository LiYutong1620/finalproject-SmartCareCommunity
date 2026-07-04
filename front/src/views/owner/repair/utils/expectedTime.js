import { ElMessage } from 'element-plus'

export function parseExpectedTime(value) {
  if (!value) return null
  return new Date(String(value).replace(/-/g, '/'))
}

/** 截断到分钟，允许选择当前时刻（含此刻） */
export function toMinuteTime(date) {
  const d = new Date(date)
  d.setSeconds(0, 0)
  return d.getTime()
}

export function isExpectedTimeValid(value) {
  const d = parseExpectedTime(value)
  if (!d) return true
  return toMinuteTime(d) >= toMinuteTime(new Date())
}

export function warnInvalidExpectedTime() {
  ElMessage.warning('期望时间不能早于当前时间')
}

/** 选择后立即校验，不合法则清空并提示 */
export function handleExpectedTimeChange(value, clear) {
  if (!value) return
  if (!isExpectedTimeValid(value)) {
    warnInvalidExpectedTime()
    clear()
  }
}

function isToday(date) {
  const now = new Date()
  return (
    date.getFullYear() === now.getFullYear() &&
    date.getMonth() === now.getMonth() &&
    date.getDate() === now.getDate()
  )
}

/** 创建期望时间日期选择器的 disabled 配置（精确到分钟，此刻可选） */
export function createExpectedTimeDisabled(getValue) {
  const disabledDate = (date) => {
    const today = new Date()
    today.setHours(0, 0, 0, 0)
    return date.getTime() < today.getTime()
  }

  const disabledHours = () => {
    const d = parseExpectedTime(getValue())
    if (!d || !isToday(d)) return []
    return Array.from({ length: new Date().getHours() }, (_, i) => i)
  }

  const disabledMinutes = (hour) => {
    const d = parseExpectedTime(getValue())
    if (!d || !isToday(d)) return []
    const now = new Date()
    if (hour > now.getHours()) return []
    if (hour < now.getHours()) return Array.from({ length: 60 }, (_, i) => i)
    return Array.from({ length: now.getMinutes() }, (_, i) => i)
  }

  return { disabledDate, disabledHours, disabledMinutes }
}
