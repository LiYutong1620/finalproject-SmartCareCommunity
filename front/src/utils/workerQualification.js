/** 维修工技能字典（与后端 WorkerSkillCatalog 一致） */

export const SKILL_CATEGORIES = [
  {
    name: '水暖管道类',
    skills: ['水管维修', '管道疏通', '水暖安装', '热水器维修']
  },
  {
    name: '电力电气类',
    skills: ['电路维修', '电工基础', '配电系统', '照明维修']
  },
  {
    name: '家电家具类',
    skills: ['家电维修', '空调维修', '锁具维修', '门窗维修']
  },
  {
    name: '公共设施类',
    skills: ['电梯维保', '弱电维修', '公共设施维护']
  },
  {
    name: '其他综合类',
    skills: ['综合维修', '网络维修', '土建维修', '燃气维修']
  }
]

export const WORKER_LEVELS = ['初级', '中级', '高级', '资深']

export const WORK_STATUS_OPTIONS = [
  { value: 'available', label: '可接单' },
  { value: 'busy', label: '忙线中' },
  { value: 'rest', label: '休息' }
]

export function workStatusLabel(status) {
  return WORK_STATUS_OPTIONS.find(o => o.value === status)?.label || status || '—'
}

export function auditStatusLabel(status) {
  const map = { 0: '待审核', 1: '已通过', 2: '已驳回' }
  return map[status] ?? map[String(status)] ?? '—'
}

/** 维修工维度汇总审核状态 */
export function workerSummaryAuditLabel(status) {
  const map = { 0: '待审核', 1: '正常' }
  return map[status] ?? map[String(status)] ?? '—'
}

export function workerSummaryAuditTagType(status) {
  const map = { 0: 'warning', 1: 'success' }
  return map[status] ?? map[String(status)] ?? 'info'
}

export function auditTagType(status) {
  const map = { 0: 'warning', 1: 'success', 2: 'danger' }
  return map[status] ?? map[String(status)] ?? 'info'
}
