/** 默认头像背景色 · 按角色区分 */
export const ROLE_AVATAR_COLORS = {
  '0': '#52C9A8', // 业主 · 清新绿
  '1': '#F5A623', // 维修工 · 活力橙
  '2': '#7B8CFF'  // 物业 · 管理紫蓝
}

export function getRoleAvatarColor(userType) {
  return ROLE_AVATAR_COLORS[String(userType)] || ROLE_AVATAR_COLORS['0']
}
