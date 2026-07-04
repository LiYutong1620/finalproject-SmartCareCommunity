<template>
  <div class="app-logo" :class="{ collapsed, vertical, [`theme-${theme}`]: true }">
    <img :src="logoUrl" :alt="APP_NAME_SHORT" class="logo-img" :style="imgStyle" />
    <div v-if="!collapsed && showText" class="logo-text-wrap">
      <span class="logo-text">{{ text || APP_NAME_SHORT }}</span>
      <span v-if="showTagline" class="logo-tagline">{{ APP_TAGLINE }}</span>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { APP_NAME_SHORT, APP_TAGLINE } from '@/constants/brand'
import logoUrl from '@/assets/logo.svg'

const props = defineProps({
  size: { type: Number, default: 32 },
  showText: { type: Boolean, default: true },
  showTagline: { type: Boolean, default: false },
  collapsed: { type: Boolean, default: false },
  vertical: { type: Boolean, default: false },
  text: { type: String, default: '' },
  /** light：浅色背景用深色字；dark：深色背景用浅色字 */
  theme: { type: String, default: 'light' }
})

const imgStyle = computed(() => ({
  width: `${props.size}px`,
  height: `${props.size}px`
}))
</script>

<style scoped lang="scss">
.app-logo {
  display: flex;
  align-items: center;
  gap: 10px;
  min-width: 0;

  &.vertical {
    flex-direction: column;
    text-align: center;
    gap: 8px;
  }

  &.collapsed {
    justify-content: center;
    .logo-text-wrap { display: none; }
  }
}

.logo-img {
  flex-shrink: 0;
  display: block;
}

.logo-text-wrap {
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.logo-text {
  font-size: 16px;
  font-weight: 700;
  letter-spacing: 0.5px;
  white-space: nowrap;
}

.logo-tagline {
  font-size: 11px;
  margin-top: 2px;
  white-space: nowrap;
}

.theme-light {
  .logo-text { color: #2D4A62; }
  .logo-tagline { color: #7A94A8; }
}

.theme-dark {
  .logo-text { color: #fff; }
  .logo-tagline { color: rgba(255, 255, 255, 0.72); }
}
</style>
