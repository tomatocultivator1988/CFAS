<template>
  <div class="exam-performance-section">
    <!-- Section Header -->
    <div class="section-header">
      <div class="header-content">
        <h2 class="section-title">Exam Performance</h2>
        <p class="section-subtitle">Analyze exam metrics and score distributions</p>
      </div>
      
      <!-- Sort Controls -->
      <div class="sort-controls">
        <div class="sort-group">
          <label class="sort-label">Sort by:</label>
          <select 
            v-model="currentSort.field" 
            @change="handleSortChange"
            class="sort-select"
          >
            <option value="attempts">Total Attempts</option>
            <option value="avgScore">Average Score</option>
            <option value="passRate">Pass Rate</option>
          </select>
        </div>
        
        <button 
          @click="toggleSortOrder"
          class="sort-order-btn"
          :class="{ 'desc': currentSort.order === 'desc' }"
        >
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M7 10l5 5 5-5"/>
          </svg>
        </button>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="exam-list">
      <div v-for="i in 6" :key="i" class="exam-performance-card skeleton">
        <div class="card-header">
          <div class="skeleton-line skeleton-title"></div>
          <div class="skeleton-line skeleton-subtitle"></div>
        </div>
        <div class="card-metrics">
          <div v-for="j in 3" :key="j" class="metric-item skeleton">
            <div class="skeleton-circle"></div>
            <div class="skeleton-line skeleton-metric"></div>
          </div>
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
      <h3>Unable to Load Exam Performance</h3>
      <p>{{ error }}</p>
      <button @click="refreshData" class="retry-button">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
        </svg>
        Try Again
      </button>
    </div>

    <!-- Exam List -->
    <div v-else-if="exams.length > 0" class="exam-list">
      <div 
        v-for="exam in exams" 
        :key="exam.id"
        class="exam-performance-card"
        :class="{ 'selected': selectedExam?.id === exam.id }"
        @click="selectExam(exam)"
      >
        <div class="card-header">
          <h3 class="exam-title">{{ exam.title }}</h3>
          <p class="exam-category">{{ exam.category || 'General' }}</p>
        </div>
        
        <div class="card-metrics">
          <!-- Total Attempts -->
          <div class="metric-item">
            <div class="metric-icon attempts-icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
              </svg>
            </div>
            <div class="metric-content">
              <div class="metric-value">{{ formatNumber(exam.totalAttempts) }}</div>
              <div class="metric-label">Attempts</div>
            </div>
          </div>

          <!-- Average Score -->
          <div class="metric-item">
            <div class="metric-icon score-icon" :class="getScoreClass(exam.averageScore)">
              <svg viewBox="0 0 24 24" fill="currentColor">
                <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
              </svg>
            </div>
            <div class="metric-content">
              <div class="metric-value" :class="getScoreClass(exam.averageScore)">
                {{ formatPercentage(exam.averageScore) }}
              </div>
              <div class="metric-label">Avg Score</div>
            </div>
          </div>

          <!-- Pass Rate -->
          <div class="metric-item">
            <div class="metric-icon pass-rate-icon" :class="getPassRateClass(exam.passRate)">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/>
                <circle cx="9" cy="7" r="4"/>
                <path d="M23 21v-2a4 4 0 00-3-3.87"/>
                <path d="M16 3.13a4 4 0 010 7.75"/>
              </svg>
            </div>
            <div class="metric-content">
              <div class="metric-value" :class="getPassRateClass(exam.passRate)">
                {{ formatPercentage(exam.passRate) }}
              </div>
              <div class="metric-label">Pass Rate</div>
            </div>
          </div>
        </div>

        <!-- Zero Attempts Edge Case -->
        <div v-if="exam.totalAttempts === 0" class="no-attempts-badge">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <circle cx="12" cy="12" r="10"/>
            <line x1="12" y1="8" x2="12" y2="12"/>
            <line x1="12" y1="16" x2="12.01" y2="16"/>
          </svg>
          <span>No attempts yet</span>
        </div>

        <!-- Selection Indicator -->
        <div v-if="selectedExam?.id === exam.id" class="selection-indicator">
          <svg viewBox="0 0 24 24" fill="currentColor">
            <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
          </svg>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="empty-state">
      <div class="empty-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
        </svg>
      </div>
      <h3>No Exams Found</h3>
      <p>No exam data available for the selected time period.</p>
    </div>

    <!-- Pagination -->
    <div v-if="pagination.totalPages > 1" class="pagination">
      <button 
        @click="goToPage(pagination.currentPage - 1)"
        :disabled="pagination.currentPage <= 1"
        class="pagination-btn"
      >
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path d="M15 18l-6-6 6-6"/>
        </svg>
        Previous
      </button>
      
      <div class="pagination-info">
        <span class="page-numbers">
          Page {{ pagination.currentPage }} of {{ pagination.totalPages }}
        </span>
        <span class="total-count">
          {{ formatNumber(pagination.total) }} total exams
        </span>
      </div>
      
      <button 
        @click="goToPage(pagination.currentPage + 1)"
        :disabled="pagination.currentPage >= pagination.totalPages"
        class="pagination-btn"
      >
        Next
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path d="M9 18l6-6-6-6"/>
        </svg>
      </button>
    </div>

    <!-- Score Distribution Chart -->
    <div v-if="selectedExam" class="score-distribution-section">
      <ScoreDistributionChart 
        :exam="selectedExam"
        :time-filter="timeFilter"
        @close="selectedExam = null"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { useAnalytics } from '@/composables/useAnalytics'
import ScoreDistributionChart from './ScoreDistributionChart.vue'

const props = defineProps({
  timeFilter: {
    type: String,
    default: 'all'
  }
})

const emit = defineEmits(['update:timeFilter'])

// Composables
const { 
  examData, 
  loadingStates, 
  errorStates, 
  paginationStates,
  fetchExamPerformance,
  fetchExamDetails,
  setExamSort
} = useAnalytics()

// Local state
const selectedExam = ref(null)
const currentSort = ref({
  field: 'attempts',
  order: 'desc'
})

// Computed properties
const loading = computed(() => loadingStates.exams)
const error = computed(() => errorStates.exams)
const exams = computed(() => examData.value?.exams || [])
const pagination = computed(() => paginationStates.exams)

// Methods
const formatNumber = (num) => {
  if (num === null || num === undefined) return '0'
  return new Intl.NumberFormat('en-US').format(num)
}

const formatPercentage = (num) => {
  if (num === null || num === undefined) return '0%'
  return `${Math.round(num)}%`
}

const getScoreClass = (score) => {
  if (score >= 90) return 'score-excellent'
  if (score >= 75) return 'score-good'
  if (score >= 60) return 'score-average'
  return 'score-needs-improvement'
}

const getPassRateClass = (passRate) => {
  if (passRate >= 80) return 'pass-rate-excellent'
  if (passRate >= 60) return 'pass-rate-good'
  if (passRate >= 40) return 'pass-rate-average'
  return 'pass-rate-poor'
}

const handleSortChange = () => {
  setExamSort(currentSort.value.field, currentSort.value.order)
  refreshData()
}

const toggleSortOrder = () => {
  currentSort.value.order = currentSort.value.order === 'asc' ? 'desc' : 'asc'
  handleSortChange()
}

const selectExam = async (exam) => {
  selectedExam.value = exam
  
  // Fetch detailed exam data from database
  try {
    const examDetails = await fetchExamDetails(exam.id, props.timeFilter, { bypassCache: true })
    // Update the selected exam with full details including score distribution
    selectedExam.value = {
      ...exam,
      ...examDetails
    }
  } catch (error) {
    console.error('Failed to fetch exam details:', error)
    // Keep the basic exam data even if details fail to load
  }
}

const ensureSelectedExam = async () => {
  if (!exams.value.length) {
    selectedExam.value = null
    return
  }

  if (selectedExam.value?.id) {
    const selectedExists = exams.value.some(exam => exam.id === selectedExam.value.id)
    if (selectedExists) {
      await selectExam(exams.value.find(exam => exam.id === selectedExam.value.id))
      return
    }
  }

  const examWithAttempts = exams.value.find(exam => (exam.totalAttempts || 0) > 0)
  await selectExam(examWithAttempts || exams.value[0])
}

const goToPage = async (page) => {
  if (page >= 1 && page <= pagination.value.totalPages) {
    await fetchExamPerformance(props.timeFilter, page)
    await ensureSelectedExam()
  }
}

const refreshData = async () => {
  try {
    await fetchExamPerformance(props.timeFilter, pagination.value.currentPage)
    await ensureSelectedExam()
  } catch (err) {
    console.error('Failed to refresh exam performance data:', err)
  }
}

// Watchers
watch(() => props.timeFilter, (newFilter) => {
  if (newFilter) {
    selectedExam.value = null // Clear selection when filter changes
    refreshData()
  }
}, { immediate: false })

// Lifecycle
onMounted(() => {
  refreshData()
})
</script>

<style scoped>
* {
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

.exam-performance-section {
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

/* Sort Controls */
.sort-controls {
  display: flex;
  align-items: center;
  gap: 12px;
}

.sort-group {
  display: flex;
  align-items: center;
  gap: 8px;
}

.sort-label {
  font-size: 13px;
  font-weight: 500;
  color: #86868B;
}

.sort-select {
  padding: 8px 12px;
  border: 1px solid rgba(0, 0, 0, 0.1);
  border-radius: 8px;
  background: #FFFFFF;
  font-size: 13px;
  font-weight: 500;
  color: #1D1D1F;
  cursor: pointer;
  transition: all 0.2s ease;
}

.sort-select:focus {
  outline: none;
  border-color: #007AFF;
  box-shadow: 0 0 0 3px rgba(0, 122, 255, 0.1);
}

.sort-order-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  background: #F5F5F7;
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.sort-order-btn:hover {
  background: #E8E8ED;
}

.sort-order-btn svg {
  width: 16px;
  height: 16px;
  color: #86868B;
  stroke-width: 2;
  transition: transform 0.2s ease;
}

.sort-order-btn.desc svg {
  transform: rotate(180deg);
}

/* Exam List */
.exam-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 20px;
}

.exam-performance-card {
  background: #FFFFFF;
  border-radius: 16px;
  padding: 24px;
  border: 1px solid rgba(0, 0, 0, 0.06);
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  cursor: pointer;
  position: relative;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.exam-performance-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
  border-color: rgba(0, 122, 255, 0.2);
}

.exam-performance-card.selected {
  border-color: #007AFF;
  box-shadow: 0 8px 24px rgba(0, 122, 255, 0.2);
}

.card-header h3 {
  margin: 0 0 4px 0;
  font-size: 18px;
  font-weight: 600;
  color: #1D1D1F;
  letter-spacing: -0.3px;
  line-height: 1.3;
}

.card-header p {
  margin: 0;
  font-size: 13px;
  color: #86868B;
  font-weight: 500;
}

/* Card Metrics */
.card-metrics {
  display: flex;
  gap: 16px;
}

.metric-item {
  display: flex;
  align-items: center;
  gap: 12px;
  flex: 1;
}

.metric-icon {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.metric-icon svg {
  width: 20px;
  height: 20px;
  stroke-width: 2;
}

.attempts-icon {
  background: rgba(255, 149, 0, 0.1);
  color: #FF9500;
}

.score-icon {
  background: rgba(52, 199, 89, 0.1);
  color: #34C759;
}

.pass-rate-icon {
  background: rgba(88, 86, 214, 0.1);
  color: #5856D6;
}

/* Score-based colors */
.score-excellent {
  color: #34C759 !important;
}

.score-good {
  color: #FF9500 !important;
}

.score-average {
  color: #5856D6 !important;
}

.score-needs-improvement {
  color: #FF3B30 !important;
}

/* Pass rate colors */
.pass-rate-excellent {
  color: #34C759 !important;
}

.pass-rate-good {
  color: #FF9500 !important;
}

.pass-rate-average {
  color: #5856D6 !important;
}

.pass-rate-poor {
  color: #FF3B30 !important;
}

.metric-content {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.metric-value {
  font-size: 16px;
  font-weight: 700;
  color: #1D1D1F;
  font-variant-numeric: tabular-nums;
}

.metric-label {
  font-size: 11px;
  font-weight: 500;
  color: #86868B;
  text-transform: uppercase;
  letter-spacing: 0.3px;
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
  margin-top: -8px;
}

.no-attempts-badge svg {
  width: 14px;
  height: 14px;
  stroke-width: 2;
}

/* Selection Indicator */
.selection-indicator {
  position: absolute;
  top: 16px;
  right: 16px;
  width: 24px;
  height: 24px;
  background: #007AFF;
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.selection-indicator svg {
  width: 14px;
  height: 14px;
  color: white;
}

/* Pagination */
.pagination {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px 0;
  border-top: 1px solid rgba(0, 0, 0, 0.06);
}

.pagination-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
  background: #F5F5F7;
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 8px;
  font-size: 13px;
  font-weight: 500;
  color: #1D1D1F;
  cursor: pointer;
  transition: all 0.2s ease;
}

.pagination-btn:hover:not(:disabled) {
  background: #E8E8ED;
}

.pagination-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.pagination-btn svg {
  width: 16px;
  height: 16px;
  stroke-width: 2;
}

.pagination-info {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}

.page-numbers {
  font-size: 14px;
  font-weight: 600;
  color: #1D1D1F;
}

.total-count {
  font-size: 12px;
  color: #86868B;
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
  width: 40px;
  height: 40px;
  background: linear-gradient(90deg, #F5F5F7 25%, #E8E8ED 50%, #F5F5F7 75%);
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
  border-radius: 10px;
}

.skeleton-title {
  width: 70%;
  height: 18px;
  margin-bottom: 8px;
}

.skeleton-subtitle {
  width: 40%;
  height: 13px;
}

.skeleton-metric {
  width: 60%;
  height: 16px;
}

@keyframes shimmer {
  0% {
    background-position: -200% 0;
  }
  100% {
    background-position: 200% 0;
  }
}

/* Score Distribution Section */
.score-distribution-section {
  margin-top: 24px;
  padding-top: 24px;
  border-top: 1px solid rgba(0, 0, 0, 0.06);
}

/* Responsive Design */
@media (max-width: 768px) {
  .section-header {
    flex-direction: column;
    align-items: stretch;
    gap: 16px;
  }
  
  .sort-controls {
    justify-content: space-between;
  }
  
  .exam-list {
    grid-template-columns: 1fr;
    gap: 16px;
  }
  
  .exam-performance-card {
    padding: 20px;
  }
  
  .card-metrics {
    flex-direction: column;
    gap: 12px;
  }
  
  .pagination {
    flex-direction: column;
    gap: 16px;
  }
}

@media (max-width: 480px) {
  .exam-performance-card {
    padding: 16px;
  }
  
  .metric-item {
    gap: 8px;
  }
  
  .metric-icon {
    width: 32px;
    height: 32px;
  }
  
  .metric-icon svg {
    width: 16px;
    height: 16px;
  }
}
</style>
