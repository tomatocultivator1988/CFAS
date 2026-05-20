import { Chart as ChartJS, registerables } from 'chart.js'

// Register Chart.js components
ChartJS.register(...registerables)

// iOS-style color palette matching existing theme
export const chartColors = {
  // Primary colors
  primary: '#007AFF',
  primaryLight: '#5AC8FA',
  primaryDark: '#0051D5',
  
  // Success/Pass colors
  success: '#34C759',
  successLight: '#30D158',
  successDark: '#248A3D',
  
  // Warning colors
  warning: '#FF9500',
  warningLight: '#FF9F0A',
  warningDark: '#D2720A',
  
  // Error/Fail colors
  error: '#FF3B30',
  errorLight: '#FF453A',
  errorDark: '#D70015',
  
  // Neutral colors
  gray: '#8E8E93',
  grayLight: '#C7C7CC',
  grayDark: '#48484A',
  
  // Background colors
  background: '#F2F2F7',
  backgroundSecondary: '#FFFFFF',
  
  // Text colors
  textPrimary: '#000000',
  textSecondary: '#3C3C43',
  textTertiary: '#8E8E93',
  
  // Chart-specific colors
  chartColors: [
    '#007AFF', // Blue
    '#34C759', // Green
    '#FF9500', // Orange
    '#FF3B30', // Red
    '#5856D6', // Purple
    '#FF2D92', // Pink
    '#5AC8FA', // Light Blue
    '#FFCC00', // Yellow
    '#AF52DE', // Violet
    '#32D74B'  // Mint
  ]
}

// Default chart configuration
export const defaultChartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  interaction: {
    intersect: false,
    mode: 'index'
  },
  plugins: {
    legend: {
      display: true,
      position: 'top',
      labels: {
        usePointStyle: true,
        pointStyle: 'circle',
        padding: 20,
        font: {
          family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
          size: 12,
          weight: '500'
        },
        color: chartColors.textSecondary
      }
    },
    tooltip: {
      backgroundColor: 'rgba(0, 0, 0, 0.8)',
      titleColor: '#FFFFFF',
      bodyColor: '#FFFFFF',
      borderColor: chartColors.grayLight,
      borderWidth: 1,
      cornerRadius: 8,
      displayColors: true,
      titleFont: {
        family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
        size: 13,
        weight: '600'
      },
      bodyFont: {
        family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
        size: 12,
        weight: '400'
      }
    }
  },
  scales: {
    x: {
      grid: {
        display: true,
        color: chartColors.grayLight,
        lineWidth: 1
      },
      ticks: {
        font: {
          family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
          size: 11,
          weight: '400'
        },
        color: chartColors.textTertiary,
        maxRotation: 45
      }
    },
    y: {
      grid: {
        display: true,
        color: chartColors.grayLight,
        lineWidth: 1
      },
      ticks: {
        font: {
          family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
          size: 11,
          weight: '400'
        },
        color: chartColors.textTertiary
      }
    }
  }
}

// Score distribution chart configuration
export const scoreDistributionConfig = {
  type: 'bar',
  options: {
    ...defaultChartOptions,
    plugins: {
      ...defaultChartOptions.plugins,
      title: {
        display: true,
        text: 'Score Distribution',
        font: {
          family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
          size: 16,
          weight: '600'
        },
        color: chartColors.textPrimary,
        padding: 20
      },
      tooltip: {
        ...defaultChartOptions.plugins.tooltip,
        callbacks: {
          title: (context) => `Score Range: ${context[0].label}`,
          label: (context) => `Students: ${context.parsed.y}`
        }
      }
    },
    scales: {
      ...defaultChartOptions.scales,
      x: {
        ...defaultChartOptions.scales.x,
        title: {
          display: true,
          text: 'Score Range',
          font: {
            family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
            size: 12,
            weight: '500'
          },
          color: chartColors.textSecondary
        }
      },
      y: {
        ...defaultChartOptions.scales.y,
        title: {
          display: true,
          text: 'Number of Students',
          font: {
            family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
            size: 12,
            weight: '500'
          },
          color: chartColors.textSecondary
        },
        beginAtZero: true
      }
    }
  }
}

// Performance trend chart configuration
export const performanceTrendConfig = {
  type: 'line',
  options: {
    ...defaultChartOptions,
    plugins: {
      ...defaultChartOptions.plugins,
      title: {
        display: true,
        text: 'Performance Trend',
        font: {
          family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
          size: 16,
          weight: '600'
        },
        color: chartColors.textPrimary,
        padding: 20
      },
      tooltip: {
        ...defaultChartOptions.plugins.tooltip,
        callbacks: {
          title: (context) => `Date: ${context[0].label}`,
          label: (context) => `Score: ${context.parsed.y}%`
        }
      }
    },
    scales: {
      ...defaultChartOptions.scales,
      x: {
        ...defaultChartOptions.scales.x,
        title: {
          display: true,
          text: 'Date',
          font: {
            family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
            size: 12,
            weight: '500'
          },
          color: chartColors.textSecondary
        }
      },
      y: {
        ...defaultChartOptions.scales.y,
        title: {
          display: true,
          text: 'Score (%)',
          font: {
            family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
            size: 12,
            weight: '500'
          },
          color: chartColors.textSecondary
        },
        min: 0,
        max: 100
      }
    },
    elements: {
      line: {
        tension: 0.4,
        borderWidth: 3
      },
      point: {
        radius: 4,
        hoverRadius: 6,
        borderWidth: 2
      }
    }
  }
}

// Trend comparison chart configuration
export const trendComparisonConfig = {
  type: 'line',
  options: {
    ...defaultChartOptions,
    plugins: {
      ...defaultChartOptions.plugins,
      title: {
        display: true,
        text: 'Category Performance Comparison',
        font: {
          family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
          size: 16,
          weight: '600'
        },
        color: chartColors.textPrimary,
        padding: 20
      },
      tooltip: {
        ...defaultChartOptions.plugins.tooltip,
        callbacks: {
          title: (context) => `Period: ${context[0].label}`,
          label: (context) => `${context.dataset.label}: ${context.parsed.y}%`
        }
      }
    },
    scales: {
      ...defaultChartOptions.scales,
      x: {
        ...defaultChartOptions.scales.x,
        title: {
          display: true,
          text: 'Time Period',
          font: {
            family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
            size: 12,
            weight: '500'
          },
          color: chartColors.textSecondary
        }
      },
      y: {
        ...defaultChartOptions.scales.y,
        title: {
          display: true,
          text: 'Average Score (%)',
          font: {
            family: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
            size: 12,
            weight: '500'
          },
          color: chartColors.textSecondary
        },
        min: 0,
        max: 100
      }
    },
    elements: {
      line: {
        tension: 0.3,
        borderWidth: 2
      },
      point: {
        radius: 3,
        hoverRadius: 5,
        borderWidth: 2
      }
    }
  }
}

// Utility functions for chart data formatting
export const chartUtils = {
  /**
   * Generate score distribution data for Chart.js
   * @param {Array} distribution - Score distribution data
   * @param {number} passingScore - Passing score threshold
   * @returns {Object} Chart.js data object
   */
  formatScoreDistribution(distribution, passingScore = 70) {
    const labels = distribution.map(item => item.range)
    const data = distribution.map(item => item.count)
    
    // Color bars based on passing score
    const backgroundColors = distribution.map(item => {
      const rangeStart = parseInt(item.range.split('-')[0])
      return rangeStart >= passingScore ? chartColors.success : chartColors.error
    })
    
    return {
      labels,
      datasets: [{
        label: 'Number of Students',
        data,
        backgroundColor: backgroundColors,
        borderColor: backgroundColors.map(color => color),
        borderWidth: 1,
        borderRadius: 4,
        borderSkipped: false
      }]
    }
  },

  /**
   * Generate performance trend data for Chart.js
   * @param {Array} trendData - Trend data points
   * @param {string} studentName - Student name for label
   * @returns {Object} Chart.js data object
   */
  formatPerformanceTrend(trendData, studentName = 'Student') {
    const labels = trendData.map(item => item.date)
    const data = trendData.map(item => item.score)
    
    return {
      labels,
      datasets: [{
        label: `${studentName} Performance`,
        data,
        borderColor: chartColors.primary,
        backgroundColor: `${chartColors.primary}20`,
        fill: true,
        tension: 0.4,
        pointBackgroundColor: chartColors.primary,
        pointBorderColor: chartColors.backgroundSecondary,
        pointBorderWidth: 2
      }]
    }
  },

  /**
   * Generate trend comparison data for Chart.js
   * @param {Array} trendData - Trend data with categories
   * @param {Array} categories - Selected categories
   * @returns {Object} Chart.js data object
   */
  formatTrendComparison(trendData, categories = []) {
    if (!trendData || trendData.length === 0) {
      return { labels: [], datasets: [] }
    }
    
    const labels = trendData.map(item => item.period)
    const datasets = []
    
    // Overall average line
    datasets.push({
      label: 'Overall Average',
      data: trendData.map(item => item.overallAverage),
      borderColor: chartColors.textPrimary,
      backgroundColor: `${chartColors.textPrimary}10`,
      borderWidth: 3,
      borderDash: [5, 5],
      fill: false,
      pointStyle: 'circle'
    })
    
    // Category lines
    if (categories && categories.length > 0) {
      categories.forEach((category, index) => {
        const colorIndex = index % chartColors.chartColors.length
        const color = chartColors.chartColors[colorIndex]
        
        datasets.push({
          label: category,
          data: trendData.map(item => item.categoryAverages?.[category] || null),
          borderColor: color,
          backgroundColor: `${color}20`,
          borderWidth: 2,
          fill: false,
          pointStyle: 'circle'
        })
      })
    }
    
    return { labels, datasets }
  },

  /**
   * Format date labels based on time filter
   * @param {string} date - Date string
   * @param {string} timeFilter - Time filter type
   * @returns {string} Formatted date label
   */
  formatDateLabel(date, timeFilter) {
    const dateObj = new Date(date)
    
    switch (timeFilter) {
      case '7days':
        return dateObj.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
      case '30days':
        return dateObj.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
      case '3months':
        return dateObj.toLocaleDateString('en-US', { year: 'numeric', month: 'short' })
      case 'all':
        return dateObj.toLocaleDateString('en-US', { year: 'numeric', month: 'short' })
      default:
        return dateObj.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
    }
  },

  /**
   * Get responsive chart height based on container size
   * @param {string} chartType - Type of chart
   * @param {boolean} isMobile - Is mobile device
   * @returns {number} Chart height in pixels
   */
  getResponsiveHeight(chartType, isMobile = false) {
    const heights = {
      bar: isMobile ? 250 : 300,
      line: isMobile ? 200 : 250,
      multiline: isMobile ? 300 : 350
    }
    
    return heights[chartType] || heights.line
  },

  /**
   * Create gradient background for charts
   * @param {CanvasRenderingContext2D} ctx - Canvas context
   * @param {string} color - Base color
   * @returns {CanvasGradient} Gradient object
   */
  createGradient(ctx, color) {
    const gradient = ctx.createLinearGradient(0, 0, 0, 300)
    gradient.addColorStop(0, `${color}40`)
    gradient.addColorStop(1, `${color}00`)
    return gradient
  }
}

export default {
  chartColors,
  defaultChartOptions,
  scoreDistributionConfig,
  performanceTrendConfig,
  trendComparisonConfig,
  chartUtils
}
