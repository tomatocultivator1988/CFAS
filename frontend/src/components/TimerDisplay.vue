<template>
  <div class="timer-display" :class="{ warning: isWarning, critical: isCritical }">
    <div class="timer-icon">
      <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="12" cy="12" r="10"></circle>
        <polyline points="12 6 12 12 16 14"></polyline>
      </svg>
    </div>
    <div class="timer-content">
      <div class="timer-label">Time Remaining</div>
      <div class="timer-value">{{ formattedTime }}</div>
    </div>
  </div>
</template>

<script setup>
import { computed, defineProps } from 'vue'

const props = defineProps({
  remainingSeconds: {
    type: Number,
    required: true
  },
  formatTime: {
    type: Function,
    required: true
  }
})

const formattedTime = computed(() => props.formatTime(props.remainingSeconds))

const isWarning = computed(() => {
  const minutes = props.remainingSeconds / 60
  return minutes <= 10 && minutes > 5
})

const isCritical = computed(() => {
  const minutes = props.remainingSeconds / 60
  return minutes <= 5
})
</script>

<style scoped>
.timer-display {
  display: flex;
  align-items: center;
  gap: 12px;
  background: white;
  border: 2px solid #e5e7eb;
  border-radius: 8px;
  padding: 12px 20px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease;
}

.timer-display.warning {
  border-color: #f59e0b;
  background: #fffbeb;
}

.timer-display.warning .timer-icon {
  color: #f59e0b;
}

.timer-display.warning .timer-value {
  color: #f59e0b;
}

.timer-display.critical {
  border-color: #ef4444;
  background: #fef2f2;
  animation: pulse 1s ease-in-out infinite;
}

.timer-display.critical .timer-icon {
  color: #ef4444;
}

.timer-display.critical .timer-value {
  color: #ef4444;
}

@keyframes pulse {
  0%, 100% {
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  }
  50% {
    box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
  }
}

.timer-icon {
  color: #3b82f6;
  display: flex;
  align-items: center;
  transition: color 0.3s ease;
}

.timer-content {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.timer-label {
  font-size: 12px;
  color: #6b7280;
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.timer-value {
  font-size: 20px;
  font-weight: 700;
  color: #1f2937;
  font-variant-numeric: tabular-nums;
  transition: color 0.3s ease;
}
</style>
