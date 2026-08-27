<template>
  <div class="hero-banner">
    <div class="hero-deco hero-circle-1" />
    <div class="hero-deco hero-circle-2" />

    <div class="hero-main">
      <div class="greeting">{{ greeting }}，{{ nickname }}！</div>
      <div class="subtitle">欢迎使用 {{ systemTitle }}，祝您工作顺利、开心每一天</div>
      <div class="date-line">
        <el-icon><Calendar /></el-icon>
        <span>{{ dateText }}</span>
        <el-divider direction="vertical" />
        <el-icon><Clock /></el-icon>
        <span>{{ weekText }}</span>
      </div>
    </div>

    <div class="hero-side">
      <el-icon :size="54"><Sunny /></el-icon>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { getGreeting } from '../data';
import { useUserStore } from '@/store/modules/user';
import { useSettingsStore } from '@/store/modules/settings';

const userStore = useUserStore();
const settingsStore = useSettingsStore();

const nickname = computed(() => userStore.nickname || '朋友');
const systemTitle = computed(() => settingsStore.title);

const now = new Date();
const greeting = computed(() => getGreeting(now.getHours()));
const dateText = `${now.getFullYear()} 年 ${now.getMonth() + 1} 月 ${now.getDate()} 日`;
const weekText = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'][now.getDay()];
</script>

<style lang="scss" scoped>
.hero-banner {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  padding: 28px 32px;
  margin-bottom: 24px;
  border-radius: 12px;
  overflow: hidden;
  color: #fff;
  /* 降级背景，不支持 color-mix 的浏览器仍可显示 */
  background-image: linear-gradient(120deg, #409eff, #6a5cff);
  background-image: linear-gradient(120deg, var(--el-color-primary), color-mix(in srgb, var(--el-color-primary) 55%, #7b3ff2));
}

.hero-deco {
  position: absolute;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.12);
  pointer-events: none;

  &.hero-circle-1 {
    width: 220px;
    height: 220px;
    right: -60px;
    top: -110px;
  }

  &.hero-circle-2 {
    width: 140px;
    height: 140px;
    left: 32%;
    bottom: -80px;
  }
}

.hero-main {
  position: relative;
  z-index: 1;
  min-width: 0;
}

.greeting {
  font-size: 24px;
  font-weight: 600;
  letter-spacing: 0.5px;
}

.subtitle {
  margin-top: 8px;
  font-size: 14px;
  opacity: 0.9;
}

.date-line {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-top: 14px;
  font-size: 13px;
  opacity: 0.85;

  .el-icon {
    font-size: 15px;
  }
}

.hero-side {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 96px;
  height: 96px;
  flex-shrink: 0;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.15);
  animation: float 4s ease-in-out infinite;

  @keyframes float {
    0%,
    100% {
      transform: translateY(0);
    }

    50% {
      transform: translateY(-10px);
    }
  }
}

@media only screen and (max-width: 767px) {
  .hero-banner {
    padding: 20px;
    margin-bottom: 20px;
  }

  .greeting {
    font-size: 19px;
  }

  .hero-side {
    display: none;
  }
}
</style>
