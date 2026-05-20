<template>
  <div class="student-performance-section">
    <!-- Section Header -->
    <div class="section-header">
      <div class="header-content">
        <h2 class="section-title">Student Performance</h2>
        <p class="section-subtitle">Track student progress and performance levels</p>
      </div>
      
      <!-- Performance Level Filter -->
      <div class="filter-controls">
        <div class="filter-group">
          <label class="filter-label">Performance Level:</label>
          <select 
            v-model="currentLevel" 
            @change="handleLevelChange"
            class="filter-select"
          >
            <option value="all">All Students</option>
            <option value="top">Top Performers</option>
            <option value="average">Average</option>
            <option value="struggling">Struggling</option>
          </select>
        </div>
      </div>
    </div>

    <!-- Top Performers Leaderboard -->
    <div v-if="topPerformers.length > 0" class="top-performers-section">
      <h3 class="leaderboard-title">🏆 Top 10 Performers</h3>
      <div class="leaderboard">
        <div 
          v-for="(student, index) in topPerformers" 
          :key="student.id"
          class="leaderboard-item"
          :class="{ 'top-three': index < 3 }"
        >
          <div class="rank-badge" :class="getRankClass(index)">
            <span v-if="index < 3" class="rank-icon">
              {{ index === 0 ? '🥇' : index === 1 ? '🥈' : '🥉' }}
            </span>
            <span v-else class="rank-number">{{ index + 1 }}</span>
          </div>
          
          <div class="student-info">
            <div class="student-name">{{ student.name }}</div>
            <div class="student-stats">
              {{ formatNumber(student.totalAttempts) }} attempts
            </div>
          </div>
          
          <div class="performance-score" :class="getScoreClass(student.averageScore)">
            {{ formatPercentage(student.averageScore) }}
          </div>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="student-list">
      <div v-for="i in 6" :key="i" class="student-performance-card skeleton">
        <div class="card-header">
          <div class="skeleton-circle"></div>
          <div class="student-details">
            <div class="skeleton-line skeleton-name"></div>
            <div class="skeleton-line skeleton-level"></div>
          </div>
        </div>
        <div class="card-metrics">
          <div v-for="j in 3" :key="j" class="metric-item skeleton">
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
      <h3>Unable to Load Student Performance</h3>
      <p>{{ error }}</p>
      <button @click="refreshData" class="retry-button">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
        </svg>
        Try Again
      </button>
    </div>
    <!-- Student List -->
    <div v-else-if="students.length > 0" class="student-list">
      <div 
        v-for="student in students" 
        :key="student.id"
        class="student-performance-card"
        :class="{ 'selected': selectedStudent?.id === student.id }"
        @click="selectStudent(student)"
      >
        <div class="card-header">
          <div class="student-avatar" :class="getPerformanceLevelClass(student.performanceLevel)">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
              <circle cx="12" cy="7" r="4"/>
            </svg>
          </div>
          
          <div class="student-details">
            <h3 class="student-name">{{ student.name }}</h3>
            <div class="performance-level" :class="getPerformanceLevelClass(student.performanceLevel)">
              <span class="level-indicator"></span>
              {{ formatPerformanceLevel(student.performanceLevel) }}
            </div>
          </div>
        </div>
        
        <div class="card-metrics">
          <!-- Total Attempts -->
          <div class="metric-item">
            <div class="metric-content">
              <div class="metric-value">{{ formatNumber(student.totalAttempts) }}</div>
              <div class="metric-label">Attempts</div>
            </div>
          </div>

          <!-- Average Score -->
          <div class="metric-item">
            <div class="metric-content">
              <div class="metric-value" :class="getScoreClass(student.averageScore)">
                {{ formatPercentage(student.averageScore) }}
              </div>
              <div class="metric-label">Avg Score</div>
            </div>
          </div>

          <!-- Completion Rate -->
          <div class="metric-item">
            <div class="metric-content">
              <div class="metric-value" :class="getCompletionRateClass(student.passRate)">
                {{ formatPercentage(student.passRate) }}
              </div>
              <div class="metric-label">Pass Rate</div>
            </div>
          </div>
        </div>

        <!-- Zero Attempts Edge Case -->
        <div v-if="student.totalAttempts === 0" class="no-attempts-badge">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <circle cx="12" cy="12" r="10"/>
            <line x1="12" y1="8" x2="12" y2="12"/>
            <line x1="12" y1="16" x2="12.01" y2="16"/>
          </svg>
          <span>No attempts yet</span>
        </div>

        <!-- Selection Indicator -->
        <div v-if="selectedStudent?.id === student.id" class="selection-indicator">
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
          <path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/>
          <circle cx="9" cy="7" r="4"/>
          <path d="M23 21v-2a4 4 0 00-3-3.87"/>
          <path d="M16 3.13a4 4 0 010 7.75"/>
        </svg>
      </div>
      <h3>No Students Found</h3>
      <p>No student data available for the selected performance level and time period.</p>
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
          {{ formatNumber(pagination.total) }} total students
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

    <Teleport to="body">
      <div v-if="selectedStudent" class="performance-trend-modal-backdrop" @click.self="selectedStudent = null">
        <div class="performance-trend-modal-content">
          <PerformanceTrendChart 
            :student="selectedStudent"
            :time-filter="timeFilter"
            @close="selectedStudent = null"
          />
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { useAnalytics } from '@/composables/useAnalytics'
import PerformanceTrendChart from './PerformanceTrendChart.vue'

const props = defineProps({
  timeFilter: {
    type: String,
    default: 'all'
  }
})

const emit = defineEmits(['update:timeFilter'])

// Composables
const { 
  studentData, 
  loadingStates, 
  errorStates, 
  paginationStates,
  fetchStudentPerformance,
  fetchTopPerformers,
  setStudentLevel
} = useAnalytics()

// Local state
const selectedStudent = ref(null)
const currentLevel = ref('all')
const topPerformers = ref([])

// Computed properties
const loading = computed(() => loadingStates.students)
const error = computed(() => errorStates.students)
const students = computed(() => studentData.value?.students || [])
const pagination = computed(() => paginationStates.students)

// Methods
const formatNumber = (num) => {
  if (num === null || num === undefined) return '0'
  return new Intl.NumberFormat('en-US').format(num)
}

const formatPercentage = (num) => {
  if (num === null || num === undefined) return '0%'
  return `${Math.round(num)}%`
}

const formatPerformanceLevel = (level) => {
  const levels = {
    'top': 'Top Performer',
    'average': 'Average',
    'struggling': 'Struggling'
  }
  return levels[level] || level
}

const getScoreClass = (score) => {
  if (score >= 90) return 'score-excellent'
  if (score >= 75) return 'score-good'
  if (score >= 60) return 'score-average'
  return 'score-needs-improvement'
}

const getCompletionRateClass = (rate) => {
  if (rate >= 90) return 'completion-excellent'
  if (rate >= 70) return 'completion-good'
  if (rate >= 50) return 'completion-average'
  return 'completion-poor'
}

const getPerformanceLevelClass = (level) => {
  return `performance-${level}`
}

const getRankClass = (index) => {
  if (index === 0) return 'rank-gold'
  if (index === 1) return 'rank-silver'
  if (index === 2) return 'rank-bronze'
  return 'rank-default'
}

const handleLevelChange = () => {
  setStudentLevel(currentLevel.value)
  selectedStudent.value = null // Clear selection when filter changes
  refreshData()
}

const selectStudent = (student) => {
  selectedStudent.value = student
}

const goToPage = (page) => {
  if (page >= 1 && page <= pagination.value.totalPages) {
    fetchStudentPerformance(props.timeFilter, page)
  }
}

const loadTopPerformers = async () => {
  try {
    // Fetch top performers from dedicated API endpoint
    const data = await fetchTopPerformers(props.timeFilter)
    if (Array.isArray(data)) {
      topPerformers.value = data
    } else if (studentData.value?.topPerformers) {
      topPerformers.value = studentData.value.topPerformers
    }
  } catch (err) {
    console.error('Failed to load top performers:', err)
    // Fallback: use top students from current data sorted by score
    if (studentData.value?.students) {
      topPerformers.value = [...studentData.value.students]
        .sort((a, b) => b.averageScore - a.averageScore)
        .slice(0, 10)
    }
  }
}

const refreshData = async () => {
  try {
    await Promise.all([
      fetchStudentPerformance(props.timeFilter, pagination.value.currentPage),
      loadTopPerformers()
    ])
  } catch (err) {
    console.error('Failed to refresh student performance data:', err)
  }
}

// Watchers
watch(() => props.timeFilter, (newFilter) => {
  if (newFilter) {
    selectedStudent.value = null // Clear selection when filter changes
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

.student-performance-section {
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

/* Filter Controls */
.filter-controls {
  display: flex;
  align-items: center;
  gap: 12px;
}

.filter-group {
  display: flex;
  align-items: center;
  gap: 8px;
}

.filter-label {
  font-size: 13px;
  font-weight: 500;
  color: #86868B;
}

.filter-select {
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

.filter-select:focus {
  outline: none;
  border-color: #007AFF;
  box-shadow: 0 0 0 3px rgba(0, 122, 255, 0.1);
}

/* Top Performers Leaderboard */
.top-performers-section {
  background: #FFFFFF;
  border-radius: 16px;
  padding: 24px;
  border: 1px solid rgba(0, 0, 0, 0.06);
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
}

.leaderboard-title {
  margin: 0 0 20px 0;
  font-size: 18px;
  font-weight: 700;
  color: #1D1D1F;
  letter-spacing: -0.3px;
}

.leaderboard {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.leaderboard-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  background: #F5F5F7;
  border-radius: 12px;
  transition: all 0.2s ease;
}

.leaderboard-item.top-three {
  background: linear-gradient(135deg, rgba(255, 215, 0, 0.1), rgba(255, 215, 0, 0.05));
  border: 1px solid rgba(255, 215, 0, 0.2);
}

.rank-badge {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  flex-shrink: 0;
}

.rank-gold {
  background: linear-gradient(135deg, #FFD700, #FFA500);
  color: #FFFFFF;
}

.rank-silver {
  background: linear-gradient(135deg, #C0C0C0, #A8A8A8);
  color: #FFFFFF;
}

.rank-bronze {
  background: linear-gradient(135deg, #CD7F32, #B8860B);
  color: #FFFFFF;
}

.rank-default {
  background: #E8E8ED;
  color: #86868B;
}

.rank-icon {
  font-size: 18px;
}

.rank-number {
  font-size: 16px;
  font-weight: 700;
}

.student-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.student-name {
  font-size: 16px;
  font-weight: 600;
  color: #1D1D1F;
  letter-spacing: -0.2px;
}

.student-stats {
  font-size: 12px;
  color: #86868B;
  font-weight: 500;
}

.performance-score {
  font-size: 18px;
  font-weight: 700;
  font-variant-numeric: tabular-nums;
}

/* Student List */
.student-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 20px;
}

.student-performance-card {
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

.student-performance-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
  border-color: rgba(0, 122, 255, 0.2);
}

.student-performance-card.selected {
  border-color: #007AFF;
  box-shadow: 0 8px 24px rgba(0, 122, 255, 0.2);
}

.card-header {
  display: flex;
  align-items: center;
  gap: 16px;
}

.student-avatar {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.student-avatar svg {
  width: 24px;
  height: 24px;
  stroke-width: 2;
}

.performance-top {
  background: rgba(52, 199, 89, 0.1);
  color: #34C759;
}

.performance-average {
  background: rgba(255, 149, 0, 0.1);
  color: #FF9500;
}

.performance-struggling {
  background: rgba(255, 59, 48, 0.1);
  color: #FF3B30;
}

.student-details {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.student-name {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: #1D1D1F;
  letter-spacing: -0.3px;
  line-height: 1.3;
}

.performance-level {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.3px;
}

.level-indicator {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
}

.performance-top .level-indicator {
  background: #34C759;
}

.performance-average .level-indicator {
  background: #FF9500;
}

.performance-struggling .level-indicator {
  background: #FF3B30;
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

/* Completion rate colors */
.completion-excellent {
  color: #34C759 !important;
}

.completion-good {
  color: #FF9500 !important;
}

.completion-average {
  color: #5856D6 !important;
}

.completion-poor {
  color: #FF3B30 !important;
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
  width: 48px;
  height: 48px;
  background: linear-gradient(90deg, #F5F5F7 25%, #E8E8ED 50%, #F5F5F7 75%);
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
  border-radius: 12px;
}

.skeleton-name {
  width: 70%;
  height: 18px;
  margin-bottom: 8px;
}

.skeleton-level {
  width: 40%;
  height: 12px;
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

.performance-trend-modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
  z-index: 9999;
}

.performance-trend-modal-content {
  width: min(980px, 100%);
  max-height: calc(100vh - 40px);
  overflow: auto;
  border-radius: 16px;
}

/* Responsive Design */
@media (max-width: 768px) {
  .section-header {
    flex-direction: column;
    align-items: stretch;
    gap: 16px;
  }
  
  .filter-controls {
    justify-content: space-between;
  }
  
  .student-list {
    grid-template-columns: 1fr;
    gap: 16px;
  }
  
  .student-performance-card {
    padding: 20px;
  }
  
  .card-metrics {
    flex-direction: column;
    gap: 12px;
  }
  
  .leaderboard-item {
    padding: 12px;
  }
  
  .pagination {
    flex-direction: column;
    gap: 16px;
  }

  .performance-trend-modal-backdrop {
    padding: 12px;
  }

  .performance-trend-modal-content {
    max-height: calc(100vh - 24px);
  }
}

@media (max-width: 480px) {
  .student-performance-card {
    padding: 16px;
  }
  
  .card-header {
    gap: 12px;
  }
  
  .student-avatar {
    width: 40px;
    height: 40px;
  }
  
  .student-avatar svg {
    width: 20px;
    height: 20px;
  }
  
  .leaderboard-item {
    gap: 12px;
  }
  
  .rank-badge {
    width: 32px;
    height: 32px;
  }
}
</style>
