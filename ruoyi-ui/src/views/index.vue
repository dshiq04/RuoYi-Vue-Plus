<template>
  <div class="app-container home">
    <!-- 数据概览 -->
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
                {{ item.value }}<span class="stat-suffix">{{ item.suffix }}</span>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 项目列表 -->
    <el-row :gutter="16">
      <el-col v-for="project in projects" :key="project.id" :sm="24" :lg="12" class="col-item">
        <el-card shadow="hover" class="project-card">
          <template #header>
            <div class="project-header">
              <span class="project-name">{{ project.name }}</span>
              <el-tag type="danger" effect="dark">免费开源</el-tag>
            </div>
          </template>

          <el-descriptions :column="2" class="project-desc">
            <el-descriptions-item label="项目简介" :span="2">
              {{ project.description }}
            </el-descriptions-item>
            <el-descriptions-item label="当前版本">
              <el-tag type="primary" effect="plain">{{ project.version }}</el-tag>
            </el-descriptions-item>
            <el-descriptions-item label="技术选型">
              <el-tag type="success" effect="plain">Vue3 + TS + Spring Boot</el-tag>
            </el-descriptions-item>
          </el-descriptions>

          <el-collapse>
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
            <el-button v-for="link in project.links" :key="link.label" type="primary" plain @click="goTarget(link.url)">
              <el-icon class="btn-icon"><Connection /></el-icon>
              {{ link.label }}
            </el-button>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 技术栈 -->
    <el-card shadow="hover" class="tech-card">
      <template #header>
        <div class="tech-header">
          <span>技术栈概览</span>
          <el-tag type="info" effect="plain">{{ techStack.length }} 项技术</el-tag>
        </div>
      </template>
      <div class="tech-grid">
        <div v-for="tech in techStack" :key="tech.name" class="tech-item">
          <el-icon :size="28" class="tech-icon"><component :is="tech.icon" /></el-icon>
          <div class="tech-name">{{ tech.name }}</div>
          <div class="tech-desc">{{ tech.desc }}</div>
          <el-tag size="small" :type="tagType(tech.tag)">{{ tech.tag }}</el-tag>
        </div>
      </div>
    </el-card>

    <el-divider />
  </div>
</template>

<script setup lang="ts" name="Index">
import { stats, projects, techStack } from './home/data';

const goTarget = (url: string) => {
  window.open(url, '__blank');
};

type TagType = 'success' | 'warning' | 'info' | 'primary' | 'danger';

const tagType = (tag: string): TagType => {
  const map: Record<string, TagType> = {
    前端: 'primary',
    后端: 'success',
    中间件: 'warning',
    数据库: 'danger',
    部署: 'info',
    监控: 'info'
  };
  return map[tag];
};
</script>

<style lang="scss" scoped>
.home {
  font-family: 'open sans', 'Helvetica Neue', Helvetica, Arial, sans-serif;
  font-size: 13px;
  color: #676a6c;
  overflow-x: hidden;

  .stat-row {
    margin-bottom: 20px;
  }

  .stat-card {
    :deep(.el-card__body) {
      padding: 16px;
    }
  }

  .stat-content {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .stat-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 52px;
    height: 52px;
    border-radius: 8px;
    color: #fff;
    flex-shrink: 0;
  }

  .stat-info {
    display: flex;
    flex-direction: column;
    min-width: 0;
  }

  .stat-title {
    font-size: 12px;
    color: #999;
    white-space: nowrap;
  }

  .stat-value {
    font-size: 24px;
    font-weight: 600;
    color: #333;
  }

  .stat-suffix {
    font-size: 13px;
    font-weight: 400;
    color: #999;
  }

  .col-item {
    margin-bottom: 16px;
  }

  .project-card {
    height: 100%;

    :deep(.el-card__body) {
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
    color: #303133;
  }

  .project-desc {
    margin-bottom: 8px;
  }

  .feature-list {
    list-style: none;
    margin: 0;
    padding: 0;

    li {
      display: flex;
      align-items: center;
      gap: 6px;
      padding: 4px 0;
      color: #606266;

      .el-icon {
        color: #67c23a;
        flex-shrink: 0;
      }
    }
  }

  .project-footer {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-top: 12px;
  }

  .btn-icon {
    margin-right: 2px;
  }

  .tech-card {
    :deep(.el-card__body) {
      padding: 20px;
    }
  }

  .tech-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    font-size: 15px;
    font-weight: 600;
    color: #303133;
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
    border: 1px solid #ebeef5;
    border-radius: 8px;
    text-align: center;
    transition: all 0.3s;

    &:hover {
      border-color: #409eff;
      box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
      transform: translateY(-2px);
    }
  }

  .tech-icon {
    color: #409eff;
  }

  .tech-name {
    font-size: 14px;
    font-weight: 600;
    color: #303133;
  }

  .tech-desc {
    font-size: 12px;
    color: #999;
  }
}
</style>
