<template>
  <div class="exam-list-container">
    <!-- Force Password Change Modal -->
    <ForcePasswordChange 
      v-if="showPasswordChangeModal" 
      @password-changed="handlePasswordChanged"
    />

    <!-- Success Message - Simple & Minimalistic -->
    <transition name="fade-slide">
      <div v-if="showSuccessMessage" class="success-toast">
        <svg class="success-check" viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5"/>
        </svg>
        <span>Exam submitted successfully</span>
      </div>
    </transition>

    <!-- Loading Overlay -->
    <transition name="fade">
      <div v-if="loading" class="loading-overlay">
        <div class="loading-container">
          <div class="loading-spinner">
            <div class="spinner-ring"></div>
            <div class="spinner-ring"></div>
            <div class="spinner-ring"></div>
          </div>
          <p class="loading-text">Loading Your Exams</p>
        </div>
      </div>
    </transition>

    <!-- Header Section -->
    <div class="dashboard-header">
      <div class="header-content">
        <div class="header-left">
          <h1 class="dashboard-title">My Exams</h1>
          <p class="dashboard-subtitle">Select an exam to begin your assessment</p>
        </div>
        <div class="header-right">
          <div v-if="autoRefreshActive" class="auto-refresh-indicator">
            <div class="refresh-dot" :class="{ 'pulsing': autoRefreshing }"></div>
            <span class="refresh-text">Auto-updating</span>
          </div>
        </div>
      </div>
    </div>
    
    <div v-if="error" class="error-state">
      <p class="error-message">{{ error }}</p>
      <button class="btn btn-secondary" @click="loadExams">Retry</button>
    </div>
    
    <div v-else-if="!loading">
      <div v-if="exams.length === 0" class="empty-state">
        <div class="empty-icon">📚</div>
        <h3>No Exams Available</h3>
        <p>You don't have any exams assigned yet. Check back later!</p>
      </div>
      
      <div v-else class="exam-grid">
        <ExamCard 
          v-for="exam in exams" 
          :key="exam.id" 
          :exam="exam"
          :loading="startingExamId === exam.id"
          @start-exam="handleStartExam"
        />
      </div>
      
      <!-- Exam History Section -->
      <div v-if="examHistory.length > 0" class="history-section">
        <div class="history-header-section">
          <div class="history-header-content">
            <div class="history-icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
              </svg>
            </div>
            <div>
              <h2 class="history-title">Exam History</h2>
              <p class="history-subtitle">{{ examHistory.length }} attempt{{ examHistory.length !== 1 ? 's' : '' }} • {{ averageScore }}% average score</p>
            </div>
          </div>
        </div>
        
        <div class="history-list">
          <div 
            v-for="attempt in examHistory" 
            :key="attempt.id" 
            class="history-item"
            @click="viewAttemptReview(attempt.id)"
          >
            <div class="history-item-left">
              <div class="history-exam-title">{{ attempt.exam_title }}</div>
              <div class="history-details">
                <span class="history-date">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <path d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                  </svg>
                  {{ formatDate(attempt.end_time) }}
                </span>
                <span class="history-separator">•</span>
                <span class="history-attempt">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                  </svg>
                  Attempt {{ attempt.attempt_number }}
                </span>
              </div>
            </div>
            <div class="history-item-right">
              <div class="history-score" :class="getScoreClass(attempt.percentage)">
                {{ attempt.percentage }}%
              </div>
              <div class="history-arrow">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <path d="M9 5l7 7-7 7" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                </svg>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Review Modal -->
    <transition name="modal-fade">
      <div v-if="showReviewModal" class="modal-overlay-review">
        <transition name="modal-scale">
          <div v-if="showReviewModal" class="review-modal">
            <div class="review-header">
              <div>
                <h2 class="review-title">{{ reviewData?.attempt?.exam_title }}</h2>
                <p class="review-subtitle">Exam Review - Attempt #{{ reviewData?.attempt?.attempt_number }}</p>
              </div>
              <button @click="closeReviewModal" class="btn-close-review">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <path d="M6 18L18 6M6 6l12 12" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                </svg>
              </button>
            </div>
            
            <div class="review-score-summary">
              <div class="summary-item">
                <div class="summary-icon" :class="getScoreClass(reviewData?.attempt?.percentage)">
                  {{ reviewData?.attempt?.percentage }}%
                </div>
                <div class="summary-info">
                  <div class="summary-label">Final Score</div>
                  <div class="summary-value">{{ reviewData?.attempt?.score }}/{{ reviewData?.attempt?.total_questions }}</div>
                </div>
              </div>
            </div>
            
            <div class="review-questions">
              <div 
                v-for="(question, index) in reviewData?.questions" 
                :key="question.id" 
                class="review-question-card"
                :class="{ 'correct': question.is_correct, 'incorrect': !question.is_correct }"
              >
                <div class="question-header-review">
                  <div class="question-number-badge" :class="question.is_correct ? 'correct-badge' : 'incorrect-badge'">
                    <svg v-if="question.is_correct" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                      <path d="M5 13l4 4L19 7" stroke-linecap="round" stroke-linejoin="round" stroke-width="3"/>
                    </svg>
                    <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor">
                      <path d="M6 18L18 6M6 6l12 12" stroke-linecap="round" stroke-linejoin="round" stroke-width="3"/>
                    </svg>
                  </div>
                  <span class="question-number">Question {{ question.order || (index + 1) }}</span>
                </div>
                
                <div class="question-text-review">{{ question.question_text }}</div>
                
                <div class="choices-review">
                  <div 
                    v-for="choice in question.choices" 
                    :key="choice.id"
                    class="choice-review"
                    :class="{
                      'user-choice': choice.id === question.user_answer_id,
                      'correct-choice': choice.is_correct,
                      'wrong-choice': choice.id === question.user_answer_id && !choice.is_correct
                    }"
                  >
                    <div class="choice-indicator">
                      <svg v-if="choice.is_correct" viewBox="0 0 24 24" fill="currentColor">
                        <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                      </svg>
                      <svg v-else-if="choice.id === question.user_answer_id" viewBox="0 0 24 24" fill="currentColor">
                        <path d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                      </svg>
                      <div v-else class="empty-circle"></div>
                    </div>
                    <div class="choice-content">
                      <div class="choice-text-review">{{ choice.choice_text }}</div>
                      <div v-if="choice.is_correct" class="choice-label correct-label">Correct Answer</div>
                      <div v-else-if="choice.id === question.user_answer_id" class="choice-label your-label">Your Answer</div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </transition>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useExamStore } from '@/stores/exam'
import { useAuthStore } from '@/stores/auth'
import ExamCard from '@/components/ExamCard.vue'
import ForcePasswordChange from '@/components/ForcePasswordChange.vue'
import { useRevieweeAutoRefresh } from '@/composables/useComponentAutoRefresh'

const router = useRouter()
const route = useRoute()
const examStore = useExamStore()
const authStore = useAuthStore()

const exams = ref([])
const examHistory = ref([])
const loading = ref(true)
const error = ref(null)
const startingExamId = ref(null)
const showPasswordChangeModal = ref(false)
const showReviewModal = ref(false)
const reviewData = ref(null)
const showSuccessMessage = ref(false)

// Watch for route changes to refresh data
watch(() => route.path, (newPath) => {
  if (newPath === '/exams') {
    // Refresh data when returning to exam list
    loadExams()
    loadHistory()
    
    // Show success message if coming from exam submission
    if (route.query.submitted === 'true') {
      showSuccessMessage.value = true
      setTimeout(() => {
        showSuccessMessage.value = false
        // Clean up URL - just clear query params, don't navigate to same route
        router.replace({ query: {} })
      }, 3000)
    }
  }
})

onMounted(async () => {
  // Check if password change is required
  if (authStore.user?.require_password_change) {
    showPasswordChangeModal.value = true
    loading.value = false // Stop loading so modal is visible
  } else {
    await loadExams()
    await loadHistory()
    
    // Show success message if coming from exam submission
    if (route.query.submitted === 'true') {
      showSuccessMessage.value = true
      setTimeout(() => {
        showSuccessMessage.value = false
        // Clean up URL - just clear query params, don't navigate to same route
        router.replace({ query: {} })
      }, 3000)
    }
  }
})

const loadExams = async () => {
  loading.value = true
  error.value = null
  
  const result = await examStore.loadAssignedExams()
  if (result.success) {
    exams.value = examStore.assignedExams
  } else {
    error.value = result.error
  }
  
  loading.value = false
}

const loadHistory = async () => {
  try {
    const response = await examStore.loadExamHistory()
    if (response.success) {
      examHistory.value = response.data
    }
  } catch (err) {
    console.error('Failed to load history:', err)
  }
}

const refreshAllData = async () => {
  await Promise.all([loadExams(), loadHistory()])
}

// Auto-refresh setup for reviewee exams and history
const { isRegistered: autoRefreshActive } = useRevieweeAutoRefresh.exams(refreshAllData)

const formatDate = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { 
    year: 'numeric', 
    month: 'short', 
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const getScoreClass = (percentage) => {
  if (percentage >= 90) return 'score-excellent'
  if (percentage >= 50) return 'score-good'
  return 'score-poor'
}

const averageScore = computed(() => {
  if (examHistory.value.length === 0) return 0
  const total = examHistory.value.reduce((sum, attempt) => sum + attempt.percentage, 0)
  return Math.round(total / examHistory.value.length)
})

const handleStartExam = async (examId) => {
  startingExamId.value = examId
  router.push(`/exams/${examId}/take`)
}

const handlePasswordChanged = async () => {
  showPasswordChangeModal.value = false
  // Refresh user data to update require_password_change flag
  await authStore.validateSession()
  // Load exams after password change
  await loadExams()
  await loadHistory()
}

const viewAttemptReview = async (attemptId) => {
  reviewData.value = null
  showReviewModal.value = true
  
  const result = await examStore.getAttemptReview(attemptId)
  if (result.success) {
    reviewData.value = result.data
  } else {
    error.value = result.error
    showReviewModal.value = false
  }
}

const closeReviewModal = () => {
  showReviewModal.value = false
  reviewData.value = null
}
</script>

<style scoped>
* {
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

.exam-list-container {
  padding: 0;
  min-height: 100vh;
  background: #F5F5F7;
  position: relative;
}

/* Loading Overlay */
.loading-overlay {
  position: fixed;
  inset: 0;
  background: rgba(245, 245, 247, 0.95);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
}

.loading-container {
  text-align: center;
}

.loading-spinner {
  position: relative;
  width: 80px;
  height: 80px;
  margin: 0 auto 24px;
}

.spinner-ring {
  position: absolute;
  width: 100%;
  height: 100%;
  border: 3px solid transparent;
  border-top-color: #007AFF;
  border-radius: 50%;
  animation: spin 1.2s cubic-bezier(0.5, 0, 0.5, 1) infinite;
}

.spinner-ring:nth-child(1) {
  animation-delay: -0.45s;
  border-top-color: #007AFF;
}

.spinner-ring:nth-child(2) {
  animation-delay: -0.3s;
  border-top-color: #5AC8FA;
  width: 70%;
  height: 70%;
  top: 15%;
  left: 15%;
}

.spinner-ring:nth-child(3) {
  animation-delay: -0.15s;
  border-top-color: #34C759;
  width: 40%;
  height: 40%;
  top: 30%;
  left: 30%;
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

.loading-text {
  font-size: 17px;
  font-weight: 600;
  color: #1D1D1F;
  letter-spacing: -0.3px;
  animation: pulse 1.5s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

/* Dashboard Header */
.dashboard-header {
  padding: 32px 48px 24px;
  background: #FFFFFF;
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
}

.header-content {
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.header-left {
  flex: 1;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

.auto-refresh-indicator {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  background: rgba(52, 199, 89, 0.1);
  border-radius: 20px;
  font-size: 13px;
  font-weight: 500;
  color: #34C759;
}

.refresh-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #34C759;
  transition: all 0.3s ease;
}

.refresh-dot.pulsing {
  animation: pulse 1.5s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% {
    opacity: 1;
    transform: scale(1);
  }
  50% {
    opacity: 0.6;
    transform: scale(1.2);
  }
}

.refresh-text {
  letter-spacing: -0.1px;
}

.dashboard-title {
  font-size: 32px;
  font-weight: 700;
  color: #1D1D1F;
  margin: 0 0 6px 0;
  letter-spacing: -0.6px;
}

.dashboard-subtitle {
  font-size: 15px;
  color: #86868B;
  margin: 0;
  font-weight: 400;
  letter-spacing: -0.2px;
}

.page-header {
  margin-bottom: 36px;
  position: relative;
  z-index: 1;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.header-content {
  flex: 1;
}

.page-header h1 {
  font-size: 40px;
  font-weight: 700;
  color: #1D1D1F;
  margin: 0 0 8px 0;
  letter-spacing: -0.8px;
}

.btn-logout {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 20px;
  background: rgba(255, 59, 48, 0.1);
  color: #FF3B30;
  border: 1px solid rgba(255, 59, 48, 0.2);
  border-radius: 12px;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  letter-spacing: -0.2px;
}

.btn-logout svg {
  width: 20px;
  height: 20px;
  stroke-width: 2;
}

.btn-logout:hover {
  background: rgba(255, 59, 48, 0.15);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(255, 59, 48, 0.2);
}

.btn-logout:active {
  transform: scale(0.96);
}

.subtitle {
  font-size: 17px;
  color: #86868B;
  margin: 0;
  font-weight: 400;
  letter-spacing: -0.2px;
}

.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80px 20px;
  text-align: center;
  position: relative;
  z-index: 1;
}

.spinner-large {
  width: 50px;
  height: 50px;
  border: 3px solid transparent;
  border-top-color: #1D1D1F;
  border-radius: 50%;
  animation: spin 1s cubic-bezier(0.68, -0.55, 0.265, 1.55) infinite;
  margin-bottom: 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.loading-state p {
  color: #86868B;
  font-size: 17px;
  font-weight: 500;
  letter-spacing: -0.2px;
}

.error-state {
  text-align: center;
  padding: 80px 20px;
  position: relative;
  z-index: 1;
  max-width: 1200px;
  margin: 0 auto;
}

.error-message {
  color: #FF3B30;
  font-size: 17px;
  font-weight: 500;
  margin-bottom: 24px;
  letter-spacing: -0.2px;
}

.empty-state {
  text-align: center;
  padding: 60px 20px;
  position: relative;
  z-index: 1;
  max-width: 1200px;
  margin: 0 auto;
}

.empty-icon {
  font-size: 56px;
  margin-bottom: 16px;
  opacity: 0.5;
}

.empty-state h3 {
  font-size: 24px;
  font-weight: 700;
  color: #1D1D1F;
  margin: 0 0 8px 0;
  letter-spacing: -0.5px;
}

.empty-state p {
  font-size: 15px;
  color: #86868B;
  margin: 0;
  font-weight: 400;
  letter-spacing: -0.2px;
}

.exam-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 20px;
  position: relative;
  z-index: 1;
  max-width: 1200px;
  margin: 0 auto;
  padding: 24px 48px;
}

.btn {
  padding: 14px 24px;
  border: none;
  border-radius: 12px;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  letter-spacing: -0.2px;
}

.btn-secondary {
  background: #FFFFFF;
  color: #1D1D1F;
  border: 1px solid rgba(0, 0, 0, 0.06);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.btn-secondary:hover {
  background: #F5F5F7;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

@media (max-width: 1024px) {
  .exam-list-container {
    padding: 0;
  }

  .dashboard-header {
    padding: 28px 32px 20px;
  }

  .exam-grid {
    padding: 20px 32px;
  }

  .history-section {
    padding: 28px 32px 40px;
  }

  .page-header h1 {
    font-size: 34px;
  }
}

@media (max-width: 768px) {
  .exam-list-container {
    padding: 0;
  }

  .dashboard-header {
    padding: 20px 16px 16px;
  }

  .header-content {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }

  .header-left {
    width: 100%;
  }

  .dashboard-title {
    font-size: 24px;
  }

  .dashboard-subtitle {
    font-size: 14px;
  }

  .header-right {
    width: 100%;
  }

  .auto-refresh-indicator {
    justify-content: flex-start;
  }

  .exam-grid {
    grid-template-columns: 1fr;
    padding: 16px;
    gap: 16px;
  }

  .history-section {
    padding: 24px 16px 32px;
  }

  .history-header-content {
    gap: 12px;
  }

  .history-icon {
    width: 40px;
    height: 40px;
  }

  .history-icon svg {
    width: 20px;
    height: 20px;
  }

  .history-title {
    font-size: 20px;
  }

  .history-subtitle {
    font-size: 13px;
  }

  .history-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
    padding: 16px;
  }

  .history-item-left {
    width: 100%;
  }

  .history-item-right {
    width: 100%;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
  }

  .history-exam-title {
    font-size: 15px;
  }

  .history-details {
    flex-wrap: wrap;
    gap: 8px;
    font-size: 12px;
  }

  .history-score {
    font-size: 20px;
  }

  .review-modal {
    max-width: 95%;
    max-height: 90vh;
    padding: 20px;
    border-radius: 16px;
  }

  .review-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
    padding-bottom: 16px;
  }

  .btn-close-review {
    position: absolute;
    top: 16px;
    right: 16px;
  }

  .review-title {
    font-size: 20px;
    padding-right: 40px;
  }

  .review-subtitle {
    font-size: 13px;
  }

  .review-score-summary {
    flex-direction: column;
    gap: 12px;
  }

  .summary-item {
    width: 100%;
  }

  .review-content {
    padding: 16px;
  }

  .question-card {
    padding: 16px;
  }

  .question-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }

  .question-number {
    font-size: 13px;
    padding: 6px 12px;
  }

  .question-text {
    font-size: 15px;
  }

  .choice-item {
    padding: 12px;
    font-size: 14px;
  }

  .choice-letter {
    width: 28px;
    height: 28px;
    font-size: 13px;
  }

  .page-header h1 {
    font-size: 28px;
  }

  .subtitle {
    font-size: 15px;
  }

  .empty-state {
    padding: 40px 20px;
  }

  .empty-icon {
    font-size: 48px;
  }

  .empty-state h3 {
    font-size: 20px;
  }

  .empty-state p {
    font-size: 14px;
  }

  .error-state {
    padding: 32px 20px;
  }

  .error-message {
    font-size: 14px;
  }

  .btn {
    padding: 12px 20px;
    font-size: 14px;
  }
}

@media (max-width: 480px) {
  .dashboard-header {
    padding: 16px 12px 12px;
  }

  .dashboard-title {
    font-size: 20px;
  }

  .dashboard-subtitle {
    font-size: 13px;
  }

  .auto-refresh-indicator {
    padding: 6px 12px;
    font-size: 12px;
  }

  .refresh-dot {
    width: 6px;
    height: 6px;
  }

  .exam-grid {
    padding: 12px;
    gap: 12px;
  }

  .history-section {
    padding: 20px 12px 24px;
  }

  .history-icon {
    width: 36px;
    height: 36px;
  }

  .history-icon svg {
    width: 18px;
    height: 18px;
  }

  .history-title {
    font-size: 18px;
  }

  .history-subtitle {
    font-size: 12px;
  }

  .history-item {
    padding: 12px;
  }

  .history-exam-title {
    font-size: 14px;
  }

  .history-details {
    font-size: 11px;
  }

  .history-details svg {
    width: 12px;
    height: 12px;
  }

  .history-score {
    font-size: 18px;
  }

  .history-arrow svg {
    width: 16px;
    height: 16px;
  }

  .review-modal {
    padding: 16px;
    border-radius: 12px;
  }

  .review-header {
    padding-bottom: 12px;
  }

  .btn-close-review {
    top: 12px;
    right: 12px;
    width: 32px;
    height: 32px;
  }

  .btn-close-review svg {
    width: 18px;
    height: 18px;
  }

  .review-title {
    font-size: 18px;
  }

  .review-subtitle {
    font-size: 12px;
  }

  .summary-icon {
    width: 56px;
    height: 56px;
    font-size: 20px;
  }

  .summary-label {
    font-size: 11px;
  }

  .summary-value {
    font-size: 13px;
  }

  .review-content {
    padding: 12px;
  }

  .question-card {
    padding: 12px;
    margin-bottom: 12px;
  }

  .question-number {
    font-size: 12px;
    padding: 4px 10px;
  }

  .question-text {
    font-size: 14px;
  }

  .choices-list {
    gap: 8px;
  }

  .choice-item {
    padding: 10px;
    font-size: 13px;
  }

  .choice-letter {
    width: 24px;
    height: 24px;
    font-size: 12px;
  }

  .choice-text {
    font-size: 13px;
  }

  .empty-state {
    padding: 32px 16px;
  }

  .empty-icon {
    font-size: 40px;
  }

  .empty-state h3 {
    font-size: 18px;
  }

  .empty-state p {
    font-size: 13px;
  }

  .error-state {
    padding: 24px 16px;
  }

  .error-message {
    font-size: 13px;
  }

  .btn {
    padding: 10px 16px;
    font-size: 13px;
  }

  .success-toast {
    padding: 12px 16px;
    font-size: 13px;
    border-radius: 10px;
  }

  .success-check {
    width: 18px;
    height: 18px;
  }

  .loading-text {
    font-size: 14px;
  }

  .spinner-ring {
    width: 40px;
    height: 40px;
  }
}

/* Exam History Section - Professional Design */
.history-section {
  margin-top: 0;
  padding: 32px 48px 48px;
  position: relative;
  z-index: 1;
  max-width: 1200px;
  margin: 0 auto;
}

.history-header-section {
  margin-bottom: 20px;
}

.history-header-content {
  display: flex;
  align-items: center;
  gap: 16px;
}

.history-icon {
  width: 48px;
  height: 48px;
  background: linear-gradient(135deg, #007AFF 0%, #0051D5 100%);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  box-shadow: 0 4px 12px rgba(0, 122, 255, 0.25);
}

.history-icon svg {
  width: 24px;
  height: 24px;
  color: white;
  stroke-width: 2;
}

.history-title {
  font-size: 24px;
  font-weight: 700;
  color: #1D1D1F;
  margin: 0 0 4px 0;
  letter-spacing: -0.5px;
}

.history-subtitle {
  font-size: 14px;
  color: #86868B;
  margin: 0;
  font-weight: 500;
  letter-spacing: -0.1px;
}

.history-list {
  background: #FFFFFF;
  border-radius: 16px;
  overflow: hidden;
  border: 1px solid rgba(0, 0, 0, 0.06);
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
}

.history-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20px;
  padding: 18px 24px;
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

.history-item:last-child {
  border-bottom: none;
}

.history-item:hover {
  background: #F5F5F7;
  transform: translateX(4px);
}

.history-item:active {
  background: #E8E8ED;
  transform: translateX(2px);
}

.history-item-left {
  flex: 1;
  min-width: 0;
}

.history-exam-title {
  font-size: 16px;
  font-weight: 600;
  color: #1D1D1F;
  margin-bottom: 8px;
  letter-spacing: -0.3px;
}

.history-details {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 13px;
  color: #86868B;
  letter-spacing: -0.1px;
}

.history-date,
.history-attempt {
  display: flex;
  align-items: center;
  gap: 6px;
  font-weight: 500;
}

.history-date svg,
.history-attempt svg {
  width: 14px;
  height: 14px;
  stroke-width: 2;
  opacity: 0.7;
}

.history-separator {
  color: #C7C7CC;
  font-weight: 400;
}

.history-item-right {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-shrink: 0;
}

.history-score {
  font-size: 18px;
  font-weight: 700;
  padding: 8px 16px;
  border-radius: 10px;
  letter-spacing: -0.3px;
  min-width: 70px;
  text-align: center;
}

.history-score.score-excellent {
  color: #34C759;
  background: rgba(52, 199, 89, 0.12);
  box-shadow: 0 2px 8px rgba(52, 199, 89, 0.15);
}

.history-score.score-good {
  color: #FF9500;
  background: rgba(255, 149, 0, 0.12);
  box-shadow: 0 2px 8px rgba(255, 149, 0, 0.15);
}

.history-score.score-poor {
  color: #FF3B30;
  background: rgba(255, 59, 48, 0.12);
  box-shadow: 0 2px 8px rgba(255, 59, 48, 0.15);
}

.history-arrow {
  width: 20px;
  height: 20px;
  color: #C7C7CC;
  transition: all 0.2s;
}

.history-item:hover .history-arrow {
  color: #007AFF;
  transform: translateX(4px);
}

.history-arrow svg {
  width: 100%;
  height: 100%;
  stroke-width: 2;
}

/* Review Modal */
.modal-overlay-review {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.4);
  backdrop-filter: blur(8px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10000;
  padding: 20px;
  overflow-y: auto;
}

.review-modal {
  background: #FFFFFF;
  border-radius: 16px;
  max-width: 800px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.12);
}

.review-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 24px 24px 20px;
  background: #FFFFFF;
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
  position: sticky;
  top: 0;
  z-index: 10;
}

.review-title {
  font-size: 20px;
  font-weight: 700;
  color: #1D1D1F;
  margin: 0 0 4px 0;
  letter-spacing: -0.4px;
}

.review-subtitle {
  font-size: 14px;
  color: #86868B;
  margin: 0;
  font-weight: 400;
  letter-spacing: -0.1px;
}

.btn-close-review {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: #F5F5F7;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s;
  flex-shrink: 0;
}

.btn-close-review:hover {
  background: #E8E8ED;
}

.btn-close-review:active {
  transform: scale(0.95);
}

.btn-close-review svg {
  width: 18px;
  height: 18px;
  color: #1D1D1F;
  stroke-width: 2;
}

.review-score-summary {
  padding: 20px 24px;
  background: #F5F5F7;
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
}

.summary-item {
  display: flex;
  align-items: center;
  gap: 16px;
}

.summary-icon {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  font-weight: 700;
  color: white;
  letter-spacing: -0.5px;
  flex-shrink: 0;
}

.summary-icon.score-excellent {
  background: #34C759;
}

.summary-icon.score-good {
  background: #FF9500;
}

.summary-icon.score-poor {
  background: #FF3B30;
}

.summary-info {
  flex: 1;
}

.summary-label {
  font-size: 13px;
  color: #86868B;
  font-weight: 500;
  margin-bottom: 2px;
  letter-spacing: -0.1px;
}

.summary-value {
  font-size: 24px;
  font-weight: 700;
  color: #1D1D1F;
  letter-spacing: -0.6px;
}

.review-questions {
  padding: 20px 24px 24px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.review-question-card {
  background: #F5F5F7;
  border-radius: 12px;
  padding: 16px;
  border-left: 3px solid transparent;
  transition: all 0.2s;
}

.review-question-card.correct {
  border-left-color: #34C759;
}

.review-question-card.incorrect {
  border-left-color: #FF3B30;
}

.question-header-review {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 12px;
}

.question-number-badge {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.correct-badge {
  background: #34C759;
}

.incorrect-badge {
  background: #FF3B30;
}

.question-number-badge svg {
  width: 16px;
  height: 16px;
  color: white;
  stroke-width: 2.5;
}

.question-number {
  font-size: 14px;
  font-weight: 600;
  color: #1D1D1F;
  letter-spacing: -0.2px;
}

.question-text-review {
  font-size: 15px;
  color: #1D1D1F;
  font-weight: 500;
  line-height: 1.5;
  margin-bottom: 12px;
  letter-spacing: -0.2px;
}

.choices-review {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.choice-review {
  display: flex;
  gap: 10px;
  padding: 12px;
  border-radius: 8px;
  background: #FFFFFF;
  border: 1px solid rgba(0, 0, 0, 0.06);
  transition: all 0.2s;
}

.choice-review.correct-choice {
  background: rgba(52, 199, 89, 0.08);
  border-color: #34C759;
}

.choice-review.wrong-choice {
  background: rgba(255, 59, 48, 0.08);
  border-color: #FF3B30;
}

.choice-indicator {
  flex-shrink: 0;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.choice-indicator svg {
  width: 24px;
  height: 24px;
}

.correct-choice .choice-indicator svg {
  color: #34C759;
}

.wrong-choice .choice-indicator svg {
  color: #FF3B30;
}

.empty-circle {
  width: 18px;
  height: 18px;
  border-radius: 50%;
  border: 2px solid #D2D2D7;
}

.choice-content {
  flex: 1;
}

.choice-text-review {
  font-size: 14px;
  color: #1D1D1F;
  font-weight: 400;
  line-height: 1.4;
  letter-spacing: -0.1px;
}

.choice-label {
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.3px;
  margin-top: 4px;
}

.correct-label {
  color: #34C759;
}

.your-label {
  color: #FF3B30;
}

@media (max-width: 1024px) {
  .history-section {
    padding: 28px 32px 40px;
  }
  
  .dashboard-header {
    padding: 28px 32px 20px;
  }
  
  .exam-grid {
    padding: 20px 32px;
  }
}

@media (max-width: 768px) {
  .history-section {
    padding: 24px 20px 36px;
  }
  
  .dashboard-header {
    padding: 24px 20px 16px;
  }
  
  .exam-grid {
    padding: 16px 20px;
  }
  
  .history-header-content {
    gap: 12px;
  }
  
  .history-icon {
    width: 40px;
    height: 40px;
  }
  
  .history-icon svg {
    width: 20px;
    height: 20px;
  }
  
  .history-title {
    font-size: 20px;
  }
  
  .history-subtitle {
    font-size: 13px;
  }
  
  .history-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
    padding: 16px 20px;
  }
  
  .history-item:hover {
    transform: none;
  }
  
  .history-item-right {
    width: 100%;
    justify-content: space-between;
  }
  
  .history-exam-title {
    font-size: 15px;
  }
  
  .history-details {
    font-size: 12px;
    flex-wrap: wrap;
  }
  
  .history-score {
    font-size: 16px;
    padding: 6px 14px;
  }
}

/* Success Toast - Simple & Minimalistic */
.success-toast {
  position: fixed;
  top: 24px;
  left: 50%;
  transform: translateX(-50%);
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  color: #1D1D1F;
  padding: 14px 24px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  gap: 10px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.12);
  border: 1px solid rgba(0, 0, 0, 0.06);
  z-index: 10000;
  font-size: 15px;
  font-weight: 600;
  letter-spacing: -0.2px;
}

.success-check {
  width: 22px;
  height: 22px;
  stroke: #34C759;
  stroke-width: 2.5;
  flex-shrink: 0;
}

.fade-slide-enter-active {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.fade-slide-leave-active {
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

.fade-slide-enter-from {
  opacity: 0;
  transform: translateX(-50%) translateY(-20px);
}

.fade-slide-leave-to {
  opacity: 0;
  transform: translateX(-50%) translateY(-10px);
}

@media (max-width: 768px) {
  .success-toast {
    top: 16px;
    padding: 12px 20px;
    font-size: 14px;
  }
  
  .success-check {
    width: 20px;
    height: 20px;
  }
}
</style>