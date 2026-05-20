<template>
  <div class="performance-trend-chart">
    <!-- Chart Header -->
    <div class="chart-header">
      <div class="header-content">
        <h3 class="chart-title">Performance Trend</h3>
        <p class="chart-subtitle">{{ student.name }}</p>
      </div>
      
      <button @click="$emit('close')" class="close-button">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <line x1="18" y1="6" x2="6" y2="18"/>
          <line x1="6" y1="6" x2="18" y2="18"/>
        </svg>
      </button>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="chart-loading">
      <div class="loading-spinner"></div>
      <p>Loading performance trend...</p>
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
        <div class="stat-item">
          <div class="stat-icon trend-icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <polyline points="22,6 13.5,15.5 8.5,10.5 2,17"/>
              <polyline points="16,6 22,6 22,12"/>
            </svg>
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ trendDirection }}</div>
            <div class="stat-label">Trend</div>
          </div>
        </div>

        <div class="stat-item">
          <div class="stat-icon highest-icon">
            <svg viewBox="0 0 24 24" fill="currentColor">
              <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
            </svg>
          </div>
          <div class="stat-content">
            <div class="stat-value" :class="getScoreClass(studentSummary.passRate)">{{ formatPercentage(studentSummary.passRate) }}</div>
            <div class="stat-label">Pass Rate</div>
          </div>
        </div>

        <div class="stat-item">
          <div class="stat-icon lowest-icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <circle cx="12" cy="12" r="10"/>
              <line x1="8" y1="12" x2="16" y2="12"/>
            </svg>
          </div>
          <div class="stat-content">
            <div class="stat-value" :class="getScoreClass(studentSummary.averageScore)">
              {{ formatPercentage(studentSummary.averageScore) }}
            </div>
            <div class="stat-label">Average Score</div>
          </div>
        </div>

        <div class="stat-item">
          <div class="stat-icon improvement-icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M7 17L17 7"/>
              <path d="M7 7h10v10"/>
            </svg>
          </div>
          <div class="stat-content">
            <div class="stat-value">
              {{ studentSummary.passedAttempts }}/{{ studentSummary.totalAttempts }}
            </div>
            <div class="stat-label">Passed Attempts</div>
          </div>
        </div>
      </div>

      <!-- Chart Container -->
      <div class="chart-container">
        <canvas ref="chartCanvas" :height="chartHeight"></canvas>
      </div>

      <!-- No Data State -->
      <div v-if="!hasData" class="no-data-state">
        <div class="no-data-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M9 17H7A5 5 0 0 1 7 7h2m0 10v-5a5 5 0 0 1 10 0v5a2 2 0 0 1-2 2H9a2 2 0 0 1-2-2Z"/>
          </svg>
        </div>
        <h4>No Trend Data Available</h4>
        <p>This student has insufficient attempts for the selected time period to show a trend.</p>
      </div>

      <div v-if="hasProgressData" class="progress-section">
        <div class="progress-section-title">Student Progress Data</div>
        <div class="progress-meta-grid">
          <div class="progress-meta-item">
            <span class="meta-label">Exams Taken</span>
            <span class="meta-value">{{ studentSummary.examsTaken }}</span>
          </div>
          <div class="progress-meta-item">
            <span class="meta-label">Latest Score</span>
            <span class="meta-value" :class="getScoreClass(studentSummary.latestScore)">{{ formatPercentage(studentSummary.latestScore) }}</span>
          </div>
          <div class="progress-meta-item">
            <span class="meta-label">Failed Attempts</span>
            <span class="meta-value">{{ studentSummary.failedAttempts }}</span>
          </div>
        </div>

        <div v-if="predictiveAnalysis.confidence > 0" class="predictive-section">
          <div class="progress-subtitle">Predictive Analysis</div>
          <div class="predictive-grid">
            <div class="predictive-card">
              <div class="meta-label">Predicted Next Score</div>
              <div class="predictive-value" :class="getScoreClass(predictiveAnalysis.predictedNextScore)">
                {{ formatPercentage(predictiveAnalysis.predictedNextScore) }}
              </div>
            </div>
            <div class="predictive-card">
              <div class="meta-label">Pass Probability</div>
              <div class="predictive-value" :class="getScoreClass(predictiveAnalysis.passProbability)">
                {{ formatPercentage(predictiveAnalysis.passProbability) }}
              </div>
            </div>
            <div class="predictive-card">
              <div class="meta-label">Confidence</div>
              <div class="predictive-value">{{ formatPercentage(predictiveAnalysis.confidence) }}</div>
            </div>
            <div class="predictive-card">
              <div class="meta-label">Risk Level</div>
              <div class="risk-badge" :class="`risk-${predictiveAnalysis.riskLevel.toLowerCase()}`">
                {{ predictiveAnalysis.riskLevel }}
              </div>
            </div>
          </div>
          <div class="predictive-footnote">
            Baseline passing score target: {{ formatPercentage(predictiveAnalysis.averagePassingScore) }} · Trend slope: {{ formatImprovement(predictiveAnalysis.trendSlope) }}
          </div>
        </div>

        <div v-if="categoryProgress.length > 0" class="category-progress">
          <div class="progress-subtitle">Category Performance</div>
          <div class="category-grid">
            <div v-for="category in categoryProgress" :key="category.category" class="category-card">
              <div class="category-name">{{ category.category }}</div>
              <div class="category-metrics">
                <span>{{ category.passedAttempts }}/{{ category.totalAttempts }} passed</span>
                <span :class="getScoreClass(category.passRate)">{{ formatPercentage(category.passRate) }}</span>
              </div>
            </div>
          </div>
        </div>

        <div v-if="recentAttempts.length > 0" class="recent-attempts">
          <div class="progress-subtitle">Recent Attempts</div>
          <div class="attempt-list">
            <div v-for="attempt in recentAttempts" :key="attempt.attemptId" class="attempt-item">
              <div class="attempt-main">
                <div class="attempt-exam">{{ attempt.examTitle }}</div>
                <div class="attempt-meta">
                  <span>{{ attempt.category }}</span>
                  <span>Try #{{ attempt.attemptNumber }}</span>
                  <span>{{ formatDateTime(attempt.startTime) }}</span>
                </div>
              </div>
              <div class="attempt-score-group">
                <div class="attempt-score" :class="getScoreClass(attempt.percentage)">
                  {{ attempt.score }}/{{ attempt.totalQuestions }} ({{ formatPercentage(attempt.percentage) }})
                </div>
                <div class="attempt-badge" :class="attempt.isPassed ? 'badge-pass' : 'badge-fail'">
                  {{ attempt.isPassed ? 'Pass' : 'Fail' }} • {{ attempt.passingScore }}%
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, onUnmounted, nextTick } from 'vue'
import { Chart as ChartJS } from 'chart.js'
import { useAnalytics } from '@/composables/useAnalytics'
import { chartColors } from '@/utils/chartConfig'

const props = defineProps({
  student: {
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
const { fetchStudentTrend } = useAnalytics()

// Local state
const chartCanvas = ref(null)
const chartInstance = ref(null)
const chartData = ref(null)
const loading = ref(false)
const error = ref(null)
const renderFrame = ref(null)
const createAttemptCount = ref(0)

// Chart configuration
const chartHeight = ref(250)

// Computed properties
const hasData = computed(() => {
  return chartData.value && chartData.value.trendData && 
         chartData.value.trendData.length > 0
})

const trendData = computed(() => chartData.value?.trendData || [])
const studentSummary = computed(() => ({
  totalAttempts: chartData.value?.summary?.totalAttempts ?? 0,
  examsTaken: chartData.value?.summary?.examsTaken ?? 0,
  passedAttempts: chartData.value?.summary?.passedAttempts ?? 0,
  failedAttempts: chartData.value?.summary?.failedAttempts ?? 0,
  passRate: chartData.value?.summary?.passRate ?? 0,
  averageScore: chartData.value?.summary?.averageScore ?? 0,
  latestScore: chartData.value?.summary?.latestScore ?? 0
}))
const recentAttempts = computed(() => chartData.value?.recentAttempts || [])
const categoryProgress = computed(() => chartData.value?.categoryProgress || [])
const hasProgressData = computed(() => studentSummary.value.totalAttempts > 0 || recentAttempts.value.length > 0)
const predictiveAnalysis = computed(() => ({
  predictedNextScore: chartData.value?.predictiveAnalysis?.predictedNextScore ?? 0,
  averagePassingScore: chartData.value?.predictiveAnalysis?.averagePassingScore ?? 75,
  trendSlope: chartData.value?.predictiveAnalysis?.trendSlope ?? 0,
  passProbability: chartData.value?.predictiveAnalysis?.passProbability ?? 0,
  failProbability: chartData.value?.predictiveAnalysis?.failProbability ?? 0,
  confidence: chartData.value?.predictiveAnalysis?.confidence ?? 0,
  riskLevel: chartData.value?.predictiveAnalysis?.riskLevel ?? 'Medium'
}))

const highestScore = computed(() => {
  if (!hasData.value) return 0
  return Math.max(...trendData.value.map(item => item.score))
})

const lowestScore = computed(() => {
  if (!hasData.value) return 0
  return Math.min(...trendData.value.map(item => item.score))
})

const improvement = computed(() => {
  if (!hasData.value || trendData.value.length < 2) return 0
  const firstScore = trendData.value[0].score
  const lastScore = trendData.value[trendData.value.length - 1].score
  return lastScore - firstScore
})

const trendDirection = computed(() => {
  if (!hasData.value || trendData.value.length < 2) return 'No Data'
  
  const trendChange = improvement.value
  if (trendChange > 5) return 'Improving'
  if (trendChange < -5) return 'Declining'
  return 'Stable'
})

// Methods
const formatPercentage = (num) => {
  if (num === null || num === undefined) return '0%'
  return `${Math.round(num)}%`
}

const formatImprovement = (num) => {
  if (num === null || num === undefined || num === 0) return '0%'
  const sign = num > 0 ? '+' : ''
  return `${sign}${Math.round(num)}%`
}

const formatDateTime = (value) => {
  if (!value) return 'N/A'
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return value
  return date.toLocaleString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
    hour: 'numeric',
    minute: '2-digit'
  })
}

const getScoreClass = (score) => {
  if (score >= 90) return 'score-excellent'
  if (score >= 75) return 'score-good'
  if (score >= 60) return 'score-average'
  return 'score-needs-improvement'
}

const getImprovementClass = (improvement) => {
  if (improvement > 5) return 'improvement-positive'
  if (improvement < -5) return 'improvement-negative'
  return 'improvement-neutral'
}

const loadChartData = async () => {
  if (!props.student?.id) return
  
  loading.value = true
  error.value = null
  createAttemptCount.value = 0
  
  try {
    const response = await fetchStudentTrend(props.student.id, props.timeFilter, { bypassCache: true })
    chartData.value = response
    
    await nextTick()
    scheduleChartRender()
  } catch (err) {
    error.value = err.message || 'Failed to load performance trend data'
    console.error('Error loading chart data:', err)
  } finally {
    loading.value = false
  }
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

const createChart = () => {
  if (!chartCanvas.value || !hasData.value) return
  const canvasWidth = chartCanvas.value.clientWidth
  const canvasHeight = chartCanvas.value.clientHeight

  if ((canvasWidth === 0 || canvasHeight === 0) && createAttemptCount.value < 6) {
    createAttemptCount.value += 1
    setTimeout(() => {
      scheduleChartRender()
    }, 80)
    return
  }
  
  // Destroy existing chart
  if (chartInstance.value) {
    chartInstance.value.destroy()
    chartInstance.value = null
  }
  
  const ctx = chartCanvas.value.getContext('2d')
  if (!ctx) return
  
  // Prepare chart data
  const labels = trendData.value.map(item => {
    const date = new Date(item.date)
    return date.toLocaleDateString('en-US', { 
      month: 'short', 
      day: 'numeric' 
    })
  })
  const data = trendData.value.map(item => item.score)
  const passingTarget = Number(predictiveAnalysis.value.averagePassingScore ?? 75)

  // Linear regression for a clean trend projection line.
  const trendlineData = (() => {
    if (data.length < 2) return [...data]
    const n = data.length
    const xMean = (n - 1) / 2
    const yMean = data.reduce((sum, value) => sum + Number(value || 0), 0) / n
    let numerator = 0
    let denominator = 0

    for (let i = 0; i < n; i += 1) {
      const dx = i - xMean
      numerator += dx * (Number(data[i] || 0) - yMean)
      denominator += dx * dx
    }

    const slope = denominator === 0 ? 0 : numerator / denominator
    const intercept = yMean - slope * xMean
    return data.map((_, index) => {
      const projected = intercept + slope * index
      return Math.min(100, Math.max(0, Number(projected.toFixed(2))))
    })
  })()

  const targetData = labels.map(() => passingTarget)
  const maxDataPoint = Math.max(...data, ...trendlineData, passingTarget)
  const minDataPoint = Math.min(...data, ...trendlineData, passingTarget)
  const yPadding = 8
  const yMin = Math.max(0, Math.floor((minDataPoint - yPadding) / 5) * 5)
  const yMax = Math.min(100, Math.ceil((maxDataPoint + yPadding) / 5) * 5)
  
  // Create gradient
  const gradient = ctx.createLinearGradient(0, 0, 0, 250)
  gradient.addColorStop(0, `${chartColors.primary}40`)
  gradient.addColorStop(1, `${chartColors.primary}00`)
  
  // Create chart
  try {
    chartInstance.value = new ChartJS(ctx, {
      type: 'line',
      data: {
        labels,
        datasets: [
          {
            label: `${props.student.name} Score`,
            data,
            borderColor: chartColors.primary,
            backgroundColor: gradient,
            fill: true,
            tension: 0.32,
            cubicInterpolationMode: 'monotone',
            pointBackgroundColor: '#FFFFFF',
            pointBorderColor: chartColors.primary,
            pointBorderWidth: 2.5,
            pointRadius: 4.5,
            pointHoverRadius: 7,
            pointHoverBorderWidth: 3,
            borderWidth: 3,
            order: 1
          },
          {
            label: 'Trendline',
            data: trendlineData,
            borderColor: '#34C759',
            backgroundColor: 'transparent',
            fill: false,
            pointRadius: 0,
            pointHoverRadius: 0,
            borderWidth: 2,
            borderDash: [6, 6],
            tension: 0,
            order: 2
          },
          {
            label: 'Passing Target',
            data: targetData,
            borderColor: '#FF9500',
            backgroundColor: 'transparent',
            fill: false,
            pointRadius: 0,
            pointHoverRadius: 0,
            borderWidth: 1.5,
            borderDash: [4, 4],
            tension: 0,
            order: 3
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        layout: {
          padding: {
            top: 4,
            right: 8,
            bottom: 0,
            left: 0
          }
        },
        interaction: {
          intersect: false,
          mode: 'index'
        },
        plugins: {
          legend: {
            display: true,
            position: 'top',
            align: 'end',
            labels: {
              usePointStyle: true,
              boxWidth: 8,
              boxHeight: 8,
              pointStyle: 'circle',
              padding: 16,
              color: chartColors.textSecondary,
              font: {
                family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
                size: 11,
                weight: '600'
              }
            }
          },
          tooltip: {
            backgroundColor: 'rgba(17, 24, 39, 0.92)',
            titleColor: '#FFFFFF',
            bodyColor: '#FFFFFF',
            borderColor: 'rgba(255, 255, 255, 0.15)',
            borderWidth: 1,
            cornerRadius: 10,
            padding: 10,
            displayColors: true,
            usePointStyle: true,
            titleFont: {
              family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
              size: 13,
              weight: '600'
            },
            bodyFont: {
              family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
              size: 12,
              weight: '400'
            },
            callbacks: {
              title: (context) => `Date: ${context[0].label}`,
              label: (context) => `${context.dataset.label}: ${Math.round(context.parsed.y)}%`
            }
          }
        },
        scales: {
          x: {
            grid: {
              display: true,
              color: 'rgba(142, 142, 147, 0.12)',
              lineWidth: 1,
              drawTicks: false
            },
            ticks: {
              font: {
                family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
                size: 11,
                weight: '500'
              },
              color: chartColors.textTertiary,
              maxRotation: 0,
              autoSkipPadding: 12
            },
            title: {
              display: true,
              text: 'Date',
              font: {
                family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
                size: 12,
                weight: '600'
              },
              color: chartColors.textSecondary,
              padding: 16
            }
          },
          y: {
            grid: {
              display: true,
              color: 'rgba(142, 142, 147, 0.16)',
              lineWidth: 1,
              drawTicks: false
            },
            ticks: {
              stepSize: 5,
              font: {
                family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
                size: 11,
                weight: '400'
              },
              color: chartColors.textTertiary,
              callback: function(value) {
                return value + '%'
              }
            },
            title: {
              display: true,
              text: 'Score (%)',
              font: {
                family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
                size: 12,
                weight: '600'
              },
              color: chartColors.textSecondary,
              padding: 16
            },
            min: yMin,
            max: yMax
          }
        },
        animation: {
          duration: 900,
          easing: 'easeOutQuart'
        }
      }
    })

    requestAnimationFrame(() => {
      if (chartInstance.value) {
        chartInstance.value.resize()
      }
    })
  } catch (chartError) {
    error.value = chartError?.message || 'Failed to render chart'
    console.error('Error creating performance trend chart:', chartError)
  }
}

const handleResize = () => {
  if (window.innerWidth < 768) {
    chartHeight.value = 200
  } else {
    chartHeight.value = 250
  }
  
  if (chartInstance.value) {
    chartInstance.value.resize()
  }
}

// Watchers
watch(() => props.timeFilter, () => {
  loadChartData()
})

watch(() => props.student?.id, () => {
  if (props.student?.id) {
    loadChartData()
  }
})

watch(
  () => [loading.value, hasData.value, chartCanvas.value],
  ([isLoading, hasTrendData, canvasEl]) => {
    if (!isLoading && hasTrendData && canvasEl && !chartInstance.value) {
      scheduleChartRender()
    }
  },
  { flush: 'post' }
)

// Lifecycle
onMounted(() => {
  window.addEventListener('resize', handleResize)
  handleResize()
  
  if (props.student?.id) {
    loadChartData()
  }
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
  if (renderFrame.value) {
    cancelAnimationFrame(renderFrame.value)
    renderFrame.value = null
  }
  
  if (chartInstance.value) {
    chartInstance.value.destroy()
    chartInstance.value = null
  }
})
</script>
<style scoped>
* {
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

.performance-trend-chart {
  background: #FFFFFF;
  border-radius: 16px;
  border: 1px solid rgba(0, 0, 0, 0.06);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

/* Chart Header */
.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 24px 24px 0 24px;
  gap: 16px;
}

.header-content h3 {
  margin: 0 0 4px 0;
  font-size: 20px;
  font-weight: 700;
  color: #1D1D1F;
  letter-spacing: -0.4px;
}

.header-content p {
  margin: 0;
  font-size: 14px;
  color: #86868B;
  font-weight: 500;
}

.close-button {
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
  flex-shrink: 0;
}

.close-button:hover {
  background: #E8E8ED;
}

.close-button svg {
  width: 16px;
  height: 16px;
  color: #86868B;
  stroke-width: 2;
}

/* Chart Stats */
.chart-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
  gap: 16px;
  padding: 24px;
  background: #F5F5F7;
  margin: 24px 24px 0 24px;
  border-radius: 12px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 12px;
}

.stat-icon {
  width: 36px;
  height: 36px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.stat-icon svg {
  width: 18px;
  height: 18px;
  stroke-width: 2;
}

.trend-icon {
  background: rgba(0, 122, 255, 0.1);
  color: #007AFF;
}

.highest-icon {
  background: rgba(52, 199, 89, 0.1);
  color: #34C759;
}

.lowest-icon {
  background: rgba(255, 149, 0, 0.1);
  color: #FF9500;
}

.improvement-icon {
  background: rgba(88, 86, 214, 0.1);
  color: #5856D6;
}

.stat-content {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.stat-value {
  font-size: 16px;
  font-weight: 700;
  color: #1D1D1F;
  font-variant-numeric: tabular-nums;
}

.stat-label {
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

/* Improvement colors */
.improvement-positive {
  color: #34C759 !important;
}

.improvement-negative {
  color: #FF3B30 !important;
}

.improvement-neutral {
  color: #86868B !important;
}

/* Chart Container */
.chart-container {
  padding: 24px;
  position: relative;
  min-height: 280px;
}

.chart-container canvas {
  display: block;
  width: 100% !important;
  min-height: 220px;
}

/* Loading State */
.chart-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 48px 24px;
  text-align: center;
}

.loading-spinner {
  width: 32px;
  height: 32px;
  border: 3px solid #F5F5F7;
  border-top-color: #007AFF;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 16px;
}

.chart-loading p {
  margin: 0;
  font-size: 14px;
  color: #86868B;
  font-weight: 500;
}

/* Error State */
.chart-error {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 48px 24px;
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

.error-icon svg {
  width: 24px;
  height: 24px;
  stroke-width: 2;
}

.chart-error h4 {
  margin: 0 0 8px 0;
  font-size: 16px;
  font-weight: 600;
  color: #1D1D1F;
}

.chart-error p {
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

/* No Data State */
.no-data-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 48px 24px;
  text-align: center;
}

.no-data-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  background: rgba(142, 142, 147, 0.1);
  color: #8E8E93;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 16px;
}

.no-data-icon svg {
  width: 24px;
  height: 24px;
  stroke-width: 2;
}

.no-data-state h4 {
  margin: 0 0 8px 0;
  font-size: 16px;
  font-weight: 600;
  color: #1D1D1F;
}

.no-data-state p {
  margin: 0;
  font-size: 14px;
  color: #86868B;
  max-width: 300px;
}

.progress-section {
  margin: 0 24px 24px;
  padding: 20px;
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 12px;
  background: #FFFFFF;
}

.progress-section-title {
  font-size: 16px;
  font-weight: 700;
  color: #1D1D1F;
  margin-bottom: 12px;
}

.progress-subtitle {
  font-size: 13px;
  font-weight: 600;
  color: #1D1D1F;
  margin: 14px 0 10px;
}

.progress-meta-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 10px;
}

.progress-meta-item {
  padding: 10px;
  border-radius: 8px;
  background: #F5F5F7;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.meta-label {
  font-size: 11px;
  color: #86868B;
  text-transform: uppercase;
  letter-spacing: 0.2px;
}

.meta-value {
  font-size: 14px;
  color: #1D1D1F;
  font-weight: 700;
}

.predictive-section {
  margin-top: 14px;
}

.predictive-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 10px;
}

.predictive-card {
  padding: 10px;
  border-radius: 8px;
  background: #F5F5F7;
  border: 1px solid rgba(0, 0, 0, 0.06);
}

.predictive-value {
  margin-top: 4px;
  font-size: 15px;
  font-weight: 700;
  color: #1D1D1F;
}

.risk-badge {
  margin-top: 6px;
  display: inline-block;
  padding: 2px 8px;
  border-radius: 999px;
  font-size: 11px;
  font-weight: 700;
}

.risk-low {
  background: rgba(52, 199, 89, 0.12);
  color: #34C759;
}

.risk-medium {
  background: rgba(255, 149, 0, 0.12);
  color: #FF9500;
}

.risk-high {
  background: rgba(255, 59, 48, 0.12);
  color: #FF3B30;
}

.predictive-footnote {
  margin-top: 8px;
  font-size: 11px;
  color: #86868B;
}

.category-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(170px, 1fr));
  gap: 10px;
}

.category-card {
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 8px;
  padding: 10px;
}

.category-name {
  font-size: 13px;
  font-weight: 600;
  color: #1D1D1F;
}

.category-metrics {
  margin-top: 6px;
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #86868B;
}

.attempt-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.attempt-item {
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 8px;
  padding: 10px;
  display: flex;
  justify-content: space-between;
  gap: 12px;
  align-items: center;
}

.attempt-main {
  min-width: 0;
}

.attempt-exam {
  font-size: 13px;
  font-weight: 600;
  color: #1D1D1F;
}

.attempt-meta {
  margin-top: 4px;
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  font-size: 11px;
  color: #86868B;
}

.attempt-score-group {
  text-align: right;
}

.attempt-score {
  font-size: 13px;
  font-weight: 700;
}

.attempt-badge {
  margin-top: 4px;
  display: inline-block;
  padding: 2px 8px;
  border-radius: 999px;
  font-size: 11px;
  font-weight: 600;
}

.badge-pass {
  background: rgba(52, 199, 89, 0.12);
  color: #34C759;
}

.badge-fail {
  background: rgba(255, 59, 48, 0.12);
  color: #FF3B30;
}

@keyframes spin {
  to { 
    transform: rotate(360deg); 
  }
}

/* Responsive Design */
@media (max-width: 768px) {
  .chart-header {
    padding: 20px 20px 0 20px;
  }
  
  .chart-stats {
    grid-template-columns: repeat(2, 1fr);
    gap: 12px;
    padding: 20px;
    margin: 20px 20px 0 20px;
  }
  
  .chart-container {
    padding: 20px;
  }

  .progress-section {
    margin: 0 20px 20px;
    padding: 16px;
  }

  .progress-meta-grid {
    grid-template-columns: 1fr;
  }

  .predictive-grid {
    grid-template-columns: 1fr 1fr;
  }

  .attempt-item {
    flex-direction: column;
    align-items: flex-start;
  }

  .attempt-score-group {
    text-align: left;
  }
}

@media (max-width: 480px) {
  .chart-header {
    padding: 16px 16px 0 16px;
  }
  
  .chart-stats {
    grid-template-columns: 1fr;
    padding: 16px;
    margin: 16px 16px 0 16px;
  }
  
  .chart-container {
    padding: 16px;
  }

  .progress-section {
    margin: 0 16px 16px;
    padding: 14px;
  }

  .predictive-grid {
    grid-template-columns: 1fr;
  }
  
  .stat-item {
    gap: 8px;
  }
  
  .stat-icon {
    width: 32px;
    height: 32px;
  }
  
  .stat-icon svg {
    width: 16px;
    height: 16px;
  }
}
</style>
