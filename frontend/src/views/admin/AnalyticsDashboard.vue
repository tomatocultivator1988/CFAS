<template>
  <div class="analytics-dashboard">
    <!-- Dashboard Header -->
    <div class="dashboard-header">
      <div class="header-content">
        <div class="title-section">
          <h1 class="dashboard-title">Analytics Dashboard</h1>
          <p class="dashboard-subtitle">Comprehensive insights into exam performance and student progress</p>
        </div>
        
        <!-- Global Time Filter -->
        <div class="global-controls">
          <div class="time-filter-group">
            <label class="filter-label">Time Range:</label>
            <select 
              :value="currentTimeFilter?.value ?? 'all'"
              @change="(e) => { 
                if (currentTimeFilter !== undefined && setTimeFilter) {
                  setTimeFilter(e.target.value); 
                  handleTimeFilterChange(); 
                }
              }"
              class="time-filter-select"
            >
              <option value="7days">Last 7 Days</option>
              <option value="30days">Last 30 Days</option>
              <option value="3months">Last 3 Months</option>
              <option value="all">All Time</option>
            </select>
          </div>
          
          <!-- Refresh Button -->
          <button 
            @click="refreshAllData"
            :disabled="isRefreshing"
            class="refresh-button"
            title="Refresh all data"
          >
            <svg 
              viewBox="0 0 24 24" 
              fill="none" 
              stroke="currentColor"
              :class="{ spinning: isRefreshing }"
            >
              <path d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
            </svg>
          </button>
        </div>
      </div>
      
      <!-- Section Navigation -->
      <div class="section-navigation">
        <div class="nav-tabs">
          <button 
            v-for="section in sections" 
            :key="section.id"
            @click="switchSection(section.id)"
            class="nav-tab"
            :class="{ active: activeSection === section.id }"
          >
            <div class="tab-icon">
              <component :is="section.icon" />
            </div>
            <span class="tab-label">{{ section.name }}</span>
            <div v-if="hasDataForSection(section.id)" class="tab-indicator"></div>
          </button>
        </div>
        
        <!-- Auto-refresh Toggle -->
        <div class="auto-refresh-control">
          <label class="auto-refresh-toggle">
            <input 
              type="checkbox" 
              v-model="autoRefreshEnabled"
              @change="toggleAutoRefresh"
            />
            <span class="toggle-slider"></span>
            <span class="toggle-label">Auto-refresh (30s)</span>
          </label>
        </div>
      </div>
    </div>

    <!-- Dashboard Content -->
    <div class="dashboard-content">
      <!-- Loading Overlay -->
      <div v-if="isInitialLoading" class="loading-overlay">
        <div class="loading-content">
          <div class="loading-spinner"></div>
          <h3>Loading Analytics Dashboard</h3>
          <p>Fetching data for {{ getSectionName(activeSection) }}...</p>
        </div>
      </div>

      <!-- Error State -->
      <div v-else-if="hasGlobalError" class="error-state">
        <div class="error-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <circle cx="12" cy="12" r="10"/>
            <line x1="12" y1="8" x2="12" y2="12"/>
            <line x1="12" y1="16" x2="12.01" y2="16"/>
          </svg>
        </div>
        <h3>Unable to Load Dashboard</h3>
        <p>There was an error loading the analytics dashboard. Please try refreshing the page.</p>
        <button @click="refreshAllData" class="retry-button">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
          </svg>
          Try Again
        </button>
      </div>

      <!-- Section Content -->
      <div v-else class="section-content">
        <!-- Overview Section -->
        <div v-if="activeSection === 'overview'" class="content-section">
          <OverviewCards :time-filter="currentTimeFilter?.value ?? 'all'" />
        </div>

        <!-- Exams Section -->
        <div v-else-if="activeSection === 'exams'" class="content-section">
          <ExamPerformanceSection :time-filter="currentTimeFilter?.value ?? 'all'" />
        </div>

        <!-- Students Section -->
        <div v-else-if="activeSection === 'students'" class="content-section">
          <StudentPerformanceSection :time-filter="currentTimeFilter?.value ?? 'all'" />
        </div>

        <!-- Questions Section -->
        <div v-else-if="activeSection === 'questions'" class="content-section">
          <QuestionAnalysisSection :time-filter="currentTimeFilter?.value ?? 'all'" />
        </div>

        <!-- Trends Section -->
        <div v-else-if="activeSection === 'trends'" class="content-section">
          <TrendAnalysisSection :time-filter="currentTimeFilter?.value ?? 'all'" />
        </div>
      </div>
    </div>

    <!-- Status Bar -->
    <div class="status-bar">
      <div class="status-info">
        <span class="status-item">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <circle cx="12" cy="12" r="10"/>
            <polyline points="12,6 12,12 16,14"/>
          </svg>
          Last updated: {{ formatLastUpdate() }}
        </span>
        <span v-if="autoRefreshEnabled" class="status-item">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
          </svg>
          Auto-refresh enabled
        </span>
        <span class="status-item">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
            <circle cx="12" cy="7" r="4"/>
          </svg>
          {{ getTotalDataPoints() }} data points
        </span>
      </div>
      
      <div class="connection-status" :class="connectionStatus">
        <div class="status-dot"></div>
        <span>{{ getConnectionStatusText() }}</span>
      </div>
    </div>
  </div>
</template>
<script setup>
import { ref, computed, watch, onMounted, onUnmounted, h } from 'vue'
import { useRouter } from 'vue-router'
import { useTimeFilter } from '@/composables/useTimeFilter'
import { useAnalytics } from '@/composables/useAnalytics'
import { useAutoRefresh } from '@/composables/useAutoRefresh'

// Components
import OverviewCards from '@/components/analytics/OverviewCards.vue'
import ExamPerformanceSection from '@/components/analytics/ExamPerformanceSection.vue'
import StudentPerformanceSection from '@/components/analytics/StudentPerformanceSection.vue'
import QuestionAnalysisSection from '@/components/analytics/QuestionAnalysisSection.vue'
import TrendAnalysisSection from '@/components/analytics/TrendAnalysisSection.vue'

// Router
const router = useRouter()

// Composables - Initialize in correct order to avoid TDZ errors
const timeFilterComposable = useTimeFilter('all')
const { timeFilter: currentTimeFilter, setTimeFilter } = timeFilterComposable

const analyticsComposable = useAnalytics()
const { 
  overviewData,
  examData,
  studentData,
  questionData,
  trendData,
  loadingStates,
  errorStates,
  filterStates,
  hasAnyData,
  isAnyLoading,
  hasAnyError,
  refreshAllSections,
  startAutoRefresh,
  stopAutoRefresh,
  autoRefresh
} = analyticsComposable

// Local state
const activeSection = ref('overview')
const autoRefreshEnabled = ref(false)
const lastUpdateTime = ref(new Date())
const connectionStatus = ref('connected')
const isInitialLoading = ref(true)

// Auto-refresh composable - 30 second interval
const autoRefreshComposable = useAutoRefresh(
  async () => {
    const timeFilter = currentTimeFilter?.value ?? 'all'
    await refreshAllSections(timeFilter)
    lastUpdateTime.value = new Date()
  },
  {
    interval: 30000, // 30 seconds
    immediate: false, // Don't start automatically
    pauseOnError: true,
    onSuccess: () => {
      console.log('✅ Auto-refresh completed successfully')
    },
    onError: (error) => {
      console.error('❌ Auto-refresh failed:', error)
      connectionStatus.value = 'error'
    }
  }
)

const { isActive: isAutoRefreshActive, isRefreshing: isAutoRefreshing, start: startPolling, stop: stopPolling, refresh: manualRefresh } = autoRefreshComposable

// Section definitions with icons
const OverviewIcon = () =>
  h('svg', { viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor' }, [
    h('rect', { x: '3', y: '3', width: '18', height: '18', rx: '2', ry: '2' }),
    h('line', { x1: '9', y1: '9', x2: '15', y2: '9' }),
    h('line', { x1: '9', y1: '15', x2: '15', y2: '15' })
  ])

const ExamIcon = () =>
  h('svg', { viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor' }, [
    h('path', { d: 'M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2' }),
    h('line', { x1: '9', y1: '12', x2: '15', y2: '12' })
  ])

const StudentIcon = () =>
  h('svg', { viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor' }, [
    h('path', { d: 'M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2' }),
    h('circle', { cx: '12', cy: '7', r: '4' })
  ])

const QuestionIcon = () =>
  h('svg', { viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor' }, [
    h('circle', { cx: '12', cy: '12', r: '10' }),
    h('path', { d: 'M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3' }),
    h('line', { x1: '12', y1: '17', x2: '12.01', y2: '17' })
  ])

const TrendIcon = () =>
  h('svg', { viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor' }, [
    h('path', { d: 'M3 3v18h18' }),
    h('path', { d: 'M7 12l4-4 4 4 6-6' })
  ])

const sections = [
  {
    id: 'overview',
    name: 'Overview',
    icon: OverviewIcon
  },
  {
    id: 'exams',
    name: 'Exams',
    icon: ExamIcon
  },
  {
    id: 'students',
    name: 'Students',
    icon: StudentIcon
  },
  {
    id: 'questions',
    name: 'Questions',
    icon: QuestionIcon
  },
  {
    id: 'trends',
    name: 'Trends',
    icon: TrendIcon
  }
]

// Computed properties
const isRefreshing = computed(() => isAnyLoading.value || isAutoRefreshing.value)

const hasGlobalError = computed(() => {
  // Only show global error if all sections have errors AND there's no data at all
  const errorCount = Object.values(errorStates).filter(error => error !== null).length
  const totalSections = Object.keys(errorStates).length
  const hasNoData = !overviewData.value && !examData.value && !studentData.value && !trendData.value
  return errorCount === totalSections && errorCount > 0 && hasNoData
})

// Methods
const getSectionName = (sectionId) => {
  const section = sections.find(s => s.id === sectionId)
  return section ? section.name : 'Unknown'
}

const hasDataForSection = (sectionId) => {
  switch (sectionId) {
    case 'overview':
      return overviewData.value !== null && overviewData.value !== undefined
    case 'exams':
      return examData.value !== null && examData.value !== undefined
    case 'students':
      return studentData.value !== null && studentData.value !== undefined
    case 'questions':
      return questionData.value !== null && questionData.value !== undefined
    case 'trends':
      return trendData.value !== null && trendData.value !== undefined
    default:
      return false
  }
}

const getCurrentSectionData = () => {
  switch (activeSection.value) {
    case 'overview':
      return overviewData.value
    case 'exams':
      return examData.value
    case 'students':
      return studentData.value
    case 'questions':
      return questionData.value
    case 'trends':
      return trendData.value
    default:
      return null
  }
}

const getCurrentFilters = () => {
  switch (activeSection.value) {
    case 'exams':
      return {
        sortBy: filterStates.exams.sortBy,
        order: filterStates.exams.order
      }
    case 'students':
      return {
        level: filterStates.students.level
      }
    case 'questions':
      return {
        examId: filterStates.questions.examId,
        difficulty: filterStates.questions.difficulty
      }
    case 'trends':
      return {
        categories: filterStates.trends.categories
      }
    default:
      return {}
  }
}

const getTotalDataPoints = () => {
  let total = 0
  
  if (overviewData.value) total += 4 // 4 overview metrics
  if (examData.value?.exams) total += examData.value.exams.length
  if (studentData.value?.students) total += studentData.value.students.length
  if (questionData.value?.questions) total += questionData.value.questions.length
  // trendData now stores the full response object with trendData array
  if (trendData.value?.trendData) total += trendData.value.trendData.length
  else if (Array.isArray(trendData.value)) total += trendData.value.length
  
  return total
}

const formatLastUpdate = () => {
  return lastUpdateTime.value.toLocaleTimeString('en-US', {
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  })
}

const getConnectionStatusText = () => {
  switch (connectionStatus.value) {
    case 'connected':
      return 'Connected'
    case 'connecting':
      return 'Connecting...'
    case 'disconnected':
      return 'Disconnected'
    case 'error':
      return 'Connection Error'
    default:
      return 'Unknown'
  }
}

const switchSection = (sectionId) => {
  if (activeSection.value === sectionId) return
  
  activeSection.value = sectionId
  
  // Safe router replace with proper ref unwrapping
  try {
    const currentQuery = router.currentRoute.value.query
    const newQuery = { 
      section: sectionId, 
      timeFilter: currentTimeFilter?.value ?? 'all'  // ✅ Always unwrap ref with .value
    }
    
    // Check if navigation is actually needed
    if (currentQuery.section === newQuery.section && 
        currentQuery.timeFilter === newQuery.timeFilter) {
      return // Already at this route, skip navigation
    }
    
    router.replace({ 
      name: 'admin-analytics', 
      query: newQuery
    }).catch(err => {
      // Ignore navigation duplicated errors
      if (err.name !== 'NavigationDuplicated') {
        console.warn('Router navigation warning:', err)
      }
    })
  } catch (error) {
    console.warn('Router replace error:', error)
  }
}

const handleTimeFilterChange = () => {
  // Safe ref unwrapping
  const timeFilter = currentTimeFilter?.value ?? 'all'  // ✅ Always unwrap ref with .value
  
  if (setTimeFilter) {
    setTimeFilter(timeFilter)
  }
  refreshAllData()
  
  // Safe router replace with duplicate check
  try {
    const currentQuery = router.currentRoute.value.query
    const newQuery = { 
      section: activeSection.value, 
      timeFilter: timeFilter 
    }
    
    // Check if navigation is actually needed
    if (currentQuery.section === newQuery.section && 
        currentQuery.timeFilter === newQuery.timeFilter) {
      return // Already at this route, skip navigation
    }
    
    router.replace({ 
      name: 'admin-analytics', 
      query: newQuery
    }).catch(err => {
      // Ignore navigation duplicated errors
      if (err.name !== 'NavigationDuplicated') {
        console.warn('Router navigation warning:', err)
      }
    })
  } catch (error) {
    console.warn('Router replace error:', error)
  }
}

const refreshAllData = async () => {
  try {
    connectionStatus.value = 'connecting'
    // Safe ref unwrapping
    const timeFilter = currentTimeFilter?.value ?? 'all'  // ✅ Always unwrap ref with .value
    if (refreshAllSections) {
      await refreshAllSections(timeFilter)
    }
    lastUpdateTime.value = new Date()
    connectionStatus.value = 'connected'
  } catch (error) {
    console.error('Failed to refresh data:', error)
    connectionStatus.value = 'error'
    // Don't throw - allow dashboard to show partial data
  } finally {
    // Always clear initial loading state regardless of success/failure
    isInitialLoading.value = false
  }
}

const toggleAutoRefresh = () => {
  if (autoRefreshEnabled.value) {
    startPolling()
    console.log('🔄 Auto-refresh enabled (30s interval)')
  } else {
    stopPolling()
    console.log('⏹️ Auto-refresh disabled')
  }
}

// Initialize from URL query parameters
const initializeFromQuery = () => {
  try {
    const query = router.currentRoute.value.query
    
    if (query.section && sections.some(s => s.id === query.section)) {
      activeSection.value = query.section
    }
    
    if (query.timeFilter && ['7days', '30days', '3months', 'all'].includes(query.timeFilter)) {
      // Safe access to reactive references
      if (setTimeFilter) {
        setTimeFilter(query.timeFilter)
      }
    }
  } catch (error) {
    console.warn('Error initializing from query:', error)
    // Set defaults if query parsing fails
    activeSection.value = 'overview'
  }
}

// Lifecycle
onMounted(async () => {
  initializeFromQuery()
  
  // Set a timeout to prevent infinite loading state
  const loadingTimeout = setTimeout(() => {
    if (isInitialLoading.value) {
      isInitialLoading.value = false
      console.warn('[AnalyticsDashboard] Loading timeout reached, forcing display')
    }
  }, 15000) // 15 second timeout
  
  try {
    await refreshAllData()
  } finally {
    clearTimeout(loadingTimeout)
    isInitialLoading.value = false
  }
  
  // Set up connection monitoring
  window.addEventListener('online', () => {
    connectionStatus.value = 'connected'
    refreshAllData()
  })
  
  window.addEventListener('offline', () => {
    connectionStatus.value = 'disconnected'
  })
})

onUnmounted(() => {
  stopPolling()
  stopAutoRefresh()
  window.removeEventListener('online', () => {})
  window.removeEventListener('offline', () => {})
})

// Watch for auto-refresh state changes
watch(() => autoRefresh?.enabled, (enabled) => {
  if (enabled !== undefined) {
    autoRefreshEnabled.value = enabled
  }
}, { immediate: true })

// Sync autoRefreshEnabled with composable state
watch(isAutoRefreshActive, (active) => {
  autoRefreshEnabled.value = active
})
</script>
<style scoped>
* {
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

.analytics-dashboard {
  min-height: 100vh;
  background: #F5F5F7;
  display: flex;
  flex-direction: column;
}

/* Dashboard Header */
.dashboard-header {
  background: #FFFFFF;
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
  padding: 24px 32px;
  position: sticky;
  top: 0;
  z-index: 100;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 24px;
  margin-bottom: 24px;
}

.title-section {
  flex: 1;
}

.dashboard-title {
  margin: 0 0 4px 0;
  font-size: 32px;
  font-weight: 700;
  color: #1D1D1F;
  letter-spacing: -0.8px;
}

.dashboard-subtitle {
  margin: 0;
  font-size: 16px;
  color: #86868B;
  font-weight: 500;
  letter-spacing: -0.2px;
}

/* Global Controls */
.global-controls {
  display: flex;
  align-items: center;
  gap: 16px;
}

.time-filter-group {
  display: flex;
  align-items: center;
  gap: 8px;
}

.filter-label {
  font-size: 14px;
  font-weight: 500;
  color: #86868B;
  white-space: nowrap;
}

.time-filter-select {
  padding: 8px 12px;
  border: 1px solid rgba(0, 0, 0, 0.1);
  border-radius: 8px;
  background: #FFFFFF;
  font-size: 14px;
  font-weight: 500;
  color: #1D1D1F;
  cursor: pointer;
  transition: all 0.2s ease;
  min-width: 140px;
}

.time-filter-select:focus {
  outline: none;
  border-color: #007AFF;
  box-shadow: 0 0 0 3px rgba(0, 122, 255, 0.1);
}

.refresh-button {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  background: #F5F5F7;
  border: 1px solid rgba(0, 0, 0, 0.1);
  color: #86868B;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s ease;
}

.refresh-button:hover:not(:disabled) {
  background: #EBEBF0;
  color: #1D1D1F;
}

.refresh-button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.refresh-button svg {
  width: 18px;
  height: 18px;
  stroke-width: 2;
  transition: transform 0.2s ease;
}

.refresh-button svg.spinning {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Section Navigation */
.section-navigation {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 24px;
}

.nav-tabs {
  display: flex;
  gap: 4px;
  background: #F5F5F7;
  padding: 4px;
  border-radius: 12px;
}

.nav-tab {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 16px;
  border-radius: 8px;
  background: transparent;
  border: none;
  font-size: 14px;
  font-weight: 500;
  color: #86868B;
  cursor: pointer;
  transition: all 0.2s ease;
  position: relative;
}

.nav-tab:hover {
  color: #1D1D1F;
}

.nav-tab.active {
  background: #FFFFFF;
  color: #1D1D1F;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.tab-icon {
  width: 18px;
  height: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.tab-icon svg {
  width: 18px;
  height: 18px;
  stroke-width: 2;
}

.tab-indicator {
  position: absolute;
  top: 6px;
  right: 6px;
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: #34C759;
}

/* Auto-refresh Control */
.auto-refresh-control {
  display: flex;
  align-items: center;
}

.auto-refresh-toggle {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  font-size: 13px;
  font-weight: 500;
  color: #86868B;
}

.auto-refresh-toggle input[type="checkbox"] {
  display: none;
}

.toggle-slider {
  width: 40px;
  height: 20px;
  background: #E5E5E7;
  border-radius: 10px;
  position: relative;
  transition: all 0.2s ease;
}

.toggle-slider::before {
  content: '';
  position: absolute;
  top: 2px;
  left: 2px;
  width: 16px;
  height: 16px;
  background: #FFFFFF;
  border-radius: 50%;
  transition: all 0.2s ease;
}

.auto-refresh-toggle input:checked + .toggle-slider {
  background: #007AFF;
}

.auto-refresh-toggle input:checked + .toggle-slider::before {
  transform: translateX(20px);
}

/* Dashboard Content */
.dashboard-content {
  flex: 1;
  padding: 24px 32px;
  position: relative;
}

.loading-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(245, 245, 247, 0.95);
  backdrop-filter: blur(8px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 50;
}

.loading-content {
  text-align: center;
  max-width: 300px;
}

.loading-spinner {
  width: 48px;
  height: 48px;
  border: 4px solid #E5E5E7;
  border-top: 4px solid #007AFF;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 20px;
}

.loading-content h3 {
  margin: 0 0 8px 0;
  font-size: 18px;
  font-weight: 600;
  color: #1D1D1F;
}

.loading-content p {
  margin: 0;
  font-size: 14px;
  color: #86868B;
  font-weight: 500;
}

/* Error State */
.error-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80px 24px;
  text-align: center;
  background: #FFFFFF;
  border-radius: 16px;
  border: 1px solid rgba(0, 0, 0, 0.06);
  margin: 40px 0;
}

.error-icon {
  width: 80px;
  height: 80px;
  border-radius: 20px;
  background: rgba(255, 59, 48, 0.1);
  color: #FF3B30;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 24px;
}

.error-icon svg {
  width: 40px;
  height: 40px;
  stroke-width: 2;
}

.error-state h3 {
  margin: 0 0 12px 0;
  font-size: 24px;
  font-weight: 600;
  color: #1D1D1F;
}

.error-state p {
  margin: 0 0 32px 0;
  font-size: 16px;
  color: #86868B;
  max-width: 400px;
  line-height: 1.5;
}

.retry-button {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 24px;
  background: #007AFF;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}

.retry-button:hover {
  background: #0056CC;
}

.retry-button svg {
  width: 18px;
  height: 18px;
  stroke-width: 2;
}

/* Section Content */
.section-content {
  display: flex;
  flex-direction: column;
  gap: 32px;
}

.content-section {
  background: transparent;
}

/* Status Bar */
.status-bar {
  background: #FFFFFF;
  border-top: 1px solid rgba(0, 0, 0, 0.06);
  padding: 12px 32px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
}

.status-info {
  display: flex;
  align-items: center;
  gap: 24px;
}

.status-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  font-weight: 500;
  color: #86868B;
}

.status-item svg {
  width: 14px;
  height: 14px;
  stroke-width: 2;
}

.connection-status {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  font-weight: 500;
}

.connection-status.connected {
  color: #34C759;
}

.connection-status.connecting {
  color: #FF9500;
}

.connection-status.disconnected,
.connection-status.error {
  color: #FF3B30;
}

.status-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: currentColor;
}

/* Responsive Design */
@media (max-width: 1024px) {
  .dashboard-header {
    padding: 20px 24px;
  }
  
  .dashboard-content {
    padding: 20px 24px;
  }
  
  .status-bar {
    padding: 12px 24px;
  }
  
  .header-content {
    flex-direction: column;
    align-items: stretch;
    gap: 16px;
  }
  
  .global-controls {
    justify-content: flex-end;
  }
}

@media (max-width: 768px) {
  .dashboard-header {
    padding: 16px 20px;
  }
  
  .dashboard-content {
    padding: 16px 20px;
  }
  
  .status-bar {
    padding: 10px 20px;
    flex-direction: column;
    align-items: stretch;
    gap: 8px;
  }
  
  .dashboard-title {
    font-size: 24px;
  }
  
  .dashboard-subtitle {
    font-size: 14px;
  }
  
  .section-navigation {
    flex-direction: column;
    align-items: stretch;
    gap: 16px;
  }
  
  .nav-tabs {
    overflow-x: auto;
    scrollbar-width: none;
    -ms-overflow-style: none;
  }
  
  .nav-tabs::-webkit-scrollbar {
    display: none;
  }
  
  .nav-tab {
    white-space: nowrap;
    flex-shrink: 0;
  }
  
  .status-info {
    flex-wrap: wrap;
    gap: 12px;
  }
}

@media (max-width: 480px) {
  .dashboard-header {
    padding: 12px 16px;
  }
  
  .dashboard-content {
    padding: 12px 16px;
  }
  
  .status-bar {
    padding: 8px 16px;
  }
  
  .dashboard-title {
    font-size: 20px;
  }
  
  .global-controls {
    flex-direction: column;
    align-items: stretch;
    gap: 12px;
  }
  
  .time-filter-group {
    justify-content: space-between;
  }
  
  .nav-tab {
    padding: 10px 12px;
    font-size: 13px;
  }
  
  .tab-icon {
    width: 16px;
    height: 16px;
  }
  
  .tab-icon svg {
    width: 16px;
    height: 16px;
  }
  
  .section-content {
    gap: 24px;
  }
}
</style>