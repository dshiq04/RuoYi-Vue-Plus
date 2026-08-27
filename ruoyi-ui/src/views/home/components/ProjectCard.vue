<template>
  <el-card shadow="hover" class="project-card">
    <template #header>
      <div class="project-header">
        <span class="project-name">{{ project.name }}</span>
        <div class="project-tags">
          <el-tag type="primary" effect="plain">{{ project.version }}</el-tag>
          <el-tag type="danger" effect="dark">免费开源</el-tag>
        </div>
      </div>
    </template>

    <p class="project-desc">{{ project.description }}</p>

    <el-collapse class="feature-collapse">
      <el-collapse-item :title="`功能特性（${project.features.length}）`" name="features">
        <ul class="feature-list">
          <li v-for="(feature, index) in project.features" :key="index">
            <el-icon><CircleCheck /></el-icon>
            <span>{{ feature }}</span>
          </li>
        </ul>
      </el-collapse-item>
    </el-collapse>

    <div class="project-footer">
      <el-button v-for="link in project.links" :key="link.label" type="primary" plain size="small" @click="goTarget(link.url)">
        <el-icon class="btn-icon"><Connection /></el-icon>
        {{ link.label }}
      </el-button>
    </div>
  </el-card>
</template>

<script setup lang="ts">
import type { ProjectVO } from '../data';

defineProps<{ project: ProjectVO }>();

const goTarget = (url: string) => {
  window.open(url, '_blank');
};
</script>

<style lang="scss" scoped>
.project-card {
  height: 100%;

  :deep(.el-card__body) {
    display: flex;
    flex-direction: column;
    padding: 16px 20px;
  }
}

.project-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.project-name {
  font-size: 16px;
  font-weight: 600;
  color: var(--el-text-color-primary);
}

.project-tags {
  display: flex;
  gap: 6px;
}

.project-desc {
  margin: 0 0 8px;
  font-size: 13px;
  line-height: 1.7;
  color: var(--el-text-color-regular);
}

.feature-collapse {
  border-top: 1px dashed var(--el-border-color-lighter);
  border-bottom: none;

  :deep(.el-collapse-item__header) {
    font-size: 13px;
    color: var(--el-text-color-secondary);
  }

  :deep(.el-collapse-item__wrap) {
    border-bottom: none;
  }

  :deep(.el-collapse-item__content) {
    padding-bottom: 8px;
  }
}

.feature-list {
  list-style: none;
  margin: 0;
  padding: 0;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  column-gap: 16px;

  li {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 4px 0;
    font-size: 13px;
    color: var(--el-text-color-regular);

    .el-icon {
      color: var(--el-color-success);
      flex-shrink: 0;
    }
  }
}

.project-footer {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: auto;
  padding-top: 12px;
}

.btn-icon {
  margin-right: 2px;
}
</style>
