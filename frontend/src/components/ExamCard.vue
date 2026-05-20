<template>
  <div class="exam-card">
    <div class="exam-header">
      <div class="exam-title-section">
        <h3 class="exam-title">{{ exam.title }}</h3>
        <span class="exam-status" :class="statusClass">{{ statusText }}</span>
      </div>
      <p class="exam-description">{{ exam.description || 'No description available' }}</p>
    </div>
    
    <div class="exam-meta">
      <div class="meta-item">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
        </svg>
        <span>{{ exam.time_limit_minutes }} min</span>
      </div>
      <div class="meta-item">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
        </svg>
        <span>{{ exam.total_questions || 'N/A' }} questions</span>
      </div>
      <div class="meta-item">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
        </svg>
        <span>{{ exam.attempts_used || 0 }}/{{ exam.max_attempts }}</span>
      </div>
    </div>
    
    <!-- Latest Score - Inline with button -->
    <div class="exam-footer">
      <div v-if="exam.latest_score !== null && exam.latest_score !== undefined" class="score-inline" :class="scoreClass">
        <svg viewBox="0 0 24 24" fill="currentColor">
          <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
        </svg>
        <span class="score-label-text">Last Score:</span>
        <span class="score-text">{{ exam.latest_score }}%</span>
      </div>
      
      <button 
        class="btn-start-exam" 
        @click="$emit('start-exam', exam.id)"
        :disabled="isDisabled"
        :class="{ 'btn-disabled': isDisabled }"
      >
        <span v-if="loading" class="btn-spinner"></span>
        <template v-else>
          <svg v-if="hasAttemptsLeft" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
            <path d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
          </svg>
          <span>{{ buttonText }}</span>
        </template>
      </button>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  exam: {
    type: Object,
    required: true
  },
  loading: {
    type: Boolean,
    default: false
  }
})

defineEmits(['start-exam'])

const attemptsUsed = computed(() => props.exam.attempts_used || 0)
const maxAttempts = computed(() => props.exam.max_attempts || 3)
const hasAttemptsLeft = computed(() => attemptsUsed.value < maxAttempts.value)

const isDisabled = computed(() => !hasAttemptsLeft.value || props.loading)

const buttonText = computed(() => {
  if (!hasAttemptsLeft.value) return 'No Attempts Left'
  if (attemptsUsed.value === 0) return 'Start Exam'
  return 'Retake Exam'
})

const statusClass = computed(() => {
  if (!hasAttemptsLeft.value) return 'status-exhausted'
  if (attemptsUsed.value === 0) return 'status-new'
  return 'status-completed'
})

const statusText = computed(() => {
  if (!hasAttemptsLeft.value) return 'Exhausted'
  if (attemptsUsed.value === 0) return 'New'
  return 'Completed'
})

const scoreClass = computed(() => {
  const score = props.exam.latest_score || 0
  if (score >= 90) return 'score-excellent'
  if (score >= 50) return 'score-good'
  return 'score-needs-improvement'
})
</script>

<style scoped>
* {
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

.exam-card {
  background: #FFFFFF;
  border-radius: 16px;
  padding: 28px;
  border: 1px solid rgba(0, 0, 0, 0.06);
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  flex-direction: column;
  gap: 24px;
  height: 100%;
}

.exam-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
  border-color: rgba(0, 122, 255, 0.2);
}

.exam-header {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.exam-title-section {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
}

.exam-title {
  margin: 0;
  font-size: 22px;
  font-weight: 700;
  color: #1D1D1F;
  letter-spacing: -0.5px;
  line-height: 1.3;
  flex: 1;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.exam-status {
  padding: 5px 12px;
  border-radius: 6px;
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.3px;
  flex-shrink: 0;
}

.status-new {
  background: rgba(0, 122, 255, 0.1);
  color: #007AFF;
}

.status-completed {
  background: rgba(52, 199, 89, 0.1);
  color: #34C759;
}

.status-exhausted {
  background: rgba(255, 59, 48, 0.1);
  color: #FF3B30;
}

.exam-description {
  color: #86868B;
  font-size: 15px;
  line-height: 1.5;
  margin: 0;
  letter-spacing: -0.1px;
  min-height: 44px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.exam-meta {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 10px;
  padding: 16px 18px;
  background: #F5F5F7;
  border-radius: 12px;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 7px;
  min-width: 0;
  font-size: 14px;
  font-weight: 500;
  color: #1D1D1F;
  letter-spacing: -0.1px;
  white-space: nowrap;
  overflow: hidden;
}

.meta-item svg {
  width: 17px;
  height: 17px;
  color: #86868B;
  stroke-width: 2;
  flex-shrink: 0;
}

.exam-footer {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-top: auto;
}

.score-inline {
  display: flex;
  align-items: center;
  gap: 7px;
  padding: 10px 16px;
  border-radius: 10px;
  font-size: 14px;
  font-weight: 700;
  letter-spacing: -0.2px;
  flex-shrink: 0;
  white-space: nowrap;
}

.score-inline svg {
  width: 19px;
  height: 19px;
  flex-shrink: 0;
}

.score-inline.score-excellent {
  background: rgba(52, 199, 89, 0.12);
  color: #34C759;
}

.score-inline.score-good {
  background: rgba(255, 149, 0, 0.12);
  color: #FF9500;
}

.score-inline.score-needs-improvement {
  background: rgba(255, 59, 48, 0.12);
  color: #FF3B30;
}

.score-label-text {
  font-size: 13px;
  font-weight: 500;
  opacity: 0.8;
}

.score-text {
  font-variant-numeric: tabular-nums;
  font-weight: 700;
}

.btn-start-exam {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  padding: 10px 18px;
  background: #1D1D1F;
  color: white;
  border: none;
  border-radius: 10px;
  font-size: 13px;
  font-weight: 600;
  letter-spacing: -0.2px;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  min-height: 42px;
  white-space: nowrap;
}

.btn-start-exam:hover:not(.btn-disabled) {
  background: #000000;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

.btn-start-exam:active:not(.btn-disabled) {
  transform: translateY(0);
}

.btn-start-exam svg {
  width: 16px;
  height: 16px;
  stroke-width: 2;
}

.btn-disabled {
  background: #E8E8ED;
  color: #86868B;
  cursor: not-allowed;
  box-shadow: none;
}

.btn-spinner {
  width: 18px;
  height: 18px;
  border: 2.5px solid rgba(255, 255, 255, 0.3);
  border-top-color: #FFFFFF;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

@media (max-width: 768px) {
  .exam-card {
    padding: 20px;
  }
  
  .exam-title {
    font-size: 18px;
  }
  
  .exam-meta {
    grid-template-columns: 1fr;
    gap: 10px;
  }

  .exam-footer {
    flex-direction: column;
    align-items: stretch;
  }

  .score-inline {
    width: 100%;
    justify-content: center;
  }

  .btn-start-exam {
    width: 100%;
  }
  
  .score-percentage {
    font-size: 28px;
  }
}
</style>
