<template>
  <el-row :gutter="16" class="stat-row">
    <el-col v-for="item in stats" :key="item.title" :xs="12" :sm="12" :md="6">
      <el-card shadow="hover" class="stat-card">
        <div class="stat-content">
          <div class="stat-icon" :style="{ backgroundColor: item.color }">
            <el-icon :size="26"><component :is="item.icon" /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-title">{{ item.title }}</div>
            <div class="stat-value">
              {{ displayValue(item) }}<span class="stat-suffix">{{ item.suffix }}</span>
            </div>
          </div>
        </div>
      </el-card>
    </el-col>
  </el-row>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue';
import { useTransition } from '@vueuse/core';
import type { StatItem } from '../data';
import { stats } from '../data';

// 页面进入时数字从 0 滚动到目标值
const progress = ref(0);
const animated = useTransition(progress, { duration: 1200 });
progress.value = 1;

const displayValue = (item: StatItem): number => Math.round(animated.value * item.value);
</script>

<style lang="scss" scoped>
.stat-row {
  margin-bottom: 20px;
}

.stat-card {
  :deep(.el-card__body) {
    padding: 18px;
  }
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 14px;
}

.stat-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 52px;
  height: 52px;
  border-radius: 10px;
  color: #fff;
  flex-shrink: 0;
}

.stat-info {
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.stat-title {
  font-size: 13px;
  color: var(--el-text-color-secondary);
  white-space: nowrap;
}

.stat-value {
  font-size: 26px;
  font-weight: 600;
  font-variant-numeric: tabular-nums;
  color: var(--el-text-color-primary);
}

.stat-suffix {
  margin-left: 2px;
  font-size: 14px;
  font-weight: 400;
  color: var(--el-text-color-secondary);
}
</style>
