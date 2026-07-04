/** 维修工端工单状态中文与标签样式 */



const STATUS_LABELS = {

  assigned: '待接单',

  processing: '处理中',

  wait_accept: '待验收',

  completed: '已完成',

  pending: '待分配',

  cancelled: '已取消'

}



const STATUS_TAG_TYPES = {

  assigned: 'warning',

  processing: 'primary',

  wait_accept: '',

  completed: 'success',

  pending: 'info',

  cancelled: 'danger'

}



export function workerStatusLabel(status) {

  return STATUS_LABELS[status] || status || '—'

}



export function workerStatusTagType(status) {

  return STATUS_TAG_TYPES[status] ?? 'info'

}



export function workerStatusTagClass(status) {

  return status === 'wait_accept' ? 'tag-wait-accept' : ''

}



export function workerUrgencyLabel(urgency) {

  const map = { emergency: '紧急', urgent: '较急', normal: '普通' }

  return map[urgency] || urgency || '—'

}

