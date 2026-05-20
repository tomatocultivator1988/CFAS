<template>
  <div class="skeleton-loader" :class="variant">
    <!-- User Card Skeleton -->
    <div v-if="variant === 'user-card'" class="skeleton-user-card">
      <div class="skeleton-card-header">
        <div class="skeleton-avatar"></div>
        <div class="skeleton-badges">
          <div class="skeleton-badge"></div>
          <div class="skeleton-badge small"></div>
        </div>
      </div>
      <div class="skeleton-content">
        <div class="skeleton-line title"></div>
        <div class="skeleton-line subtitle"></div>
      </div>
      <div class="skeleton-actions">
        <div class="skeleton-button"></div>
        <div class="skeleton-button"></div>
        <div class="skeleton-button"></div>
      </div>
    </div>

    <!-- Exam Card Skeleton -->
    <div v-else-if="variant === 'exam-card'" class="skeleton-exam-card">
      <div class="skeleton-exam-header">
        <div class="skeleton-line title"></div>
        <div class="skeleton-badge"></div>
      </div>
      <div class="skeleton-exam-content">
        <div class="skeleton-line"></div>
        <div class="skeleton-line short"></div>
      </div>
      <div class="skeleton-exam-footer">
        <div class="skeleton-button primary"></div>
      </div>
    </div>

    <!-- Score Card Skeleton -->
    <div v-else-if="variant === 'score-card'" class="skeleton-score-card">
      <div class="skeleton-score-header">
        <div class="skeleton-avatar"></div>
        <div class="skeleton-content">
          <div class="skeleton-line title"></div>
          <div class="skeleton-line subtitle"></div>
        </div>
      </div>
      <div class="skeleton-stats">
        <div class="skeleton-stat">
          <div class="skeleton-line short"></div>
          <div class="skeleton-line number"></div>
        </div>
        <div class="skeleton-stat">
          <div class="skeleton-line short"></div>
          <div class="skeleton-line number"></div>
        </div>
      </div>
    </div>

    <!-- Generic List Item Skeleton -->
    <div v-else class="skeleton-list-item">
      <div class="skeleton-line title"></div>
      <div class="skeleton-line"></div>
      <div class="skeleton-line short"></div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  variant: {
    type: String,
    default: 'default',
    validator: (value) => ['default', 'user-card', 'exam-card', 'score-card'].includes(value)
  }
})
</script>

<style scoped>
.skeleton-loader {
  animation: skeleton-pulse 1.5s ease-in-out infinite;
}

@keyframes skeleton-pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.7;
  }
}

/* Base skeleton elements */
.skeleton-line {
  height: 16px;
  background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
  background-size: 200% 100%;
  border-radius: 8px;
  margin-bottom: 8px;
  animation: skeleton-shimmer 1.5s infinite;
}

.skeleton-line.title {
  height: 20px;
  width: 70%;
}

.skeleton-line.subtitle {
  height: 14px;
  width: 50%;
}

.skeleton-line.short {
  width: 40%;
}

.skeleton-line.number {
  width: 60px;
  height: 24px;
}

@keyframes skeleton-shimmer {
  0% {
    background-position: -200% 0;
  }
  100% {
    background-position: 200% 0;
  }
}

/* User Card Skeleton */
.skeleton-user-card {
  background: #FFFFFF;
  border-radius: 16px;
  border: 1px solid rgba(0, 0, 0, 0.06);
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.skeleton-card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 16px;
}

.skeleton-avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
  background-size: 200% 100%;
  animation: skeleton-shimmer 1.5s infinite;
}

.skeleton-badges {
  display: flex;
  flex-direction: column;
  gap: 8px;
  align-items: flex-end;
}

.skeleton-badge {
  height: 24px;
  width: 80px;
  border-radius: 12px;
  background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
  background-size: 200% 100%;
  animation: skeleton-shimmer 1.5s infinite;
}

.skeleton-badge.small {
  width: 60px;
  height: 20px;
}

.skeleton-content {
  margin-bottom: 20px;
}

.skeleton-actions {
  display: flex;
  gap: 8px;
}

.skeleton-button {
  height: 36px;
  width: 80px;
  border-radius: 8px;
  background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
  background-size: 200% 100%;
  animation: skeleton-shimmer 1.5s infinite;
}

/* Exam Card Skeleton */
.skeleton-exam-card {
  background: #FFFFFF;
  border-radius: 16px;
  border: 1px solid rgba(0, 0, 0, 0.06);
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.skeleton-exam-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 16px;
}

.skeleton-exam-content {
  margin-bottom: 20px;
}

.skeleton-exam-footer {
  display: flex;
  justify-content: flex-end;
}

.skeleton-button.primary {
  width: 120px;
  background: linear-gradient(90deg, #e3f2fd 25%, #bbdefb 50%, #e3f2fd 75%);
  background-size: 200% 100%;
}

/* Score Card Skeleton */
.skeleton-score-card {
  background: #FFFFFF;
  border-radius: 16px;
  border: 1px solid rgba(0, 0, 0, 0.06);
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.skeleton-score-header {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 20px;
}

.skeleton-stats {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.skeleton-stat {
  text-align: center;
}

/* Generic List Item */
.skeleton-list-item {
  padding: 16px;
  background: #FFFFFF;
  border-radius: 12px;
  border: 1px solid rgba(0, 0, 0, 0.06);
}

/* Responsive */
@media (max-width: 768px) {
  .skeleton-user-card,
  .skeleton-exam-card,
  .skeleton-score-card {
    padding: 16px;
  }
  
  .skeleton-actions {
    flex-direction: column;
  }
  
  .skeleton-button {
    width: 100%;
  }
}

/* Dark mode support */
@media (prefers-color-scheme: dark) {
  .skeleton-line,
  .skeleton-avatar,
  .skeleton-badge,
  .skeleton-button {
    background: linear-gradient(90deg, #2a2a2a 25%, #3a3a3a 50%, #2a2a2a 75%);
    background-size: 200% 100%;
  }
  
  .skeleton-button.primary {
    background: linear-gradient(90deg, #1a237e 25%, #283593 50%, #1a237e 75%);
    background-size: 200% 100%;
  }
  
  .skeleton-user-card,
  .skeleton-exam-card,
  .skeleton-score-card,
  .skeleton-list-item {
    background: #1e1e1e;
    border-color: rgba(255, 255, 255, 0.1);
  }
}
</style>