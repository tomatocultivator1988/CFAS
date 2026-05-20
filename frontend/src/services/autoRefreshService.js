import { ref, reactive } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useAdminStore } from '@/stores/admin'
import { useExamStore } from '@/stores/exam'

class AutoRefreshService {
  constructor() {
    this.isGlobalRefreshActive = ref(true)
    this.refreshIntervals = reactive({
      users: 60000,      // 1 minute for user management
      exams: 45000,      // 45 seconds for exam management
      scores: 30000,     // 30 seconds for scores/analytics
      dashboard: 120000  // 2 minutes for dashboard stats
    })
    
    this.lastRefreshTimes = reactive({
      users: null,
      exams: null,
      scores: null,
      dashboard: null
    })
    
    this.refreshCallbacks = new Map()
    this.activeIntervals = new Map()
  }

  // Register a refresh callback for a specific feature
  register(feature, callback, interval = null) {
    if (interval) {
      this.refreshIntervals[feature] = interval
    }
    
    this.refreshCallbacks.set(feature, callback)
    
    if (this.isGlobalRefreshActive.value) {
      this.startFeatureRefresh(feature)
    }
    
    console.log(`📝 Registered auto-refresh for ${feature}`)
  }

  // Unregister a refresh callback
  unregister(feature) {
    this.refreshCallbacks.delete(feature)
    this.stopFeatureRefresh(feature)
    console.log(`🗑️ Unregistered auto-refresh for ${feature}`)
  }

  // Start refresh for a specific feature
  startFeatureRefresh(feature) {
    if (this.activeIntervals.has(feature)) {
      return // Already running
    }

    const callback = this.refreshCallbacks.get(feature)
    const interval = this.refreshIntervals[feature]
    
    if (!callback || !interval) return

    const intervalId = setInterval(async () => {
      try {
        await callback()
        this.lastRefreshTimes[feature] = new Date()
        console.log(`✅ Auto-refreshed ${feature}`)
        
        // Emit success event for notifications
        window.dispatchEvent(new CustomEvent('autoRefreshSuccess', {
          detail: { feature }
        }))
      } catch (error) {
        console.error(`❌ Auto-refresh failed for ${feature}:`, error)
        
        // Emit error event for notifications
        window.dispatchEvent(new CustomEvent('autoRefreshError', {
          detail: { feature, error }
        }))
      }
    }, interval)

    this.activeIntervals.set(feature, intervalId)
    console.log(`🔄 Started auto-refresh for ${feature} (${interval/1000}s)`)
  }

  // Stop refresh for a specific feature
  stopFeatureRefresh(feature) {
    const intervalId = this.activeIntervals.get(feature)
    if (intervalId) {
      clearInterval(intervalId)
      this.activeIntervals.delete(feature)
      console.log(`⏹️ Stopped auto-refresh for ${feature}`)
    }
  }

  // Start all registered refreshes
  startAll() {
    this.isGlobalRefreshActive.value = true
    
    for (const feature of this.refreshCallbacks.keys()) {
      this.startFeatureRefresh(feature)
    }
    
    console.log('🚀 Started all auto-refreshes')
  }

  // Stop all refreshes
  stopAll() {
    this.isGlobalRefreshActive.value = false
    
    for (const feature of this.activeIntervals.keys()) {
      this.stopFeatureRefresh(feature)
    }
    
    console.log('🛑 Stopped all auto-refreshes')
  }

  // Refresh a specific feature immediately
  async refreshNow(feature) {
    const callback = this.refreshCallbacks.get(feature)
    if (callback) {
      try {
        await callback()
        this.lastRefreshTimes[feature] = new Date()
        console.log(`🔄 Manual refresh completed for ${feature}`)
      } catch (error) {
        console.error(`❌ Manual refresh failed for ${feature}:`, error)
        throw error
      }
    }
  }

  // Refresh all features immediately
  async refreshAllNow() {
    const promises = []
    
    for (const [feature, callback] of this.refreshCallbacks.entries()) {
      promises.push(
        callback().then(() => {
          this.lastRefreshTimes[feature] = new Date()
        }).catch(error => {
          console.error(`❌ Refresh failed for ${feature}:`, error)
        })
      )
    }
    
    await Promise.allSettled(promises)
    console.log('🔄 Manual refresh completed for all features')
  }

  // Update refresh interval for a feature
  updateInterval(feature, newInterval) {
    this.refreshIntervals[feature] = newInterval
    
    // Restart the refresh with new interval
    if (this.activeIntervals.has(feature)) {
      this.stopFeatureRefresh(feature)
      this.startFeatureRefresh(feature)
    }
    
    console.log(`⏱️ Updated refresh interval for ${feature} to ${newInterval/1000}s`)
  }

  // Get status of all refreshes
  getStatus() {
    const status = {
      globalActive: this.isGlobalRefreshActive.value,
      features: {}
    }
    
    for (const feature of this.refreshCallbacks.keys()) {
      status.features[feature] = {
        active: this.activeIntervals.has(feature),
        interval: this.refreshIntervals[feature],
        lastRefresh: this.lastRefreshTimes[feature]
      }
    }
    
    return status
  }

  // Smart refresh based on user activity
  setupSmartRefresh() {
    let lastActivity = Date.now()
    const inactivityThreshold = 300000 // 5 minutes
    
    const updateActivity = () => {
      lastActivity = Date.now()
    }
    
    const checkActivity = () => {
      const now = Date.now()
      const inactive = (now - lastActivity) > inactivityThreshold
      
      if (inactive && this.isGlobalRefreshActive.value) {
        // Slow down refresh rates when inactive
        for (const [feature, interval] of Object.entries(this.refreshIntervals)) {
          this.updateInterval(feature, interval * 2) // Double the interval
        }
        console.log('😴 Slowed down refresh rates due to inactivity')
      } else if (!inactive) {
        // Restore normal refresh rates when active
        this.refreshIntervals.users = 60000
        this.refreshIntervals.exams = 45000
        this.refreshIntervals.scores = 30000
        this.refreshIntervals.dashboard = 120000
        console.log('⚡ Restored normal refresh rates')
      }
    }
    
    // Track user activity
    const events = ['mousedown', 'mousemove', 'keypress', 'scroll', 'touchstart', 'click']
    events.forEach(event => {
      document.addEventListener(event, updateActivity, { passive: true })
    })
    
    // Check activity every minute
    setInterval(checkActivity, 60000)
    
    // Pause/resume on visibility change
    document.addEventListener('visibilitychange', () => {
      if (document.hidden) {
        this.stopAll()
        console.log('📱 Paused auto-refresh (tab hidden)')
      } else {
        this.startAll()
        console.log('📱 Resumed auto-refresh (tab visible)')
      }
    })
  }
}

// Create singleton instance
export const autoRefreshService = new AutoRefreshService()

// Initialize smart refresh
autoRefreshService.setupSmartRefresh()

export default autoRefreshService