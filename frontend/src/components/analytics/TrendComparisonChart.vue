<template>
  <div class="trend-comparison-chart">
    <!-- Chart Header -->
    <div class="chart-header">
      <div class="chart-title-section">
        <h3 class="chart-title">Performance Trends</h3>
        <p class="chart-subtitle">{{ getTimeRangeDescription() }}</p>
      </div>
      <div class="chart-controls">
        <div class="legend-toggle">
          <button 
            @click="toggleLegend"
            class="legend-button"
            :class="{ active: showLegend }"
          >
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <rect x="3" y="3" width="18" height="18" rx="2" ry="2"/>
              <line x1="9" y1="9" x2="15" y2="9"/>
              <line x1="9" y1="15" x2="15" y2="15"/>
            </svg>
            Legend
          </button>
        </div>
      </div>
    </div>

    <!-- Chart Container -->
    <div class="chart-container" ref="chartContainer">
      <canvas ref="chartCanvas"></canvas>
      
      <!-- Loading Overlay -->
      <div v-if="loading" class="chart-loading">
        <div class="loading-spinner"></div>
        <p>Loading trend data...</p>
      </div>
      
      <!-- Error Overlay -->
      <div v-if="error" class="chart-error">
        <div class="error-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <circle cx="12" cy="12" r="10"/>
            <line x1="12" y1="8" x2="12" y2="12"/>
            <line x1="12" y1="16" x2="12.01" y2="16"/>
          </svg>
        </div>
        <p>{{ error }}</p>
        <button @click="refreshChart" class="retry-button">Try Again</button>
      </div>
    </div>

    <!-- Chart Statistics -->
    <div v-if="chartStats && !loading && !error" class="chart-statistics">
      <div class="stats-row">
        <div class="stat-item">
          <span class="stat-label">Data Points:</span>
          <span class="stat-value">{{ formatNumber(chartStats.totalPoints) }}</span>
        </div>
        <div class="stat-item">
          <span class="stat-label">Time Range:</span>
          <span class="stat-value">{{ chartStats.dateRange }}</span>
        </div>
        <div class="stat-item">
          <span class="stat-label">Categories:</span>
          <span class="stat-value">{{ chartStats.categoryCount }}</span>
        </div>
        <div class="stat-item">
          <span class="stat-label">Avg Trend:</span>
          <span class="stat-value" :class="getTrendClass(chartStats.averageTrend)">
            {{ formatPercentage(chartStats.averageTrend) }}
          </span>
        </div>
      </div>
    </div>

    <!-- Custom Legend -->
    <div v-if="showLegend && chartData.datasets.length > 0" class="custom-legend">
      <div class="legend-items">
        <div 
          v-for="(dataset, index) in chartData.datasets" 
          :key="index"
          class="legend-item"
          @click="toggleDataset(index)"
          :class="{ disabled: datasetVisibility[index] === false }"
        >
          <div 
            class="legend-color" 
            :style="{ backgroundColor: dataset.borderColor }"
          ></div>
          <span class="legend-label">{{ dataset.label }}</span>
          <span class="legend-trend" :class="getTrendClass(dataset.trend || 0)">
            {{ formatPercentage(dataset.trend || 0) }}
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, onUnmounted, nextTick } from 'vue'
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  Filler
} from 'chart.js'

// Register Chart.js components
ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  Filler
)

const props = defineProps({
  trendData: {
    type: Array,
    default: () => []
  },
  categories: {
    type: Array,
    default: () => []
  },
  timeFilter: {
    type: String,
    default: 'all'
  },
  loading: {
    type: Boolean,
    default: false
  },
  error: {
    type: String,
    default: null
  }
})

const emit = defineEmits(['refresh'])

// Refs
const chartCanvas = ref(null)
const chartContainer = ref(null)
const chart = ref(null)
const renderFrame = ref(null)

// Local state
const showLegend = ref(true)
const datasetVisibility = ref([])

// Color palette for categories (iOS-style)
const colorPalette = [
  '#007AFF', // Blue
  '#34C759', // Green
  '#FF9500', // Orange
  '#FF3B30', // Red
  '#AF52DE', // Purple
  '#FF2D92', // Pink
  '#5AC8FA', // Light Blue
  '#FFCC00', // Yellow
  '#FF6B35', // Red Orange
  '#32D74B', // Light Green
  '#BF5AF2', // Light Purple
  '#FF375F'  // Light Red
]

// Computed properties
const chartData = computed(() => {
  if (!props.trendData || props.trendData.length === 0) {
    return { labels: [], datasets: [] }
  }

  // Extract labels (dates)
  const labels = props.trendData.map(point => formatDateLabel(point.date))

  // Create datasets
  const datasets = []

  // Overall average line (always first)
  const overallData = props.trendData.map(point => point.overallAverage || 0)
  datasets.push({
    label: 'Overall Average',
    data: overallData,
    borderColor: '#1D1D1F',
    backgroundColor: 'rgba(29, 29, 31, 0.1)',
    borderWidth: 3,
    pointRadius: 4,
    pointHoverRadius: 6,
    fill: false,
    tension: 0.4,
    trend: calculateTrend(overallData)
  })

  // Category lines
  if (props.categories && props.categories.length > 0) {
    props.categories.forEach((category, index) => {
      const categoryData = props.trendData.map(point => 
        point.categoryAverages?.[category] || null
      )
      
      // Only add if there's data
      if (categoryData.some(value => value !== null)) {
        datasets.push({
          label: category,
          data: categoryData,
          borderColor: colorPalette[index % colorPalette.length],
          backgroundColor: `${colorPalette[index % colorPalette.length]}20`,
          borderWidth: 2,
          pointRadius: 3,
          pointHoverRadius: 5,
          fill: false,
          tension: 0.4,
          trend: calculateTrend(categoryData.filter(v => v !== null))
        })
      }
    })
  }

  return { labels, datasets }
})

const chartOptions = computed(() => ({
  responsive: true,
  maintainAspectRatio: false,
  events: ['mousemove', 'mouseout', 'click', 'touchstart', 'touchmove'],
  interaction: {
    intersect: false,
    mode: 'index'
  },
  plugins: {
    legend: {
      display: false // We use custom legend
    },
    tooltip: {
      backgroundColor: 'rgba(0, 0, 0, 0.8)',
      titleColor: '#FFFFFF',
      bodyColor: '#FFFFFF',
      borderColor: 'rgba(255, 255, 255, 0.1)',
      borderWidth: 1,
      cornerRadius: 8,
      displayColors: true,
      callbacks: {
        title: (context) => {
          return `${context[0].label}`
        },
        label: (context) => {
          const value = context.parsed.y
          return `${context.dataset.label}: ${formatPercentage(value)}`
        }
      }
    }
  },
  scales: {
    x: {
      grid: {
        color: 'rgba(0, 0, 0, 0.05)',
        drawBorder: false
      },
      ticks: {
        color: '#86868B',
        font: {
          size: 12,
          weight: '500'
        },
        maxTicksLimit: 8
      }
    },
    y: {
      beginAtZero: true,
      max: 100,
      grid: {
        color: 'rgba(0, 0, 0, 0.05)',
        drawBorder: false
      },
      ticks: {
        color: '#86868B',
        font: {
          size: 12,
          weight: '500'
        },
        callback: (value) => `${value}%`
      }
    }
  },
  elements: {
    point: {
      hoverBackgroundColor: '#FFFFFF',
      hoverBorderWidth: 2
    }
  }
}))

const chartStats = computed(() => {
  if (!props.trendData || props.trendData.length === 0) return null

  const totalPoints = props.trendData.length * (props.categories?.length || 0 + 1)
  const dateRange = getDateRangeText()
  const categoryCount = props.categories?.length || 0
  
  // Calculate average trend across all categories
  let totalTrend = 0
  let trendCount = 0
  
  chartData.value.datasets.forEach(dataset => {
    if (dataset.trend !== undefined) {
      totalTrend += dataset.trend
      trendCount++
    }
  })
  
  const averageTrend = trendCount > 0 ? totalTrend / trendCount : 0

  return {
    totalPoints,
    dateRange,
    categoryCount,
    averageTrend
  }
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

const formatDateLabel = (dateString) => {
  const date = new Date(dateString)
  
  switch (props.timeFilter) {
    case '7days':
      return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
    case '30days':
      return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
    case '3months':
      return date.toLocaleDateString('en-US', { month: 'short', year: '2-digit' })
    default:
      return date.toLocaleDateString('en-US', { month: 'short', year: 'numeric' })
  }
}

const getTimeRangeDescription = () => {
  switch (props.timeFilter) {
    case '7days':
      return 'Last 7 days'
    case '30days':
      return 'Last 30 days'
    case '3months':
      return 'Last 3 months'
    default:
      return 'All time'
  }
}

const getDateRangeText = () => {
  if (!props.trendData || props.trendData.length === 0) return 'No data'
  
  const firstDate = new Date(props.trendData[0].date)
  const lastDate = new Date(props.trendData[props.trendData.length - 1].date)
  
  return `${firstDate.toLocaleDateString()} - ${lastDate.toLocaleDateString()}`
}

const calculateTrend = (data) => {
  if (!data || data.length < 2) return 0
  
  const validData = data.filter(v => v !== null && v !== undefined)
  if (validData.length < 2) return 0
  
  const first = validData[0]
  const last = validData[validData.length - 1]
  
  if (first === 0) return 0
  return ((last - first) / first) * 100
}

const getTrendClass = (trend) => {
  if (trend > 5) return 'trend-up'
  if (trend < -5) return 'trend-down'
  return 'trend-stable'
}

const toggleLegend = () => {
  showLegend.value = !showLegend.value
}

const toggleDataset = (index) => {
  if (chart.value) {
    const meta = chart.value.getDatasetMeta(index)
    meta.hidden = !meta.hidden
    datasetVisibility.value[index] = !meta.hidden
    chart.value.update()
  }
}

const scheduleChartRender = () => {
  if (renderFrame.value) {
    cancelAnimationFrame(renderFrame.value)
  }
  renderFrame.value = requestAnimationFrame(() => {
    createChart()
  })
}

const createChart = async () => {
  if (!chartCanvas.value || !chartData.value.labels.length) return

  await nextTick()

  // Destroy existing chart
  if (chart.value) {
    chart.value.destroy()
  }

  // Create new chart
  const ctx = chartCanvas.value.getContext('2d')
  if (!ctx) return

  const labels = [...chartData.value.labels]
  const datasets = chartData.value.datasets.map((dataset, index) => ({
    ...dataset,
    data: Array.isArray(dataset.data) ? [...dataset.data] : [],
    hidden: datasetVisibility.value[index] === false
  }))

  const options = {
    ...chartOptions.value,
    interaction: { ...chartOptions.value.interaction },
    plugins: {
      ...chartOptions.value.plugins,
      legend: { ...chartOptions.value.plugins.legend },
      tooltip: {
        ...chartOptions.value.plugins.tooltip,
        callbacks: { ...chartOptions.value.plugins.tooltip.callbacks }
      }
    },
    scales: {
      ...chartOptions.value.scales,
      x: {
        ...chartOptions.value.scales.x,
        grid: { ...chartOptions.value.scales.x.grid },
        ticks: { ...chartOptions.value.scales.x.ticks }
      },
      y: {
        ...chartOptions.value.scales.y,
        grid: { ...chartOptions.value.scales.y.grid },
        ticks: { ...chartOptions.value.scales.y.ticks }
      }
    },
    elements: {
      ...chartOptions.value.elements,
      point: { ...chartOptions.value.elements.point }
    }
  }

  chart.value = new ChartJS(ctx, {
    type: 'line',
    data: { labels, datasets },
    options
  })
}

const refreshChart = () => {
  emit('refresh')
}

const handleResize = () => {
  if (chart.value) {
    chart.value.resize()
  }
}

// Watchers
watch(() => props.trendData, () => {
  datasetVisibility.value = chartData.value.datasets.map((_, index) => datasetVisibility.value[index] ?? true)
  scheduleChartRender()
})

watch(() => props.categories, () => {
  datasetVisibility.value = chartData.value.datasets.map((_, index) => datasetVisibility.value[index] ?? true)
  scheduleChartRender()
})

// Lifecycle
onMounted(() => {
  datasetVisibility.value = chartData.value.datasets.map(() => true)
  scheduleChartRender()
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  if (renderFrame.value) {
    cancelAnimationFrame(renderFrame.value)
    renderFrame.value = null
  }
  if (chart.value) {
    chart.value.destroy()
  }
  window.removeEventListener('resize', handleResize)
})
</script>

<style scoped>
* {
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

.trend-comparison-chart {
  display: flex;
  flex-direction: column;
  gap: 16px;
  height: 100%;
}

/* Chart Header */
.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 16px;
}

.chart-title-section {
  flex: 1;
}

.chart-title {
  margin: 0 0 4px 0;
  font-size: 18px;
  font-weight: 600;
  color: #1D1D1F;
  letter-spacing: -0.3px;
}

.chart-subtitle {
  margin: 0;
  font-size: 13px;
  color: #86868B;
  font-weight: 500;
}

.chart-controls {
  display: flex;
  align-items: center;
  gap: 12px;
}

.legend-button {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 6px 12px;
  background: #F5F5F7;
  border: 1px solid rgba(0, 0, 0, 0.1);
  border-radius: 6px;
  font-size: 12px;
  font-weight: 500;
  color: #86868B;
  cursor: pointer;
  transition: all 0.2s ease;
}

.legend-button:hover {
  background: #EBEBF0;
  color: #1D1D1F;
}

.legend-button.active {
  background: #007AFF;
  color: white;
  border-color: #007AFF;
}

.legend-button svg {
  width: 14px;
  height: 14px;
  stroke-width: 2;
}

/* Chart Container */
.chart-container {
  position: relative;
  height: 350px;
  background: #FFFFFF;
  border-radius: 12px;
  overflow: hidden;
}

.chart-container canvas {
  width: 100% !important;
  height: 100% !important;
}

/* Loading and Error Overlays */
.chart-loading,
.chart-error {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(4px);
  z-index: 10;
}

.loading-spinner {
  width: 32px;
  height: 32px;
  border: 3px solid #F5F5F7;
  border-top: 3px solid #007AFF;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 12px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.chart-loading p,
.chart-error p {
  margin: 0;
  font-size: 14px;
  color: #86868B;
  font-weight: 500;
}

.error-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  background: rgba(255, 59, 48, 0.1);
  color: #FF3B30;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 12px;
}

.error-icon svg {
  width: 24px;
  height: 24px;
  stroke-width: 2;
}

.retry-button {
  margin-top: 12px;
  padding: 8px 16px;
  background: #007AFF;
  color: white;
  border: none;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}

.retry-button:hover {
  background: #0056CC;
}

/* Chart Statistics */
.chart-statistics {
  background: #F5F5F7;
  border-radius: 8px;
  padding: 12px 16px;
}

.stats-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
}

.stat-label {
  color: #86868B;
  font-weight: 500;
}

.stat-value {
  color: #1D1D1F;
  font-weight: 600;
  font-variant-numeric: tabular-nums;
}

.stat-value.trend-up {
  color: #34C759;
}

.stat-value.trend-down {
  color: #FF3B30;
}

.stat-value.trend-stable {
  color: #86868B;
}

/* Custom Legend */
.custom-legend {
  background: #F5F5F7;
  border-radius: 8px;
  padding: 12px;
}

.legend-items {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 10px;
  background: #FFFFFF;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s ease;
  font-size: 12px;
}

.legend-item:hover {
  background: #EBEBF0;
}

.legend-item.disabled {
  opacity: 0.5;
}

.legend-item.disabled .legend-color {
  background: #D1D1D6 !important;
}

.legend-color {
  width: 12px;
  height: 12px;
  border-radius: 2px;
  flex-shrink: 0;
}

.legend-label {
  font-weight: 500;
  color: #1D1D1F;
}

.legend-trend {
  font-weight: 600;
  font-size: 11px;
  margin-left: auto;
}

.legend-trend.trend-up {
  color: #34C759;
}

.legend-trend.trend-down {
  color: #FF3B30;
}

.legend-trend.trend-stable {
  color: #86868B;
}

/* Responsive Design */
@media (max-width: 768px) {
  .chart-header {
    flex-direction: column;
    align-items: stretch;
    gap: 12px;
  }
  
  .chart-controls {
    justify-content: flex-end;
  }
  
  .chart-container {
    height: 280px;
  }
  
  .stats-row {
    flex-direction: column;
    align-items: stretch;
    gap: 8px;
  }
  
  .stat-item {
    justify-content: space-between;
  }
  
  .legend-items {
    flex-direction: column;
    gap: 8px;
  }
  
  .legend-item {
    justify-content: space-between;
  }
}

@media (max-width: 480px) {
  .chart-container {
    height: 240px;
  }
  
  .chart-title {
    font-size: 16px;
  }
  
  .chart-subtitle {
    font-size: 12px;
  }
  
  .legend-button {
    padding: 4px 8px;
    font-size: 11px;
  }
  
  .legend-button svg {
    width: 12px;
    height: 12px;
  }
}
</style>
