<template>
  <div class="question-analysis-section">
    <!-- Section Header -->
    <div class="section-header">
      <div class="header-content">
        <h2 class="section-title">Question Analysis</h2>
        <p class="section-subtitle">Analyze question difficulty and performance</p>
      </div>
      
      <!-- Controls -->
      <div class="controls">
        <!-- Exam Selector -->
        <div class="control-group">
          <label class="control-label">Exam:</label>
          <select 
            v-model="selectedExamId" 
            @change="handleExamChange"
            class="control-select"
          >
            <option value="">Select an exam...</option>
            <option 
              v-for="exam in availableExams" 
              :key="exam.id" 
              :value="exam.id"
            >
              {{ exam.title }}
            </option>
          </select>
        </div>
        
        <!-- Difficulty Filter -->
        <div class="control-group">
          <label class="control-label">Difficulty:</label>
          <select 
            v-model="currentDifficulty" 
            @change="handleDifficultyChange"
            class="control-select"
            :disabled="!selectedExamId"
          >
            <option value="all">All Questions</option>
            <option value="difficult">Difficult (75%-100%)</option>
            <option value="easy">Easy (≤30%)</option>
          </select>
        </div>
      </div>
    </div>

    <!-- Selected Exam Info -->
    <div v-if="examInfo" class="exam-info-card">
      <div class="exam-info-header">
        <div class="exam-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
          </svg>
        </div>
        <div class="exam-details">
          <h3 class="exam-title">{{ examInfo.examTitle }}</h3>
          <p class="exam-stats">
            {{ formatNumber(examInfo.totalQuestions) }} questions • 
            {{ formatNumber(examInfo.totalAttempts) }} attempts analyzed
          </p>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="question-list">
      <div v-for="i in 4" :key="i" class="question-card skeleton">
        <div class="question-header">
          <div class="skeleton-line skeleton-title"></div>
          <div class="skeleton-circle"></div>
        </div>
        <div class="question-content">
          <div class="skeleton-line skeleton-text"></div>
          <div class="skeleton-line skeleton-text"></div>
        </div>
        <div class="question-choices">
          <div v-for="j in 4" :key="j" class="skeleton-line skeleton-choice"></div>
        </div>
      </div>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="error-state">
      <div class="error-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <circle cx="12" cy="12" r="10"/>
          <line x1="12" y1="8" x2="12" y2="12"/>
          <line x1="12" y1="16" x2="12.01" y2="16"/>
        </svg>
      </div>
      <h3>Unable to Load Question Analysis</h3>
      <p>{{ error }}</p>
      <button @click="refreshData" class="retry-button">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
        </svg>
        Try Again
      </button>
    </div>

    <!-- Question List -->
    <div v-else-if="questions.length > 0" class="question-list">
      <div 
        v-for="question in questions" 
        :key="question.id"
        class="question-card"
        :class="getDifficultyClass(question.incorrectRate)"
      >
        <div class="question-header">
          <div class="question-number">Q{{ question.questionNumber }}</div>
          <div class="difficulty-badge" :class="getDifficultyClass(question.incorrectRate)">
            <span class="difficulty-percentage">{{ formatPercentage(question.incorrectRate) }}</span>
            <span class="difficulty-label">{{ getDifficultyLabel(question.incorrectRate) }}</span>
          </div>
        </div>
        
        <div class="question-content">
          <div class="question-text">{{ question.questionText }}</div>
        </div>
        
        <div class="question-choices">
          <div 
            v-for="choice in question.choices" 
            :key="choice.id"
            class="choice-item"
            :class="{ 'correct-choice': choice.isCorrect }"
          >
            <div class="choice-marker" :class="{ 'correct': choice.isCorrect }">
              {{ choice.choiceLetter }}
            </div>
            <div class="choice-text">{{ choice.choiceText }}</div>
            <div v-if="choice.isCorrect" class="correct-indicator">
              <svg viewBox="0 0 24 24" fill="currentColor">
                <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
              </svg>
            </div>
          </div>
        </div>

        <!-- Zero Attempts Edge Case -->
        <div v-if="question.totalAttempts === 0" class="no-attempts-badge">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <circle cx="12" cy="12" r="10"/>
            <line x1="12" y1="8" x2="12" y2="12"/>
            <line x1="12" y1="16" x2="12.01" y2="16"/>
          </svg>
          <span>No attempts for this question</span>
        </div>

        <div class="question-stats">
          <div class="stat-item">
            <span class="stat-label">Total Attempts:</span>
            <span class="stat-value">{{ formatNumber(question.totalAttempts) }}</span>
          </div>
          <div class="stat-item">
            <span class="stat-label">Incorrect Rate:</span>
            <span class="stat-value" :class="getDifficultyClass(question.incorrectRate)">
              {{ formatPercentage(question.incorrectRate) }}
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else-if="!selectedExamId" class="empty-state">
      <div class="empty-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
          <line x1="9" y1="12" x2="15" y2="12"/>
        </svg>
      </div>
      <h3>Select an Exam</h3>
      <p>Choose an exam from the dropdown above to analyze question difficulty and performance.</p>
    </div>

    <!-- No Questions State -->
    <div v-else class="empty-state">
      <div class="empty-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <circle cx="12" cy="12" r="10"/>
          <line x1="12" y1="8" x2="12" y2="12"/>
          <line x1="12" y1="16" x2="12.01" y2="16"/>
        </svg>
      </div>
      <h3>No Questions Found</h3>
      <p>No questions match the selected difficulty filter for this exam and time period.</p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { useAnalytics } from '@/composables/useAnalytics'

const props = defineProps({
  timeFilter: {
    type: String,
    default: 'all'
  }
})

const emit = defineEmits(['update:timeFilter'])

// Composables
const { 
  questionData, 
  examData,
  loadingStates, 
  errorStates, 
  fetchQuestionAnalysis,
  fetchExamPerformance,
  setQuestionDifficulty
} = useAnalytics()

// Local state
const selectedExamId = ref('')
const currentDifficulty = ref('difficult')
const availableExams = ref([])

// Computed properties
const loading = computed(() => loadingStates.questions)
const error = computed(() => errorStates.questions)
const questions = computed(() => questionData.value?.questions || [])
const examInfo = computed(() => questionData.value || null)

// Methods
const formatNumber = (num) => {
  if (num === null || num === undefined) return '0'
  return new Intl.NumberFormat('en-US').format(num)
}

const formatPercentage = (num) => {
  if (num === null || num === undefined) return '0%'
  return `${Math.round(num)}%`
}

const getDifficultyLabel = (incorrectRate) => {
  if (incorrectRate >= 75) return 'Difficult'
  if (incorrectRate <= 30) return 'Easy'
  return 'Medium'
}

const getDifficultyClass = (incorrectRate) => {
  if (incorrectRate >= 75) return 'difficulty-hard'
  if (incorrectRate <= 30) return 'difficulty-easy'
  return 'difficulty-medium'
}

const handleExamChange = () => {
  if (selectedExamId.value) {
    refreshData()
  }
}

const handleDifficultyChange = () => {
  setQuestionDifficulty(currentDifficulty.value)
  if (selectedExamId.value) {
    refreshData()
  }
}

const loadAvailableExams = async () => {
  try {
    // Load exam list from exam performance data
    await fetchExamPerformance(props.timeFilter, 1)
    if (examData.value?.exams) {
      availableExams.value = examData.value.exams.map(exam => ({
        id: exam.id,
        title: exam.title
      }))
    }
  } catch (err) {
    console.error('Failed to load available exams:', err)
  }
}

const refreshData = async () => {
  if (!selectedExamId.value) return
  
  try {
    await fetchQuestionAnalysis(selectedExamId.value, props.timeFilter)
  } catch (err) {
    console.error('Failed to refresh question analysis data:', err)
  }
}

// Watchers
watch(() => props.timeFilter, (newFilter) => {
  if (newFilter) {
    loadAvailableExams()
    if (selectedExamId.value) {
      refreshData()
    }
  }
}, { immediate: false })

// Lifecycle
onMounted(() => {
  setQuestionDifficulty(currentDifficulty.value)
  loadAvailableExams()
})
</script>
<style scoped>
* {
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

.question-analysis-section {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

/* Section Header */
.section-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 20px;
  padding-bottom: 16px;
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
}

.header-content h2 {
  margin: 0 0 4px 0;
  font-size: 24px;
  font-weight: 700;
  color: #1D1D1F;
  letter-spacing: -0.5px;
}

.header-content p {
  margin: 0;
  font-size: 14px;
  color: #86868B;
  letter-spacing: -0.1px;
}

/* Controls */
.controls {
  display: flex;
  align-items: center;
  gap: 20px;
}

.control-group {
  display: flex;
  align-items: center;
  gap: 8px;
}

.control-label {
  font-size: 13px;
  font-weight: 500;
  color: #86868B;
  white-space: nowrap;
}

.control-select {
  padding: 8px 12px;
  border: 1px solid rgba(0, 0, 0, 0.1);
  border-radius: 8px;
  background: #FFFFFF;
  font-size: 13px;
  font-weight: 500;
  color: #1D1D1F;
  cursor: pointer;
  transition: all 0.2s ease;
  min-width: 160px;
}

.control-select:focus {
  outline: none;
  border-color: #007AFF;
  box-shadow: 0 0 0 3px rgba(0, 122, 255, 0.1);
}

.control-select:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  background: #F5F5F7;
}

/* Exam Info Card */
.exam-info-card {
  background: #FFFFFF;
  border-radius: 12px;
  padding: 20px;
  border: 1px solid rgba(0, 0, 0, 0.06);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.exam-info-header {
  display: flex;
  align-items: center;
  gap: 16px;
}

.exam-icon {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  background: rgba(0, 122, 255, 0.1);
  color: #007AFF;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.exam-icon svg {
  width: 20px;
  height: 20px;
  stroke-width: 2;
}

.exam-details {
  flex: 1;
}

.exam-title {
  margin: 0 0 4px 0;
  font-size: 16px;
  font-weight: 600;
  color: #1D1D1F;
  letter-spacing: -0.2px;
}

.exam-stats {
  margin: 0;
  font-size: 13px;
  color: #86868B;
  font-weight: 500;
}

/* Question List */
.question-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.question-card {
  background: #FFFFFF;
  border-radius: 16px;
  padding: 24px;
  border: 1px solid rgba(0, 0, 0, 0.06);
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.question-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
}

.question-card.difficulty-easy {
  border-left: 4px solid #34C759;
}

.question-card.difficulty-medium {
  border-left: 4px solid #FF9500;
}

.question-card.difficulty-hard {
  border-left: 4px solid #FF3B30;
}

.question-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
}

.question-number {
  padding: 6px 12px;
  background: #F5F5F7;
  border-radius: 8px;
  font-size: 13px;
  font-weight: 600;
  color: #1D1D1F;
  flex-shrink: 0;
}

.difficulty-badge {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2px;
  padding: 8px 12px;
  border-radius: 8px;
  flex-shrink: 0;
}

.difficulty-badge.difficulty-easy {
  background: rgba(52, 199, 89, 0.1);
  color: #34C759;
}

.difficulty-badge.difficulty-medium {
  background: rgba(255, 149, 0, 0.1);
  color: #FF9500;
}

.difficulty-badge.difficulty-hard {
  background: rgba(255, 59, 48, 0.1);
  color: #FF3B30;
}

.difficulty-percentage {
  font-size: 16px;
  font-weight: 700;
  font-variant-numeric: tabular-nums;
}

.difficulty-label {
  font-size: 10px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.3px;
}

.question-content {
  padding: 16px 20px;
  background: #F5F5F7;
  border-radius: 12px;
}

.question-text {
  font-size: 16px;
  font-weight: 500;
  color: #1D1D1F;
  line-height: 1.5;
  letter-spacing: -0.1px;
}

.question-choices {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.choice-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  background: #FFFFFF;
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 10px;
  transition: all 0.2s ease;
}

.choice-item.correct-choice {
  background: rgba(52, 199, 89, 0.05);
  border-color: rgba(52, 199, 89, 0.2);
}

.choice-marker {
  width: 28px;
  height: 28px;
  border-radius: 6px;
  background: #F5F5F7;
  color: #86868B;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 700;
  flex-shrink: 0;
}

.choice-marker.correct {
  background: #34C759;
  color: white;
}

.choice-text {
  flex: 1;
  font-size: 14px;
  font-weight: 500;
  color: #1D1D1F;
  line-height: 1.4;
}

.correct-indicator {
  width: 20px;
  height: 20px;
  color: #34C759;
  flex-shrink: 0;
}

.correct-indicator svg {
  width: 20px;
  height: 20px;
}

.question-stats {
  display: flex;
  gap: 24px;
  padding: 16px 20px;
  background: #F5F5F7;
  border-radius: 12px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.stat-label {
  font-size: 13px;
  font-weight: 500;
  color: #86868B;
}

.stat-value {
  font-size: 13px;
  font-weight: 600;
  color: #1D1D1F;
  font-variant-numeric: tabular-nums;
}

.stat-value.difficulty-easy {
  color: #34C759;
}

.stat-value.difficulty-medium {
  color: #FF9500;
}

.stat-value.difficulty-hard {
  color: #FF3B30;
}

/* No Attempts Badge */
.no-attempts-badge {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  background: rgba(255, 149, 0, 0.1);
  color: #FF9500;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 500;
}

.no-attempts-badge svg {
  width: 14px;
  height: 14px;
  stroke-width: 2;
}

/* Error and Empty States */
.error-state,
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 48px 24px;
  text-align: center;
  background: #FFFFFF;
  border-radius: 16px;
  border: 1px solid rgba(0, 0, 0, 0.06);
}

.error-icon,
.empty-icon {
  width: 64px;
  height: 64px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 16px;
}

.error-icon {
  background: rgba(255, 59, 48, 0.1);
  color: #FF3B30;
}

.empty-icon {
  background: rgba(142, 142, 147, 0.1);
  color: #8E8E93;
}

.error-icon svg,
.empty-icon svg {
  width: 32px;
  height: 32px;
  stroke-width: 2;
}

.error-state h3,
.empty-state h3 {
  margin: 0 0 8px 0;
  font-size: 18px;
  font-weight: 600;
  color: #1D1D1F;
}

.error-state p,
.empty-state p {
  margin: 0 0 24px 0;
  font-size: 14px;
  color: #86868B;
  max-width: 300px;
}

.retry-button {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
  background: #1D1D1F;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}

.retry-button:hover {
  background: #000000;
}

.retry-button svg {
  width: 16px;
  height: 16px;
  stroke-width: 2;
}

/* Skeleton Loading */
.skeleton {
  background: #F5F5F7;
  border: 1px solid rgba(0, 0, 0, 0.04);
  pointer-events: none;
}

.skeleton-line {
  height: 16px;
  background: linear-gradient(90deg, #F5F5F7 25%, #E8E8ED 50%, #F5F5F7 75%);
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
  border-radius: 4px;
}

.skeleton-circle {
  width: 60px;
  height: 40px;
  background: linear-gradient(90deg, #F5F5F7 25%, #E8E8ED 50%, #F5F5F7 75%);
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
  border-radius: 8px;
}

.skeleton-title {
  width: 80px;
  height: 16px;
}

.skeleton-text {
  width: 100%;
  height: 16px;
  margin-bottom: 8px;
}

.skeleton-choice {
  width: 90%;
  height: 14px;
  margin-bottom: 6px;
}

@keyframes shimmer {
  0% {
    background-position: -200% 0;
  }
  100% {
    background-position: 200% 0;
  }
}

/* Responsive Design */
@media (max-width: 768px) {
  .section-header {
    flex-direction: column;
    align-items: stretch;
    gap: 16px;
  }
  
  .controls {
    flex-direction: column;
    align-items: stretch;
    gap: 12px;
  }
  
  .control-group {
    justify-content: space-between;
  }
  
  .control-select {
    min-width: auto;
    flex: 1;
  }
  
  .question-card {
    padding: 20px;
  }
  
  .question-header {
    flex-direction: column;
    align-items: stretch;
    gap: 12px;
  }
  
  .question-stats {
    flex-direction: column;
    gap: 12px;
  }
}

@media (max-width: 480px) {
  .question-card {
    padding: 16px;
  }
  
  .choice-item {
    padding: 10px 12px;
  }
  
  .choice-marker {
    width: 24px;
    height: 24px;
    font-size: 12px;
  }
  
  .exam-info-card {
    padding: 16px;
  }
  
  .exam-info-header {
    gap: 12px;
  }
  
  .exam-icon {
    width: 36px;
    height: 36px;
  }
  
  .exam-icon svg {
    width: 18px;
    height: 18px;
  }
}
</style>
