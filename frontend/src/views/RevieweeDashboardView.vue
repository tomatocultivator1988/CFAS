<template>
  <div class="reviewee-dashboard">
    <div class="sidebar">
      <div class="sidebar-header">
        <div class="logo-container">
          <img src="/cfas-logo.jpg" alt="CFAS Logo" class="logo-image" onerror="this.style.display='none'" />
          <div class="logo-text">
            <h2>CFAS Review Hub</h2>
            <p>Reviewee Portal</p>
          </div>
        </div>
      </div>
      
      <nav class="sidebar-nav">
        <router-link to="/exams" class="nav-item" exact-active-class="active">
          <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
          </svg>
          <span>My Exams</span>
        </router-link>

        <router-link to="/exams/email" class="nav-item" active-class="active">
          <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M4 4h16v16H4z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
            <path d="M4 7l8 6 8-6" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
          </svg>
          <span>Score Email</span>
        </router-link>
      </nav>
      
      <div class="sidebar-footer">
        <div class="user-info">
          <div class="user-avatar">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
            </svg>
          </div>
          <div class="user-details">
            <div class="user-name">
              {{ authStore.user?.first_name && authStore.user?.last_name 
                ? `${authStore.user.first_name} ${authStore.user.last_name}` 
                : authStore.user?.username || 'Reviewee' }}
            </div>
            <div class="user-role">Reviewee</div>
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
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const showLogoutModal = ref(false)
const loggingOut = ref(false)

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
.reviewee-dashboard {
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
  height: 100vh;
  z-index: 1000;
}

.sidebar-header {
  padding: 32px 24px;
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
}

.logo-container {
  display: flex;
  align-items: center;
  gap: 16px;
}

.logo-image {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  object-fit: cover;
  flex-shrink: 0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
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
  margin: 0 0 2px 0;
  font-size: 17px;
  font-weight: 700;
  color: #1D1D1F;
  letter-spacing: -0.3px;
}

.logo-text p {
  margin: 0;
  font-size: 12px;
  color: #86868B;
  font-weight: 500;
  letter-spacing: -0.1px;
}

.sidebar-nav {
  flex: 1;
  padding: 24px 16px;
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
  cursor: pointer;
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

/* Responsive */
@media (max-width: 1024px) {
  .sidebar {
    width: 260px;
  }
  
  .main-content {
    margin-left: 260px;
  }
}

@media (max-width: 768px) {
  .sidebar {
    width: 100%;
    transform: translateX(-100%);
    transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  }
  
  .sidebar.mobile-open {
    transform: translateX(0);
  }
  
  .main-content {
    margin-left: 0;
    width: 100%;
  }
  
  .sidebar-header {
    padding: 24px 20px;
  }
  
  .logo-text h2 {
    font-size: 16px;
  }
  
  .logo-text p {
    font-size: 11px;
  }
  
  .sidebar-nav {
    padding: 20px 12px;
  }
  
  .nav-item {
    padding: 10px 14px;
    font-size: 14px;
  }
  
  .nav-icon {
    width: 20px;
    height: 20px;
  }
  
  .sidebar-footer {
    padding: 16px;
  }
  
  .user-info {
    padding: 10px;
  }
  
  .user-avatar {
    width: 36px;
    height: 36px;
  }
  
  .user-name {
    font-size: 13px;
  }
  
  .btn-logout {
    padding: 10px 14px;
    font-size: 14px;
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
  .sidebar-header {
    padding: 20px 16px;
  }
  
  .logo-image {
    width: 40px;
    height: 40px;
  }
  
  .logo-text h2 {
    font-size: 15px;
  }
  
  .logo-text p {
    font-size: 10px;
  }
  
  .sidebar-nav {
    padding: 16px 12px;
  }
  
  .nav-item {
    padding: 10px 12px;
    font-size: 13px;
    margin-bottom: 6px;
  }
  
  .sidebar-footer {
    padding: 12px;
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
    font-size: 11px;
  }
  
  .btn-logout {
    padding: 10px 12px;
    font-size: 13px;
  }
  
  .btn-logout svg {
    width: 18px;
    height: 18px;
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
</style>
