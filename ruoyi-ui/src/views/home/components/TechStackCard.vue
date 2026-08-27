<template>
  <el-card shadow="never" class="tech-card">
    <template #header>
      <div class="card-header">
        <span>技术栈概览</span>
        <el-radio-group v-model="activeCategory" size="small">
          <el-radio-button v-for="category in categories" :key="category" :value="category">{{ category }}</el-radio-button>
        </el-radio-group>
      </div>
    </template>

    <div class="tech-grid">
      <TransitionGroup name="tech-fade">
        <div v-for="tech in filteredStack" :key="tech.name" class="tech-item">
          <el-icon :size="26" class="tech-icon"><component :is="tech.icon" /></el-icon>
          <div class="tech-name">{{ tech.name }}</div>
          <div class="tech-desc">{{ tech.desc }}</div>
          <el-tag size="small" :type="tagType(tech.category)" effect="plain">{{ tech.category }}</el-tag>
        </div>
      </TransitionGroup>
    </div>
  </el-card>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue';
import type { TechCategory, TechItem } from '../data';
import { techStack } from '../data';

const ALL = '全部' as const;

type TagType = 'success' | 'warning' | 'info' | 'primary' | 'danger';

/** 分类 → 标签颜色的映射 */
const tagTypeMap: Record<TechCategory, TagType> = {
  前端: 'primary',
  后端: 'success',
  中间件: 'warning',
  数据库: 'danger',
  部署: 'info',
  监控: 'info'
};

const categories: Array<typeof ALL | TechCategory> = [ALL, ...new Set(techStack.map((item) => item.category))];

const activeCategory = ref<typeof ALL | TechCategory>(ALL);

const filteredStack = computed<TechItem[]>(() =>
  activeCategory.value === ALL ? techStack : techStack.filter((item) => item.category === activeCategory.value)
);

const tagType = (category: TechCategory): TagType => tagTypeMap[category];
</script>

<style lang="scss" scoped>
.tech-card {
  margin-bottom: 20px;

  :deep(.el-card__body) {
    padding: 20px;
  }
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 8px;
  font-size: 15px;
  font-weight: 600;
  color: var(--el-text-color-primary);
}

.tech-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  gap: 12px;
}

.tech-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  padding: 16px 12px;
  border: 1px solid var(--el-border-color-lighter);
  border-radius: 8px;
  text-align: center;
  transition: all 0.3s;

  &:hover {
    border-color: var(--el-color-primary-light-5);
    box-shadow: var(--el-box-shadow-light);
    transform: translateY(-2px);
  }
}

.tech-icon {
  color: var(--el-color-primary);
}

.tech-name {
  font-size: 14px;
  font-weight: 600;
  color: var(--el-text-color-primary);
}

.tech-desc {
  font-size: 12px;
  color: var(--el-text-color-secondary);
}

.tech-fade-enter-active,
.tech-fade-leave-active {
  transition: all 0.3s ease;
}

.tech-fade-enter-from,
.tech-fade-leave-to {
  opacity: 0;
  transform: scale(0.92);
}
</style>
