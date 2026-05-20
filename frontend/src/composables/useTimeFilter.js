import { ref, computed, watch } from 'vue'

/**
 * Composable for managing time filter state across analytics components
 */
export function useTimeFilter(initialFilter = 'all') {
  // Reactive state
  const timeFilter = ref(initialFilter)
  const isLoading = ref(false)

  // Available time filter options
  const timeFilterOptions = [
    { value: '7days', label: 'Last 7 Days', shortLabel: '7D' },
    { value: '30days', label: 'Last 30 Days', shortLabel: '30D' },
    { value: '3months', label: 'Last 3 Months', shortLabel: '3M' },
    { value: 'all', label: 'All Time', shortLabel: 'All' }
  ]

  // Computed properties
  const currentFilterLabel = computed(() => {
    const option = timeFilterOptions.find(opt => opt.value === timeFilter.value)
    return option?.label || 'All Time'
  })

  const currentFilterShortLabel = computed(() => {
    const option = timeFilterOptions.find(opt => opt.value === timeFilter.value)
    return option?.shortLabel || 'All'
  })

  const isShortTerm = computed(() => {
    return ['7days', '30days'].includes(timeFilter.value)
  })

  const isMediumTerm = computed(() => {
    return timeFilter.value === '3months'
  })

  const isLongTerm = computed(() => {
    return timeFilter.value === 'all'
  })

  // Methods
  const setTimeFilter = (newFilter) => {
    if (timeFilterOptions.some(opt => opt.value === newFilter)) {
      timeFilter.value = newFilter
    }
  }

  const getDateRange = () => {
    const now = new Date()
    const ranges = {
      '7days': {
        start: new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000),
        end: now,
        label: 'Last 7 days'
      },
      '30days': {
        start: new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000),
        end: now,
        label: 'Last 30 days'
      },
      '3months': {
        start: new Date(now.getTime() - 90 * 24 * 60 * 60 * 1000),
        end: now,
        label: 'Last 3 months'
      },
      'all': {
        start: null,
        end: null,
        label: 'All time'
      }
    }
    return ranges[timeFilter.value] || ranges.all
  }

  const getChartInterval = () => {
    const intervals = {
      '7days': 'day',
      '30days': 'week',
      '3months': 'month',
      'all': 'month'
    }
    return intervals[timeFilter.value] || 'month'
  }

  const formatDateForDisplay = (date) => {
    if (!date) return ''
    
    const options = {
      '7days': { month: 'short', day: 'numeric' },
      '30days': { month: 'short', day: 'numeric' },
      '3months': { year: 'numeric', month: 'short' },
      'all': { year: 'numeric', month: 'short' }
    }
    
    return date.toLocaleDateString('en-US', options[timeFilter.value] || options.all)
  }

  // Validation
  const isValidTimeFilter = (filter) => {
    return timeFilterOptions.some(opt => opt.value === filter)
  }

  // Persistence (optional)
  const saveToStorage = () => {
    try {
      localStorage.setItem('analytics_time_filter', timeFilter.value)
    } catch (error) {
      console.warn('Failed to save time filter to localStorage:', error)
    }
  }

  const loadFromStorage = () => {
    try {
      const saved = localStorage.getItem('analytics_time_filter')
      if (saved && isValidTimeFilter(saved)) {
        timeFilter.value = saved
      }
    } catch (error) {
      console.warn('Failed to load time filter from localStorage:', error)
    }
  }

  // Auto-save on change
  watch(timeFilter, saveToStorage)

  // Load from storage on initialization
  loadFromStorage()

  return {
    // State
    timeFilter,
    isLoading,
    
    // Options
    timeFilterOptions,
    
    // Computed
    currentFilterLabel,
    currentFilterShortLabel,
    isShortTerm,
    isMediumTerm,
    isLongTerm,
    
    // Methods
    setTimeFilter,
    getDateRange,
    getChartInterval,
    formatDateForDisplay,
    isValidTimeFilter,
    saveToStorage,
    loadFromStorage
  }
}