<template>
  <div class="auth-page">
    <div class="auth-wrapper">
      <!-- 左侧：社区场景轮播（与右侧渐变相融） -->
      <div class="auth-carousel-panel">
        <el-carousel
          :interval="5500"
          arrow="never"
          indicator-position="outside"
          :height="`${panelHeight}px`"
          class="auth-carousel"
        >
          <el-carousel-item v-for="(slide, index) in slides" :key="index">
            <div class="slide">
              <div class="scene" :class="`scene-${index}`">
                <component :is="slide.scene" />
              </div>
              <div class="slide-caption">
                <span class="slide-tag">{{ slide.tag }}</span>
                <h2>{{ slide.title }}</h2>
                <p>{{ slide.desc }}</p>
              </div>
            </div>
          </el-carousel-item>
        </el-carousel>
      </div>

      <!-- 右侧：表单 -->
      <div class="auth-form-panel">
        <div class="form-brand">
          <AppLogo :size="30" :show-text="false" />
          <div class="brand-text">
            <span class="brand-name">{{ APP_NAME_SHORT }}</span>
            <span class="brand-tag">{{ APP_TAGLINE }}</span>
          </div>
        </div>
        <div class="auth-form-inner">
          <slot />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { defineComponent, h } from 'vue'
import AppLogo from '@/components/AppLogo.vue'
import { APP_NAME_SHORT, APP_TAGLINE } from '@/constants/brand'

const panelHeight = 540

/** 场景 1：社区报修 */
const SceneRepair = defineComponent({
  render() {
    return h('div', { class: 'illustration repair-scene' }, [
      h('div', { class: 'sky-cloud c1' }),
      h('div', { class: 'sky-cloud c2' }),
      h('div', { class: 'buildings' }, [
        h('div', { class: 'building b1' }, [h('div', { class: 'win' }), h('div', { class: 'win' }), h('div', { class: 'win' })]),
        h('div', { class: 'building b2 main' }, [h('div', { class: 'win lit' }), h('div', { class: 'win' }), h('div', { class: 'win lit' })]),
        h('div', { class: 'building b3' }, [h('div', { class: 'win' }), h('div', { class: 'win' })])
      ]),
      h('div', { class: 'ground-line' }),
      h('div', { class: 'scene-badge repair' }, '🔧 一键报修')
    ])
  }
})

/** 场景 2：智能问答 */
const SceneAi = defineComponent({
  render() {
    return h('div', { class: 'illustration ai-scene' }, [
      h('div', { class: 'chat-card left' }, '物业费怎么交？'),
      h('div', { class: 'chat-card right' }, '您好，可通过…'),
      h('div', { class: 'chat-card left small' }, '谢谢！'),
      h('div', { class: 'ai-avatar' }, '🤖'),
      h('div', { class: 'scene-badge ai' }, '💬 智能问答')
    ])
  }
})

/** 场景 3：老人关怀 */
const SceneElder = defineComponent({
  render() {
    return h('div', { class: 'illustration elder-scene' }, [
      h('div', { class: 'cozy-home' }, [
        h('div', { class: 'home-roof' }),
        h('div', { class: 'home-body' }, [
          h('div', { class: 'home-window' }),
          h('div', { class: 'home-door' })
        ]),
        h('div', { class: 'home-heart' }, '♥')
      ]),
      h('div', { class: 'elder-tree' }),
      h('div', { class: 'care-ring r1' }),
      h('div', { class: 'care-ring r2' }),
      h('div', { class: 'scene-badge elder' }, '🏠 安全监测')
    ])
  }
})

const slides = [
  {
    scene: SceneRepair,
    tag: '社区服务',
    title: '报修工单 · 全程可追踪',
    desc: '业主提交、物业派单、维修作业、线上验收，一站式闭环'
  },
  {
    scene: SceneAi,
    tag: 'AI 赋能',
    title: '智能问答 · 随时解答',
    desc: '社区生活疑问即问即答，复杂问题一键转人工'
  },
  {
    scene: SceneElder,
    tag: '暖心关怀',
    title: '独居老人 · 安全守护',
    desc: '水电用量智能监测，异常预警与关怀工单联动'
  }
]
</script>

<style scoped lang="scss">
$primary: #52B8F5;
$primary-light: #8FD4FF;
$primary-pale: #E8F6FF;
$mint: #9EDFC8;
$peach: #FFD4BC;
$lavender: #D4C8F0;

.auth-page {
  height: 100vh;
  min-height: 540px;
  max-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  background: #FAFCFE;
  padding: 12px 16px;
  --brand-primary: #52B8F5;
  --brand-primary-dark: #2E9FE8;
  --el-color-primary: #52B8F5;
  --el-color-primary-dark-2: #2E9FE8;
}

.auth-wrapper {
  display: flex;
  width: 100%;
  max-width: 880px;
  height: 540px;
  border-radius: 18px;
  overflow: hidden;
  background: #fff;
  border: 1px solid #D8E8F4;
  box-shadow: 0 18px 50px rgba(66, 175, 245, 0.18);
}

.auth-carousel-panel {
  flex: 1.05;
  min-width: 0;
  display: none;
  position: relative;
  background: linear-gradient(160deg, #8FD4FF 0%, #5EC2FA 46%, #42AFF5 100%);

  @media (min-width: 820px) {
    display: block;
  }
}

.auth-carousel {
  :deep(.el-carousel__container) {
    height: 540px !important;
  }

  :deep(.el-carousel__indicators--outside) {
    position: absolute;
    bottom: 14px;
    left: 0;
    right: 0;
    margin: 0;

    .el-carousel__button {
      width: 6px;
      height: 6px;
      border-radius: 50%;
      background: rgba(255, 255, 255, 0.5);
      opacity: 1;
    }

    .is-active .el-carousel__button {
      width: 18px;
      border-radius: 3px;
      background: #fff;
    }
  }
}

.slide {
  height: 540px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 20px 28px 36px;
  color: #fff;
}

.scene {
  width: 100%;
  max-width: 280px;
  height: 200px;
  position: relative;
  margin-bottom: 16px;
}

.slide-caption {
  text-align: center;
  max-width: 300px;

  .slide-tag {
    display: inline-block;
    font-size: 11px;
    padding: 3px 10px;
    border-radius: 20px;
    background: rgba(255, 255, 255, 0.22);
    margin-bottom: 8px;
    letter-spacing: 0.5px;
  }

  h2 {
    font-size: 17px;
    font-weight: 700;
    margin-bottom: 6px;
    text-shadow: 0 1px 6px rgba(0, 0, 0, 0.08);
  }

  p {
    font-size: 12px;
    line-height: 1.6;
    opacity: 0.9;
  }
}

/* ---- 插画：报修场景 ---- */
:deep(.repair-scene) {
  .sky-cloud {
    position: absolute;
    background: rgba(255, 255, 255, 0.35);
    border-radius: 20px;
    &.c1 { width: 50px; height: 16px; top: 8px; left: 20px; }
    &.c2 { width: 36px; height: 12px; top: 20px; right: 30px; opacity: 0.6; }
  }

  .buildings {
    position: absolute;
    bottom: 28px;
    left: 50%;
    transform: translateX(-50%);
    display: flex;
    align-items: flex-end;
    gap: 8px;
  }

  .building {
    background: rgba(255, 255, 255, 0.75);
    border-radius: 4px 4px 0 0;
    padding: 6px;
    display: flex;
    flex-wrap: wrap;
    gap: 4px;
    width: 52px;

    &.b1 { height: 70px; }
    &.b2.main { height: 95px; background: rgba(255, 255, 255, 0.9); width: 60px; }
    &.b3 { height: 58px; }

    .win {
      width: 14px;
      height: 12px;
      background: $primary-pale;
      border-radius: 2px;
      &.lit { background: $peach; }
    }
  }

  .ground-line {
    position: absolute;
    bottom: 24px;
    left: 10%;
    right: 10%;
    height: 3px;
    background: rgba(255, 255, 255, 0.4);
    border-radius: 2px;
  }

  .scene-badge {
    position: absolute;
    bottom: 0;
    left: 50%;
    transform: translateX(-50%);
    background: rgba(255, 255, 255, 0.92);
    color: $primary;
    font-size: 12px;
    font-weight: 600;
    padding: 6px 14px;
    border-radius: 20px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
    white-space: nowrap;
  }
}

/* ---- 插画：AI 问答 ---- */
:deep(.ai-scene) {
  .chat-card {
    position: absolute;
    background: rgba(255, 255, 255, 0.88);
    color: #4A5568;
    font-size: 11px;
    padding: 8px 12px;
    border-radius: 12px;
    max-width: 140px;
    line-height: 1.4;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);

    &.left { left: 8px; top: 30px; border-bottom-left-radius: 4px; }
    &.right {
      right: 8px;
      top: 72px;
      background: rgba(255, 255, 255, 0.95);
      border-bottom-right-radius: 4px;
      color: $primary;
    }
    &.small { left: 24px; top: 130px; font-size: 10px; padding: 6px 10px; }
  }

  .ai-avatar {
    position: absolute;
    top: 16px;
    right: 50%;
    transform: translateX(50%);
    width: 44px;
    height: 44px;
    background: rgba(255, 255, 255, 0.9);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 22px;
    box-shadow: 0 4px 14px rgba(0, 0, 0, 0.08);
  }

  .scene-badge.ai {
    position: absolute;
    bottom: 8px;
    left: 50%;
    transform: translateX(-50%);
    background: rgba(212, 200, 240, 0.88);
    color: #fff;
    font-size: 12px;
    font-weight: 600;
    padding: 6px 14px;
    border-radius: 20px;
  }
}

/* ---- 插画：老人关怀 ---- */
:deep(.elder-scene) {
  .cozy-home {
    position: absolute;
    left: 50%;
    bottom: 30px;
    transform: translateX(-50%);
    width: 90px;
  }

  .home-roof {
    width: 0;
    height: 0;
    border-left: 50px solid transparent;
    border-right: 50px solid transparent;
    border-bottom: 32px solid rgba(255, 255, 255, 0.85);
    margin: 0 auto;
  }

  .home-body {
    width: 80px;
    height: 56px;
    background: rgba(255, 255, 255, 0.8);
    margin: 0 auto;
    border-radius: 0 0 6px 6px;
    position: relative;
    display: flex;
    justify-content: center;
    gap: 8px;
    padding-top: 12px;
  }

  .home-window {
    width: 18px;
    height: 18px;
    background: $mint;
    border-radius: 3px;
    opacity: 0.8;
  }

  .home-door {
    width: 16px;
    height: 28px;
    background: $peach;
    border-radius: 3px 3px 0 0;
    position: absolute;
    bottom: 0;
    left: 50%;
    transform: translateX(-50%);
    opacity: 0.85;
  }

  .home-heart {
    position: absolute;
    top: -8px;
    right: -6px;
    color: $peach;
    font-size: 18px;
    filter: drop-shadow(0 2px 4px rgba(0,0,0,0.1));
  }

  .elder-tree {
    position: absolute;
    bottom: 28px;
    left: 30px;
    width: 28px;
    height: 28px;
    background: $mint;
    border-radius: 50% 50% 50% 0;
    transform: rotate(-45deg);
    opacity: 0.7;
  }

  .care-ring {
    position: absolute;
    border: 2px solid rgba(255, 255, 255, 0.35);
    border-radius: 50%;
    &.r1 { width: 120px; height: 120px; top: 40px; left: 50%; transform: translateX(-50%); }
    &.r2 { width: 160px; height: 160px; top: 20px; left: 50%; transform: translateX(-50%); opacity: 0.5; }
  }

  .scene-badge.elder {
    position: absolute;
    bottom: 0;
    left: 50%;
    transform: translateX(-50%);
    background: rgba(158, 223, 200, 0.92);
    color: #fff;
    font-size: 12px;
    font-weight: 600;
    padding: 6px 14px;
    border-radius: 20px;
  }
}

/* ---- 右侧表单 ---- */
.auth-form-panel {
  flex: 0.95;
  min-width: 0;
  min-height: 0;
  display: flex;
  flex-direction: column;
  padding: 16px 26px 18px;
  background: #fff;
  border-left: 1px solid #E6F0F8;

  @media (max-width: 819px) {
    flex: 1;
    border-left: none;
    padding: 24px 22px 18px;
  }
}

.form-brand {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 4px;
  flex-shrink: 0;

  .brand-text {
    display: flex;
    flex-direction: column;
    min-width: 0;
  }

  .brand-name {
    font-size: 15px;
    font-weight: 700;
    color: #1E3A52;
    line-height: 1.2;
  }

  .brand-tag {
    font-size: 11px;
    color: #5A7288;
    margin-top: 1px;
  }
}

.auth-form-inner {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  max-width: 360px;
  width: 100%;
  height: 100%;
  margin: 0 auto;
  overflow: visible;
  min-height: 0;
}
</style>
