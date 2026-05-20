<template>
  <transition name="notification-slide">
    <div v-if="showNotification" class="auto-refresh-notification" :class="notificationType">
      <div class="notification-content">
        <div class="notification-icon">
          <svg v-if="notificationType === 'success'" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
          </svg>
          <svg v-else-if="notificationType === 'error'" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.732-.833-2.464 0L4.34 16.5c-.77.833.192 2.5 1.732 2.5z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
          </svg>
          <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
          </svg>
        </div>
        <div class="notification-text">
          <div class="notification-title">{{ notificationTitle }}</div>
          <div class="notification-message">{{ notificationMessage }}</div>
        </div>
        <button @click="hideNotification" class="notification-close">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M6 18L18 6M6 6l12 12" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
          </svg>
        </button>
      </div>
    </div>
  </transition>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { autoRefreshService } from '@/services/autoRefreshService'

const showNotification = ref(false)
const notificationType = ref('info')
const notificationTitle = ref('')
const notificationMessage = ref('')

let hideTimeout = null

const showRefreshNotification = (type, title, message, duration = 3000) => {
  notificationType.value = type
  notificationTitle.value = title
  notificationMessage.value = message
  showNotification.value = true
  
  if (hideTimeout) {
    clearTimeout(hideTimeout)
  }
  
  hideTimeout = setTimeout(() => {
    hideNotification()
  }, duration)
}

const hideNotification = () => {
  showNotification.value = false
  if (hideTimeout) {
    clearTimeout(hideTimeout)
    hideTimeout = null
  }
}

// Listen for auto-refresh events
const handleRefreshSuccess = (feature) => {
  showRefreshNotification(
    'success',
    'Data Updated',
    `${feature.charAt(0).toUpperCase() + feature.slice(1)} data refreshed automatically`,
    2000
  )
}

const handleRefreshError = (feature, error) => {
  showRefreshNotification(
    'error',
    'Refresh Failed',
    `Failed to update ${feature} data. Please refresh manually.`,
    4000
  )
}

onMounted(() => {
  // Listen for global refresh events
  window.addEventListener('autoRefreshSuccess', (event) => {
    handleRefreshSuccess(event.detail.feature)
  })
  
  window.addEventListener('autoRefreshError', (event) => {
    handleRefreshError(event.detail.feature, event.detail.error)
  })
})

onUnmounted(() => {
  if (hideTimeout) {
    clearTimeout(hideTimeout)
  }
  
  window.removeEventListener('autoRefreshSuccess', handleRefreshSuccess)
  window.removeEventListener('autoRefreshError', handleRefreshError)
})
</script>

<style scoped>
.auto-refresh-notification {
  position: fixed;
  top: 20px;
  right: 20px;
  z-index: 10000;
  max-width: 400px;
  background: #FFFFFF;
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.12);
  border: 1px solid rgba(0, 0, 0, 0.06);
  overflow: hidden;
}

.notification-content {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 16px;
}

.notification-icon {
  width: 24px;
  height: 24px;
  flex-shrink: 0;
  margin-top: 2px;
}

.notification-icon svg {
  width: 100%;
  height: 100%;
  stroke-width: 2;
}

.auto-refresh-notification.success .notification-icon svg {
  color: #34C759;
}

.auto-refresh-notification.error .notification-icon svg {
  color: #FF3B30;
}

.auto-refresh-notification.info .notification-icon svg {
  color: #007AFF;
}

.notification-text {
  flex: 1;
  min-width: 0;
}

.notification-title {
  font-size: 14px;
  font-weight: 600;
  color: #1D1D1F;
  margin-bottom: 4px;
  letter-spacing: -0.2px;
}

.notification-message {
  font-size: 13px;
  color: #86868B;
  line-height: 1.4;
  letter-spacing: -0.1px;
}

.notification-close {
  width: 24px;
  height: 24px;
  border: none;
  background: none;
  cursor: pointer;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
  flex-shrink: 0;
}

.notification-close:hover {
  background: #F5F5F7;
}

.notification-close svg {
  width: 16px;
  height: 16px;
  color: #86868B;
  stroke-width: 2;
}

/* Success variant */
.auto-refresh-notification.success {
  border-left: 4px solid #34C759;
}

/* Error variant */
.auto-refresh-notification.error {
  border-left: 4px solid #FF3B30;
}

/* Info variant */
.auto-refresh-notification.info {
  border-left: 4px solid #007AFF;
}

/* Animations */
.notification-slide-enter-active {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.notification-slide-leave-active {
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

.notification-slide-enter-from {
  opacity: 0;
  transform: translateX(100%) translateY(-10px);
}

.notification-slide-leave-to {
  opacity: 0;
  transform: translateX(100%) translateY(-5px);
}

@media (max-width: 768px) {
  .auto-refresh-notification {
    top: 16px;
    right: 16px;
    left: 16px;
    max-width: none;
  }
  
  .notification-content {
    padding: 14px;
  }
  
  .notification-title {
    font-size: 13px;
  }
  
  .notification-message {
    font-size: 12px;
  }
}
</style>