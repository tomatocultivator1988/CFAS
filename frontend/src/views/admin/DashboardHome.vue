<template>
  <div class="dashboard-home">
    <!-- Loading Overlay -->
    <transition name="fade">
      <div v-if="isLoading" class="loading-overlay">
        <div class="loading-container">
          <div class="loading-spinner">
            <div class="spinner-ring"></div>
            <div class="spinner-ring"></div>
            <div class="spinner-ring"></div>
          </div>
          <p class="loading-text">Loading Dashboard</p>
        </div>
      </div>
    </transition>

    <!-- Header Section -->
    <div class="dashboard-header">
      <div class="header-content">
        <div class="header-top">
          <div>
            <h1 class="dashboard-title">Dashboard</h1>
            <p class="dashboard-subtitle">Welcome back! Here's what's happening today.</p>
          </div>
          <div class="header-time">
            <div class="time-badge">
              <svg class="time-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <circle cx="12" cy="12" r="10" stroke-width="2"/>
                <path d="M12 6v6l4 2" stroke-linecap="round" stroke-width="2"/>
              </svg>
              <span>{{ currentTime }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Stats Grid -->
    <div class="stats-section">
      <div class="section-header-inline">
        <h2 class="section-title">Overview</h2>
        <button class="view-all-btn">
          <span>View All</span>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M9 18l6-6-6-6" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
          </svg>
        </button>
      </div>
      
      <div class="stats-grid">
        <div class="stat-card" v-for="(stat, index) in statsData" :key="index" :style="{ animationDelay: `${index * 0.08}s` }">
          <div class="stat-content">
            <div class="stat-header">
              <div class="stat-icon-wrapper" :style="{ background: stat.iconBg }">
                <svg class="stat-icon" :viewBox="stat.iconViewBox" fill="none" stroke="currentColor">
                  <path :d="stat.iconPath" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                </svg>
              </div>
              <div class="stat-badge" :class="stat.badgeClass">
                <span class="badge-dot"></span>
                <span>{{ stat.badge }}</span>
              </div>
            </div>
            <div class="stat-body">
              <div class="stat-value">{{ stat.value }}</div>
              <div class="stat-label">{{ stat.label }}</div>
            </div>
          </div>
          <div class="stat-shine"></div>
        </div>
      </div>
    </div>

    <!-- Quick Actions Section -->
    <div class="quick-actions-section">
      <div class="section-header-inline">
        <h2 class="section-title">Recent Activity</h2>
        <button class="view-all-btn">
          <span>View All</span>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M9 18l6-6-6-6" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
          </svg>
        </button>
      </div>

      <div class="activity-grid">
        <div class="activity-card" :style="{ animationDelay: '0.4s' }">
          <div class="activity-icon" style="background: linear-gradient(135deg, rgba(0, 122, 255, 0.1) 0%, rgba(0, 122, 255, 0.15) 100%);">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
            </svg>
          </div>
          <div class="activity-content">
            <div class="activity-title">Active Exams</div>
            <div class="activity-value">{{ activeExamsCount }}</div>
            <div class="activity-description">Currently available for students</div>
          </div>
          <router-link to="/admin/exams" class="activity-action">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M9 5l7 7-7 7" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
            </svg>
          </router-link>
        </div>

        <div class="activity-card" :style="{ animationDelay: '0.48s' }">
          <div class="activity-icon" style="background: linear-gradient(135deg, rgba(52, 199, 89, 0.1) 0%, rgba(52, 199, 89, 0.15) 100%);">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
            </svg>
          </div>
          <div class="activity-content">
            <div class="activity-title">Active Students</div>
            <div class="activity-value">{{ activeUsersCount }}</div>
            <div class="activity-description">Registered and active</div>
          </div>
          <router-link to="/admin/users" class="activity-action">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M9 5l7 7-7 7" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
            </svg>
          </router-link>
        </div>

        <div class="activity-card" :style="{ animationDelay: '0.56s' }">
          <div class="activity-icon" style="background: linear-gradient(135deg, rgba(255, 149, 0, 0.1) 0%, rgba(255, 149, 0, 0.15) 100%);">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
            </svg>
          </div>
          <div class="activity-content">
            <div class="activity-title">Recent Submissions</div>
            <div class="activity-value">{{ recentSubmissionsCount }}</div>
            <div class="activity-description">In the last 24 hours</div>
          </div>
          <router-link to="/admin/scores" class="activity-action">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M9 5l7 7-7 7" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
            </svg>
          </router-link>
        </div>

        <div class="activity-card" :style="{ animationDelay: '0.64s' }">
          <div class="activity-icon" style="background: linear-gradient(135deg, rgba(175, 82, 222, 0.1) 0%, rgba(175, 82, 222, 0.15) 100%);">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M13 10V3L4 14h7v7l9-11h-7z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
            </svg>
          </div>
          <div class="activity-content">
            <div class="activity-title">Average Score</div>
            <div class="activity-value">{{ averageScore }}%</div>
            <div class="activity-description">Across all exams</div>
          </div>
          <router-link to="/admin/analytics" class="activity-action">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M9 5l7 7-7 7" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
            </svg>
          </router-link>
        </div>
      </div>
    </div>

    <!-- System Status Section -->
    <div class="status-section">
      <div class="section-header-inline">
        <h2 class="section-title">System Health</h2>
        <div class="health-badge">
          <span class="health-dot"></span>
          <span>All Systems Operational</span>
        </div>
      </div>

      <div class="status-grid">
        <div class="status-card" v-for="(status, index) in systemStatus" :key="index" :style="{ animationDelay: `${(index + 8) * 0.08}s` }">
          <div class="status-indicator" :class="status.status">
            <span class="indicator-pulse"></span>
          </div>
          <div class="status-info">
            <div class="status-label">{{ status.label }}</div>
            <div class="status-value">{{ status.value }}</div>
          </div>
          <div class="status-icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M5 13l4 4L19 7" stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5"/>
            </svg>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, onUnmounted } from 'vue'
import api from '@/services/api'

const isLoading = ref(true)
const currentTime = ref('')

const stats = ref({
  totalExams: 0,
  activeExams: 0,
  totalQuestions: 0,
  totalUsers: 0,
  activeUsers: 0,
  recentSubmissions: 0,
  totalAttempts: 0
})

// Update time every second
const updateTime = () => {
  const now = new Date()
  currentTime.value = now.toLocaleTimeString('en-US', { 
    hour: '2-digit', 
    minute: '2-digit',
    hour12: true 
  })
}

let timeInterval = null

// iOS-style SF Symbols inspired icons using SVG paths
const statsData = computed(() => [
  {
    value: stats.value.totalExams,
    label: 'Total Exams',
    badge: 'Active',
    badgeClass: 'badge-blue',
    iconBg: 'linear-gradient(135deg, #F5F5F7 0%, #E8E8ED 100%)',
    iconViewBox: '0 0 24 24',
    iconPath: 'M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z'
  },
  {
    value: stats.value.totalQuestions,
    label: 'Total Questions',
    badge: 'Updated',
    badgeClass: 'badge-green',
    iconBg: 'linear-gradient(135deg, #F5F5F7 0%, #E8E8ED 100%)',
    iconViewBox: '0 0 24 24',
    iconPath: 'M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z'
  },
  {
    value: stats.value.totalUsers,
    label: 'Total Users',
    badge: 'Growing',
    badgeClass: 'badge-purple',
    iconBg: 'linear-gradient(135deg, #F5F5F7 0%, #E8E8ED 100%)',
    iconViewBox: '0 0 24 24',
    iconPath: 'M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z'
  },
  {
    value: stats.value.totalAttempts,
    label: 'Total Attempts',
    badge: 'Tracked',
    badgeClass: 'badge-orange',
    iconBg: 'linear-gradient(135deg, #F5F5F7 0%, #E8E8ED 100%)',
    iconViewBox: '0 0 24 24',
    iconPath: 'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z'
  }
])

const activeExamsCount = computed(() => {
  return stats.value.activeExams
})

const activeUsersCount = computed(() => {
  return stats.value.activeUsers
})

const recentSubmissionsCount = computed(() => {
  return stats.value.recentSubmissions
})

const averageScore = computed(() => {
  // This would need actual calculation from all attempts
  // Placeholder for now
  return 85
})

const actions = [
  {
    title: 'Manage Exams',
    description: 'Create, edit, and organize examinations',
    route: '/admin/exams',
    iconBg: 'linear-gradient(135deg, #F5F5F7 0%, #E8E8ED 100%)',
    iconViewBox: '0 0 24 24',
    iconPath: 'M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z'
  },
  {
    title: 'Manage Users',
    description: 'Control user accounts and permissions',
    route: '/admin/users',
    iconBg: 'linear-gradient(135deg, #F5F5F7 0%, #E8E8ED 100%)',
    iconViewBox: '0 0 24 24',
    iconPath: 'M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z'
  },
  {
    title: 'View Scores',
    description: 'View all student exam scores and results',
    route: '/admin/scores',
    iconBg: 'linear-gradient(135deg, #F5F5F7 0%, #E8E8ED 100%)',
    iconViewBox: '0 0 24 24',
    iconPath: 'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z'
  },
  {
    title: 'View Analytics',
    description: 'Track performance and insights',
    route: '/admin/analytics',
    iconBg: 'linear-gradient(135deg, #F5F5F7 0%, #E8E8ED 100%)',
    iconViewBox: '0 0 24 24',
    iconPath: 'M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z'
  },
  {
    title: 'Export Reports',
    description: 'Download exam results and analytics',
    route: '/admin/exports',
    iconBg: 'linear-gradient(135deg, #F5F5F7 0%, #E8E8ED 100%)',
    iconViewBox: '0 0 24 24',
    iconPath: 'M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z'
  }
]

const systemStatus = ref([
  { label: 'Database', value: 'Connected', status: 'online' },
  { label: 'API Server', value: 'Running', status: 'online' },
  { label: 'Cache', value: 'Active', status: 'online' },
  { label: 'Storage', value: 'Loading...', status: 'online' }
])

onMounted(async () => {
  updateTime()
  timeInterval = setInterval(updateTime, 1000)
  
  try {
    const [dashboardStatsResponse, storageResponse] = await Promise.all([
      api.get('/admin/dashboard/stats'),
      api.get('/admin/system/storage')
    ])

    const dashboardStats = dashboardStatsResponse.data
    const storageData = storageResponse.data
    
    // Update storage status
    const storageIndex = systemStatus.value.findIndex(s => s.label === 'Storage')
    if (storageIndex !== -1) {
      systemStatus.value[storageIndex].value = storageData.formatted
      // Set status based on percentage
      if (storageData.percentage >= 90) {
        systemStatus.value[storageIndex].status = 'offline'
      } else if (storageData.percentage >= 75) {
        systemStatus.value[storageIndex].status = 'warning'
      } else {
        systemStatus.value[storageIndex].status = 'online'
      }
    }

    stats.value = {
      totalExams: dashboardStats.totalExams || 0,
      activeExams: dashboardStats.activeExams || 0,
      totalQuestions: dashboardStats.totalQuestions || 0,
      totalUsers: dashboardStats.totalUsers || 0,
      activeUsers: dashboardStats.activeUsers || 0,
      recentSubmissions: dashboardStats.recentSubmissions || 0,
      totalAttempts: dashboardStats.totalAttempts || 0
    }
  } catch (error) {
    console.error('Error loading dashboard stats:', error)
    stats.value = {
      totalExams: 0,
      activeExams: 0,
      totalQuestions: 0,
      totalUsers: 0,
      activeUsers: 0,
      recentSubmissions: 0,
      totalAttempts: 0
    }
  } finally {
    // Simulate minimum loading time for smooth UX
    setTimeout(() => {
      isLoading.value = false
    }, 800)
  }
})

onUnmounted(() => {
  if (timeInterval) {
    clearInterval(timeInterval)
  }
})
</script>

<style scoped>
/* Apple-Inspired Premium Design System
   - Background: #F5F5F7 (iOS light grey)
   - Cards: #FFFFFF with subtle shadows
   - Text Primary: #1D1D1F (Apple black)
   - Text Secondary: #86868B (Apple grey)
   - Accent Blue: #007AFF
   - Accent Green: #34C759
   - Accent Purple: #AF52DE
   - Accent Orange: #FF9500
*/

* {
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

.dashboard-home {
  padding: 40px 48px;
  max-width: 1440px;
  margin: 0 auto;
  background: #F5F5F7;
  min-height: 100vh;
  position: relative;
}

/* Loading Overlay - Enhanced */
.loading-overlay {
  position: fixed;
  inset: 0;
  background: rgba(245, 245, 247, 0.98);
  backdrop-filter: blur(20px) saturate(180%);
  -webkit-backdrop-filter: blur(20px) saturate(180%);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  z-index: 9999;
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
}

.loading-spinner {
  position: relative;
  width: 64px;
  height: 64px;
}

.spinner-ring {
  position: absolute;
  width: 100%;
  height: 100%;
  border: 3px solid transparent;
  border-top-color: #1D1D1F;
  border-radius: 50%;
  animation: spin 1s cubic-bezier(0.68, -0.55, 0.265, 1.55) infinite;
}

.spinner-ring:nth-child(2) {
  border-top-color: #86868B;
  animation-delay: -0.33s;
  width: 85%;
  height: 85%;
  top: 7.5%;
  left: 7.5%;
}

.spinner-ring:nth-child(3) {
  border-top-color: #D2D2D7;
  animation-delay: -0.66s;
  width: 70%;
  height: 70%;
  top: 15%;
  left: 15%;
}

.loading-text {
  margin: 0;
  font-size: 17px;
  font-weight: 600;
  color: #1D1D1F;
  letter-spacing: -0.4px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.fade-enter-active, .fade-leave-active {
  transition: opacity 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

.fade-enter-from, .fade-leave-to {
  opacity: 0;
}

/* Header Section - Enhanced */
.dashboard-header {
  margin-bottom: 36px;
}

.header-top {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.dashboard-title {
  font-size: 40px;
  font-weight: 700;
  margin: 0 0 8px 0;
  letter-spacing: -0.8px;
  color: #1D1D1F;
  line-height: 1.1;
}

.dashboard-subtitle {
  font-size: 17px;
  color: #86868B;
  margin: 0;
  font-weight: 400;
  letter-spacing: -0.2px;
}

.header-time {
  display: flex;
  align-items: center;
}

.time-badge {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
  background: #FFFFFF;
  border-radius: 20px;
  border: 1px solid rgba(0, 0, 0, 0.04);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  font-size: 15px;
  font-weight: 600;
  color: #1D1D1F;
  letter-spacing: -0.2px;
}

.time-icon {
  width: 18px;
  height: 18px;
  color: #86868B;
  stroke-width: 2;
}

/* Section Headers - Enhanced */
.section-header-inline {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.section-title {
  font-size: 28px;
  font-weight: 700;
  color: #1D1D1F;
  margin: 0;
  letter-spacing: -0.6px;
}

.section-subtitle-inline {
  font-size: 15px;
  color: #86868B;
  margin: 0;
  font-weight: 500;
  letter-spacing: -0.2px;
}

.view-all-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 14px;
  background: transparent;
  border: none;
  border-radius: 12px;
  font-size: 15px;
  font-weight: 600;
  color: #007AFF;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  letter-spacing: -0.2px;
}

.view-all-btn:hover {
  background: rgba(0, 122, 255, 0.08);
}

.view-all-btn:active {
  transform: scale(0.96);
}

.view-all-btn svg {
  width: 16px;
  height: 16px;
  stroke-width: 2.5;
}

/* Stats Section - Enhanced */
.stats-section {
  margin-bottom: 40px;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 20px;
}

.stat-card {
  position: relative;
  background: #FFFFFF;
  border-radius: 20px;
  border: 1px solid rgba(0, 0, 0, 0.04);
  overflow: hidden;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  animation: fadeInUp 0.6s cubic-bezier(0.34, 1.56, 0.64, 1) backwards;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.stat-card:hover {
  transform: translateY(-4px) scale(1.01);
  box-shadow: 0 12px 32px rgba(0, 0, 0, 0.1);
  border-color: rgba(0, 0, 0, 0.08);
}

.stat-card:active {
  transform: translateY(-2px) scale(1.005);
}

.stat-content {
  padding: 24px;
  position: relative;
  z-index: 2;
}

.stat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.stat-icon-wrapper {
  width: 60px;
  height: 60px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  background: linear-gradient(135deg, #F5F5F7 0%, #E8E8ED 100%);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.stat-card:hover .stat-icon-wrapper {
  transform: scale(1.08) rotate(5deg);
}

.stat-icon {
  width: 30px;
  height: 30px;
  color: #1D1D1F;
  stroke-width: 2;
}

.stat-badge {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 6px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 600;
  letter-spacing: -0.1px;
}

.badge-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  animation: pulse 2s ease-in-out infinite;
}

.badge-blue {
  background: rgba(0, 122, 255, 0.1);
  color: #007AFF;
}

.badge-blue .badge-dot {
  background: #007AFF;
}

.badge-green {
  background: rgba(52, 199, 89, 0.1);
  color: #34C759;
}

.badge-green .badge-dot {
  background: #34C759;
}

.badge-purple {
  background: rgba(175, 82, 222, 0.1);
  color: #AF52DE;
}

.badge-purple .badge-dot {
  background: #AF52DE;
}

.badge-orange {
  background: rgba(255, 149, 0, 0.1);
  color: #FF9500;
}

.badge-orange .badge-dot {
  background: #FF9500;
}

.stat-body {
  margin-top: 16px;
}

.stat-value {
  font-size: 36px;
  font-weight: 700;
  color: #1D1D1F;
  line-height: 1;
  margin-bottom: 6px;
  letter-spacing: -1.2px;
}

.stat-label {
  font-size: 15px;
  font-weight: 500;
  color: #86868B;
  letter-spacing: -0.2px;
}

.stat-shine {
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.6), transparent);
  transition: left 0.5s ease;
  pointer-events: none;
}

.stat-card:hover .stat-shine {
  left: 100%;
}

.dashboard-title {
  font-size: 34px;
  font-weight: 700;
  margin: 0 0 6px 0;
  letter-spacing: -0.5px;
  color: #1D1D1F;
}

.dashboard-subtitle {
  font-size: 15px;
  color: #86868B;
  margin: 0;
  font-weight: 400;
  letter-spacing: -0.1px;
}

/* Stats Grid */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 20px;
  margin-bottom: 32px;
}

.stat-card {
  position: relative;
  background: #FFFFFF;
  border-radius: 14px;
  border: 1px solid #E8E8E8;
  overflow: hidden;
  transition: all 0.3s ease;
  animation: fadeInUp 0.5s ease-out backwards;
}

.stat-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 16px rgba(123, 163, 192, 0.1);
  border-color: #C8E0E8;
}

.stat-background {
  position: absolute;
  inset: 0;
  opacity: 0.02;
}

.stat-content {
  position: relative;
  z-index: 2;
  padding: 22px;
}

.stat-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 14px;
}

.stat-icon-wrapper {
  width: 50px;
  height: 50px;
  border-radius: 11px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 25px;
  background: linear-gradient(135deg, #C8E0E8 0%, #7BA3C0 100%);
}

.stat-trend {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 4px 9px;
  border-radius: 7px;
  font-size: 12px;
  font-weight: 600;
  background: #EFF6FF;
  color: #7BA3C0;
}

.stat-trend.up {
  background: #ECFDF5;
  color: #10B981;
}

.stat-trend.neutral {
  background: #F3F4F6;
  color: #7F8C8D;
}

.stat-body {
  margin-bottom: 12px;
}

.stat-value {
  font-size: 38px;
  font-weight: 700;
  color: #2C3E50;
  line-height: 1;
  margin-bottom: 6px;
  letter-spacing: -1px;
}

.stat-label {
  font-size: 14px;
  font-weight: 600;
  color: #7F8C8D;
  text-transform: none;
  letter-spacing: 0;
}

.stat-footer {
  padding-top: 12px;
  border-top: 1px solid #F5F5F5;
}

.stat-description {
  font-size: 13px;
  color: #95A5A6;
}

.stat-glow {
  display: none;
}

/* Section Headers */
.section-header {
  margin-bottom: 20px;
}

.section-title {
  font-size: 28px;
  font-weight: 700;
  color: #1D1D1F;
  margin: 0 0 4px 0;
  letter-spacing: -0.5px;
}

.title-icon {
  font-size: 26px;
}

.section-subtitle {
  font-size: 14px;
  color: #86868B;
  margin: 0;
  font-weight: 400;
  letter-spacing: -0.1px;
}

/* Stats Grid */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 16px;
  margin-bottom: 32px;
}

.stat-card {
  background: #FFFFFF;
  border-radius: 16px;
  border: 1px solid rgba(0, 0, 0, 0.06);
  overflow: hidden;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  animation: fadeInUp 0.5s ease-out backwards;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
  border-color: rgba(0, 0, 0, 0.1);
}

.stat-content {
  padding: 24px;
  display: flex;
  align-items: center;
  gap: 16px;
}

.stat-icon-wrapper {
  width: 56px;
  height: 56px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  background: linear-gradient(135deg, #F5F5F7 0%, #E8E8ED 100%);
}

.stat-icon {
  width: 28px;
  height: 28px;
  color: #1D1D1F;
  stroke-width: 2;
}

.stat-body {
  flex: 1;
}

.stat-value {
  font-size: 32px;
  font-weight: 700;
  color: #1D1D1F;
  line-height: 1;
  margin-bottom: 4px;
  letter-spacing: -1px;
}

.stat-label {
  font-size: 13px;
  font-weight: 500;
  color: #86868B;
  letter-spacing: -0.1px;
}

/* Quick Actions - Enhanced */
.quick-actions-section {
  margin-bottom: 40px;
}

.activity-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 20px;
}

.activity-card {
  position: relative;
  background: #FFFFFF;
  border-radius: 20px;
  border: 1px solid rgba(0, 0, 0, 0.04);
  padding: 24px;
  display: flex;
  align-items: center;
  gap: 16px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  animation: fadeInUp 0.6s cubic-bezier(0.34, 1.56, 0.64, 1) backwards;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.activity-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 32px rgba(0, 0, 0, 0.1);
  border-color: rgba(0, 0, 0, 0.08);
}

.activity-icon {
  width: 56px;
  height: 56px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.activity-card:hover .activity-icon {
  transform: scale(1.08) rotate(-5deg);
}

.activity-icon svg {
  width: 28px;
  height: 28px;
  stroke-width: 2;
}

.activity-icon svg {
  color: #007AFF;
}

.activity-card:nth-child(2) .activity-icon svg {
  color: #34C759;
}

.activity-card:nth-child(3) .activity-icon svg {
  color: #FF9500;
}

.activity-card:nth-child(4) .activity-icon svg {
  color: #AF52DE;
}

.activity-content {
  flex: 1;
  min-width: 0;
}

.activity-title {
  font-size: 13px;
  font-weight: 600;
  color: #86868B;
  margin-bottom: 4px;
  letter-spacing: -0.1px;
  text-transform: uppercase;
}

.activity-value {
  font-size: 32px;
  font-weight: 700;
  color: #1D1D1F;
  line-height: 1;
  margin-bottom: 4px;
  letter-spacing: -1px;
}

.activity-description {
  font-size: 13px;
  color: #86868B;
  letter-spacing: -0.1px;
}

.activity-action {
  width: 36px;
  height: 36px;
  background: #F5F5F7;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  text-decoration: none;
}

.activity-action svg {
  width: 18px;
  height: 18px;
  color: #1D1D1F;
  stroke-width: 2.5;
}

.activity-card:hover .activity-action {
  background: #007AFF;
  transform: translateX(4px);
}

.activity-card:hover .activity-action svg {
  color: white;
}

/* Old action grid styles - keep for backwards compatibility */
.quick-actions-section {
  margin-bottom: 40px;
}

.action-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
}

.action-card {
  position: relative;
  background: #FFFFFF;
  border-radius: 20px;
  border: 1px solid rgba(0, 0, 0, 0.04);
  overflow: hidden;
  text-decoration: none;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  animation: fadeInUp 0.6s cubic-bezier(0.34, 1.56, 0.64, 1) backwards;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.action-card:hover {
  transform: translateY(-4px) scale(1.01);
  box-shadow: 0 12px 32px rgba(0, 0, 0, 0.1);
  border-color: rgba(0, 0, 0, 0.08);
}

.action-card:active {
  transform: translateY(-2px) scale(1.005);
}

.action-content {
  padding: 28px;
  display: flex;
  align-items: center;
  gap: 20px;
  position: relative;
  z-index: 2;
}

.action-icon-wrapper {
  width: 64px;
  height: 64px;
  border-radius: 18px;
  background: linear-gradient(135deg, #F5F5F7 0%, #E8E8ED 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.action-card:hover .action-icon-wrapper {
  transform: scale(1.08) rotate(-5deg);
}

.action-icon {
  width: 32px;
  height: 32px;
  color: #1D1D1F;
  stroke-width: 2;
}

.action-info {
  flex: 1;
}

.action-title {
  font-size: 19px;
  font-weight: 600;
  color: #1D1D1F;
  margin: 0 0 6px 0;
  letter-spacing: -0.4px;
}

.action-description {
  font-size: 14px;
  color: #86868B;
  margin: 0;
  line-height: 1.5;
  letter-spacing: -0.1px;
}

.action-arrow {
  width: 28px;
  height: 28px;
  flex-shrink: 0;
  color: #86868B;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  opacity: 0.6;
}

.action-arrow svg {
  width: 100%;
  height: 100%;
  stroke-width: 2.5;
}

.action-card:hover .action-arrow {
  color: #1D1D1F;
  transform: translateX(6px);
  opacity: 1;
}

.action-shine {
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.6), transparent);
  transition: left 0.5s ease;
  pointer-events: none;
}

.action-card:hover .action-shine {
  left: 100%;
}

/* System Status - Enhanced */
.status-section {
  margin-bottom: 40px;
}

.health-badge {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  background: rgba(52, 199, 89, 0.1);
  border-radius: 16px;
  font-size: 14px;
  font-weight: 600;
  color: #34C759;
  letter-spacing: -0.2px;
}

.health-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #34C759;
  animation: pulse 2s ease-in-out infinite;
}

.status-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 16px;
}

.status-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px 24px;
  background: #FFFFFF;
  border-radius: 18px;
  border: 1px solid rgba(0, 0, 0, 0.04);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  animation: fadeInUp 0.6s cubic-bezier(0.34, 1.56, 0.64, 1) backwards;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.status-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08);
  border-color: rgba(0, 0, 0, 0.08);
}

.status-indicator {
  position: relative;
  width: 12px;
  height: 12px;
  border-radius: 50%;
  flex-shrink: 0;
}

.indicator-pulse {
  position: absolute;
  inset: -6px;
  border-radius: 50%;
  background: inherit;
  opacity: 0.3;
  animation: pulse 2s ease-in-out infinite;
}

.status-indicator.online {
  background: #34C759;
}

.status-indicator.warning {
  background: #FF9500;
}

.status-indicator.offline {
  background: #FF3B30;
}

.status-info {
  flex: 1;
}

.status-label {
  font-size: 13px;
  color: #86868B;
  margin-bottom: 4px;
  font-weight: 500;
  letter-spacing: -0.1px;
}

.status-value {
  font-size: 16px;
  font-weight: 600;
  color: #1D1D1F;
  letter-spacing: -0.3px;
}

.status-icon {
  width: 24px;
  height: 24px;
  color: #34C759;
  flex-shrink: 0;
  opacity: 0;
  transform: scale(0.8);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.status-icon svg {
  width: 100%;
  height: 100%;
}

.status-card:hover .status-icon {
  opacity: 1;
  transform: scale(1);
}

/* Animations */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(24px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes pulse {
  0%, 100% {
    opacity: 0.3;
    transform: scale(1);
  }
  50% {
    opacity: 0.5;
    transform: scale(1.4);
  }
}

/* Responsive Design */
@media (max-width: 1024px) {
  .dashboard-home {
    padding: 32px 24px;
  }

  .dashboard-title {
    font-size: 34px;
  }

  .section-title {
    font-size: 24px;
  }
}

@media (max-width: 768px) {
  .dashboard-home {
    padding: 24px 20px;
  }

  .dashboard-title {
    font-size: 28px;
  }

  .section-title {
    font-size: 22px;
  }

  .header-top {
    flex-direction: column;
    gap: 16px;
  }

  .stats-grid,
  .action-grid,
  .status-grid {
    grid-template-columns: 1fr;
  }

  .stat-value {
    font-size: 28px;
  }

  .action-content {
    padding: 24px;
  }
}
</style>
