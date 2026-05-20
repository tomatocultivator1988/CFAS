<template>
  <div class="trend-analysis-section">
    <!-- Section Header -->
    <div class="section-header">
      <div class="header-content">
        <h2 class="section-title">Trend Analysis</h2>
        <p class="section-subtitle">Compare performance trends across categories</p>
      </div>
      
      <!-- Category Selection -->
      <div class="category-controls">
        <div class="control-group">
          <label class="control-label">Categories:</label>
          <div class="category-checkboxes">
            <label class="checkbox-item">
              <input 
                type="checkbox" 
                :checked="allCategoriesSelected"
                @change="toggleAllCategories"
              />
              <span class="checkbox-label">All Categories</span>
            </label>
            <label 
              v-for="category in availableCategories" 
              :key="category"
              class="checkbox-item"
            >
              <input 
                type="checkbox" 
                :value="category"
                v-model="selectedCategories"
                @change="handleCategoryChange"
              />
              <span class="checkbox-label">{{ category }}</span>
            </label>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="trend-content">
      <div class="trend-chart-container skeleton">
        <div class="skeleton-chart"></div>
      </div>
      <div class="trend-stats skeleton">
        <div v-for="i in 3" :key="i" class="skeleton-stat">
          <div class="skeleton-line skeleton-stat-title"></div>
          <div class="skeleton-line skeleton-stat-value"></div>
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
      <h3>Unable to Load Trend Analysis</h3>
      <p>{{ error }}</p>
      <button @click="refreshData" class="retry-button">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
        </svg>
        Try Again
      </button>
    </div>

    <!-- Trend Content -->
    <div v-else-if="trendDataArray && trendDataArray.length > 0" class="trend-content">
        <!-- Trend Chart -->
      <div class="trend-chart-container">
        <TrendComparisonChart 
          :trend-data="trendDataArray"
          :categories="selectedCategories"
          :time-filter="timeFilter"
        />
      </div>
      
      <!-- Trend Statistics -->
      <div class="trend-stats">
        <div class="stats-grid">
          <div class="stat-card">
            <div class="stat-icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M3 3v18h18"/>
                <path d="M7 12l4-4 4 4 6-6"/>
              </svg>
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ formatPercentage(overallTrend) }}</div>
              <div class="stat-label">Overall Trend</div>
              <div class="stat-description" :class="getTrendClass(overallTrend)">
                {{ getTrendDescription(overallTrend) }}
              </div>
            </div>
          </div>
          
          <div class="stat-card">
            <div class="stat-icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/>
              </svg>
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ formatNumber(totalDataPoints) }}</div>
              <div class="stat-label">Data Points</div>
              <div class="stat-description">Across {{ selectedCategories.length }} categories</div>
            </div>
          </div>
          
          <div class="stat-card">
            <div class="stat-icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/>
                <rect x="8" y="2" width="8" height="4" rx="1" ry="1"/>
              </svg>
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ formatPercentage(averageScore) }}</div>
              <div class="stat-label">Average Score</div>
              <div class="stat-description">Across selected period</div>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Category Performance Summary -->
      <div v-if="categoryPerformance.length > 0" class="category-performance">
        <h3 class="performance-title">Category Performance Summary</h3>
        <div class="performance-grid">
          <div 
            v-for="category in categoryPerformance" 
            :key="category.name"
            class="performance-card"
          >
            <div class="performance-header">
              <div class="category-name">{{ category.name }}</div>
              <div class="category-trend" :class="getTrendClass(category.trend)">
                <svg v-if="category.trend > 0" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <path d="M7 14l5-5 5 5"/>
                </svg>
                <svg v-else-if="category.trend < 0" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <path d="M7 10l5 5 5-5"/>
                </svg>
                <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <path d="M5 12h14"/>
                </svg>
                {{ formatPercentage(Math.abs(category.trend)) }}
              </div>
            </div>
            <div class="performance-metrics">
              <div class="metric">
                <span class="metric-label">Average:</span>
                <span class="metric-value">{{ formatPercentage(category.average) }}</span>
              </div>
              <div class="metric">
                <span class="metric-label">Best:</span>
                <span class="metric-value">{{ formatPercentage(category.highest) }}</span>
              </div>
              <div class="metric">
                <span class="metric-label">Lowest:</span>
                <span class="metric-value">{{ formatPercentage(category.lowest) }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="empty-state">
      <div class="empty-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path d="M3 3v18h18"/>
          <path d="M7 12l4-4 4 4 6-6"/>
        </svg>
      </div>
      <h3>No Trend Data Available</h3>
      <p>No performance data found for the selected time period and categories.</p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { useAnalytics } from '@/composables/useAnalytics'
import TrendComparisonChart from './TrendComparisonChart.vue'

const props = defineProps({
  timeFilter: {
    type: String,
    default: 'all'
  }
})

const emit = defineEmits(['update:timeFilter'])

// Composables
const { 
  trendData, 
  loadingStates, 
  errorStates, 
  fetchTrendData,
  setTrendCategories
} = useAnalytics()

// Local state
const selectedCategories = ref([])
const availableCategories = ref([])

// Computed properties
const loading = computed(() => loadingStates.trends)
const error = computed(() => errorStates.trends)

// trendData now stores the full API response object with trendData array and availableCategories
const trendDataArray = computed(() => trendData.value?.trendData || [])

const allCategoriesSelected = computed(() => {
  return availableCategories.value.length > 0 && 
         selectedCategories.value.length === availableCategories.value.length
})

const overallTrend = computed(() => {
  if (!trendDataArray.value || trendDataArray.value.length < 2) return 0
  
  const firstPoint = trendDataArray.value[0]?.overallAverage || 0
  const lastPoint = trendDataArray.value[trendDataArray.value.length - 1]?.overallAverage || 0
  
  if (firstPoint === 0) return 0
  return ((lastPoint - firstPoint) / firstPoint) * 100
})

const totalDataPoints = computed(() => {
  if (!trendDataArray.value) return 0
  return trendDataArray.value.reduce((total, point) => {
    return total + (point.totalAttempts || 0)
  }, 0)
})

const averageScore = computed(() => {
  if (!trendDataArray.value || trendDataArray.value.length === 0) return 0
  
  const sum = trendDataArray.value.reduce((total, point) => total + (point.overallAverage || 0), 0)
  return sum / trendDataArray.value.length
})

const categoryPerformance = computed(() => {
  if (!trendDataArray.value || selectedCategories.value.length === 0) return []
  
  return selectedCategories.value.map(category => {
    const categoryData = trendDataArray.value
      .map(point => point.categoryAverages?.[category]?.averageScore)
      .filter(score => score !== undefined && score !== null)
    
    if (categoryData.length === 0) {
      return {
        name: category,
        average: 0,
        highest: 0,
        lowest: 0,
        trend: 0
      }
    }
    
    const average = categoryData.reduce((sum, score) => sum + score, 0) / categoryData.length
    const highest = Math.max(...categoryData)
    const lowest = Math.min(...categoryData)
    
    // Calculate trend
    let trend = 0
    if (categoryData.length >= 2) {
      const first = categoryData[0]
      const last = categoryData[categoryData.length - 1]
      if (first > 0) {
        trend = ((last - first) / first) * 100
      }
    }
    
    return {
      name: category,
      average,
      highest,
      lowest,
      trend
    }
  })
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

const getTrendClass = (trend) => {
  if (trend > 5) return 'trend-up'
  if (trend < -5) return 'trend-down'
  return 'trend-stable'
}

const getTrendDescription = (trend) => {
  if (trend > 5) return 'Improving'
  if (trend < -5) return 'Declining'
  return 'Stable'
}

const toggleAllCategories = () => {
  if (allCategoriesSelected.value) {
    selectedCategories.value = []
  } else {
    selectedCategories.value = [...availableCategories.value]
  }
  handleCategoryChange()
}

const handleCategoryChange = () => {
  const categories = selectedCategories.value.length > 0 ? selectedCategories.value : 'all'
  setTrendCategories(categories)
  refreshData()
}

const refreshData = async () => {
  try {
    const result = await fetchTrendData(props.timeFilter)
    // Update available categories from API response
    if (result?.availableCategories && result.availableCategories.length > 0) {
      const newCategories = result.availableCategories.filter(c => c !== null && c !== undefined && c !== '')
      // Only update if categories changed
      if (JSON.stringify(newCategories) !== JSON.stringify(availableCategories.value)) {
        availableCategories.value = newCategories
        // Select all categories by default
        selectedCategories.value = [...newCategories]
      }
    }
  } catch (err) {
    console.error('Failed to refresh trend data:', err)
  }
}

// Watchers
watch(() => props.timeFilter, (newFilter) => {
  if (newFilter) {
    refreshData()
  }
}, { immediate: false })

// Watch trendData for available categories update
watch(() => trendData.value, (newData) => {
  if (newData?.availableCategories && newData.availableCategories.length > 0) {
    const newCategories = newData.availableCategories.filter(c => c !== null && c !== undefined && c !== '')
    if (availableCategories.value.length === 0) {
      availableCategories.value = newCategories
      selectedCategories.value = [...newCategories]
    }
  }
}, { immediate: true })

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

.trend-analysis-section {
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

/* Category Controls */
.category-controls {
  display: flex;
  align-items: flex-start;
  gap: 16px;
}

.control-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.control-label {
  font-size: 13px;
  font-weight: 500;
  color: #86868B;
}

.category-checkboxes {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  max-width: 400px;
}

.checkbox-item {
  display: flex;
  align-items: center;
  gap: 6px;
  cursor: pointer;
  font-size: 13px;
  font-weight: 500;
  color: #1D1D1F;
  transition: color 0.2s ease;
}

.checkbox-item:hover {
  color: #007AFF;
}

.checkbox-item input[type="checkbox"] {
  width: 16px;
  height: 16px;
  border: 1px solid rgba(0, 0, 0, 0.2);
  border-radius: 4px;
  cursor: pointer;
}

.checkbox-item input[type="checkbox"]:checked {
  background: #007AFF;
  border-color: #007AFF;
}

.checkbox-label {
  white-space: nowrap;
}

/* Trend Content */
.trend-content {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.trend-chart-container {
  background: #FFFFFF;
  border-radius: 16px;
  padding: 24px;
  border: 1px solid rgba(0, 0, 0, 0.06);
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
  min-height: 400px;
}

/* Trend Statistics */
.trend-stats {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 16px;
}

.stat-card {
  background: #FFFFFF;
  border-radius: 12px;
  padding: 20px;
  border: 1px solid rgba(0, 0, 0, 0.06);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  display: flex;
  align-items: center;
  gap: 16px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
}

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  background: rgba(0, 122, 255, 0.1);
  color: #007AFF;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.stat-icon svg {
  width: 24px;
  height: 24px;
  stroke-width: 2;
}

.stat-content {
  flex: 1;
}

.stat-value {
  font-size: 24px;
  font-weight: 700;
  color: #1D1D1F;
  line-height: 1.2;
  font-variant-numeric: tabular-nums;
}

.stat-label {
  font-size: 13px;
  font-weight: 500;
  color: #86868B;
  margin: 2px 0 4px 0;
}

.stat-description {
  font-size: 12px;
  font-weight: 500;
}

.stat-description.trend-up {
  color: #34C759;
}

.stat-description.trend-down {
  color: #FF3B30;
}

.stat-description.trend-stable {
  color: #86868B;
}

/* Category Performance */
.category-performance {
  background: #FFFFFF;
  border-radius: 16px;
  padding: 24px;
  border: 1px solid rgba(0, 0, 0, 0.06);
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
}

.performance-title {
  margin: 0 0 20px 0;
  font-size: 18px;
  font-weight: 600;
  color: #1D1D1F;
  letter-spacing: -0.3px;
}

.performance-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 16px;
}

.performance-card {
  background: #F5F5F7;
  border-radius: 12px;
  padding: 16px;
  transition: all 0.2s ease;
}

.performance-card:hover {
  background: #EBEBF0;
}

.performance-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.category-name {
  font-size: 14px;
  font-weight: 600;
  color: #1D1D1F;
}

.category-trend {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  font-weight: 600;
}

.category-trend svg {
  width: 14px;
  height: 14px;
  stroke-width: 2;
}

.category-trend.trend-up {
  color: #34C759;
}

.category-trend.trend-down {
  color: #FF3B30;
}

.category-trend.trend-stable {
  color: #86868B;
}

.performance-metrics {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.metric {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.metric-label {
  font-size: 12px;
  font-weight: 500;
  color: #86868B;
}

.metric-value {
  font-size: 12px;
  font-weight: 600;
  color: #1D1D1F;
  font-variant-numeric: tabular-nums;
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

.skeleton-chart {
  height: 350px;
  background: linear-gradient(90deg, #F5F5F7 25%, #E8E8ED 50%, #F5F5F7 75%);
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
  border-radius: 12px;
}

.skeleton-stat {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: 20px;
  background: #FFFFFF;
  border-radius: 12px;
  border: 1px solid rgba(0, 0, 0, 0.04);
}

.skeleton-line {
  height: 16px;
  background: linear-gradient(90deg, #F5F5F7 25%, #E8E8ED 50%, #F5F5F7 75%);
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
  border-radius: 4px;
}

.skeleton-stat-title {
  width: 60%;
  height: 14px;
}

.skeleton-stat-value {
  width: 40%;
  height: 20px;
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
  
  .category-controls {
    align-items: stretch;
  }
  
  .category-checkboxes {
    max-width: none;
  }
  
  .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .performance-grid {
    grid-template-columns: 1fr;
  }
  
  .trend-chart-container {
    padding: 16px;
    min-height: 300px;
  }
}

@media (max-width: 480px) {
  .category-checkboxes {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .stat-card {
    padding: 16px;
  }
  
  .stat-icon {
    width: 40px;
    height: 40px;
  }
  
  .stat-icon svg {
    width: 20px;
    height: 20px;
  }
  
  .stat-value {
    font-size: 20px;
  }
}
</style>