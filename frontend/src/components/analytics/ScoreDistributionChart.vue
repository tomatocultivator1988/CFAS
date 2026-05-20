<template>
  <div class="score-distribution-chart">
    <!-- Chart Header -->
    <div class="chart-header">
      <div class="header-content">
        <h3 class="chart-title">Score Distribution</h3>
        <p class="chart-subtitle">{{ exam.title }}</p>
      </div>
      
      <button @click="$emit('close')" class="close-button" aria-label="Close">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <line x1="18" y1="6" x2="6" y2="18"/>
          <line x1="6" y1="6" x2="18" y2="18"/>
        </svg>
      </button>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="chart-loading">
      <div class="loading-spinner"></div>
      <p>Loading score distribution...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="chart-error">
      <div class="error-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <circle cx="12" cy="12" r="10"/>
          <line x1="12" y1="8" x2="12" y2="12"/>
          <line x1="12" y1="16" x2="12.01" y2="16"/>
        </svg>
      </div>
      <h4>Unable to Load Chart</h4>
      <p>{{ error }}</p>
      <button @click="loadChartData" class="retry-button">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
        </svg>
        Try Again
      </button>
    </div>

    <!-- Chart Content -->
    <div v-else class="chart-content">
      <!-- Chart Stats -->
      <div class="chart-stats">
        <div class="stat-card">
          <div class="stat-label">Total Attempts</div>
          <div class="stat-value total-attempts-color">{{ formatNumber(totalAttempts) }}</div>
        </div>

        <div class="stat-card">
          <div class="stat-label">Passing Count</div>
          <div class="stat-value passing-color">{{ formatNumber(passingAttempts) }}</div>
        </div>

        <div class="stat-card">
          <div class="stat-label">Failing Count</div>
          <div class="stat-value failing-color">{{ formatNumber(failingAttempts) }}</div>
        </div>

        <div class="stat-card">
          <div class="stat-label">Average Score</div>
          <div class="stat-value" :class="getAverageScoreClass(averageScore)">
            {{ formatPercentage(averageScore) }}
          </div>
        </div>
      </div>

      <!-- Passing Score Threshold Info -->
      <div class="threshold-container" v-if="hasData && totalAttempts > 0">
        <div class="threshold-dot"></div>
        <span class="threshold-label">Passing Score: {{ passingScore }}%</span>
        <div class="threshold-line"></div>
        <div class="pass-rate-badge">
          {{ formatPercentage(passRate) }} passed
        </div>
      </div>

      <!-- Chart Container -->
      <div v-if="hasData" ref="chartContainer" class="chart-container" :style="{ height: `${chartHeight}px` }">
        <canvas ref="chartCanvas"></canvas>
      </div>

      <!-- No Data State -->
      <div v-if="!hasData" class="no-data-state">
        <div class="no-data-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
            <line x1="9" y1="12" x2="15" y2="12"/>
          </svg>
        </div>
        <h4 class="no-data-title">No Score Data Available</h4>
        <p class="no-data-sub">This exam has no completed attempts for the selected time period.</p>
      </div>

      <!-- Additional Insights Section -->
      <div v-if="hasData && totalAttempts > 0" class="insights-section">
        <h4 class="insights-title">Performance Insights</h4>
        
        <div class="insights-grid">
          <!-- Highest Score -->
          <div class="insight-card">
            <div class="insight-label">Highest Bin</div>
            <div class="insight-value highest-score-color">{{ formatPercentage(highestScore) }}</div>
          </div>

          <!-- Lowest Score -->
          <div class="insight-card">
            <div class="insight-label">Lowest Bin</div>
            <div class="insight-value lowest-score-color">{{ formatPercentage(lowestScore) }}</div>
          </div>

          <!-- Pass Rate -->
          <div class="insight-card">
            <div class="insight-label">Pass Rate</div>
            <div class="insight-value" :class="getPassRateClass(passRate)">{{ formatPercentage(passRate) }}</div>
          </div>

          <!-- Median Score -->
          <div class="insight-card">
            <div class="insight-label">Median (Est.)</div>
            <div class="insight-value median-score-color">{{ formatPercentage(medianScore) }}</div>
          </div>
        </div>

        <!-- Performance Distribution Summary Strip -->
        <div class="summary-strip">
          <div class="summary-title">Summary</div>
          <div class="summary-divider"></div>
          
          <div class="summary-items">
            <div class="summary-item">
              <span class="summary-item-label">Most Common Range</span>
              <span class="summary-item-value">{{ mostCommonRange }}</span>
            </div>
            
            <div class="summary-bullet">·</div>
            
            <div class="summary-item">
              <span class="summary-item-label">Standard Deviation</span>
              <span class="summary-item-value">{{ formatNumber(standardDeviation) }}%</span>
            </div>
            
            <div class="summary-bullet">·</div>
            
            <div class="summary-item">
              <span class="summary-item-label">Performance Level</span>
              <span class="performance-badge" :class="getPerformanceLevelClass(averageScore)">
                {{ getPerformanceLevel(averageScore) }}
              </span>
            </div>
          </div>
        </div>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, shallowRef, reactive, computed, watch, onMounted, onUnmounted, nextTick } from 'vue'
import { Chart as ChartJS, registerables } from 'chart.js'
import { useAnalytics } from '@/composables/useAnalytics'

ChartJS.register(...registerables)

const props = defineProps({
  exam: {
    type: Object,
    required: true
  },
  timeFilter: {
    type: String,
    default: 'all'
  }
})

const emit = defineEmits(['close'])

// Composables
const { fetchExamDetails } = useAnalytics()

// Local state
const chartCanvas = ref(null)
const chartContainer = ref(null)
const chartInstance = shallowRef(null)
const chartData = ref(null)
const loading = ref(false)
const error = ref(null)
const resizeObserver = ref(null)
const renderFrame = ref(null)
const isCreatingChart = ref(false)
const diagnostics = reactive({
  stage: 'idle',
  message: 'Waiting for chart load',
  fetchOk: null,
  chartOk: null,
  hasData: false,
  hasDataReason: 'No data loaded yet',
  responseKeys: [],
  distributionLength: 0,
  nonZeroBins: 0,
  totalCountFromBins: 0,
  sampleRanges: [],
  canvasClientWidth: 0,
  canvasClientHeight: 0,
  containerClientWidth: 0,
  containerClientHeight: 0,
  chartWidth: 0,
  chartHeight: 0,
  chartDatasetLength: 0,
  lastUpdated: null
})

// Chart configuration
const chartHeight = ref(300)
const passingScore = ref(70) // Default passing score

// Computed properties
const hasData = computed(() => {
  return chartData.value && chartData.value.scoreDistribution &&
         chartData.value.scoreDistribution.some(item => item.count > 0)
})

const totalAttempts = computed(() => {
  if (!hasData.value) return 0
  return chartData.value.scoreDistribution.reduce((sum, item) => sum + item.count, 0)
})

const passingAttempts = computed(() => {
  if (!hasData.value) return 0
  return chartData.value.scoreDistribution
    .filter(item => {
      const rangeStart = parseInt(item.range.split('-')[0])
      return rangeStart >= passingScore.value
    })
    .reduce((sum, item) => sum + item.count, 0)
})

const failingAttempts = computed(() => {
  return totalAttempts.value - passingAttempts.value
})

const averageScore = computed(() => {
  return chartData.value?.averageScore || 0
})

// Additional computed properties for insights
const highestScore = computed(() => {
  if (!hasData.value) return 0
  const distribution = chartData.value.scoreDistribution
  for (let i = distribution.length - 1; i >= 0; i--) {
    if (distribution[i].count > 0) {
      // Return the end of the range
      const rangeEnd = parseInt(distribution[i].range.split('-')[1])
      return rangeEnd
    }
  }
  return 0
})

const lowestScore = computed(() => {
  if (!hasData.value) return 0
  const distribution = chartData.value.scoreDistribution
  for (let i = 0; i < distribution.length; i++) {
    if (distribution[i].count > 0) {
      // Return the start of the range
      const rangeStart = parseInt(distribution[i].range.split('-')[0])
      return rangeStart
    }
  }
  return 0
})

const passRate = computed(() => {
  if (totalAttempts.value === 0) return 0
  return (passingAttempts.value / totalAttempts.value) * 100
})

const medianScore = computed(() => {
  if (!hasData.value || totalAttempts.value === 0) return 0
  
  // Find the middle attempt
  const middleIndex = Math.floor(totalAttempts.value / 2)
  let cumulativeCount = 0
  
  for (const item of chartData.value.scoreDistribution) {
    cumulativeCount += item.count
    if (cumulativeCount >= middleIndex) {
      // Return the midpoint of the range
      const [start, end] = item.range.split('-').map(Number)
      return (start + end) / 2
    }
  }
  
  return averageScore.value
})

const mostCommonRange = computed(() => {
  if (!hasData.value) return 'N/A'
  
  const distribution = chartData.value.scoreDistribution
  let maxCount = 0
  let maxRange = 'N/A'
  
  for (const item of distribution) {
    if (item.count > maxCount) {
      maxCount = item.count
      maxRange = item.range
    }
  }
  
  return maxCount > 0 ? `${maxRange}%` : 'N/A'
})

const standardDeviation = computed(() => {
  if (!hasData.value || totalAttempts.value === 0) return 0
  
  const distribution = chartData.value.scoreDistribution
  const mean = averageScore.value
  let sumSquaredDiff = 0
  
  for (const item of distribution) {
    if (item.count > 0) {
      const [start, end] = item.range.split('-').map(Number)
      const midpoint = (start + end) / 2
      sumSquaredDiff += item.count * Math.pow(midpoint - mean, 2)
    }
  }
  
  const variance = sumSquaredDiff / totalAttempts.value
  return Math.sqrt(variance)
})

const hasDataReason = computed(() => {
  if (!chartData.value) return 'chartData is null'
  if (!Array.isArray(chartData.value.scoreDistribution)) return 'scoreDistribution is missing or not an array'
  if (chartData.value.scoreDistribution.length === 0) return 'scoreDistribution is empty'
  if (!chartData.value.scoreDistribution.some(item => Number(item?.count || 0) > 0)) return 'all scoreDistribution bins have count 0'
  return 'hasData true'
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

const getAverageScoreClass = (score) => {
  if (score >= 90) return 'color-green'
  if (score >= 75) return 'color-blue'
  if (score >= 60) return 'color-orange'
  return 'color-red'
}

const getPassRateClass = (rate) => {
  if (rate >= 80) return 'color-green'
  if (rate >= 60) return 'color-orange'
  return 'color-red'
}

const getPerformanceLevel = (score) => {
  if (score >= 90) return 'Excellent'
  if (score >= 75) return 'Good'
  if (score >= 60) return 'Needs Improvement'
  return 'Poor'
}

const getPerformanceLevelClass = (score) => {
  if (score >= 90) return 'badge-excellent'
  if (score >= 75) return 'badge-good'
  if (score >= 60) return 'badge-needs-improvement'
  return 'badge-poor'
}

const getRangeColor = (rangeStart) => {
  if (rangeStart >= 90) return '#34C759'
  if (rangeStart >= 80) return '#185FA5'
  if (rangeStart >= 70) return '#007AFF'
  if (rangeStart >= 60) return '#FF9500'
  return '#FF3B30'
}

const updateCanvasMetrics = () => {
  diagnostics.canvasClientWidth = chartCanvas.value?.clientWidth || 0
  diagnostics.canvasClientHeight = chartCanvas.value?.clientHeight || 0
  diagnostics.containerClientWidth = chartContainer.value?.clientWidth || 0
  diagnostics.containerClientHeight = chartContainer.value?.clientHeight || 0
  diagnostics.chartWidth = chartInstance.value?.width || 0
  diagnostics.chartHeight = chartInstance.value?.height || 0
  diagnostics.chartDatasetLength = chartInstance.value?.data?.datasets?.length || 0
  diagnostics.lastUpdated = new Date().toISOString()
}

const updateDistributionMetrics = (distribution) => {
  diagnostics.distributionLength = distribution.length
  diagnostics.nonZeroBins = distribution.filter(item => Number(item?.count || 0) > 0).length
  diagnostics.totalCountFromBins = distribution.reduce((sum, item) => sum + Number(item?.count || 0), 0)
  diagnostics.sampleRanges = distribution.slice(0, 5).map(item => `${item.range}:${item.count}`)
  diagnostics.hasData = hasData.value
  diagnostics.hasDataReason = hasDataReason.value
  diagnostics.lastUpdated = new Date().toISOString()
}

const scheduleChartRender = () => {
  if (renderFrame.value) {
    cancelAnimationFrame(renderFrame.value)
  }
  renderFrame.value = requestAnimationFrame(() => {
    renderFrame.value = null
    createChart()
  })
}

const loadChartData = async () => {
  if (!props.exam?.id) return
  
  loading.value = true
  error.value = null
  diagnostics.stage = 'fetching'
  diagnostics.message = 'Fetching exam details'
  
  try {
    const response = await fetchExamDetails(props.exam.id, props.timeFilter, { bypassCache: true })
    chartData.value = response
    diagnostics.fetchOk = true
    diagnostics.responseKeys = Object.keys(response || {})
    updateDistributionMetrics(Array.isArray(response?.scoreDistribution) ? response.scoreDistribution : [])
    
    if (response.passingScore) {
      passingScore.value = response.passingScore
    }
    
    loading.value = false
    diagnostics.stage = 'rendering'
    diagnostics.message = 'Waiting for canvas mount'
    await nextTick()
    scheduleChartRender()
  } catch (err) {
    error.value = err.message || 'Failed to load score distribution data'
    diagnostics.fetchOk = false
    diagnostics.chartOk = false
    diagnostics.stage = 'fetch_error'
    diagnostics.message = error.value
    diagnostics.hasData = false
    diagnostics.hasDataReason = hasDataReason.value
    loading.value = false
    console.error('Error loading chart data:', err)
  } finally {
    updateCanvasMetrics()
  }
}

const createChart = () => {
  if (isCreatingChart.value) return

  if (!chartCanvas.value) {
    diagnostics.chartOk = false
    diagnostics.stage = 'create_skipped'
    diagnostics.message = 'chartCanvas is null'
    updateCanvasMetrics()
    return
  }

  if (!hasData.value) {
    diagnostics.chartOk = false
    diagnostics.stage = 'create_skipped'
    diagnostics.message = 'hasData is false'
    diagnostics.hasData = false
    diagnostics.hasDataReason = hasDataReason.value
    updateCanvasMetrics()
    return
  }

  if (!chartCanvas.value.isConnected) {
    diagnostics.chartOk = false
    diagnostics.stage = 'create_skipped'
    diagnostics.message = 'chartCanvas is detached'
    updateCanvasMetrics()
    return
  }

  isCreatingChart.value = true

  if (chartInstance.value) {
    try {
      chartInstance.value.stop()
      chartInstance.value.destroy()
    } catch (e) {
      console.warn('Error destroying previous chart:', e)
    }
    chartInstance.value = null
  }
  
  // Ensure canvas has dimensions before getting context
  if (!chartCanvas.value.clientWidth || !chartCanvas.value.clientHeight) {
    isCreatingChart.value = false
    diagnostics.chartOk = false
    diagnostics.stage = 'create_skipped'
    diagnostics.message = 'Canvas has no dimensions'
    updateCanvasMetrics()
    return
  }
  
  const ctx = chartCanvas.value.getContext('2d', { willReadFrequently: false })
  if (!ctx) {
    isCreatingChart.value = false
    diagnostics.chartOk = false
    diagnostics.stage = 'create_error'
    diagnostics.message = '2D canvas context is null'
    updateCanvasMetrics()
    return
  }
  
  // Verify context is still valid
  try {
    ctx.save()
    ctx.restore()
  } catch (e) {
    isCreatingChart.value = false
    diagnostics.chartOk = false
    diagnostics.stage = 'create_error'
    diagnostics.message = 'Canvas context is invalid'
    updateCanvasMetrics()
    return
  }
  
  const distribution = chartData.value.scoreDistribution
  const labels = distribution.map(item => item.range)
  const data = distribution.map(item => item.count)
  const backgroundColors = distribution.map(item => {
    const rangeStart = parseInt(item.range.split('-')[0])
    return getRangeColor(rangeStart)
  })
  try {
    chartInstance.value = new ChartJS(ctx, {
      type: 'bar',
      data: {
        labels,
        datasets: [{
          label: 'Number of Students',
          data,
          backgroundColor: backgroundColors,
          borderWidth: 0,
          borderRadius: 6,
          borderSkipped: false,
          barThickness: 'flex',
          maxBarThickness: 60
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        interaction: {
          intersect: false,
          mode: 'index'
        },
        plugins: {
          legend: {
            display: false
          },
          tooltip: {
            backgroundColor: '#1D1D1F',
            padding: 10,
            cornerRadius: 10,
            displayColors: false,
            titleFont: {
              family: "-apple-system, BlinkMacSystemFont, 'SF Pro Text', sans-serif",
              size: 13,
              weight: '600'
            },
            bodyFont: {
              family: "-apple-system, BlinkMacSystemFont, 'SF Pro Text', sans-serif",
              size: 12,
              weight: '400'
            },
            callbacks: {
              title: (context) => `Score Range: ${context[0].label}%`,
              label: (context) => {
                const count = context.parsed.y
                const percentage = totalAttempts.value > 0 
                  ? ((count / totalAttempts.value) * 100).toFixed(1)
                  : '0.0'
                return [
                  `Students: ${count}`,
                  `Percentage: ${percentage}%`
                ]
              }
            }
          }
        },
        scales: {
          x: {
            grid: {
              display: false
            },
            ticks: {
              font: {
                family: "-apple-system, BlinkMacSystemFont, 'SF Pro Text', sans-serif",
                size: 11
              },
              color: '#86868B',
              maxRotation: 0
            }
          },
          y: {
            grid: {
              display: true,
              color: 'rgba(0,0,0,0.04)',
              lineWidth: 1
            },
            ticks: {
              font: {
                family: "-apple-system, BlinkMacSystemFont, 'SF Pro Text', sans-serif",
                size: 11
              },
              color: '#86868B',
              stepSize: 1
            },
            beginAtZero: true
          }
        },
        animation: {
          duration: 800,
          easing: 'easeOutQuart'
        }
      }
    })
    diagnostics.chartOk = true
    diagnostics.stage = 'chart_created'
    diagnostics.message = 'Chart created'
    diagnostics.hasData = true
    diagnostics.hasDataReason = hasDataReason.value
  } catch (chartError) {
    diagnostics.chartOk = false
    diagnostics.stage = 'create_error'
    diagnostics.message = chartError?.message || 'Chart creation failed'
    error.value = diagnostics.message
    console.error('ScoreDistribution chart creation error:', chartError)
  } finally {
    isCreatingChart.value = false
  }

  const createdChart = chartInstance.value
  requestAnimationFrame(() => {
    if (createdChart && chartCanvas.value?.isConnected) {
      try {
        createdChart.resize()
      } catch (e) {
        console.warn('Error resizing chart:', e)
      }
    }
    updateCanvasMetrics()
  })
}

const handleResize = () => {
  if (window.innerWidth < 768) {
    chartHeight.value = 250
  } else {
    chartHeight.value = 300
  }
  
  if (chartInstance.value && chartCanvas.value?.isConnected) {
    try {
      chartInstance.value.resize()
    } catch (e) {
      console.warn('Error resizing chart on window resize:', e)
    }
  }
  updateCanvasMetrics()
}

// Watchers
watch(() => props.timeFilter, () => {
  loadChartData()
})

watch(() => props.exam?.id, () => {
  if (props.exam?.id) {
    loadChartData()
  }
})

watch(
  () => [loading.value, hasData.value, chartCanvas.value],
  ([isLoading, hasDistributionData, canvasEl]) => {
    if (!isLoading && hasDistributionData && canvasEl && !chartInstance.value) {
      diagnostics.stage = 'rendering'
      diagnostics.message = 'Canvas mounted, creating chart'
      scheduleChartRender()
    }
  },
  { flush: 'post' }
)

watch(hasData, () => {
  diagnostics.hasData = hasData.value
  diagnostics.hasDataReason = hasDataReason.value
  diagnostics.lastUpdated = new Date().toISOString()
})

// Lifecycle
onMounted(() => {
  window.addEventListener('resize', handleResize)
  handleResize()

  if (typeof ResizeObserver !== 'undefined') {
    resizeObserver.value = new ResizeObserver(() => {
      if (chartInstance.value && chartCanvas.value?.isConnected) {
        try {
          chartInstance.value.resize()
        } catch (e) {
          console.warn('Error resizing chart via ResizeObserver:', e)
        }
      }
      updateCanvasMetrics()
    })

    if (chartContainer.value) {
      resizeObserver.value.observe(chartContainer.value)
    }
  }
  
  if (props.exam?.id) {
    loadChartData()
  }
  updateCanvasMetrics()
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)

  if (renderFrame.value) {
    cancelAnimationFrame(renderFrame.value)
    renderFrame.value = null
  }
  
  if (chartInstance.value) {
    try {
      chartInstance.value.stop()
      chartInstance.value.destroy()
    } catch (e) {
      console.warn('Error destroying chart on unmount:', e)
    }
    chartInstance.value = null
  }

  if (resizeObserver.value) {
    resizeObserver.value.disconnect()
    resizeObserver.value = null
  }
})
</script>

<style scoped>
.score-distribution-chart {
  background: #FFFFFF;
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 20px;
  overflow: hidden;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  transition: 0.2s ease;
}

/* Chart Header */
.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 20px 24px 0 24px;
}

.chart-title {
  font-size: 17px;
  font-weight: 600;
  color: #1D1D1F;
  margin: 0;
}

.chart-subtitle {
  font-size: 13px;
  color: #86868B;
  margin: 2px 0 0 0;
}

.close-button {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  background: rgba(0, 0, 0, 0.05);
  border: none;
  border-radius: 50%;
  color: #86868B;
  cursor: pointer;
  transition: 0.2s ease;
}

.close-button:hover {
  background: rgba(0, 0, 0, 0.1);
  color: #1D1D1F;
}

.close-button svg {
  width: 16px;
  height: 16px;
  stroke-width: 2.5;
}

/* Stat Cards Row */
.chart-stats {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
  padding: 20px 24px;
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
}

.stat-card {
  background: #F5F5F7;
  border-radius: 14px;
  padding: 14px 16px;
  transition: 0.2s ease;
}

.stat-label {
  font-size: 12px;
  color: #86868B;
  margin-bottom: 6px;
}

.stat-value {
  font-size: 24px;
  font-weight: 600;
  letter-spacing: -0.5px;
  font-variant-numeric: tabular-nums;
}

/* Passing Threshold Indicator */
.threshold-container {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 0 24px 16px;
  margin-top: 16px;
}

.threshold-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #34C759;
}

.threshold-label {
  font-size: 13px;
  color: #86868B;
}

.threshold-line {
  flex: 1;
  border-top: 1.5px dashed rgba(52, 199, 89, 0.4);
}

.pass-rate-badge {
  background: rgba(52, 199, 89, 0.1);
  color: #34C759;
  border-radius: 99px;
  padding: 4px 10px;
  font-size: 12px;
  font-weight: 600;
}

/* Chart Container */
.chart-container {
  padding: 0 24px 20px;
  position: relative;
}

.chart-container canvas {
  width: 100% !important;
  height: 100% !important;
  display: block;
}

/* Performance Insights Grid */
.insights-section {
  border-top: 1px solid rgba(0, 0, 0, 0.06);
}

.insights-title {
  font-size: 15px;
  font-weight: 600;
  color: #1D1D1F;
  padding: 20px 24px 12px;
  margin: 0;
}

.insights-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 10px;
  padding: 0 24px;
}

.insight-card {
  background: #F5F5F7;
  border-radius: 14px;
  padding: 14px 16px;
  transition: 0.2s ease;
}

.insight-label {
  font-size: 12px;
  color: #86868B;
  margin-bottom: 6px;
}

.insight-value {
  font-size: 22px;
  font-weight: 600;
  letter-spacing: -0.5px;
}

/* Distribution Summary Strip */
.summary-strip {
  margin: 16px 24px 20px;
  background: #F5F5F7;
  border-radius: 14px;
  padding: 14px 18px;
  display: flex;
  align-items: center;
  gap: 16px;
}

.summary-title {
  font-size: 13px;
  font-weight: 600;
  color: #1D1D1F;
  white-space: nowrap;
}

.summary-divider {
  width: 1px;
  height: 20px;
  background: rgba(0, 0, 0, 0.1);
}

.summary-items {
  display: flex;
  align-items: center;
  flex: 1;
}

.summary-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.summary-item-label {
  font-size: 12px;
  color: #86868B;
}

.summary-item-value {
  font-size: 12px;
  font-weight: 600;
  color: #1D1D1F;
}

.summary-bullet {
  margin: 0 16px;
  color: #86868B;
}

/* Badge colors */
.performance-badge {
  border-radius: 99px;
  padding: 2px 8px;
  font-size: 11px;
  font-weight: 600;
}

.badge-excellent {
  background: rgba(52, 199, 89, 0.1);
  color: #34C759;
}

.badge-good {
  background: rgba(0, 122, 255, 0.1);
  color: #007AFF;
}

.badge-needs-improvement {
  background: rgba(255, 149, 0, 0.1);
  color: #FF9500;
}

.badge-poor {
  background: rgba(255, 59, 48, 0.1);
  color: #FF3B30;
}

/* Color rules for values */
.color-green { color: #34C759; }
.color-blue { color: #007AFF; }
.color-orange { color: #FF9500; }
.color-red { color: #FF3B30; }

.total-attempts-color { color: #1D1D1F; }
.passing-color { color: #34C759; }
.failing-color { color: #FF3B30; }
.highest-score-color { color: #34C759; }
.lowest-score-color { color: #FF3B30; }
.median-score-color { color: #007AFF; }

/* Loading State */
.chart-loading {
  min-height: 300px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 16px;
}

.loading-spinner {
  width: 32px;
  height: 32px;
  border: 3px solid #F5F5F7;
  border-top-color: #007AFF;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

.chart-loading p {
  font-size: 14px;
  color: #86868B;
  margin: 0;
}

/* No Data State */
.no-data-state {
  min-height: 200px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 20px;
}

.no-data-icon {
  color: #C7C7CC;
}

.no-data-title {
  font-size: 15px;
  font-weight: 600;
  color: #1D1D1F;
  margin: 0;
}

.no-data-sub {
  font-size: 13px;
  color: #86868B;
  margin: 0;
}

/* Error State */
.chart-error {
  min-height: 300px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px;
  text-align: center;
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
  margin-bottom: 16px;
}

.retry-button {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 18px;
  background: #1D1D1F;
  color: white;
  border: none;
  border-radius: 10px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: 0.2s ease;
  margin-top: 20px;
}

.retry-button:hover {
  background: #000000;
  transform: translateY(-1px);
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Responsive adjustments */
@media (max-width: 1024px) {
  .chart-stats, .insights-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 640px) {
  .summary-strip {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }
  .summary-divider {
    display: none;
  }
  .summary-items {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }
  .summary-bullet {
    display: none;
  }
}
</style>
