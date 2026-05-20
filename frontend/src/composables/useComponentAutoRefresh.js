import { onMounted, onUnmounted, ref } from 'vue'
import { autoRefreshService } from '@/services/autoRefreshService'

/**
 * Simple composable to add auto-refresh to any component
 * @param {string} featureName - Unique name for this feature (e.g., 'users', 'exams', 'scores')
 * @param {Function} refreshCallback - Function to call for refreshing data
 * @param {Object} options - Configuration options
 * @param {number} options.interval - Refresh interval in milliseconds
 * @param {boolean} options.immediate - Whether to register immediately on mount (default: true)
 */
export function useComponentAutoRefresh(featureName, refreshCallback, options = {}) {
  const {
    interval = null,
    immediate = true
  } = options

  const isRegistered = ref(false)
  const lastRefresh = ref(null)

  const register = () => {
    if (isRegistered.value) return
    
    autoRefreshService.register(featureName, async () => {
      await refreshCallback()
      lastRefresh.value = new Date()
    }, interval)
    
    isRegistered.value = true
  }

  const unregister = () => {
    if (!isRegistered.value) return
    
    autoRefreshService.unregister(featureName)
    isRegistered.value = false
  }

  const refreshNow = async () => {
    await autoRefreshService.refreshNow(featureName)
    lastRefresh.value = new Date()
  }

  if (immediate) {
    onMounted(() => {
      register()
    })
  }

  onUnmounted(() => {
    unregister()
  })

  return {
    isRegistered,
    lastRefresh,
    register,
    unregister,
    refreshNow
  }
}

/**
 * Quick setup for common admin features
 */
export const useAdminAutoRefresh = {
  users: (refreshCallback) => useComponentAutoRefresh('users', refreshCallback, { interval: 60000 }),
  exams: (refreshCallback) => useComponentAutoRefresh('exams', refreshCallback, { interval: 45000 }),
  scores: (refreshCallback) => useComponentAutoRefresh('scores', refreshCallback, { interval: 30000 }),
  dashboard: (refreshCallback) => useComponentAutoRefresh('dashboard', refreshCallback, { interval: 120000 })
}

/**
 * Quick setup for reviewee features
 */
export const useRevieweeAutoRefresh = {
  exams: (refreshCallback) => useComponentAutoRefresh('reviewee-exams', refreshCallback, { interval: 45000 }),
  history: (refreshCallback) => useComponentAutoRefresh('exam-history', refreshCallback, { interval: 60000 })
}