<template>
  <div class="admin-dashboard">
    <!-- Hamburger Menu Button (Mobile Only) -->
    <button @click="toggleMobileSidebar" class="hamburger-menu" :class="{ 'open': isMobileSidebarOpen }">
      <span></span>
      <span></span>
      <span></span>
    </button>
    
    <!-- Mobile Overlay -->
    <div v-if="isMobileSidebarOpen" @click="closeMobileSidebar" class="mobile-overlay"></div>
    
    <div class="sidebar" :class="{ 'mobile-open': isMobileSidebarOpen }">
      <div class="sidebar-header">
        <div class="logo-container">
          <img src="/cfas-logo.jpg" alt="CFAS Logo" class="logo-image" />
          <div class="logo-text">
            <h2>CFAS Review Hub</h2>
            <p>Admin Panel</p>
          </div>
        </div>
      </div>
      
      <nav class="sidebar-nav">
        <router-link to="/admin" class="nav-item" exact-active-class="active">
          <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
          </svg>
          <span>Dashboard</span>
        </router-link>

        <router-link to="/admin/exams" class="nav-item" active-class="active">
          <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
          </svg>
          <span>Manage Exams</span>
        </router-link>

        <router-link to="/admin/users" class="nav-item" active-class="active">
          <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
          </svg>
          <span>Manage Users</span>
        </router-link>

        <router-link to="/admin/scores" class="nav-item" active-class="active">
          <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
          </svg>
          <span>View Scores</span>
        </router-link>

        <router-link to="/admin/analytics" class="nav-item" active-class="active">
          <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
          </svg>
          <span>Analytics</span>
        </router-link>

        <router-link to="/admin/ml-predictive" class="nav-item" active-class="active">
          <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M4 19h16M7 16l3-4 3 2 4-6" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
            <circle cx="7" cy="16" r="1.5" />
            <circle cx="10" cy="12" r="1.5" />
            <circle cx="13" cy="14" r="1.5" />
            <circle cx="17" cy="8" r="1.5" />
          </svg>
          <span>ML Predictive</span>
        </router-link>

        <router-link to="/admin/exports" class="nav-item" active-class="active">
          <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
          </svg>
          <span>Export Reports</span>
        </router-link>
      </nav>
      
      <div class="sidebar-footer">
        <!-- Auto-refresh controls -->
        <div class="auto-refresh-controls">
          <div class="refresh-header">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
            </svg>
            <span>Auto-Refresh</span>
          </div>
          <div class="refresh-status">
            <div class="status-indicator" :class="{ 'active': autoRefreshStatus.globalActive }"></div>
            <span class="status-text">{{ autoRefreshStatus.globalActive ? 'Active' : 'Inactive' }}</span>
            <button @click="toggleGlobalAutoRefresh" class="btn-toggle">
              {{ autoRefreshStatus.globalActive ? 'Disable' : 'Enable' }}
            </button>
          </div>
        </div>
        
        <div class="user-info">
          <div class="user-avatar">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
            </svg>
          </div>
          <div class="user-details">
            <div class="user-name">Admin User</div>
            <div class="user-role">Administrator</div>
          </div>
        </div>
        <button @click="handleLogout" class="btn-logout">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
          </svg>
          <span>Logout</span>
        </button>
      </div>
    </div>

    <div class="main-content">
      <!-- Back Button (shows on all pages except dashboard) -->
      <div v-if="showBackButton" class="page-header">
        <button @click="goBack" class="back-button">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M15 19l-7-7 7-7" stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5"/>
          </svg>
          <span>Back to Dashboard</span>
        </button>
        <h1 class="page-title">{{ currentPageTitle }}</h1>
      </div>
      
      <router-view />
    </div>

    <!-- Logout Confirmation Modal -->
    <transition name="modal-fade">
      <div v-if="showLogoutModal" class="modal-overlay">
        <transition name="modal-scale">
          <div v-if="showLogoutModal" class="logout-modal">
            <div class="modal-icon-wrapper">
              <svg class="modal-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
              </svg>
            </div>
            
            <h3 class="modal-title">Log Out?</h3>
            <p class="modal-message">
              Are you sure you want to log out of your account?
            </p>
            
            <div class="modal-actions">
              <button @click="cancelLogout" class="modal-btn modal-btn-cancel" :disabled="loggingOut">
                Cancel
              </button>
              <button @click="confirmLogout" class="modal-btn modal-btn-logout" :disabled="loggingOut">
                <div v-if="loggingOut" class="btn-spinner">
                  <div class="spinner-ring-small"></div>
                </div>
                <template v-else>
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <path d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                  </svg>
                  <span>Log Out</span>
                </template>
              </button>
            </div>
          </div>
        </transition>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { autoRefreshService } from '@/services/autoRefreshService'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const showLogoutModal = ref(false)
const loggingOut = ref(false)
const isMobileSidebarOpen = ref(false)

// Mobile sidebar controls
const toggleMobileSidebar = () => {
  isMobileSidebarOpen.value = !isMobileSidebarOpen.value
}

const closeMobileSidebar = () => {
  isMobileSidebarOpen.value = false
}

// Auto-refresh controls
const autoRefreshStatus = computed(() => autoRefreshService.getStatus())
const toggleGlobalAutoRefresh = () => {
  if (autoRefreshService.isGlobalRefreshActive.value) {
    autoRefreshService.stopAll()
  } else {
    autoRefreshService.startAll()
  }
}

// Determine current page title and icon based on route
const currentPageTitle = computed(() => {
  const path = route.path
  if (path.includes('/exams')) return 'Manage Exams'
  if (path.includes('/users')) return 'Manage Users'
  if (path.includes('/scores')) return 'View Scores'
  if (path.includes('/ml-predictive')) return 'ML Predictive'
  if (path.includes('/analytics')) return 'Analytics'
  if (path.includes('/exports')) return 'Export Reports'
  return 'Dashboard'
})

const currentPageIcon = computed(() => {
  const path = route.path
  
  if (path.includes('/exams')) {
    return {
      viewBox: '0 0 24 24',
      path: 'M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z'
    }
  }
  
  if (path.includes('/users')) {
    return {
      viewBox: '0 0 24 24',
      path: 'M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z'
    }
  }
  
  if (path.includes('/scores')) {
    return {
      viewBox: '0 0 24 24',
      path: 'M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z'
    }
  }
  
  if (path.includes('/analytics')) {
    return {
      viewBox: '0 0 24 24',
      path: 'M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z'
    }
  }
  
  if (path.includes('/exports')) {
    return {
      viewBox: '0 0 24 24',
      path: 'M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z'
    }
  }
  
  // Default dashboard icon
  return {
    viewBox: '0 0 24 24',
    path: 'M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6'
  }
})

// Show back button on all pages except dashboard
const showBackButton = computed(() => {
  return route.path !== '/admin'
})

const goBack = () => {
  router.push('/admin')
}

const handleLogout = () => {
  showLogoutModal.value = true
}

const cancelLogout = () => {
  showLogoutModal.value = false
}

const confirmLogout = async () => {
  loggingOut.value = true
  
  try {
    await authStore.logout()
    showLogoutModal.value = false
    router.push('/login')
  } finally {
    loggingOut.value = false
  }
}
</script>

<style scoped>
.admin-dashboard {
  display: flex;
  min-height: 100vh;
  background: #F5F5F7;
}

.sidebar {
  width: 280px;
  background: #FFFFFF;
  border-right: 1px solid rgba(0, 0, 0, 0.06);
  display: flex;
  flex-direction: column;
  box-shadow: 2px 0 12px rgba(0, 0, 0, 0.04);
  position: fixed;
  left: 0;
  top: 0;
  bottom: 0;
  overflow: hidden;
}

.sidebar-header {
  padding: 40px 24px;
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
}

.logo-container {
  display: flex;
  align-items: center;
  gap: 20px;
}

.logo-image {
  width: 80px;
  height: 80px;
  border-radius: 20px;
  object-fit: cover;
  flex-shrink: 0;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.logo-icon {
  width: 48px;
  height: 48px;
  background: linear-gradient(135deg, #F5F5F7 0%, #E8E8ED 100%);
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.logo-icon svg {
  width: 26px;
  height: 26px;
  color: #1D1D1F;
  stroke-width: 2;
}

.logo-text h2 {
  margin: 0 0 4px 0;
  font-size: 24px;
  font-weight: 700;
  color: #1D1D1F;
  letter-spacing: -0.5px;
}

.logo-text p {
  margin: 0;
  font-size: 16px;
  color: #86868B;
  font-weight: 500;
  letter-spacing: -0.2px;
}

.sidebar-nav {
  flex: 1;
  padding: 24px 16px;
  overflow-y: auto;
  overflow-x: hidden;
}

.sidebar-nav::-webkit-scrollbar {
  width: 6px;
}

.sidebar-nav::-webkit-scrollbar-track {
  background: transparent;
}

.sidebar-nav::-webkit-scrollbar-thumb {
  background: rgba(0, 0, 0, 0.1);
  border-radius: 3px;
}

.sidebar-nav::-webkit-scrollbar-thumb:hover {
  background: rgba(0, 0, 0, 0.15);
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  color: #86868B;
  text-decoration: none;
  border-radius: 12px;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  font-size: 15px;
  font-weight: 600;
  letter-spacing: -0.2px;
  margin-bottom: 8px;
}

.nav-icon {
  width: 22px;
  height: 22px;
  stroke-width: 2;
  flex-shrink: 0;
}

.nav-item:hover {
  background: rgba(0, 0, 0, 0.04);
  color: #1D1D1F;
}

.nav-item.active {
  background: rgba(0, 122, 255, 0.1);
  color: #007AFF;
}

.sidebar-footer {
  padding: 20px;
  border-top: 1px solid rgba(0, 0, 0, 0.06);
  flex-shrink: 0;
  background: #FFFFFF;
}

.auto-refresh-controls {
  background: #F5F5F7;
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 16px;
}

.refresh-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
  font-size: 14px;
  font-weight: 600;
  color: #1D1D1F;
  letter-spacing: -0.2px;
}

.refresh-header svg {
  width: 18px;
  height: 18px;
  stroke-width: 2;
  color: #86868B;
}

.refresh-status {
  display: flex;
  align-items: center;
  gap: 8px;
}

.status-indicator {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #86868B;
  transition: all 0.2s;
}

.status-indicator.active {
  background: #34C759;
  box-shadow: 0 0 8px rgba(52, 199, 89, 0.4);
}

.status-text {
  flex: 1;
  font-size: 13px;
  font-weight: 500;
  color: #1D1D1F;
  letter-spacing: -0.1px;
}

.btn-toggle {
  padding: 4px 10px;
  background: #FFFFFF;
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 6px;
  font-size: 11px;
  font-weight: 600;
  color: #007AFF;
  cursor: pointer;
  transition: all 0.2s;
  letter-spacing: -0.1px;
}

.btn-toggle:hover {
  background: rgba(0, 122, 255, 0.08);
}

.user-info {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: #F5F5F7;
  border-radius: 12px;
  margin-bottom: 12px;
}

.user-avatar {
  width: 40px;
  height: 40px;
  background: linear-gradient(135deg, #E8E8ED 0%, #D2D2D7 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.user-avatar svg {
  width: 22px;
  height: 22px;
  color: #1D1D1F;
  stroke-width: 2;
}

.user-details {
  flex: 1;
  min-width: 0;
}

.user-name {
  font-size: 14px;
  font-weight: 600;
  color: #1D1D1F;
  letter-spacing: -0.2px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.user-role {
  font-size: 12px;
  color: #86868B;
  font-weight: 500;
  letter-spacing: -0.1px;
}

.btn-logout {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 12px 16px;
  background: rgba(255, 59, 48, 0.1);
  color: #FF3B30;
  border: none;
  border-radius: 12px;
  cursor: pointer;
  font-weight: 600;
  font-size: 15px;
  letter-spacing: -0.2px;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

.btn-logout svg {
  width: 20px;
  height: 20px;
  stroke-width: 2;
}

.btn-logout:hover {
  background: rgba(255, 59, 48, 0.15);
  transform: translateY(-1px);
}

.btn-logout:active {
  transform: scale(0.96);
}

.main-content {
  flex: 1;
  margin-left: 280px;
  overflow-y: auto;
}

/* Page Header with Back Button */
.page-header {
  padding: 32px 48px 24px 48px;
  background: #FFFFFF;
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
  position: sticky;
  top: 0;
  z-index: 100;
  backdrop-filter: blur(20px) saturate(180%);
  -webkit-backdrop-filter: blur(20px) saturate(180%);
  background: rgba(255, 255, 255, 0.95);
}

.back-button {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  background: transparent;
  border: none;
  border-radius: 12px;
  color: #007AFF;
  font-size: 15px;
  font-weight: 600;
  letter-spacing: -0.2px;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  margin-bottom: 16px;
}

.back-button svg {
  width: 20px;
  height: 20px;
  stroke-width: 2.5;
}

.back-button:hover {
  background: rgba(0, 122, 255, 0.08);
  transform: translateX(-2px);
}

.back-button:active {
  transform: translateX(-2px) scale(0.96);
}

.page-title {
  font-size: 34px;
  font-weight: 700;
  color: #1D1D1F;
  margin: 0;
  letter-spacing: -0.8px;
}

/* Mobile Hamburger Menu Button */
.hamburger-menu {
  display: none;
  position: fixed;
  top: 20px;
  left: 20px;
  z-index: 10001;
  width: 44px;
  height: 44px;
  background: #FFFFFF;
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 12px;
  cursor: pointer;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 5px;
  padding: 0;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.hamburger-menu span {
  display: block;
  width: 20px;
  height: 2px;
  background: #1D1D1F;
  border-radius: 2px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.hamburger-menu.open span:nth-child(1) {
  transform: translateY(7px) rotate(45deg);
}

.hamburger-menu.open span:nth-child(2) {
  opacity: 0;
}

.hamburger-menu.open span:nth-child(3) {
  transform: translateY(-7px) rotate(-45deg);
}

.hamburger-menu:hover {
  background: #F5F5F7;
  transform: scale(1.05);
}

.hamburger-menu:active {
  transform: scale(0.95);
}

/* Mobile Overlay */
.mobile-overlay {
  display: none;
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
  -webkit-backdrop-filter: blur(4px);
  z-index: 999;
}

/* Overlay Fade Animation */
.overlay-fade-enter-active,
.overlay-fade-leave-active {
  transition: opacity 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.overlay-fade-enter-from,
.overlay-fade-leave-to {
  opacity: 0;
}

/* Responsive Breakpoints */
@media (max-width: 1024px) {
  .sidebar {
    width: 260px;
  }
  
  .main-content {
    margin-left: 260px;
  }
  
  .page-header {
    padding: 28px 40px 20px 40px;
  }
}

@media (max-width: 768px) {
  .hamburger-menu {
    display: flex;
  }
  
  .mobile-overlay {
    display: block;
  }
  
  .sidebar {
    width: 280px;
    transform: translateX(-100%);
    transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    z-index: 1000;
  }
  
  .sidebar.mobile-open {
    transform: translateX(0);
  }
  
  .main-content {
    margin-left: 0;
    width: 100%;
  }
  
  .sidebar-header {
    padding: 32px 20px;
  }
  
  .logo-image {
    width: 60px;
    height: 60px;
  }
  
  .logo-text h2 {
    font-size: 20px;
  }
  
  .logo-text p {
    font-size: 14px;
  }
  
  .sidebar-nav {
    padding: 20px 14px;
  }
  
  .nav-item {
    padding: 11px 14px;
    font-size: 14px;
  }
  
  .nav-icon {
    width: 20px;
    height: 20px;
  }
  
  .sidebar-footer {
    padding: 18px;
  }
  
  .auto-refresh-controls {
    padding: 14px;
    margin-bottom: 14px;
  }
  
  .refresh-header {
    font-size: 13px;
  }
  
  .status-text {
    font-size: 12px;
  }
  
  .btn-toggle {
    padding: 4px 8px;
    font-size: 10px;
  }
  
  .user-info {
    padding: 10px;
    margin-bottom: 10px;
  }
  
  .user-avatar {
    width: 36px;
    height: 36px;
  }
  
  .user-avatar svg {
    width: 20px;
    height: 20px;
  }
  
  .user-name {
    font-size: 13px;
  }
  
  .user-role {
    font-size: 11px;
  }
  
  .btn-logout {
    padding: 11px 14px;
    font-size: 14px;
  }
  
  .btn-logout svg {
    width: 18px;
    height: 18px;
  }
  
  .page-header {
    padding: 80px 20px 20px 20px;
  }
  
  .back-button {
    padding: 8px 14px;
    font-size: 14px;
    margin-bottom: 12px;
  }
  
  .back-button svg {
    width: 18px;
    height: 18px;
  }
  
  .page-title {
    font-size: 28px;
  }
  
  .logout-modal {
    max-width: 90%;
    padding: 28px 24px;
    border-radius: 18px;
  }
  
  .modal-title {
    font-size: 20px;
  }
  
  .modal-message {
    font-size: 14px;
  }
}

@media (max-width: 480px) {
  .hamburger-menu {
    top: 16px;
    left: 16px;
    width: 40px;
    height: 40px;
  }
  
  .hamburger-menu span {
    width: 18px;
  }
  
  .sidebar {
    width: 100%;
  }
  
  .sidebar-header {
    padding: 24px 16px;
  }
  
  .logo-image {
    width: 48px;
    height: 48px;
    border-radius: 14px;
  }
  
  .logo-text h2 {
    font-size: 17px;
  }
  
  .logo-text p {
    font-size: 12px;
  }
  
  .sidebar-nav {
    padding: 16px 12px;
  }
  
  .nav-item {
    padding: 10px 12px;
    font-size: 13px;
    margin-bottom: 6px;
  }
  
  .nav-icon {
    width: 18px;
    height: 18px;
  }
  
  .sidebar-footer {
    padding: 14px 12px;
  }
  
  .auto-refresh-controls {
    padding: 12px;
    margin-bottom: 12px;
    border-radius: 10px;
  }
  
  .refresh-header {
    font-size: 12px;
    margin-bottom: 10px;
  }
  
  .refresh-header svg {
    width: 16px;
    height: 16px;
  }
  
  .status-indicator {
    width: 6px;
    height: 6px;
  }
  
  .status-text {
    font-size: 11px;
  }
  
  .btn-toggle {
    padding: 3px 8px;
    font-size: 10px;
  }
  
  .user-info {
    padding: 8px;
    margin-bottom: 10px;
  }
  
  .user-avatar {
    width: 32px;
    height: 32px;
  }
  
  .user-avatar svg {
    width: 18px;
    height: 18px;
  }
  
  .user-name {
    font-size: 12px;
  }
  
  .user-role {
    font-size: 10px;
  }
  
  .btn-logout {
    padding: 10px 12px;
    font-size: 13px;
  }
  
  .btn-logout svg {
    width: 16px;
    height: 16px;
  }
  
  .page-header {
    padding: 70px 16px 16px 16px;
  }
  
  .back-button {
    padding: 6px 12px;
    font-size: 13px;
    margin-bottom: 10px;
  }
  
  .back-button svg {
    width: 16px;
    height: 16px;
  }
  
  .page-title {
    font-size: 24px;
  }
  
  .logout-modal {
    padding: 24px 20px;
    border-radius: 16px;
  }
  
  .modal-icon-wrapper {
    width: 56px;
    height: 56px;
    margin-bottom: 16px;
  }
  
  .modal-icon {
    width: 28px;
    height: 28px;
  }
  
  .modal-title {
    font-size: 18px;
    margin-bottom: 10px;
  }
  
  .modal-message {
    font-size: 13px;
    margin-bottom: 24px;
  }
  
  .modal-actions {
    flex-direction: column;
    gap: 10px;
  }
  
  .modal-btn {
    width: 100%;
    padding: 12px 16px;
    font-size: 14px;
  }
}

/* iOS-Style Logout Modal */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.4);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10000;
  padding: 20px;
}

.logout-modal {
  background: #FFFFFF;
  border-radius: 20px;
  padding: 32px;
  max-width: 400px;
  width: 100%;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  text-align: center;
}

.modal-icon-wrapper {
  width: 64px;
  height: 64px;
  background: linear-gradient(135deg, rgba(255, 149, 0, 0.1) 0%, rgba(255, 149, 0, 0.15) 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 20px;
}

.modal-icon {
  width: 32px;
  height: 32px;
  color: #FF9500;
  stroke-width: 2;
}

.modal-title {
  font-size: 22px;
  font-weight: 700;
  color: #1D1D1F;
  margin: 0 0 12px 0;
  letter-spacing: -0.5px;
}

.modal-message {
  font-size: 15px;
  color: #86868B;
  line-height: 1.5;
  margin: 0 0 28px 0;
  letter-spacing: -0.2px;
}

.modal-actions {
  display: flex;
  gap: 12px;
}

.modal-btn {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 14px 20px;
  border: none;
  border-radius: 12px;
  font-size: 15px;
  font-weight: 600;
  letter-spacing: -0.2px;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

.modal-btn svg {
  width: 18px;
  height: 18px;
  stroke-width: 2;
}

.modal-btn-cancel {
  background: #F5F5F7;
  color: #1D1D1F;
}

.modal-btn-cancel:hover {
  background: #E8E8ED;
  transform: translateY(-1px);
}

.modal-btn-cancel:active {
  transform: scale(0.96);
}

.modal-btn-logout {
  background: #FF9500;
  color: white;
  box-shadow: 0 4px 12px rgba(255, 149, 0, 0.3);
}

.modal-btn-logout:hover {
  background: #FF8C00;
  transform: translateY(-1px);
  box-shadow: 0 6px 16px rgba(255, 149, 0, 0.4);
}

.modal-btn-logout:active {
  transform: scale(0.96);
}

.modal-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.modal-btn:disabled:hover {
  transform: none;
}

/* Button Loading Spinner */
.btn-spinner {
  display: flex;
  align-items: center;
  justify-content: center;
}

.spinner-ring-small {
  width: 18px;
  height: 18px;
  border: 2px dashed rgba(255, 255, 255, 0.8);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Modal Animations */
.modal-fade-enter-active {
  transition: opacity 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.modal-fade-leave-active {
  transition: opacity 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}

.modal-scale-enter-active {
  transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.modal-scale-leave-active {
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

.modal-scale-enter-from {
  opacity: 0;
  transform: scale(0.9) translateY(20px);
}

.modal-scale-leave-to {
  opacity: 0;
  transform: scale(0.95) translateY(-10px);
}

@media (max-width: 480px) {
  .logout-modal {
    padding: 24px 20px;
    border-radius: 16px;
  }
  
  .modal-icon-wrapper {
    width: 56px;
    height: 56px;
    margin-bottom: 16px;
  }
  
  .modal-icon {
    width: 28px;
    height: 28px;
  }
  
  .modal-title {
    font-size: 18px;
    margin-bottom: 10px;
  }
  
  .modal-message {
    font-size: 13px;
    margin-bottom: 24px;
  }
  
  .modal-actions {
    flex-direction: column;
    gap: 10px;
  }
  
  .modal-btn {
    width: 100%;
    padding: 12px 16px;
    font-size: 14px;
  }
}
</style>
