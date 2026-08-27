<template>
  <div class="app-container home">
    <!-- 欢迎横幅 -->
    <HeroBanner />

    <!-- 数据概览 -->
    <StatCards class="fade-item" />

    <!-- 快捷入口 -->
    <QuickAccess class="fade-item" />

    <!-- 项目列表 -->
    <el-row :gutter="16">
      <el-col
        v-for="(project, index) in projects"
        :key="project.id"
        :sm="24"
        :lg="12"
        class="project-col fade-item"
        :style="{ animationDelay: `${(index + 1) * 80}ms` }"
      >
        <ProjectCard :project="project" />
      </el-col>
    </el-row>

    <!-- 技术栈 -->
    <TechStackCard />
  </div>
</template>

<script setup lang="ts" name="Index">
import HeroBanner from './home/components/HeroBanner.vue';
import StatCards from './home/components/StatCards.vue';
import QuickAccess from './home/components/QuickAccess.vue';
import ProjectCard from './home/components/ProjectCard.vue';
import TechStackCard from './home/components/TechStackCard.vue';
import { projects } from './home/data';
</script>

<style lang="scss" scoped>
.home {
  font-family: 'open sans', 'Helvetica Neue', Helvetica, Arial, sans-serif;
  overflow-x: hidden;
}

.project-col {
  margin-bottom: 20px;
}

/* 区块渐入动效 */
.fade-item {
  animation: fade-slide-in 0.5s ease both;
}

@keyframes fade-slide-in {
  from {
    opacity: 0;
    transform: translateY(12px);
  }

  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@media (prefers-reduced-motion: reduce) {
  .fade-item {
    animation: none;
  }
}
</style>
