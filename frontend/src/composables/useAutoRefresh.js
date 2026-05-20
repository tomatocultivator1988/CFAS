import { ref, onMounted, onUnmounted, watch } from 'vue'

/**
 * Auto-refresh composable for AJAX data updates
 * @param {Function} refreshFunction - Function to call for refreshing data
 * @param {Object} options - Configuration options
 * @param {number} options.interval - Refresh interval in milliseconds (default: 30000 = 30 seconds)
 * @param {boolean} options.immediate - Whether to start auto-refresh immediately (default: true)
 * @param {boolean} options.pauseOnError - Whether to pause auto-refresh on error (default: true)
 * @param {Function} options.onError - Error handler function
 * @param {Function} options.onSuccess - Success handler function
 */
export function useAutoRefresh(refreshFunction, options = {}) {
  const {
    interval = 30000, // 30 seconds default
    immediate = true,
    pauseOnError = true,
    onError = null,
    onSuccess = null
  } = options

  const isActive = ref(false)
  const isRefreshing = ref(false)
  const lastRefresh = ref(null)
  const errorCount = ref(0)
  const maxErrors = ref(3)
  
  let intervalId = null

  const start = () => {
    if (intervalId) return // Already running
    
    isActive.value = true
    errorCount.value = 0
    
    intervalId = setInterval(async () => {
      await performRefresh()
    }, interval)
    
    console.log(`🔄 Auto-refresh started (${interval/1000}s interval)`)
  }

  const stop = () => {
    if (intervalId) {
      clearInterval(intervalId)
      intervalId = null
    }
    isActive.value = false
    console.log('⏹️ Auto-refresh stopped')
  }

  const performRefresh = async () => {
    if (isRefreshing.value) return // Prevent overlapping refreshes
    
    isRefreshing.value = true
    
    try {
      await refreshFunction()
      lastRefresh.value = new Date()
      errorCount.value = 0 // Reset error count on success
      
      if (onSuccess) {
        onSuccess()
      }
      
      console.log('✅ Auto-refresh completed successfully')
    } catch (error) {
      errorCount.value++
      console.error('❌ Auto-refresh failed:', error)
      
      if (onError) {
        onError(error)
      }
      
      // Pause auto-refresh if too many errors
      if (pauseOnError && errorCount.value >= maxErrors.value) {
        stop()
        console.warn(`⚠️ Auto-refresh paused after ${maxErrors.value} consecutive errors`)
      }
    } finally {
      isRefreshing.value = false
    }
  }

  const refresh = async () => {
    await performRefresh()
  }

  const reset = () => {
    stop()
    errorCount.value = 0
    lastRefresh.value = null
  }

  // Auto-start if immediate is true
  onMounted(() => {
    if (immediate) {
      start()
    }
  })

  // Cleanup on unmount
  onUnmounted(() => {
    stop()
  })

  // Pause/resume based on document visibility
  const handleVisibilityChange = () => {
    if (document.hidden) {
      if (isActive.value) {
        stop()
        console.log('📱 Auto-refresh paused (tab hidden)')
      }
    } else {
      if (!isActive.value && immediate) {
        start()
        console.log('📱 Auto-refresh resumed (tab visible)')
      }
    }
  }

  onMounted(() => {
    document.addEventListener('visibilitychange', handleVisibilityChange)
  })

  onUnmounted(() => {
    document.removeEventListener('visibilitychange', handleVisibilityChange)
  })

  return {
    isActive,
    isRefreshing,
    lastRefresh,
    errorCount,
    maxErrors,
    start,
    stop,
    refresh,
    reset
  }
}

/**
 * Smart auto-refresh that adjusts interval based on user activity
 * @param {Function} refreshFunction - Function to call for refreshing data
 * @param {Object} options - Configuration options
 */
export function useSmartAutoRefresh(refreshFunction, options = {}) {
  const {
    activeInterval = 15000,   // 15 seconds when active
    inactiveInterval = 60000, // 60 seconds when inactive
    inactivityThreshold = 300000, // 5 minutes
    ...otherOptions
  } = options

  const lastActivity = ref(Date.now())
  const currentInterval = ref(activeInterval)
  
  const updateActivity = () => {
    lastActivity.value = Date.now()
    if (currentInterval.value !== activeInterval) {
      currentInterval.value = activeInterval
      // Restart with new interval
      if (autoRefresh.isActive.value) {
        autoRefresh.stop()
        setTimeout(() => {
          autoRefresh.start()
        }, 100)
      }
    }
  }

  // Track user activity
  const activityEvents = ['mousedown', 'mousemove', 'keypress', 'scroll', 'touchstart', 'click']
  
  onMounted(() => {
    activityEvents.forEach(event => {
      document.addEventListener(event, updateActivity, { passive: true })
    })
  })

  onUnmounted(() => {
    activityEvents.forEach(event => {
      document.removeEventListener(event, updateActivity)
    })
  })

  // Check for inactivity
  const checkInactivity = () => {
    const now = Date.now()
    const timeSinceActivity = now - lastActivity.value
    
    if (timeSinceActivity > inactivityThreshold && currentInterval.value !== inactiveInterval) {
      currentInterval.value = inactiveInterval
      console.log('😴 Switching to inactive refresh interval')
      
      // Restart with new interval
      if (autoRefresh.isActive.value) {
        autoRefresh.stop()
        setTimeout(() => {
          autoRefresh.start()
        }, 100)
      }
    }
  }

  // Check inactivity every minute
  onMounted(() => {
    setInterval(checkInactivity, 60000)
  })

  const autoRefresh = useAutoRefresh(refreshFunction, {
    ...otherOptions,
    interval: currentInterval.value
  })

  return {
    ...autoRefresh,
    lastActivity,
    currentInterval,
    updateActivity
  }
}