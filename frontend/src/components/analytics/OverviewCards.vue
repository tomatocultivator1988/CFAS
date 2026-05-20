<template>
  <div class="overview-cards">
    <!-- Loading State -->
    <div v-if="loading" class="cards-grid">
      <div v-for="i in 4" :key="i" class="overview-card skeleton">
        <div class="card-icon skeleton-circle"></div>
        <div class="card-content">
          <div class="skeleton-line skeleton-title"></div>
          <div class="skeleton-line skeleton-value"></div>
          <div class="skeleton-line skeleton-subtitle"></div>
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
      <h3>Unable to Load Overview</h3>
      <p>{{ error }}</p>
      <button @click="refreshData" class="retry-button">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
        </svg>
        Try Again
      </button>
    </div>

    <!-- Data Cards -->
    <div v-else class="cards-grid">
      <!-- Total Exams Card -->
      <div class="overview-card exams-card">
        <div class="card-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
          </svg>
        </div>
        <div class="card-content">
          <h3 class="card-title">Total Exams</h3>
          <div class="card-value">{{ formatNumber(data.totalExams) }}</div>
          <p class="card-subtitle">Active examinations</p>
        </div>
      </div>

      <!-- Total Attempts Card -->
      <div class="overview-card attempts-card">
        <div class="card-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
          </svg>
        </div>
        <div class="card-content">
          <h3 class="card-title">Total Attempts</h3>
          <div class="card-value">{{ formatNumber(data.totalAttempts) }}</div>
          <p class="card-subtitle">{{ timeFilterLabel }}</p>
        </div>
      </div>

      <!-- Active Reviewees Card -->
      <div class="overview-card reviewees-card">
        <div class="card-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/>
            <circle cx="9" cy="7" r="4"/>
            <path d="M23 21v-2a4 4 0 00-3-3.87"/>
            <path d="M16 3.13a4 4 0 010 7.75"/>
          </svg>
        </div>
        <div class="card-content">
          <h3 class="card-title">Active Reviewees</h3>
          <div class="card-value">{{ formatNumber(data.activeReviewees) }}</div>
          <p class="card-subtitle">{{ timeFilterLabel }}</p>
        </div>
      </div>

      <!-- Overall Average Card -->
      <div class="overview-card average-card">
        <div class="card-icon" :class="averageScoreClass">
          <svg viewBox="0 0 24 24" fill="currentColor">
            <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
          </svg>
        </div>
        <div class="card-content">
          <h3 class="card-title">Overall Average</h3>
          <div class="card-value" :class="averageScoreClass">
            {{ formatPercentage(data.overallAverage) }}
          </div>
          <p class="card-subtitle">{{ timeFilterLabel }}</p>
        </div>
      </div>

      <!-- Pass Rate Card -->
      <div class="overview-card passrate-card" v-if="data.overallPassRate !== undefined">
        <div class="card-icon" :class="passRateClass">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
            <polyline points="22 4 12 14.01 9 11.01"/>
          </svg>
        </div>
        <div class="card-content">
          <h3 class="card-title">Pass Rate</h3>
          <div class="card-value" :class="passRateClass">
            {{ formatPercentage(data.overallPassRate) }}
          </div>
          <p class="card-subtitle">{{ timeFilterLabel }}</p>
        </div>
      </div>
    </div>

    <!-- Category Breakdown Section -->
    <div v-if="!loading && !error && categoryBreakdown.length > 0" class="category-breakdown-section">
      <h3 class="section-title">Performance by Category</h3>
      <div class="category-grid">
        <div 
          v-for="cat in categoryBreakdown" 
          :key="cat.category"
          class="category-card"
        >
          <div class="category-header">
            <span class="category-name">{{ cat.category || 'Uncategorized' }}</span>
            <span class="category-attempts">{{ formatNumber(cat.totalAttempts) }} attempts</span>
          </div>
          <div class="category-metrics">
            <div class="category-metric">
              <span class="metric-label">Avg Score</span>
              <span class="metric-value" :class="getScoreClass(cat.averageScore)">{{ formatPercentage(cat.averageScore) }}</span>
            </div>
            <div class="category-metric">
              <span class="metric-label">Pass Rate</span>
              <span class="metric-value" :class="getScoreClass(cat.passRate)">{{ formatPercentage(cat.passRate) }}</span>
            </div>
          </div>
          <div class="category-progress">
            <div class="progress-bar">
              <div 
                class="progress-fill" 
                :style="{ width: `${Math.min(cat.averageScore, 100)}%` }"
                :class="getScoreClass(cat.averageScore)"
              ></div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Recent Activity Section -->
    <div v-if="!loading && !error && recentActivity.length > 0" class="recent-activity-section">
      <div class="section-header">
        <h3 class="section-title">Recent Activity <span class="section-badge">Last 7 Days</span></h3>
        <button v-if="hasMoreRecentActivity" @click="toggleRecentActivity" class="see-all-button">
          {{ showAllRecentActivity ? 'Show Less' : 'See All' }}
        </button>
      </div>
      <div class="activity-list">
        <div 
          v-for="activity in displayedRecentActivity" 
          :key="activity.id"
          class="activity-item"
        >
          <div class="activity-avatar">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
              <circle cx="12" cy="7" r="4"/>
            </svg>
          </div>
          <div class="activity-details">
            <div class="activity-student">{{ activity.studentName }}</div>
            <div class="activity-exam">{{ activity.examTitle }}</div>
          </div>
          <div class="activity-score" :class="getScoreClass(activity.score)">
            {{ formatPercentage(activity.score) }}
          </div>
          <div class="activity-date">{{ formatDate(activity.date) }}</div>
        </div>
      </div>
    </div>

    <!-- Top Exams Section -->
    <div v-if="!loading && !error && topExams.length > 0" class="top-exams-section">
      <h3 class="section-title">Most Active Exams</h3>
      <div class="top-exams-list">
        <div 
          v-for="(exam, index) in topExams" 
          :key="exam.id"
          class="top-exam-item"
        >
          <div class="exam-rank">{{ index + 1 }}</div>
          <div class="exam-info">
            <div class="exam-title">{{ exam.title }}</div>
            <div class="exam-category">{{ exam.category || 'General' }}</div>
          </div>
          <div class="exam-stats">
            <span class="exam-attempts">{{ formatNumber(exam.totalAttempts) }} attempts</span>
            <span class="exam-avg" :class="getScoreClass(exam.averageScore)">{{ formatPercentage(exam.averageScore) }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Enhanced Status Bar -->
    <div v-if="!loading && !error" class="status-bar">
      <div class="status-info">
        <!-- Last Updated -->
        <span class="status-item">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <circle cx="12" cy="12" r="10"/>
            <polyline points="12,6 12,12 16,14"/>
          </svg>
          Last updated: {{ lastUpdatedTime }}
        </span>
        
        <!-- Data Points -->
        <span class="status-item" v-if="totalDataPoints > 0">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
            <circle cx="12" cy="7" r="4"/>
          </svg>
          {{ formatNumber(totalDataPoints) }} data points
        </span>
        
        <!-- Time Filter -->
        <span class="status-item filter-badge">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <polygon points="22,3 2,3 10,12.46 10,19 14,21 14,12.46"/>
          </svg>
          {{ timeFilterLabel }}
        </span>
        
        <!-- Performance Indicator -->
        <span class="status-item performance-indicator" :class="performanceClass">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M22 12h-4l-3 9L9 3l-3 9H2"/>
          </svg>
          {{ performanceLabel }}
        </span>
      </div>
      
      <div class="status-actions">
        <!-- Connection Status -->
        <div class="connection-status" :class="connectionStatusClass">
          <div class="status-dot"></div>
          <span>{{ connectionStatusText }}</span>
        </div>
        
        <!-- Auto Refresh Toggle -->
        <button @click="toggleAutoRefresh" class="auto-refresh-toggle" :class="{ active: autoRefreshEnabled }">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
          </svg>
          <span>Auto</span>
        </button>
        
        <!-- Manual Refresh -->
        <button @click="refreshData" class="refresh-button" :disabled="loading">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" :class="{ 'spinning': loading }">
            <path d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
          </svg>
        </button>
        
        <!-- Export Data -->
        <button @click="exportData" class="export-button" title="Export Overview Data">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
            <polyline points="7,10 12,15 17,10"/>
            <line x1="12" y1="15" x2="12" y2="3"/>
          </svg>
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, watch, onMounted, ref, onUnmounted } from 'vue'
import { useTimeFilter } from '@/composables/useTimeFilter'
import { useAnalytics } from '@/composables/useAnalytics'

const props = defineProps({
  timeFilter: {
    type: String,
    default: 'all'
  }
})

const emit = defineEmits(['update:timeFilter'])

// Reactive state
const lastUpdated = ref(new Date())
const autoRefreshEnabled = ref(false)
const autoRefreshInterval = ref(null)
const connectionStatus = ref('connected') // 'connected', 'connecting', 'error'

// Composables
const { timeFilterOptions } = useTimeFilter()
const { 
  overviewData, 
  loadingStates, 
  errorStates, 
  fetchOverviewMetrics 
} = useAnalytics()

// Computed properties
const loading = computed(() => loadingStates.overview)
const error = computed(() => errorStates.overview)
const data = computed(() => overviewData.value || {
  totalExams: 0,
  totalAttempts: 0,
  activeReviewees: 0,
  overallAverage: 0,
  overallPassRate: undefined
})

const categoryBreakdown = computed(() => overviewData.value?.categoryBreakdown || [])
const recentActivity = computed(() => overviewData.value?.recentActivity || [])
const topExams = computed(() => overviewData.value?.topExams || [])
const showAllRecentActivity = ref(false)
const hasMoreRecentActivity = computed(() => recentActivity.value.length > 5)
const displayedRecentActivity = computed(() => {
  if (showAllRecentActivity.value) {
    return recentActivity.value
  }

  return recentActivity.value.slice(0, 5)
})

const timeFilterLabel = computed(() => {
  const option = timeFilterOptions.find(opt => opt.value === props.timeFilter)
  return option?.label || 'All Time'
})

const averageScoreClass = computed(() => {
  const score = data.value.overallAverage || 0
  if (score >= 90) return 'score-excellent'
  if (score >= 75) return 'score-good'
  if (score >= 60) return 'score-average'
  return 'score-needs-improvement'
})

const passRateClass = computed(() => {
  const rate = data.value.overallPassRate || 0
  if (rate >= 80) return 'score-excellent'
  if (rate >= 60) return 'score-good'
  if (rate >= 40) return 'score-average'
  return 'score-needs-improvement'
})

// Enhanced computed properties
const lastUpdatedTime = computed(() => {
  return lastUpdated.value.toLocaleTimeString('en-US', {
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: true
  })
})

const totalDataPoints = computed(() => {
  return (data.value.totalExams || 0) + (data.value.totalAttempts || 0) + (data.value.activeReviewees || 0)
})

const performanceClass = computed(() => {
  const score = data.value.overallAverage || 0
  if (score >= 85) return 'performance-excellent'
  if (score >= 70) return 'performance-good'
  if (score >= 50) return 'performance-average'
  return 'performance-poor'
})

const performanceLabel = computed(() => {
  const score = data.value.overallAverage || 0
  if (score >= 85) return 'Excellent'
  if (score >= 70) return 'Good'
  if (score >= 50) return 'Average'
  return 'Needs Attention'
})

const connectionStatusClass = computed(() => {
  if (error.value) return 'error'
  if (loading.value) return 'connecting'
  return 'connected'
})

const connectionStatusText = computed(() => {
  if (error.value) return 'Connection Error'
  if (loading.value) return 'Connecting...'
  return 'Connected'
})

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
  if (score >= 85) return 'score-excellent'
  if (score >= 70) return 'score-good'
  if (score >= 50) return 'score-average'
  return 'score-needs-improvement'
}

const formatDate = (dateStr) => {
  if (!dateStr) return ''
  try {
    const date = new Date(dateStr)
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' })
  } catch {
    return dateStr
  }
}

const toggleRecentActivity = () => {
  showAllRecentActivity.value = !showAllRecentActivity.value
}

const refreshData = async () => {
  try {
    connectionStatus.value = 'connecting'
    // Add null check for props.timeFilter
    const timeFilter = props.timeFilter || 'all'
    await fetchOverviewMetrics(timeFilter)
    lastUpdated.value = new Date()
    connectionStatus.value = 'connected'
  } catch (err) {
    console.error('Failed to refresh overview data:', err)
    connectionStatus.value = 'error'
  }
}

const toggleAutoRefresh = () => {
  autoRefreshEnabled.value = !autoRefreshEnabled.value
  
  if (autoRefreshEnabled.value) {
    // Start auto refresh every 30 seconds
    autoRefreshInterval.value = setInterval(() => {
      refreshData()
    }, 30000)
  } else {
    // Stop auto refresh
    if (autoRefreshInterval.value) {
      clearInterval(autoRefreshInterval.value)
      autoRefreshInterval.value = null
    }
  }
}

const exportData = () => {
  try {
    // Add null checks for all data references
    const currentData = data.value || {}
    const exportData = {
      timestamp: new Date().toISOString(),
      timeFilter: props.timeFilter || 'all',
      data: currentData,
      summary: {
        totalDataPoints: totalDataPoints.value || 0,
        performance: performanceLabel.value || 'Unknown',
        lastUpdated: lastUpdated.value ? lastUpdated.value.toISOString() : new Date().toISOString()
      }
    }
    
    const blob = new Blob([JSON.stringify(exportData, null, 2)], { type: 'application/json' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `analytics-overview-${new Date().toISOString().split('T')[0]}.json`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
  } catch (error) {
    console.error('Export failed:', error)
    // Show user-friendly error message
    alert('Export failed. Please try again.')
  }
}

// Watchers
watch(() => props.timeFilter, (newFilter) => {
  if (newFilter) {
    refreshData()
  }
}, { immediate: false })

// Lifecycle
onMounted(() => {
  refreshData()
})

onUnmounted(() => {
  if (autoRefreshInterval.value) {
    clearInterval(autoRefreshInterval.value)
  }
})
</script>

<style scoped>
* {
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

.overview-cards {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.cards-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 20px;
}

.overview-card {
  background: #FFFFFF;
  border-radius: 16px;
  padding: 24px;
  border: 1px solid rgba(0, 0, 0, 0.06);
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  align-items: flex-start;
  gap: 16px;
}

.overview-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
}

.card-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  transition: all 0.2s ease;
}

.card-icon svg {
  width: 24px;
  height: 24px;
  stroke-width: 2;
}

/* Card-specific icon colors */
.exams-card .card-icon {
  background: rgba(0, 122, 255, 0.1);
  color: #007AFF;
}

.attempts-card .card-icon {
  background: rgba(255, 149, 0, 0.1);
  color: #FF9500;
}

.reviewees-card .card-icon {
  background: rgba(88, 86, 214, 0.1);
  color: #5856D6;
}

.average-card .card-icon {
  background: rgba(52, 199, 89, 0.1);
  color: #34C759;
}

.card-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.card-title {
  margin: 0;
  font-size: 14px;
  font-weight: 500;
  color: #86868B;
  letter-spacing: -0.1px;
  text-transform: uppercase;
  font-size: 11px;
  letter-spacing: 0.3px;
}

.card-value {
  font-size: 32px;
  font-weight: 700;
  color: #1D1D1F;
  letter-spacing: -1px;
  line-height: 1.1;
  font-variant-numeric: tabular-nums;
}

.card-subtitle {
  margin: 0;
  font-size: 13px;
  font-weight: 400;
  color: #86868B;
  letter-spacing: -0.1px;
}

/* Score-based colors for average card */
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

.average-card .card-icon.score-excellent {
  background: rgba(52, 199, 89, 0.1);
  color: #34C759;
}

.average-card .card-icon.score-good {
  background: rgba(255, 149, 0, 0.1);
  color: #FF9500;
}

.average-card .card-icon.score-average {
  background: rgba(88, 86, 214, 0.1);
  color: #5856D6;
}

.average-card .card-icon.score-needs-improvement {
  background: rgba(255, 59, 48, 0.1);
  color: #FF3B30;
}

/* Enhanced Status Bar */
.status-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 20px;
  background: linear-gradient(135deg, #F8F9FA 0%, #FFFFFF 100%);
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  flex-wrap: wrap;
  gap: 16px;
}

.status-info {
  display: flex;
  align-items: center;
  gap: 24px;
  flex-wrap: wrap;
}

.status-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  font-weight: 500;
  color: #1D1D1F;
  padding: 6px 12px;
  background: rgba(255, 255, 255, 0.8);
  border-radius: 8px;
  border: 1px solid rgba(0, 0, 0, 0.04);
  transition: all 0.2s ease;
}

.status-item:hover {
  background: rgba(255, 255, 255, 1);
  border-color: rgba(0, 0, 0, 0.08);
  transform: translateY(-1px);
}

.status-item svg {
  width: 14px;
  height: 14px;
  color: #86868B;
  stroke-width: 2;
  flex-shrink: 0;
}

.status-item.filter-badge {
  background: linear-gradient(135deg, #007AFF 0%, #5856D6 100%);
  color: white;
  border-color: transparent;
}

.status-item.filter-badge svg {
  color: rgba(255, 255, 255, 0.8);
}

.status-item.performance-indicator {
  font-weight: 600;
}

.status-item.performance-excellent {
  background: linear-gradient(135deg, #34C759 0%, #30D158 100%);
  color: white;
  border-color: transparent;
}

.status-item.performance-excellent svg {
  color: rgba(255, 255, 255, 0.9);
}

.status-item.performance-good {
  background: linear-gradient(135deg, #FF9500 0%, #FF9F0A 100%);
  color: white;
  border-color: transparent;
}

.status-item.performance-good svg {
  color: rgba(255, 255, 255, 0.9);
}

.status-item.performance-average {
  background: linear-gradient(135deg, #5856D6 0%, #5AC8FA 100%);
  color: white;
  border-color: transparent;
}

.status-item.performance-average svg {
  color: rgba(255, 255, 255, 0.9);
}

.status-item.performance-poor {
  background: linear-gradient(135deg, #FF3B30 0%, #FF453A 100%);
  color: white;
  border-color: transparent;
}

.status-item.performance-poor svg {
  color: rgba(255, 255, 255, 0.9);
}

.status-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.connection-status {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  font-weight: 500;
  padding: 6px 12px;
  border-radius: 8px;
  transition: all 0.2s ease;
}

.connection-status.connected {
  background: rgba(52, 199, 89, 0.1);
  color: #34C759;
  border: 1px solid rgba(52, 199, 89, 0.2);
}

.connection-status.connecting {
  background: rgba(255, 149, 0, 0.1);
  color: #FF9500;
  border: 1px solid rgba(255, 149, 0, 0.2);
}

.connection-status.error {
  background: rgba(255, 59, 48, 0.1);
  color: #FF3B30;
  border: 1px solid rgba(255, 59, 48, 0.2);
}

.status-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
}

.connection-status.connected .status-dot {
  background: #34C759;
  animation: pulse-green 2s infinite;
}

.connection-status.connecting .status-dot {
  background: #FF9500;
  animation: pulse-orange 1s infinite;
}

.connection-status.error .status-dot {
  background: #FF3B30;
  animation: pulse-red 1s infinite;
}

.auto-refresh-toggle {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 12px;
  background: #FFFFFF;
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 8px;
  font-size: 12px;
  font-weight: 500;
  color: #86868B;
  cursor: pointer;
  transition: all 0.2s ease;
}

.auto-refresh-toggle:hover {
  background: #F5F5F7;
  border-color: rgba(0, 0, 0, 0.1);
}

.auto-refresh-toggle.active {
  background: linear-gradient(135deg, #34C759 0%, #30D158 100%);
  color: white;
  border-color: transparent;
}

.auto-refresh-toggle svg {
  width: 14px;
  height: 14px;
  stroke-width: 2;
}

.auto-refresh-toggle.active svg {
  animation: spin 2s linear infinite;
}

.refresh-button, .export-button {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  background: #FFFFFF;
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.refresh-button:hover:not(:disabled), .export-button:hover {
  background: #F5F5F7;
  border-color: rgba(0, 0, 0, 0.1);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.refresh-button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none;
}

.refresh-button svg, .export-button svg {
  width: 16px;
  height: 16px;
  color: #86868B;
  stroke-width: 2;
  transition: transform 0.6s ease;
}

.refresh-button svg.spinning {
  animation: spin 1s linear infinite;
}

.export-button:hover svg {
  color: #007AFF;
}

@keyframes pulse-green {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

@keyframes pulse-orange {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.3; }
}

@keyframes pulse-red {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.2; }
}

/* Filter Info */
.filter-info {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 16px;
  background: #F5F5F7;
  border-radius: 12px;
}

.filter-badge {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  font-weight: 500;
  color: #1D1D1F;
}

.filter-badge svg {
  width: 16px;
  height: 16px;
  color: #86868B;
  stroke-width: 2;
}

.refresh-button {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  background: #FFFFFF;
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.refresh-button:hover:not(:disabled) {
  background: #F5F5F7;
  border-color: rgba(0, 0, 0, 0.1);
}

.refresh-button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.refresh-button svg {
  width: 16px;
  height: 16px;
  color: #86868B;
  stroke-width: 2;
  transition: transform 0.6s ease;
}

.refresh-button svg.spinning {
  animation: spin 1s linear infinite;
}

/* Error State */
.error-state {
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

.error-icon {
  width: 64px;
  height: 64px;
  border-radius: 16px;
  background: rgba(255, 59, 48, 0.1);
  color: #FF3B30;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 16px;
}

.error-icon svg {
  width: 32px;
  height: 32px;
  stroke-width: 2;
}

.error-state h3 {
  margin: 0 0 8px 0;
  font-size: 18px;
  font-weight: 600;
  color: #1D1D1F;
}

.error-state p {
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

.skeleton-circle {
  background: linear-gradient(90deg, #F5F5F7 25%, #E8E8ED 50%, #F5F5F7 75%);
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
  border-radius: 12px;
}

.skeleton-line {
  height: 16px;
  background: linear-gradient(90deg, #F5F5F7 25%, #E8E8ED 50%, #F5F5F7 75%);
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
  border-radius: 4px;
}

.skeleton-title {
  height: 12px;
  width: 60%;
}

.skeleton-value {
  height: 32px;
  width: 80%;
  margin: 4px 0;
}

.skeleton-subtitle {
  height: 10px;
  width: 50%;
}

@keyframes shimmer {
  0% {
    background-position: -200% 0;
  }
  100% {
    background-position: 200% 0;
  }
}

@keyframes spin {
  to { 
    transform: rotate(360deg); 
  }
}

/* Responsive Design */
@media (max-width: 768px) {
  .cards-grid {
    grid-template-columns: 1fr;
    gap: 16px;
  }
  
  .overview-card {
    padding: 20px;
  }
  
  .card-value {
    font-size: 28px;
  }
  
  .status-bar {
    flex-direction: column;
    align-items: stretch;
    gap: 12px;
  }
  
  .status-info {
    justify-content: center;
    gap: 12px;
  }
  
  .status-actions {
    justify-content: center;
  }
  
  .category-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 480px) {
  .overview-card {
    padding: 16px;
    flex-direction: column;
    text-align: center;
    gap: 12px;
  }
  
  .card-icon {
    align-self: center;
  }
  
  .card-value {
    font-size: 24px;
  }
  
  .status-info {
    flex-direction: column;
    gap: 8px;
  }
  
  .status-item {
    justify-content: center;
    width: 100%;
  }
  
  .category-card {
    min-height: auto;
  }
  
  .category-metrics {
    gap: 12px;
  }
}

/* Pass Rate Card */
.passrate-card .card-icon {
  background: rgba(52, 199, 89, 0.1);
  color: #34C759;
}

.passrate-card .card-icon.score-excellent {
  background: rgba(52, 199, 89, 0.1);
  color: #34C759;
}

.passrate-card .card-icon.score-good {
  background: rgba(255, 149, 0, 0.1);
  color: #FF9500;
}

.passrate-card .card-icon.score-average {
  background: rgba(88, 86, 214, 0.1);
  color: #5856D6;
}

.passrate-card .card-icon.score-needs-improvement {
  background: rgba(255, 59, 48, 0.1);
  color: #FF3B30;
}

/* Category Breakdown Section */
.category-breakdown-section,
.recent-activity-section,
.top-exams-section {
  background: #FFFFFF;
  border-radius: 16px;
  padding: 24px;
  border: 1px solid rgba(0, 0, 0, 0.06);
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
}

.section-title {
  margin: 0 0 16px 0;
  font-size: 16px;
  font-weight: 600;
  color: #1D1D1F;
  letter-spacing: -0.3px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 16px;
}

.section-header .section-title {
  margin: 0;
}

.see-all-button {
  border: 1px solid rgba(0, 0, 0, 0.08);
  background: #FFFFFF;
  color: #007AFF;
  border-radius: 10px;
  font-size: 12px;
  font-weight: 600;
  padding: 8px 12px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.see-all-button:hover {
  background: #F5F5F7;
  border-color: rgba(0, 122, 255, 0.25);
}

.section-badge {
  font-size: 11px;
  font-weight: 500;
  color: #86868B;
  background: #F5F5F7;
  padding: 2px 8px;
  border-radius: 20px;
  letter-spacing: 0;
}

.category-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 20px;
  width: 100%;
}

.category-card {
  background: linear-gradient(135deg, #FFFFFF 0%, #FAFAFA 100%);
  border: 1px solid rgba(0, 0, 0, 0.08);
  border-radius: 16px;
  padding: 24px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  flex-direction: column;
  min-height: 180px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  position: relative;
  overflow: hidden;
}

.category-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(90deg, #007AFF 0%, #5AC8FA 100%);
  opacity: 0;
  transition: opacity 0.3s ease;
}

.category-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 28px rgba(0, 0, 0, 0.12);
  border-color: rgba(0, 122, 255, 0.2);
}

.category-card:hover::before {
  opacity: 1;
}

.category-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  gap: 12px;
}

.category-name {
  font-size: 15px;
  font-weight: 700;
  color: #1D1D1F;
  line-height: 1.4;
  flex: 1;
  word-break: break-word;
  letter-spacing: -0.3px;
}

.category-attempts {
  font-size: 11px;
  font-weight: 600;
  color: #007AFF;
  background: rgba(0, 122, 255, 0.08);
  padding: 6px 10px;
  border-radius: 8px;
  white-space: nowrap;
  flex-shrink: 0;
  letter-spacing: 0.2px;
}

.category-metrics {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-bottom: 18px;
}

.category-metric {
  display: flex;
  flex-direction: column;
  gap: 6px;
  padding: 12px;
  background: rgba(0, 0, 0, 0.02);
  border-radius: 10px;
  transition: all 0.2s ease;
}

.category-metric:hover {
  background: rgba(0, 0, 0, 0.04);
}

.metric-label {
  font-size: 10px;
  font-weight: 700;
  color: #86868B;
  text-transform: uppercase;
  letter-spacing: 0.8px;
}

.metric-value {
  font-size: 20px;
  font-weight: 800;
  color: #1D1D1F;
  font-variant-numeric: tabular-nums;
  letter-spacing: -0.5px;
}

.category-progress {
  margin-top: auto;
}

.progress-bar {
  height: 8px;
  background: rgba(0, 0, 0, 0.05);
  border-radius: 4px;
  overflow: hidden;
  box-shadow: inset 0 1px 2px rgba(0, 0, 0, 0.05);
}

.progress-fill {
  height: 100%;
  border-radius: 4px;
  transition: width 0.8s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.progress-fill::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(90deg, transparent 0%, rgba(255, 255, 255, 0.3) 50%, transparent 100%);
  animation: shimmer 2s infinite;
}

@keyframes shimmer {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
}

.progress-fill.score-excellent {
  background: #34C759 !important;
  color: inherit;
}

.progress-fill.score-good {
  background: #FF9500 !important;
  color: inherit;
}

.progress-fill.score-average {
  background: #5856D6 !important;
  color: inherit;
}

.progress-fill.score-needs-improvement {
  background: #FF3B30 !important;
  color: inherit;
}

/* Recent Activity */
.activity-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.activity-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: #F5F5F7;
  border-radius: 10px;
  transition: all 0.2s ease;
}

.activity-item:hover {
  background: #EBEBF0;
}

.activity-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: rgba(0, 122, 255, 0.1);
  color: #007AFF;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.activity-avatar svg {
  width: 18px;
  height: 18px;
  stroke-width: 2;
}

.activity-details {
  flex: 1;
  min-width: 0;
}

.activity-student {
  font-size: 13px;
  font-weight: 600;
  color: #1D1D1F;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.activity-exam {
  font-size: 11px;
  color: #86868B;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.activity-score {
  font-size: 14px;
  font-weight: 700;
  flex-shrink: 0;
}

.activity-date {
  font-size: 11px;
  color: #86868B;
  flex-shrink: 0;
}

/* Top Exams */
.top-exams-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.top-exam-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: #F5F5F7;
  border-radius: 10px;
  transition: all 0.2s ease;
}

.top-exam-item:hover {
  background: #EBEBF0;
}

.exam-rank {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  background: rgba(0, 122, 255, 0.1);
  color: #007AFF;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 700;
  flex-shrink: 0;
}

.exam-info {
  flex: 1;
  min-width: 0;
}

.exam-title {
  font-size: 13px;
  font-weight: 600;
  color: #1D1D1F;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.exam-category {
  font-size: 11px;
  color: #86868B;
}

.exam-stats {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 2px;
  flex-shrink: 0;
}

.exam-attempts {
  font-size: 11px;
  color: #86868B;
}

.exam-avg {
  font-size: 14px;
  font-weight: 700;
}
</style>


/* Responsive Design for Category Cards */
@media (max-width: 1200px) {
  .category-grid {
    grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
    gap: 16px;
  }
  
  .category-card {
    padding: 20px;
    min-height: 170px;
  }
  
  .metric-value {
    font-size: 18px;
  }
}

@media (max-width: 768px) {
  .category-grid {
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap: 14px;
  }
  
  .category-card {
    padding: 18px;
    min-height: 160px;
  }
  
  .category-name {
    font-size: 14px;
  }
  
  .category-metrics {
    gap: 14px;
    margin-bottom: 16px;
  }
  
  .category-metric {
    padding: 10px;
  }
  
  .metric-value {
    font-size: 17px;
  }
}

@media (max-width: 480px) {
  .category-grid {
    grid-template-columns: 1fr;
    gap: 12px;
  }
  
  .category-card {
    padding: 16px;
    min-height: 150px;
  }
  
  .category-header {
    margin-bottom: 16px;
  }
  
  .category-name {
    font-size: 13px;
  }
  
  .category-attempts {
    font-size: 10px;
    padding: 5px 8px;
  }
  
  .category-metrics {
    gap: 12px;
    margin-bottom: 14px;
  }
  
  .category-metric {
    padding: 8px;
  }
  
  .metric-label {
    font-size: 9px;
  }
  
  .metric-value {
    font-size: 16px;
  }
  
  .progress-bar {
    height: 6px;
  }
}
