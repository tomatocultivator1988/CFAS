<template>
  <div class="exam-container">
    <!-- Loading State -->
    <div v-if="loading" class="loading-container">
      <div class="spinner"></div>
      <p>Loading exam...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="error-container">
      <div class="error-icon">⚠️</div>
      <h2>Unable to Load Exam</h2>
      <p>{{ error }}</p>
      <button @click="$router.push('/exams')" class="btn-primary">
        Back to Exams
      </button>
    </div>

    <!-- Exam Interface -->
    <div v-else-if="currentAttempt && questions.length > 0" class="exam-interface">
      <!-- Network Error Message -->
      <ErrorMessage
        v-if="networkError"
        :show="true"
        type="warning"
        title="Network Issue"
        :message="networkError"
        @dismiss="networkError = null"
      />

      <div v-if="isOffline || syncMessage" class="sync-banner" :class="{ offline: isOffline }">
        <span>{{ isOffline ? 'Connection lost. Answers are saved locally and will sync automatically when connection returns.' : syncMessage }}</span>
      </div>
      
      <!-- General Error Message -->
      <ErrorMessage
        v-if="handlerError"
        :show="true"
        type="error"
        title="Error"
        :message="handlerError"
        @dismiss="clearError"
      />
      
      <!-- Header -->
      <div class="exam-header">
        <div class="exam-info">
          <h1>{{ currentExam?.title || 'Exam' }}</h1>
          <p class="exam-description">{{ currentExam?.description }}</p>
        </div>
        <div class="header-actions">
          <div class="sync-status-pill" :class="syncStatusClass">
            <span class="sync-dot"></span>
            <span>{{ syncStatusText }}</span>
            <span v-if="lastSyncedLabel" class="sync-last-time">Last synced {{ lastSyncedLabel }}</span>
          </div>
          <TimerDisplay 
            :remaining-seconds="remainingTime"
            :format-time="formatTime"
          />
          <button 
            @click="showSubmitConfirmation = true"
            class="btn-submit-exam"
          >
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
            </svg>
            <span>Submit Exam</span>
          </button>
        </div>
      </div>

      <!-- Security Warnings -->
      <div v-if="violationCount > 0" class="warning-banner">
        <span class="warning-icon">⚠️</span>
        <span>Security violations detected: {{ violationCount }}. Exam will auto-submit at {{ maxViolations }} violations.</span>
      </div>

      <!-- Question Display -->
      <div class="question-section">
        <QuestionDisplay
          :question="currentQuestion"
          :question-number="currentQuestionIndex + 1"
          :total-questions="questions.length"
          :selected-choice-id="answers[currentQuestion.id]"
          @answer-selected="handleAnswerSelected"
        />
      </div>

      <!-- Navigation -->
      <div class="navigation-section">
        <button 
          @click="previousQuestion"
          :disabled="currentQuestionIndex === 0"
          class="btn-secondary"
        >
          ← Previous
        </button>

        <div class="question-indicators-wrapper">
          <!-- Pagination controls for indicators -->
          <button 
            v-if="indicatorPage > 0"
            @click="indicatorPage--"
            class="indicator-nav-btn"
            title="Previous questions"
          >
            ←
          </button>

          <div class="question-indicators">
            <button
              v-for="(question, index) in paginatedIndicators"
              :key="question.id"
              @click="goToQuestion(question.actualIndex)"
              class="question-indicator"
              :class="{
                active: question.actualIndex === currentQuestionIndex,
                answered: answers[question.id] !== undefined
              }"
            >
              {{ question.actualIndex + 1 }}
            </button>
          </div>

          <button 
            v-if="indicatorPage < totalIndicatorPages - 1"
            @click="indicatorPage++"
            class="indicator-nav-btn"
            title="Next questions"
          >
            →
          </button>

          <!-- Page indicator -->
          <div class="indicator-page-info">
            {{ indicatorPage + 1 }}/{{ totalIndicatorPages }}
          </div>
        </div>

        <button 
          v-if="currentQuestionIndex < questions.length - 1"
          @click="nextQuestion"
          class="btn-secondary"
        >
          Next →
        </button>
        <button 
          v-else
          @click="nextQuestion"
          class="btn-secondary"
          disabled
        >
          Last Question
        </button>
      </div>

      <!-- Submit Confirmation Modal -->
      <div v-if="showSubmitConfirmation" class="modal-overlay">
        <div class="modal-content">
          <h2>Submit Exam?</h2>
          
          <!-- Answered Summary -->
          <div class="submit-summary">
            <div class="summary-stat" :class="answeredCount === questions.length ? 'all-answered' : 'has-unanswered'">
              <div class="stat-number">{{ answeredCount }}/{{ questions.length }}</div>
              <div class="stat-label">Questions Answered</div>
            </div>
          </div>
          
          <!-- Unanswered Questions Warning -->
          <div v-if="unansweredQuestions.length > 0" class="unanswered-warning">
            <div class="warning-header">
              <svg viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
              </svg>
              <span>{{ unansweredQuestions.length }} Unanswered Question{{ unansweredQuestions.length > 1 ? 's' : '' }}</span>
            </div>
            <div class="unanswered-list">
              <span v-for="qNum in unansweredQuestions" :key="qNum" class="unanswered-number">
                {{ qNum }}
              </span>
            </div>
            <p class="warning-text">These questions will be marked as incorrect if not answered.</p>
          </div>
          
          <p class="confirm-text">Are you sure you want to submit your exam?</p>
          
          <div class="modal-actions">
            <button @click="showSubmitConfirmation = false" class="btn-secondary">
              Cancel
            </button>
            <button @click="handleSubmit" class="btn-primary" :disabled="submitting">
              <span v-if="submitting" class="spinner-small"></span>
              {{ submitting ? 'Submitting...' : 'Submit Exam' }}
            </button>
          </div>
        </div>
      </div>

      <!-- Success Modal - REMOVED FROM HERE, now at bottom of template outside exam-interface -->
    </div>

    <!-- Success Modal - Clean iOS Style -->
    <div v-if="showSuccessModal" class="modal-overlay">
      <div class="success-modal">
        <div class="success-icon-wrapper">
          <svg class="success-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
        </div>
        
        <h2>Exam Submitted</h2>
        <p class="success-message">Your exam has been successfully submitted and graded.</p>
        
        <div v-if="examResults" class="score-display">
          <div class="score-label">Your Score</div>
          <div class="score-value" :class="getScoreClass(examResults.score_percentage)">
            <span class="score-percentage">{{ examResults.score_percentage }}%</span>
          </div>
          <div class="score-details">
            {{ examResults.correct_answers }} out of {{ examResults.total_questions }} correct
          </div>
        </div>
        
        <button @click="goToDashboard" class="btn-primary btn-full">
          Back to Dashboard
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useExamStore } from '@/stores/exam'
import { useTimer } from '@/composables/useTimer'
import { useSecurityMonitor } from '@/composables/useSecurityMonitor'
import { useErrorHandler } from '@/composables/useErrorHandler'
import QuestionDisplay from '@/components/QuestionDisplay.vue'
import TimerDisplay from '@/components/TimerDisplay.vue'
import ErrorMessage from '@/components/ErrorMessage.vue'

const route = useRoute()
const router = useRouter()
const examStore = useExamStore()

const loading = ref(true)
const error = ref(null)
const currentQuestionIndex = ref(0)
const answers = ref({})
const showSubmitConfirmation = ref(false)
const showSuccessModal = ref(false)
const examResults = ref(null)
const submitting = ref(false)
const maxViolations = ref(3)
const retryCount = ref(0)
const maxRetries = ref(3)
const networkError = ref(null)
const isOffline = ref(!navigator.onLine)
const isSyncing = ref(false)
const syncMessage = ref('')
const syncInterval = ref(null)
const pendingAnswerCount = ref(0)
const lastSyncedAt = ref(null)
const indicatorPage = ref(0)
const indicatorsPerPage = 10

const { error: handlerError, handleError, clearError, saveToLocalStorage, loadFromLocalStorage } = useErrorHandler()

const currentAttempt = computed(() => examStore.currentAttempt)
const currentExam = computed(() => examStore.currentExam)

const questions = computed(() => {
  if (!currentAttempt.value?.questions) return []
  return currentAttempt.value.questions.map((q, index) => ({
    ...q,
    choices: (q.answer_choices || q.answerChoices || q.choices || []).map((c, cIndex) => ({
      ...c,
      letter: String.fromCharCode(65 + cIndex),
      order: cIndex
    }))
  }))
})

const currentQuestion = computed(() => questions.value[currentQuestionIndex.value] || {})

const answeredCount = computed(() => Object.keys(answers.value).length)

const unansweredQuestions = computed(() => {
  const unanswered = []
  questions.value.forEach((question, index) => {
    if (answers.value[question.id] === undefined) {
      unanswered.push(index + 1)
    }
  })
  return unanswered
})

const syncStatusText = computed(() => {
  if (isOffline.value) return 'Offline mode'
  if (submitting.value) return 'Submitting exam...'
  if (isSyncing.value) return 'Syncing answers...'
  if (pendingAnswerCount.value > 0) return `${pendingAnswerCount.value} answer(s) pending sync`
  return 'All answers synced'
})

const syncStatusClass = computed(() => {
  if (isOffline.value) return 'offline'
  if (submitting.value || isSyncing.value) return 'syncing'
  if (pendingAnswerCount.value > 0) return 'pending'
  return 'synced'
})

const lastSyncedLabel = computed(() => {
  if (!lastSyncedAt.value || isOffline.value || isSyncing.value || pendingAnswerCount.value > 0) return ''

  const diffSeconds = Math.max(0, Math.floor((Date.now() - lastSyncedAt.value) / 1000))
  if (diffSeconds < 5) return 'just now'
  if (diffSeconds < 60) return `${diffSeconds}s ago`

  const diffMinutes = Math.floor(diffSeconds / 60)
  if (diffMinutes < 60) return `${diffMinutes}m ago`

  const diffHours = Math.floor(diffMinutes / 60)
  return `${diffHours}h ago`
})

const refreshPendingAnswerCount = () => {
  if (!currentAttempt.value?.id) {
    pendingAnswerCount.value = 0
    return
  }

  const pendingAnswers = examStore.getPendingAnswers(currentAttempt.value.id)
  pendingAnswerCount.value = Object.keys(pendingAnswers).length
}

// Pagination for question indicators
const totalIndicatorPages = computed(() => Math.ceil(questions.value.length / indicatorsPerPage))

const paginatedIndicators = computed(() => {
  const start = indicatorPage.value * indicatorsPerPage
  const end = start + indicatorsPerPage
  return questions.value.slice(start, end).map((q, idx) => ({
    ...q,
    actualIndex: start + idx
  }))
})

// Auto-adjust indicator page when navigating questions
watch(currentQuestionIndex, (newIndex) => {
  const targetPage = Math.floor(newIndex / indicatorsPerPage)
  if (targetPage !== indicatorPage.value) {
    indicatorPage.value = targetPage
  }
})

// Timer setup - use computed to get the actual time limit from exam
const timeLimit = computed(() => {
  const minutes = currentExam.value?.time_limit_minutes
  return minutes ? minutes * 60 : 3600 // Convert minutes to seconds
})

// Initialize timer with the reactive computed ref (not .value)
const { remainingTime, isRunning, startTimer, stopTimer, formatTime, resetTimer } = useTimer(timeLimit)

// Watch for exam data changes and update timer accordingly
watch(() => currentExam.value?.time_limit_minutes, (newTimeLimit) => {
  if (newTimeLimit && !isRunning.value) {
    // Reset timer to the correct time limit when exam data is loaded
    resetTimer(newTimeLimit * 60)
  }
}, { immediate: true })

// Security monitoring - pass a getter function, not a snapshot value
const { violationCount, startMonitoring, stopMonitoring } = useSecurityMonitor(
  () => currentAttempt.value?.id,
  examStore.reportViolation
)

const handleAttemptClosed = (message) => {
  if (syncInterval.value) {
    clearInterval(syncInterval.value)
    syncInterval.value = null
  }

  stopTimer()
  stopMonitoring()
  if (currentAttempt.value?.id) {
    examStore.clearPendingAnswers(currentAttempt.value.id)
  }
  networkError.value = null
  error.value = message || 'This exam attempt is already completed.'
}

// Watch for timer expiration
watch(remainingTime, (newTime) => {
  if (newTime <= 0) {
    handleAutoSubmit()
  }
})

// Watch for violation threshold
watch(violationCount, (count) => {
  if (count >= maxViolations.value) {
    handleAutoSubmit()
  }
})

const handleAnswerSelected = async (choiceId) => {
  if (!currentAttempt.value || !currentQuestion.value?.id) return

  answers.value[currentQuestion.value.id] = choiceId
  
  // Save to localStorage immediately as backup
  saveToLocalStorage(`exam_${currentAttempt.value.id}_answers`, answers.value)
  examStore.queuePendingAnswer(currentAttempt.value.id, currentQuestion.value.id, choiceId)
  refreshPendingAnswerCount()
  
  // Try to save answer to backend with retry logic
  let attempts = 0
  while (attempts < maxRetries.value) {
    const result = await examStore.submitAnswer(
      currentAttempt.value.id,
      currentQuestion.value.id,
      choiceId
    )
    
    if (result.success) {
      clearError()
      networkError.value = null
      examStore.markAnswerSynced(currentAttempt.value.id, currentQuestion.value.id)
      lastSyncedAt.value = Date.now()
      refreshPendingAnswerCount()
      break
    } else if (result.isAttemptClosed) {
      handleAttemptClosed(result.error)
      return
    } else {
      attempts++
      if (attempts >= maxRetries.value) {
        networkError.value = 'Failed to save answer. Your answer is saved locally and will be submitted with the exam.'
        handleError(new Error(result.error), 'Answer submission')
      } else {
        // Wait before retry (exponential backoff)
        await new Promise(resolve => setTimeout(resolve, 1000 * attempts))
      }
    }
  }
}

const syncPendingAnswers = async (showSuccessMessage = false) => {
  if (!currentAttempt.value || isSyncing.value || !navigator.onLine) return

  isSyncing.value = true
  try {
    const result = await examStore.flushPendingAnswers(currentAttempt.value.id)
    if (result.success) {
      if (result.synced > 0) {
        lastSyncedAt.value = Date.now()
      }
      refreshPendingAnswerCount()
      if (result.synced > 0 && showSuccessMessage) {
        syncMessage.value = `${result.synced} pending answer(s) synced to server.`
        setTimeout(() => {
          syncMessage.value = ''
        }, 3000)
      }
      networkError.value = null
    } else if (result.attemptClosed) {
      handleAttemptClosed(result.error)
    } else {
      networkError.value = 'Some answers are still waiting for connection. They remain saved locally.'
      refreshPendingAnswerCount()
    }
  } finally {
    isSyncing.value = false
  }
}

const nextQuestion = () => {
  if (currentQuestionIndex.value < questions.value.length - 1) {
    currentQuestionIndex.value++
  }
}

const previousQuestion = () => {
  if (currentQuestionIndex.value > 0) {
    currentQuestionIndex.value--
  }
}

const goToQuestion = (index) => {
  currentQuestionIndex.value = index
}

const handleSubmit = async () => {
  // Prevent multiple submissions
  if (submitting.value || !currentAttempt.value) {
    return
  }
  
  submitting.value = true
  showSubmitConfirmation.value = false
  clearError()
  
  const attemptId = currentAttempt.value.id
  
  try {
    await syncPendingAnswers()

    const pendingBeforeSubmit = examStore.getPendingAnswers(attemptId)
    if (Object.keys(pendingBeforeSubmit).length > 0) {
      networkError.value = 'Cannot submit yet. Waiting to sync saved answers to server.'
      submitting.value = false
      return
    }

    const result = await examStore.submitExam(attemptId)
    
    if (result.success) {
      // Clean up
      stopTimer()
      stopMonitoring()
      localStorage.removeItem(`exam_${attemptId}_answers`)
      
      // Map the backend response
      const attemptData = result.data.attempt || result.data
      
      examResults.value = {
        score_percentage: attemptData.percentage || 0,
        correct_answers: attemptData.score || 0,
        total_questions: attemptData.total_questions || questions.value.length
      }
      
      // Show success modal
      showSuccessModal.value = true
    } else {
      examStore.queuePendingSubmit(attemptId)
      networkError.value = 'Submit failed due to connection. Your exam is queued and will auto-submit when connection returns.'
      error.value = result.error || 'Failed to submit exam'
      submitting.value = false
    }
  } catch (err) {
    examStore.queuePendingSubmit(attemptId)
    networkError.value = 'Connection issue while submitting. Exam saved locally and will auto-submit once online.'
    error.value = 'An error occurred while submitting the exam'
    submitting.value = false
  }
}

const handleAutoSubmit = async () => {
  if (submitting.value) return
  await handleSubmit()
}

const getScoreClass = (percentage) => {
  if (percentage >= 75) return 'score-excellent'
  if (percentage >= 50) return 'score-good'
  return 'score-poor'
}

const goToDashboard = () => {
  examStore.clearExamData()
  router.push('/exams')
}

onMounted(async () => {
  const examId = route.params.id
  
  // Prevent browser back button
  window.history.pushState(null, '', window.location.href)
  window.addEventListener('popstate', preventBack)
  
  // Try to load existing attempt or start new one
  const result = await examStore.startExam(examId)
  
  if (result.success) {
    // Load attempt details with questions
    const attemptId = result.data.attempt.id
    const detailsResult = await examStore.getAttempt(attemptId)
    
    if (!detailsResult.success) {
      error.value = detailsResult.error
      handleError(new Error(detailsResult.error), 'Loading exam questions')
      loading.value = false
      return
    }
    
    // Load saved answers from localStorage
    const savedAnswers = loadFromLocalStorage(`exam_${currentAttempt.value.id}_answers`)
    if (savedAnswers) {
      answers.value = savedAnswers
    }

    // Merge any pending (unsynced) answers to ensure latest local state is visible
    const pendingAnswers = examStore.getPendingAnswers(currentAttempt.value.id)
    if (Object.keys(pendingAnswers).length > 0) {
      answers.value = {
        ...answers.value,
        ...pendingAnswers
      }
    }
    refreshPendingAnswerCount()

    // Try syncing pending answers immediately on load
    await syncPendingAnswers()
    
    // Start timer and security monitoring
    startTimer()
    startMonitoring()
  } else {
    error.value = result.error
    handleError(new Error(result.error), 'Exam initialization')
  }
  
  loading.value = false
})

const preventBack = (event) => {
  event.preventDefault()
  window.history.pushState(null, '', window.location.href)
}

const handleOnline = async () => {
  isOffline.value = false
  syncMessage.value = 'Connection restored. Syncing saved answers...'
  await syncPendingAnswers(true)

  if (currentAttempt.value && examStore.hasPendingSubmit(currentAttempt.value.id) && !submitting.value) {
    syncMessage.value = 'Connection restored. Auto-submitting your exam...'
    await handleSubmit()
  }
}

const handleOffline = () => {
  isOffline.value = true
  refreshPendingAnswerCount()
}

onUnmounted(() => {
  stopTimer()
  stopMonitoring()
  window.removeEventListener('popstate', preventBack)
  window.removeEventListener('online', handleOnline)
  window.removeEventListener('offline', handleOffline)

  if (syncInterval.value) {
    clearInterval(syncInterval.value)
    syncInterval.value = null
  }
})

onMounted(() => {
  window.addEventListener('online', handleOnline)
  window.addEventListener('offline', handleOffline)

  // Keep trying to sync while exam is open
  syncInterval.value = setInterval(() => {
    syncPendingAnswers()
  }, 8000)
})
</script>

<style scoped>
* {
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

.exam-container {
  min-height: 100vh;
  background: #F5F5F7;
  padding: 16px;
  position: relative;
}

@media (min-width: 768px) {
  .exam-container {
    padding: 24px;
  }
}

.exam-container::before {
  content: '';
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-image: url('/ISUFST-logo-PNG-1-1024x712-800x550.png');
  background-size: 45%;
  background-position: center;
  background-repeat: no-repeat;
  opacity: 0.08;
  pointer-events: none;
  z-index: 0;
  filter: grayscale(100%) brightness(1.2);
}

.loading-container,
.error-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 60vh;
  gap: 20px;
  position: relative;
  z-index: 1;
}

.spinner {
  width: 50px;
  height: 50px;
  border: 3px solid transparent;
  border-top-color: #1D1D1F;
  border-radius: 50%;
  animation: spin 1s cubic-bezier(0.68, -0.55, 0.265, 1.55) infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.loading-container p {
  color: #86868B;
  font-size: 17px;
  font-weight: 500;
  letter-spacing: -0.2px;
}

.error-icon {
  font-size: 48px;
  opacity: 0.5;
}

.error-container h2 {
  color: #FF3B30;
  margin: 0;
  font-size: 28px;
  font-weight: 700;
  letter-spacing: -0.6px;
}

.error-container p {
  color: #86868B;
  margin: 8px 0 24px;
  font-size: 17px;
  font-weight: 400;
  letter-spacing: -0.2px;
}

.exam-interface {
  max-width: 1200px;
  margin: 0 auto;
  position: relative;
  z-index: 1;
}

.exam-header {
  display: flex;
  flex-direction: column;
  gap: 16px;
  margin-bottom: 16px;
  background: #FFFFFF;
  padding: 16px;
  border-radius: 16px;
  border: 1px solid rgba(0, 0, 0, 0.04);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  position: sticky;
  top: 0;
  z-index: 100;
}

@media (min-width: 768px) {
  .exam-header {
    flex-direction: row;
    justify-content: space-between;
    align-items: flex-start;
    gap: 24px;
    margin-bottom: 24px;
    padding: 28px;
    border-radius: 20px;
  }
}

.header-actions {
  display: flex;
  flex-direction: column;
  align-items: stretch;
  gap: 12px;
  width: 100%;
}

@media (min-width: 768px) {
  .header-actions {
    flex-direction: row;
    align-items: center;
    gap: 16px;
    flex-shrink: 0;
    width: auto;
  }
}

.btn-submit-exam {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 14px 20px;
  background: #34C759;
  color: white;
  border: none;
  border-radius: 12px;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  letter-spacing: -0.2px;
  box-shadow: 0 4px 12px rgba(52, 199, 89, 0.3);
  width: 100%;
}

@media (min-width: 768px) {
  .btn-submit-exam {
    width: auto;
    padding: 12px 24px;
  }
}

.btn-submit-exam:hover {
  background: #28A745;
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(52, 199, 89, 0.4);
}

.btn-submit-exam:active {
  transform: translateY(0);
}

.btn-submit-exam svg {
  width: 20px;
  height: 20px;
  stroke-width: 2;
}

.exam-info h1 {
  margin: 0 0 8px 0;
  color: #1D1D1F;
  font-size: 22px;
  font-weight: 700;
  letter-spacing: -0.5px;
}

@media (min-width: 768px) {
  .exam-info h1 {
    font-size: 32px;
    letter-spacing: -0.8px;
  }
}

.exam-description {
  color: #86868B;
  margin: 0;
  font-size: 14px;
  font-weight: 400;
  letter-spacing: -0.2px;
}

@media (min-width: 768px) {
  .exam-description {
    font-size: 17px;
  }
}

.warning-banner {
  background: rgba(255, 59, 48, 0.08);
  border: 1.5px solid rgba(255, 59, 48, 0.2);
  border-radius: 12px;
  padding: 12px 16px;
  margin-bottom: 16px;
  display: flex;
  align-items: center;
  gap: 10px;
  color: #FF3B30;
  font-weight: 600;
  font-size: 13px;
  letter-spacing: -0.2px;
}

.sync-banner {
  background: rgba(0, 122, 255, 0.1);
  border: 1.5px solid rgba(0, 122, 255, 0.25);
  border-radius: 12px;
  padding: 12px 16px;
  margin-bottom: 16px;
  color: #0051D5;
  font-weight: 600;
  font-size: 13px;
  letter-spacing: -0.2px;
}

.sync-banner.offline {
  background: rgba(255, 149, 0, 0.1);
  border-color: rgba(255, 149, 0, 0.35);
  color: #b76b00;
}

.sync-status-pill {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 10px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 700;
  letter-spacing: -0.1px;
  border: 1.5px solid transparent;
  flex-wrap: wrap;
}

.sync-status-pill .sync-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: currentColor;
}

.sync-status-pill.synced {
  background: rgba(52, 199, 89, 0.12);
  border-color: rgba(52, 199, 89, 0.35);
  color: #1f8f40;
}

.sync-status-pill.syncing {
  background: rgba(0, 122, 255, 0.1);
  border-color: rgba(0, 122, 255, 0.25);
  color: #0051d5;
}

.sync-status-pill.pending,
.sync-status-pill.offline {
  background: rgba(255, 149, 0, 0.1);
  border-color: rgba(255, 149, 0, 0.35);
  color: #b76b00;
}

.sync-last-time {
  font-weight: 600;
  opacity: 0.85;
}

@media (min-width: 768px) {
  .warning-banner {
    border-radius: 16px;
    padding: 18px 20px;
    margin-bottom: 24px;
    gap: 12px;
    font-size: 15px;
  }
}

.warning-icon {
  font-size: 20px;
}

.question-section {
  margin-bottom: 16px;
}

@media (min-width: 768px) {
  .question-section {
    margin-bottom: 24px;
  }
}

.navigation-section {
  display: flex;
  flex-direction: column;
  gap: 12px;
  background: #FFFFFF;
  padding: 16px;
  border-radius: 16px;
  border: 1px solid rgba(0, 0, 0, 0.04);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  overflow: visible;
}

@media (min-width: 768px) {
  .navigation-section {
    flex-direction: row;
    align-items: center;
    gap: 16px;
    padding: 24px;
    border-radius: 20px;
    max-height: 500px;
  }
}

.question-indicators-wrapper {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  width: 100%;
  order: -1;
}

@media (min-width: 768px) {
  .question-indicators-wrapper {
    flex-direction: row;
    gap: 12px;
    flex: 1;
    justify-content: center;
    order: 0;
    width: auto;
  }
}

.indicator-nav-btn {
  width: 36px;
  height: 36px;
  border: 1.5px solid #D2D2D7;
  background: #FFFFFF;
  border-radius: 10px;
  cursor: pointer;
  font-weight: 600;
  font-size: 16px;
  color: #007AFF;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

@media (min-width: 768px) {
  .indicator-nav-btn {
    width: 40px;
    height: 40px;
    font-size: 18px;
  }
}

.indicator-nav-btn:hover {
  background: #007AFF;
  border-color: #007AFF;
  color: #FFFFFF;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 122, 255, 0.2);
}

.indicator-nav-btn:active {
  transform: translateY(0);
}

.indicator-page-info {
  font-size: 12px;
  font-weight: 600;
  color: #86868B;
  padding: 4px 8px;
  white-space: nowrap;
  flex-shrink: 0;
  text-align: center;
}

@media (min-width: 768px) {
  .indicator-page-info {
    font-size: 13px;
    padding: 0 8px;
  }
}

.question-indicators {
  display: grid;
  grid-template-columns: repeat(10, 1fr);
  gap: 6px;
  justify-content: center;
  padding: 8px;
  width: 100%;
}

@media (min-width: 480px) {
  .question-indicators {
    grid-template-columns: repeat(15, 1fr);
  }
}

@media (min-width: 768px) {
  .question-indicators {
    grid-template-columns: repeat(20, 1fr);
  }
}

.question-indicator {
  width: 100%;
  aspect-ratio: 1;
  min-width: 28px;
  border: 1.5px solid #D2D2D7;
  background: #FFFFFF;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  font-size: 11px;
  color: #86868B;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  letter-spacing: -0.2px;
  display: flex;
  align-items: center;
  justify-content: center;
}

@media (min-width: 768px) {
  .question-indicator {
    width: 32px;
    height: 32px;
  }
}

.question-indicator:hover {
  border-color: #007AFF;
  color: #007AFF;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 122, 255, 0.15);
}

.question-indicator.active {
  background: #007AFF;
  border-color: #007AFF;
  color: #FFFFFF;
  box-shadow: 0 4px 12px rgba(0, 122, 255, 0.3);
}

.question-indicator.answered {
  background: #34C759;
  border-color: #34C759;
  color: #FFFFFF;
}

.question-indicator.answered.active {
  background: #28A745;
  border-color: #28A745;
}

.btn-primary,
.btn-secondary {
  padding: 12px 20px;
  border-radius: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  border: none;
  font-size: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  letter-spacing: -0.2px;
  flex: 1;
}

@media (min-width: 768px) {
  .btn-primary,
  .btn-secondary {
    padding: 14px 24px;
    font-size: 15px;
    flex: 0 0 auto;
  }
}

.btn-primary {
  background: #007AFF;
  color: #FFFFFF;
  box-shadow: 0 2px 8px rgba(0, 122, 255, 0.25);
}

.btn-primary:hover:not(:disabled) {
  background: #0051D5;
  transform: translateY(-1px);
  box-shadow: 0 4px 16px rgba(0, 122, 255, 0.35);
}

.btn-primary:active:not(:disabled) {
  transform: translateY(0);
}

.btn-primary:disabled {
  background: #86868B;
  cursor: not-allowed;
  opacity: 0.6;
}

.btn-secondary {
  background: #FFFFFF;
  color: #1D1D1F;
  border: 1.5px solid #D2D2D7;
}

.btn-secondary:hover:not(:disabled) {
  background: #F5F5F7;
  border-color: #86868B;
  transform: translateY(-1px);
}

.btn-secondary:active:not(:disabled) {
  transform: translateY(0);
}

.btn-secondary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.4);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10000;
  padding: 20px;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.4);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10000;
  padding: 20px;
  animation: fadeIn 0.2s ease-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

.modal-content {
  background: #FFFFFF;
  border-radius: 16px;
  padding: 20px;
  max-width: 600px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  scrollbar-width: thin;
  scrollbar-color: #007AFF #F5F5F7;
  margin: 0 16px;
}

@media (min-width: 768px) {
  .modal-content {
    border-radius: 20px;
    padding: 32px;
    margin: 0;
  }
}

/* Webkit scrollbar for modal */
.modal-content::-webkit-scrollbar {
  width: 8px;
}

.modal-content::-webkit-scrollbar-track {
  background: #F5F5F7;
  border-radius: 4px;
}

.modal-content::-webkit-scrollbar-thumb {
  background: #007AFF;
  border-radius: 4px;
}

.modal-content::-webkit-scrollbar-thumb:hover {
  background: #0051D5;
}

.modal-content h2 {
  margin: 0 0 16px 0;
  color: #1D1D1F;
  font-size: 22px;
  font-weight: 700;
  letter-spacing: -0.5px;
  text-align: center;
}

@media (min-width: 768px) {
  .modal-content h2 {
    margin: 0 0 20px 0;
    font-size: 28px;
    letter-spacing: -0.6px;
  }
}

.submit-summary {
  display: flex;
  justify-content: center;
  margin-bottom: 24px;
}

.summary-stat {
  text-align: center;
  padding: 20px 40px;
  border-radius: 16px;
  background: #F5F5F7;
}

.summary-stat.all-answered {
  background: rgba(52, 199, 89, 0.12);
}

.summary-stat.has-unanswered {
  background: rgba(255, 149, 0, 0.12);
}

.stat-number {
  font-size: 36px;
  font-weight: 800;
  letter-spacing: -1px;
  margin-bottom: 4px;
}

.summary-stat.all-answered .stat-number {
  color: #34C759;
}

.summary-stat.has-unanswered .stat-number {
  color: #FF9500;
}

.stat-label {
  font-size: 13px;
  font-weight: 600;
  color: #86868B;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.unanswered-warning {
  background: rgba(255, 149, 0, 0.08);
  border: 1.5px solid rgba(255, 149, 0, 0.3);
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 20px;
}

.warning-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
  color: #FF9500;
  font-weight: 600;
  font-size: 15px;
}

.warning-header svg {
  width: 20px;
  height: 20px;
  flex-shrink: 0;
}

.unanswered-list {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-bottom: 12px;
}

.unanswered-number {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 32px;
  height: 32px;
  padding: 0 8px;
  background: #FFFFFF;
  border: 1.5px solid rgba(255, 149, 0, 0.3);
  border-radius: 8px;
  font-size: 13px;
  font-weight: 700;
  color: #FF9500;
}

.warning-text {
  font-size: 13px;
  color: #86868B;
  margin: 0;
  font-weight: 500;
}

.confirm-text {
  color: #86868B;
  margin: 0 0 24px 0;
  line-height: 1.6;
  font-size: 15px;
  font-weight: 400;
  letter-spacing: -0.2px;
  text-align: center;
}

.modal-actions {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

@media (min-width: 768px) {
  .modal-actions {
    flex-direction: row;
    justify-content: flex-end;
  }
  
  .modal-actions .btn-primary,
  .modal-actions .btn-secondary {
    flex: 0 0 auto;
  }
}

.spinner-small {
  width: 18px;
  height: 18px;
  border: 2.5px solid rgba(255, 255, 255, 0.3);
  border-top-color: #FFFFFF;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

/* Success Modal */
.success-modal {
  background: #FFFFFF;
  border-radius: 20px;
  padding: 32px 24px;
  max-width: 480px;
  width: 100%;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  text-align: center;
  animation: modalSlideUp 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  margin: 0 16px;
}

@media (min-width: 768px) {
  .success-modal {
    border-radius: 24px;
    padding: 48px 40px;
    margin: 0;
  }
}

@keyframes modalSlideUp {
  from {
    opacity: 0;
    transform: translateY(30px) scale(0.95);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.success-icon-wrapper {
  width: 80px;
  height: 80px;
  background: linear-gradient(135deg, #34C759, #30D158);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 24px;
  box-shadow: 0 8px 24px rgba(52, 199, 89, 0.3);
  animation: successPulse 0.6s ease-out;
}

@keyframes successPulse {
  0% {
    transform: scale(0);
    opacity: 0;
  }
  50% {
    transform: scale(1.1);
  }
  100% {
    transform: scale(1);
    opacity: 1;
  }
}

.success-icon {
  width: 48px;
  height: 48px;
  color: white;
  stroke-width: 2.5;
}

.success-modal h2 {
  font-size: 24px;
  font-weight: 800;
  color: #1D1D1F;
  margin: 0 0 12px 0;
  letter-spacing: -0.6px;
}

@media (min-width: 768px) {
  .success-modal h2 {
    font-size: 32px;
    letter-spacing: -0.8px;
  }
}

.success-message {
  font-size: 17px;
  color: #86868B;
  margin: 0 0 32px 0;
  font-weight: 500;
  letter-spacing: -0.2px;
}

.score-display {
  background: linear-gradient(135deg, #F5F5F7, #FFFFFF);
  border-radius: 20px;
  padding: 32px 24px;
  margin-bottom: 32px;
  border: 1px solid rgba(0, 0, 0, 0.04);
}

.score-label {
  font-size: 14px;
  color: #86868B;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 1px;
  margin-bottom: 16px;
}

.score-value {
  font-size: 48px;
  font-weight: 800;
  margin-bottom: 8px;
  letter-spacing: -1.5px;
  line-height: 1;
}

@media (min-width: 768px) {
  .score-value {
    font-size: 56px;
    letter-spacing: -2px;
  }
}

.score-percentage {
  font-size: 28px;
  font-weight: 700;
  letter-spacing: -0.8px;
}

.score-excellent {
  color: #34C759;
}

.score-good {
  color: #FF9500;
}

.score-poor {
  color: #FF3B30;
}

.score-details {
  font-size: 15px;
  color: #86868B;
  font-weight: 600;
  margin-top: 12px;
}

.btn-full {
  width: 100%;
  justify-content: center;
  padding: 16px 24px;
  font-size: 17px;
}

</style>
