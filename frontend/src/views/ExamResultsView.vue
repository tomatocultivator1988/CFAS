<template>
  <div class="results-container">
    <!-- Loading State -->
    <div v-if="loading" class="loading-container">
      <div class="spinner"></div>
      <p>Loading results...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="error-container">
      <div class="error-icon">⚠️</div>
      <h2>Unable to Load Results</h2>
      <p>{{ error }}</p>
      <button @click="$router.push('/exams')" class="btn-primary">
        Back to Exams
      </button>
    </div>

    <!-- Results Display -->
    <div v-else-if="result" class="results-content">
      <!-- Success Header -->
      <div class="results-header">
        <div class="success-icon" :class="{ pass: isPassing, fail: !isPassing }">
          <svg v-if="isPassing" xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
            <polyline points="22 4 12 14.01 9 11.01"></polyline>
          </svg>
          <svg v-else xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"></circle>
            <line x1="15" y1="9" x2="9" y2="15"></line>
            <line x1="9" y1="9" x2="15" y2="15"></line>
          </svg>
        </div>
        <h1>{{ isPassing ? 'Congratulations!' : 'Exam Completed' }}</h1>
        <p class="subtitle">{{ isPassing ? 'You passed the exam!' : 'Keep practicing to improve your score.' }}</p>
      </div>

      <!-- Score Card -->
      <div class="score-card">
        <div class="score-main">
          <div class="score-circle" :class="{ pass: isPassing, fail: !isPassing }">
            <div class="score-value">{{ result.percentage }}%</div>
            <div class="score-label">Score</div>
          </div>
        </div>

        <div class="score-details">
          <div class="detail-item">
            <div class="detail-label">Correct Answers</div>
            <div class="detail-value">{{ result.correct_answers }} / {{ result.total_questions }}</div>
          </div>
          <div class="detail-item">
            <div class="detail-label">Time Taken</div>
            <div class="detail-value">{{ formatDuration(result.time_taken) }}</div>
          </div>
          <div class="detail-item">
            <div class="detail-label">Completion Date</div>
            <div class="detail-value">{{ formatDate(result.completed_at) }}</div>
          </div>
        </div>
      </div>

      <!-- Exam Info -->
      <div class="exam-info-card">
        <h2>{{ result.exam_title || 'Exam' }}</h2>
        <div class="info-grid">
          <div class="info-item">
            <span class="info-label">Attempt Number:</span>
            <span class="info-value">{{ result.attempt_number || 1 }}</span>
          </div>
          <div class="info-item" v-if="result.passing_score">
            <span class="info-label">Passing Score:</span>
            <span class="info-value">{{ result.passing_score }}%</span>
          </div>
        </div>
      </div>

      <!-- Actions -->
      <div class="actions">
        <button @click="$router.push('/exams')" class="btn-primary">
          Back to Exams
        </button>
        <button v-if="canRetake" @click="retakeExam" class="btn-secondary">
          Retake Exam
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useExamStore } from '@/stores/exam'

const route = useRoute()
const router = useRouter()
const examStore = useExamStore()

const loading = ref(true)
const error = ref(null)

const result = computed(() => examStore.examResult)

const isPassing = computed(() => {
  if (!result.value) return false
  const passingScore = result.value.passing_score || 90
  return result.value.percentage >= passingScore
})

const canRetake = computed(() => {
  if (!result.value) return false
  const maxAttempts = result.value.max_attempts || 3
  const currentAttempt = result.value.attempt_number || 1
  return currentAttempt < maxAttempts
})

const formatDuration = (seconds) => {
  if (!seconds) return 'N/A'
  const hours = Math.floor(seconds / 3600)
  const minutes = Math.floor((seconds % 3600) / 60)
  const secs = seconds % 60
  
  if (hours > 0) {
    return `${hours}h ${minutes}m ${secs}s`
  }
  return `${minutes}m ${secs}s`
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  const date = new Date(dateString)
  return date.toLocaleString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const retakeExam = () => {
  examStore.clearExamData()
  router.push(`/exams/${route.params.id}/take`)
}

onMounted(async () => {
  // If no result in store, try to fetch it
  if (!result.value) {
    // For now, redirect to exams list
    // In a full implementation, we'd fetch the result from the API
    error.value = 'No exam result found'
    setTimeout(() => {
      router.push('/exams')
    }, 3000)
  }
  loading.value = false
})
</script>

<style scoped>
.results-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 40px 20px;
}

.loading-container,
.error-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 60vh;
  gap: 16px;
  color: white;
}

.spinner {
  width: 48px;
  height: 48px;
  border: 4px solid rgba(255, 255, 255, 0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.error-icon {
  font-size: 48px;
}

.error-container h2 {
  color: white;
  margin: 0;
}

.error-container p {
  color: rgba(255, 255, 255, 0.9);
  margin: 8px 0 24px;
}

.results-content {
  max-width: 800px;
  margin: 0 auto;
}

.results-header {
  text-align: center;
  color: white;
  margin-bottom: 32px;
}

.success-icon {
  margin: 0 auto 24px;
  width: 80px;
  height: 80px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.success-icon.pass {
  background: #10b981;
  color: white;
}

.success-icon.fail {
  background: #ef4444;
  color: white;
}

.results-header h1 {
  margin: 0 0 8px 0;
  font-size: 36px;
  font-weight: 700;
}

.subtitle {
  font-size: 18px;
  opacity: 0.9;
  margin: 0;
}

.score-card {
  background: white;
  border-radius: 16px;
  padding: 40px;
  margin-bottom: 24px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
}

.score-main {
  display: flex;
  justify-content: center;
  margin-bottom: 32px;
}

.score-circle {
  width: 200px;
  height: 200px;
  border-radius: 50%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  position: relative;
}

.score-circle.pass {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  box-shadow: 0 8px 32px rgba(16, 185, 129, 0.3);
}

.score-circle.fail {
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  box-shadow: 0 8px 32px rgba(239, 68, 68, 0.3);
}

.score-value {
  font-size: 48px;
  font-weight: 700;
  color: white;
}

.score-label {
  font-size: 16px;
  color: rgba(255, 255, 255, 0.9);
  text-transform: uppercase;
  letter-spacing: 1px;
}

.score-details {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 24px;
}

.detail-item {
  text-align: center;
  padding: 16px;
  background: #f9fafb;
  border-radius: 8px;
}

.detail-label {
  font-size: 14px;
  color: #6b7280;
  margin-bottom: 8px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.detail-value {
  font-size: 20px;
  font-weight: 700;
  color: #1f2937;
}

.exam-info-card {
  background: white;
  border-radius: 16px;
  padding: 32px;
  margin-bottom: 24px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
}

.exam-info-card h2 {
  margin: 0 0 20px 0;
  color: #1f2937;
  font-size: 24px;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 16px;
}

.info-item {
  display: flex;
  justify-content: space-between;
  padding: 12px;
  background: #f9fafb;
  border-radius: 6px;
}

.info-label {
  color: #6b7280;
  font-weight: 500;
}

.info-value {
  color: #1f2937;
  font-weight: 600;
}

.actions {
  display: flex;
  gap: 16px;
  justify-content: center;
}

.btn-primary,
.btn-secondary {
  padding: 14px 32px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  border: none;
  font-size: 16px;
}

.btn-primary {
  background: white;
  color: #667eea;
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
}

.btn-secondary {
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: 2px solid white;
}

.btn-secondary:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: translateY(-2px);
}
</style>
