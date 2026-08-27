<template>
  <el-card shadow="never" class="quick-card">
    <template #header>
      <div class="card-header">
        <span>快捷入口</span>
        <el-tag type="info" effect="plain" size="small">{{ visibleLinks.length }} 个功能</el-tag>
      </div>
    </template>

    <div class="quick-grid">
      <div v-for="link in visibleLinks" :key="link.path" class="quick-item" @click="goPage(link.path)">
        <div class="quick-icon" :style="{ backgroundColor: link.color }">
          <el-icon :size="22"><component :is="link.icon" /></el-icon>
        </div>
        <div class="quick-text">
          <div class="quick-title">{{ link.title }}</div>
          <div class="quick-desc">{{ link.desc }}</div>
        </div>
      </div>
    </div>
  </el-card>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { useRouter } from 'vue-router';
import auth from '@/plugins/auth';
import { quickLinks } from '../data';

const router = useRouter();

/** 按用户权限过滤，无权限的入口不展示 */
const visibleLinks = computed(() => quickLinks.filter((link) => !link.permission || auth.hasPermi(link.permission)));

const goPage = (path: string) => {
  router.push(path);
};
</script>

<style lang="scss" scoped>
.quick-card {
  margin-bottom: 20px;

  :deep(.el-card__body) {
    padding: 16px 20px;
  }
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 15px;
  font-weight: 600;
  color: var(--el-text-color-primary);
}

.quick-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(210px, 1fr));
  gap: 12px;
}

.quick-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  border: 1px solid var(--el-border-color-lighter);
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.25s;

  &:hover {
    border-color: var(--el-color-primary-light-5);
    background-color: var(--el-fill-color-light);
    transform: translateY(-2px);

    .quick-title {
      color: var(--el-color-primary);
    }
  }
}

.quick-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 42px;
  height: 42px;
  border-radius: 8px;
  color: #fff;
  flex-shrink: 0;
}

.quick-text {
  min-width: 0;
}

.quick-title {
  font-size: 14px;
  font-weight: 500;
  color: var(--el-text-color-primary);
  transition: color 0.25s;
}

.quick-desc {
  margin-top: 2px;
  font-size: 12px;
  color: var(--el-text-color-secondary);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
</style>
