/** 工单号与时间展示格式化 */

/**
 * 标准格式（14 位）：RP + yyyyMMdd(8) + 当日序号(4)
 * 展示：RP-20260621-0001
 */
export function formatOrderNo(orderNo) {
  if (!orderNo) return '—'
  const raw = String(orderNo).trim()
  const standard = raw.match(/^RP(\d{8})(\d{4})$/i)
  if (standard) {
    return `RP-${standard[1]}-${standard[2]}`
  }
  // 兼容旧长格式（20 位）：取日期 + 末4位
  const legacyLong = raw.match(/^RP(\d{8})\d{6}(\d{4})$/i)
  if (legacyLong) {
    return `RP-${legacyLong[1]}-${legacyLong[2]}`
  }
  return raw
}

/** 统一日期时间展示：2025-07-03 10:42:00 */
export function formatDateTime(value) {
  if (!value) return '—'
  const s = String(value).trim()
  if (/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}/.test(s)) {
    return s.length >= 19 ? s.slice(0, 19) : s
  }
  const normalized = s.replace('T', ' ')
  if (/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}/.test(normalized)) {
    return normalized.length >= 19 ? normalized.slice(0, 19) : normalized
  }
  return s
}

export function urgencyTagType(urgency) {
  const map = { emergency: 'danger', urgent: 'warning', normal: '' }
  return map[urgency] ?? ''
}

/** 普通紧急程度使用自定义样式，避免灰色 info */
export function urgencyTagClass(urgency) {
  if (urgency === 'normal') return 'tag-urgency-normal'
  return ''
}

export const REPAIR_STATUS_MAP = {
  pending: '待分配',
  assigned: '待接单',
  processing: '处理中',
  wait_accept: '待验收',
  completed: '已完成',
  cancelled: '已取消'
}

export const REPAIR_URGENCY_MAP = {
  normal: '普通',
  urgent: '较急',
  emergency: '紧急'
}

export function repairStatusTagType(status) {
  const map = {
    pending: 'warning',
    assigned: 'warning',
    processing: 'primary',
    wait_accept: '',
    completed: 'success',
    cancelled: 'danger'
  }
  return map[status] ?? ''
}

/** 待验收使用紫色自定义样式 */
export function repairStatusTagClass(status) {
  if (status === 'wait_accept') return 'tag-status-purple'
  return ''
}
