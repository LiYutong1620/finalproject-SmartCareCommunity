/** 报修工单状态与紧急程度中文映射（业主端展示） */

export const REPAIR_STATUS_MAP = {
  pending: '待接单',
  assigned: '待接单',
  processing: '处理中',
  wait_accept: '待验收',
  completed: '已完成',
  cancelled: '已取消'
}

export const REPAIR_STATUS_TAG = {
  pending: 'warning',
  assigned: 'warning',
  processing: 'primary',
  wait_accept: '',
  completed: 'success',
  cancelled: 'danger'
}

/** 业主端列表 Tab：全部 + 五种状态 */
export const OWNER_REPAIR_TABS = [
  { value: 'all', label: '全部' },
  { value: 'pending', label: '待接单' },
  { value: 'processing', label: '处理中' },
  { value: 'wait_accept', label: '待验收' },
  { value: 'completed', label: '已完成' },
  { value: 'cancelled', label: '已取消' }
]

export const REPAIR_URGENCY_MAP = {
  normal: '普通',
  urgent: '较急',
  emergency: '紧急',
  high: '较急',
  low: '普通'
}

export function repairStatusLabel(status) {
  return REPAIR_STATUS_MAP[status] || status || '-'
}

export function repairStatusTagType(status) {
  return REPAIR_STATUS_TAG[status] ?? 'info'
}

export function repairStatusTagClass(status) {
  return status === 'wait_accept' ? 'tag-wait-accept' : ''
}

export function repairUrgencyLabel(urgency) {
  return REPAIR_URGENCY_MAP[urgency] || urgency || '-'
}

/** 业主端「待接单」：含 pending（未派单）与 assigned（已派单待维修工接单） */
export function isWaitAcceptOrderStatus(status) {
  return status === 'pending' || status === 'assigned'
}

export function canEditOrder(order) {
  return isWaitAcceptOrderStatus(order?.status)
}

export function canCancelOrder(order) {
  return isWaitAcceptOrderStatus(order?.status)
}

export function canAppendOrder(order) {
  return order?.status === 'processing'
}

export function canSupplementOrder(order) {
  return canEditOrder(order)
}

export function isProcessingStatus(status) {
  return status === 'processing'
}

export function isCancelledStatus(status) {
  return status === 'cancelled'
}
