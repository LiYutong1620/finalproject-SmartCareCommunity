/** 项目品牌常量 */
export const APP_NAME = '智护社区：AI 智能服务平台'
export const APP_NAME_SHORT = '智护社区'
export const APP_TAGLINE = 'AI 智能服务平台'

/** 业主端 · 清新适中蓝 */
export const BRAND_COLORS = {
  primary: '#55A8D8',
  primaryLight: '#86C5E8',
  primaryPale: '#E3F2FA',
  primaryDark: '#3A94C4',
  sidebarBg: '#D0EAF8',
  sidebarBgEnd: '#C4E2F4',
  bg: '#FAFCFE',
  text: '#3D5A72',
  textLight: '#5E7F99',
  border: '#B5D8EE',
  accentMint: '#52C9A8',
  accentPeach: '#FFB88C',
  accentLavender: '#B8AEEB'
}

/**
 * 三端主题：同色系递进加深（适中饱和度）
 * 0 业主 · 1 维修工 · 2 物业
 */
export const ROLE_THEMES = {
  '0': {
    label: '业主端',
    primary: '#55A8D8',
    primaryLight: '#86C5E8',
    primaryPale: '#E3F2FA',
    primaryDark: '#3A94C4',
    sidebarBg: '#D0EAF8',
    sidebarBgEnd: '#C4E2F4',
    sidebarText: '#466880',
    sidebarTextActive: '#3A94C4',
    bg: '#FAFCFE',
    contentBg: '#FAFCFE',
    contentBorder: '#EEF2F6',
    border: '#B5D8EE',
    text: '#3D5A72'
  },
  '1': {
    label: '维修工端',
    primary: '#4898CA',
    primaryLight: '#78B8DC',
    primaryPale: '#D6EBF6',
    primaryDark: '#3585B8',
    sidebarBg: '#B8DCF0',
    sidebarBgEnd: '#A8D2EA',
    sidebarText: '#3A6078',
    sidebarTextActive: '#3585B8',
    bg: '#FAFCFE',
    contentBg: '#FAFCFE',
    contentBorder: '#EEF2F6',
    border: '#9CC8E2',
    text: '#345568'
  },
  '2': {
    label: '物业端',
    primary: '#3E8AB8',
    primaryLight: '#6AA8CC',
    primaryPale: '#CCE5F2',
    primaryDark: '#2E78A8',
    sidebarBg: '#9ECFE8',
    sidebarBgEnd: '#8EC5E2',
    sidebarText: '#2E5068',
    sidebarTextActive: '#2E78A8',
    bg: '#FAFCFE',
    contentBg: '#FAFCFE',
    contentBorder: '#EEF2F6',
    border: '#88BBD8',
    text: '#2C4A60'
  }
}

export function getRoleThemeClass(userType) {
  const type = String(userType ?? '0')
  return ROLE_THEMES[type] ? `role-theme-${type}` : 'role-theme-0'
}

export function getRoleTheme(userType) {
  return ROLE_THEMES[String(userType ?? '0')] || ROLE_THEMES['0']
}
