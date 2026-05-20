<template>
  <div class="login-page" :style="{ '--bg-image': `url(${isufstLogoPath})` }">
    <!-- Left Side - Image & Quote -->
    <div class="brand-section">
      <div class="brand-content">
        <!-- Father Paler Photo -->
        <div class="photo-container">
          <div class="photo-placeholder">
            <img :src="palerImagePath" alt="Father Paler" class="cfas-logo-image" />
          </div>
        </div>

        <!-- Quote -->
        <div class="quote-section">
          <p class="quote-text">"Review na walang bayad"</p>
          <p class="quote-author">- Doc Rey</p>
        </div>
      </div>
    </div>

    <!-- Right Side - Login Form -->
    <div class="form-section">
      <!-- Logos moved outside the form box -->
      <div class="logos-container-top">
        <div class="logo-item">
          <img :src="cfasLogoPath" alt="CFAS Logo" class="logo-image" />
        </div>
        <div class="logo-divider"></div>
        <div class="logo-item">
          <img :src="reviewHubLogoPath" alt="Review Hub Logo" class="logo-image" />
        </div>
      </div>

      <div class="form-container">
        <div class="form-header">
          <h2 class="form-title">Sign in</h2>
          <p class="form-subtitle">Enter your credentials to access your account</p>
        </div>

        <form @submit.prevent="handleLogin" class="login-form">
          <div class="input-group">
            <label for="username" class="input-label">Username</label>
            <div class="input-wrapper">
              <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
              </svg>
              <input 
                id="username" 
                v-model="username" 
                type="text" 
                required 
                autocomplete="username"
                placeholder="Enter username"
                :disabled="loading"
                class="form-input"
              />
            </div>
          </div>

          <div class="input-group">
            <label for="password" class="input-label">Password</label>
            <div class="input-wrapper">
              <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
              </svg>
              <input 
                id="password" 
                v-model="password" 
                :type="showPassword ? 'text' : 'password'" 
                required 
                autocomplete="current-password"
                placeholder="Enter password"
                :disabled="loading"
                class="form-input"
              />
              <button 
                type="button" 
                @click="togglePasswordVisibility" 
                class="password-toggle"
                :disabled="loading"
              >
                <svg v-if="showPassword" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <path d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                </svg>
                <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <path d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                  <path d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                </svg>
              </button>
            </div>
          </div>

          <transition name="alert-slide">
            <p v-if="error" class="inline-error-message">{{ error }}</p>
          </transition>

          <button type="submit" class="submit-button" :disabled="loading">
            <span v-if="loading" class="button-spinner"></span>
            <span v-else class="button-content">
              <span>Continue</span>
              <svg class="button-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M13 7l5 5m0 0l-5 5m5-5H6" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
              </svg>
            </span>
          </button>
        </form>

        <div class="form-footer">
          <p class="footer-text">
            By signing in, you agree to our 
            <a href="#" class="footer-link">Terms of Service</a> and 
            <a href="#" class="footer-link">Privacy Policy</a>
          </p>
        </div>
      </div>
    </div>
    <transition name="status-modal">
      <div v-if="showStatusModal" class="auth-modal-overlay" @click.self="closeStatusModal">
        <div class="auth-modal-card">
          <div class="auth-modal-icon" :class="`is-${statusModalState}`">
            <div v-if="statusModalState === 'loading'" class="auth-modal-spinner"></div>
            <svg v-else-if="statusModalState === 'success'" viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
            </svg>
            <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
            </svg>
          </div>
          <h3 class="auth-modal-title">{{ statusModalTitle }}</h3>
          <p class="auth-modal-message">{{ statusModalMessage }}</p>
          <button v-if="statusModalState === 'error'" type="button" class="auth-modal-button" @click="closeStatusModal">
            Try Again
          </button>
        </div>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, computed, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { getPublicAssetPath } from '@/utils/assetPath'

const router = useRouter()
const authStore = useAuthStore()

const username = ref('')
const password = ref('')
const error = ref(null)
const loading = ref(false)
const showPassword = ref(false)
const showStatusModal = ref(false)
const statusModalState = ref('loading')
const statusModalTitle = ref('')
const statusModalMessage = ref('')

const palerImagePath = computed(() => getPublicAssetPath('PalerImageFrontEndLogin.jpg'))
const cfasLogoPath = computed(() => getPublicAssetPath('cfas-logo.jpg'))
const reviewHubLogoPath = computed(() => getPublicAssetPath('review-hub-logo.png'))
const isufstLogoPath = computed(() => getPublicAssetPath('ISUFST-logo-PNG-1-1024x712-800x550.png'))

let redirectTimeout = null

const togglePasswordVisibility = () => {
  showPassword.value = !showPassword.value
}

const setStatusModal = (state, title, message) => {
  statusModalState.value = state
  statusModalTitle.value = title
  statusModalMessage.value = message
  showStatusModal.value = true
}

const closeStatusModal = () => {
  if (loading.value || statusModalState.value === 'success') {
    return
  }
  showStatusModal.value = false
}

const clearLoginTimers = () => {
  if (redirectTimeout) {
    clearTimeout(redirectTimeout)
    redirectTimeout = null
  }
}

const handleLogin = async () => {
  clearLoginTimers()
  error.value = null
  loading.value = true
  setStatusModal('loading', 'Signing in', 'Please wait while we verify your account.')
  
  const result = await authStore.login(username.value, password.value)
  
  loading.value = false
  
  if (result.success) {
    setStatusModal('success', 'Success', 'Login complete. Opening your dashboard...')

    redirectTimeout = setTimeout(() => {
      showStatusModal.value = false
      clearLoginTimers()
      if (authStore.user?.role === 'admin') {
        router.push('/admin')
      } else {
        router.push('/exams')
      }
    }, 2000)
  } else {
    const loginErrorMessage = result.error || 'Wrong username or password. Try again.'
    error.value = loginErrorMessage
    setStatusModal('error', 'Sign in failed', loginErrorMessage)
    password.value = ''

    const inputs = document.querySelectorAll('.form-input')
    inputs.forEach(input => {
      input.classList.add('shake')
      setTimeout(() => input.classList.remove('shake'), 500)
    })
  }
}

onUnmounted(() => {
  showStatusModal.value = false
  clearLoginTimers()
})
</script>

<style scoped>
* {
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

.login-page {
  display: flex;
  min-height: 100vh;
  background: #F5F5F7;
  position: relative;
}

.login-page::before {
  content: '';
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-image: var(--bg-image);
  background-size: 50%;
  background-position: center;
  background-repeat: no-repeat;
  opacity: 0.15;
  pointer-events: none;
  z-index: 0;
}

.brand-section {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 60px 30px 60px 40px;
  background: transparent;
  position: relative;
  overflow: hidden;
  z-index: 1;
}

.brand-section::before {
  content: '';
  position: absolute;
  top: -50%;
  right: -50%;
  width: 100%;
  height: 100%;
  background: radial-gradient(circle, rgba(0, 122, 255, 0.02) 0%, transparent 70%);
  animation: float 20s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translate(0, 0) rotate(0deg); }
  50% { transform: translate(-30px, -30px) rotate(5deg); }
}

.brand-content {
  width: 100%;
  max-width: 100%;
  position: relative;
  z-index: 1;
}

/* Photo Container */
.photo-container {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0;
  background: rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(10px);
  border-radius: 24px;
  border: 1px solid rgba(0, 0, 0, 0.06);
  margin-bottom: 32px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  overflow: hidden;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.06);
  width: 440px;
  height: 600px;
  margin-left: auto;
  margin-right: auto;
}

.photo-container:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
}

.photo-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #F5F5F7 0%, #E8E8ED 100%);
}

.photo-placeholder svg {
  width: 200px;
  height: 200px;
  color: #D2D2D7;
  stroke-width: 1.5;
}

.cfas-logo-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 24px;
}

/* Quote Section */
.quote-section {
  position: relative;
  padding: 56px 48px;
  background: rgba(255, 255, 255, 0.6);
  backdrop-filter: blur(10px);
  border-radius: 20px;
  border: 1px solid rgba(0, 0, 0, 0.04);
  text-align: center;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.06);
}

.quote-text {
  font-size: 42px;
  font-weight: 700;
  color: #1D1D1F;
  margin: 0 0 24px 0;
  letter-spacing: -1px;
  line-height: 1.3;
  font-style: italic;
  font-family: Georgia, 'Times New Roman', serif;
}

.quote-author {
  font-size: 24px;
  font-weight: 600;
  color: #007AFF;
  margin: 0;
  letter-spacing: -0.4px;
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
}

.brand-features {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.feature-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px 20px;
  background: rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(10px);
  border-radius: 14px;
  border: 1px solid rgba(0, 0, 0, 0.04);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.feature-item:hover {
  background: rgba(255, 255, 255, 0.8);
  transform: translateX(8px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.06);
}

.feature-icon {
  width: 24px;
  height: 24px;
  color: #007AFF;
  stroke-width: 2;
  flex-shrink: 0;
}

.feature-item span {
  font-size: 15px;
  font-weight: 500;
  color: #1D1D1F;
  letter-spacing: -0.2px;
}

.form-section {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 40px 80px 30px;
  background: transparent;
  position: relative;
  z-index: 1;
}

.form-container {
  width: 100%;
  max-width: 580px;
  margin-top: 0px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 24px;
  padding: 48px 56px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(0, 0, 0, 0.06);
}

.auth-modal-overlay {
  position: fixed;
  inset: 0;
  z-index: 1400;
  background: rgba(15, 23, 42, 0.12);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
}

.auth-modal-card {
  width: 100%;
  max-width: 430px;
  background: #FFFFFF;
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 28px;
  box-shadow: 0 24px 48px rgba(0, 0, 0, 0.15);
  padding: 32px 28px;
  text-align: center;
  transform: translateY(0);
}

.auth-modal-icon {
  width: 76px;
  height: 76px;
  border-radius: 50%;
  margin: 0 auto 18px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.auth-modal-icon.is-loading {
  background: rgba(0, 122, 255, 0.12);
}

.auth-modal-icon.is-success {
  background: rgba(52, 199, 89, 0.12);
}

.auth-modal-icon.is-error {
  background: rgba(255, 59, 48, 0.12);
}

.auth-modal-spinner {
  width: 34px;
  height: 34px;
  border: 3px solid rgba(0, 122, 255, 0.24);
  border-top-color: #007AFF;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

.auth-modal-icon svg {
  width: 40px;
  height: 40px;
  stroke-width: 2.2;
}

.auth-modal-icon.is-success svg {
  color: #34C759;
}

.auth-modal-icon.is-error svg {
  color: #FF3B30;
}

.auth-modal-title {
  margin: 0 0 8px;
  font-size: 30px;
  font-weight: 700;
  color: #1D1D1F;
  letter-spacing: -0.8px;
}

.auth-modal-message {
  margin: 0;
  font-size: 15px;
  line-height: 1.55;
  color: #6E6E73;
}

.auth-modal-button {
  margin-top: 18px;
  width: 100%;
  border: none;
  border-radius: 14px;
  background: #007AFF;
  color: #FFFFFF;
  font-size: 15px;
  font-weight: 600;
  padding: 12px 16px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.auth-modal-button:hover {
  background: #0051D5;
}

.status-modal-enter-active,
.status-modal-leave-active {
  transition: opacity 0.22s ease;
}

.status-modal-enter-from,
.status-modal-leave-to {
  opacity: 0;
}

.status-modal-enter-active .auth-modal-card,
.status-modal-leave-active .auth-modal-card {
  transition: transform 0.22s ease, opacity 0.22s ease;
}

.status-modal-enter-from .auth-modal-card,
.status-modal-leave-to .auth-modal-card {
  transform: translateY(10px) scale(0.98);
  opacity: 0;
}

.inline-error-message {
  margin: -8px 2px 0;
  color: #FF3B30;
  font-size: 14px;
  font-weight: 500;
}

/* Logos outside the form box */
.logos-container-top {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 56px;
  margin-bottom: 48px;
  padding: 0;
  background: transparent;
  backdrop-filter: none;
  border-radius: 0;
  border: none;
  box-shadow: none;
}

.logos-container-top .logo-item {
  flex: 0 0 auto;
  display: flex;
  align-items: center;
  justify-content: center;
}

.logos-container-top .logo-image {
  width: 140px;
  height: 140px;
  object-fit: cover;
  filter: drop-shadow(0 6px 16px rgba(0, 0, 0, 0.12));
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  border-radius: 50%;
}

.logos-container-top .logo-image:hover {
  transform: scale(1.05);
  filter: drop-shadow(0 8px 20px rgba(0, 0, 0, 0.18));
}

.logos-container-top .logo-divider {
  width: 2px;
  height: 90px;
  background: linear-gradient(to bottom, transparent, rgba(0, 0, 0, 0.15), transparent);
}

.form-header {
  margin-bottom: 36px;
}

.form-title {
  font-size: 42px;
  font-weight: 700;
  color: #1D1D1F;
  margin: 0 0 10px 0;
  letter-spacing: -1px;
}

.form-subtitle {
  font-size: 18px;
  font-weight: 400;
  color: #86868B;
  margin: 0;
  letter-spacing: -0.3px;
}

.alert-message {
  display: flex;
  align-items: flex-start;
  gap: 14px;
  padding: 18px 22px;
  border-radius: 14px;
  margin-bottom: 32px;
  font-size: 15px;
  font-weight: 500;
  letter-spacing: -0.2px;
  border: 1px solid;
  animation: slideDown 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.error-alert {
  background: rgba(255, 59, 48, 0.08);
  border-color: rgba(255, 59, 48, 0.2);
  color: #FF3B30;
}

.success-alert {
  background: rgba(52, 199, 89, 0.08);
  border-color: rgba(52, 199, 89, 0.2);
  color: #34C759;
}

.alert-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.alert-title {
  font-weight: 600;
  font-size: 16px;
  display: block;
}

.alert-text {
  font-weight: 400;
  font-size: 14px;
  opacity: 0.9;
  display: block;
}

.alert-spinner {
  width: 20px;
  height: 20px;
  border: 2px solid rgba(52, 199, 89, 0.3);
  border-top-color: #34C759;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  flex-shrink: 0;
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.alert-icon {
  width: 22px;
  height: 22px;
  stroke-width: 2;
  flex-shrink: 0;
}

.alert-slide-enter-active,
.alert-slide-leave-active {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.alert-slide-enter-from {
  opacity: 0;
  transform: translateY(-10px);
}

.alert-slide-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 28px;
  margin-bottom: 32px;
}

.input-group {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.input-label {
  font-size: 16px;
  font-weight: 600;
  color: #1D1D1F;
  letter-spacing: -0.3px;
}

.input-wrapper {
  position: relative;
}

.input-icon {
  position: absolute;
  left: 18px;
  top: 50%;
  transform: translateY(-50%);
  width: 22px;
  height: 22px;
  color: #86868B;
  stroke-width: 2;
  pointer-events: none;
  transition: color 0.2s ease;
}

.password-toggle {
  position: absolute;
  right: 18px;
  top: 50%;
  transform: translateY(-50%);
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: transparent;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
  padding: 0;
}

.password-toggle svg {
  width: 22px;
  height: 22px;
  color: #86868B;
  stroke-width: 2;
  transition: color 0.2s ease;
}

.password-toggle:hover:not(:disabled) {
  background: rgba(0, 0, 0, 0.04);
}

.password-toggle:hover:not(:disabled) svg {
  color: #007AFF;
}

.password-toggle:active:not(:disabled) {
  transform: translateY(-50%) scale(0.95);
}

.password-toggle:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.form-input {
  width: 100%;
  padding: 18px 18px 18px 54px;
  font-size: 18px;
  font-weight: 400;
  color: #1D1D1F;
  background: #FFFFFF;
  border: 2px solid #D2D2D7;
  border-radius: 14px;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  letter-spacing: -0.3px;
}

.form-input::placeholder {
  color: #86868B;
}

.form-input:hover {
  border-color: #86868B;
}

.form-input:focus {
  outline: none;
  border-color: #007AFF;
  box-shadow: 0 0 0 4px rgba(0, 122, 255, 0.1);
}

.input-wrapper:focus-within .input-icon {
  color: #007AFF;
}

.form-input:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Shake animation for error */
@keyframes shake {
  0%, 100% { transform: translateX(0); }
  10%, 30%, 50%, 70%, 90% { transform: translateX(-8px); }
  20%, 40%, 60%, 80% { transform: translateX(8px); }
}

.form-input.shake {
  animation: shake 0.5s cubic-bezier(0.36, 0.07, 0.19, 0.97);
  border-color: #FF3B30;
}

.submit-button {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  padding: 20px 28px;
  margin-top: 12px;
  font-size: 19px;
  font-weight: 600;
  color: #FFFFFF;
  background: #007AFF;
  border: none;
  border-radius: 14px;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  letter-spacing: -0.4px;
  box-shadow: 0 4px 12px rgba(0, 122, 255, 0.3);
}

.submit-button:hover:not(:disabled) {
  background: #0051D5;
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0, 122, 255, 0.4);
}

.submit-button:active:not(:disabled) {
  transform: translateY(0);
  box-shadow: 0 4px 12px rgba(0, 122, 255, 0.3);
}

.submit-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.button-content {
  display: flex;
  align-items: center;
  gap: 10px;
}

.button-arrow {
  width: 22px;
  height: 22px;
  stroke-width: 2.5;
  transition: transform 0.2s ease;
}

.submit-button:hover:not(:disabled) .button-arrow {
  transform: translateX(4px);
}

.button-spinner {
  width: 22px;
  height: 22px;
  border: 3px solid rgba(255, 255, 255, 0.3);
  border-top-color: #FFFFFF;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.form-footer {
  padding-top: 28px;
  border-top: 1px solid #E5E5EA;
}

.footer-text {
  font-size: 14px;
  font-weight: 400;
  color: #86868B;
  text-align: center;
  margin: 0;
  line-height: 1.6;
  letter-spacing: -0.1px;
}

.footer-link {
  color: #007AFF;
  text-decoration: none;
  font-weight: 500;
  transition: color 0.2s ease;
}

.footer-link:hover {
  color: #0051D5;
  text-decoration: underline;
}

@media (max-width: 1200px) {
  .brand-section,
  .form-section {
    padding: 60px 40px;
  }

  .brand-name {
    font-size: 40px;
  }

  .form-title {
    font-size: 36px;
  }
}

@media (max-width: 1024px) {
  .login-page {
    flex-direction: column;
  }

  .brand-section {
    padding: 60px 40px;
  }

  .logos-container-top {
    gap: 20px;
    padding: 20px;
    margin-bottom: 32px;
  }

  .logos-container-top .logo-image {
    width: 70px;
    height: 70px;
  }

  .logos-container-top .logo-divider {
    height: 50px;
  }

  .photo-placeholder {
    padding: 80px 40px;
    min-height: 300px;
  }

  .form-section {
    padding: 60px 40px;
  }
}

@media (max-width: 768px) {
  .auth-modal-card {
    max-width: 100%;
    padding: 28px 20px;
    border-radius: 22px;
  }

  .auth-modal-title {
    font-size: 25px;
  }

  .brand-section,
  .form-section {
    padding: 40px 24px;
  }

  .logos-container-top {
    flex-direction: column;
    gap: 16px;
    padding: 20px;
    margin-bottom: 24px;
  }

  .logos-container-top .logo-divider {
    width: 60px;
    height: 1px;
    background: linear-gradient(to right, transparent, rgba(0, 0, 0, 0.1), transparent);
  }

  .logos-container-top .logo-image {
    width: 60px;
    height: 60px;
  }

  .photo-container {
    width: 100%;
    height: 400px;
    margin-bottom: 24px;
  }

  .photo-placeholder {
    padding: 60px 30px;
    min-height: 250px;
  }

  .photo-placeholder svg {
    width: 120px;
    height: 120px;
  }

  .quote-section {
    padding: 32px 24px;
  }

  .quote-text {
    font-size: 28px;
  }

  .quote-author {
    font-size: 18px;
  }

  .form-container {
    padding: 32px 24px;
    border-radius: 20px;
  }

  .form-title {
    font-size: 28px;
  }

  .form-subtitle {
    font-size: 16px;
  }

  .form-input {
    padding: 16px 16px 16px 50px;
    font-size: 16px;
  }

  .submit-button {
    padding: 16px 24px;
    font-size: 17px;
  }

  .feature-item {
    padding: 14px 16px;
  }

  .feature-item span {
    font-size: 14px;
  }
}

@media (max-width: 480px) {
  .brand-section,
  .form-section {
    padding: 24px 16px;
  }

  .logos-container-top {
    padding: 16px;
    margin-bottom: 20px;
  }

  .logos-container-top .logo-image {
    width: 50px;
    height: 50px;
  }

  .photo-container {
    height: 300px;
    border-radius: 16px;
  }

  .quote-section {
    padding: 24px 20px;
    border-radius: 16px;
  }

  .quote-text {
    font-size: 22px;
  }

  .quote-author {
    font-size: 16px;
  }

  .form-container {
    padding: 24px 20px;
    border-radius: 16px;
  }

  .form-title {
    font-size: 24px;
  }

  .form-subtitle {
    font-size: 14px;
  }

  .login-form {
    gap: 20px;
  }

  .input-label {
    font-size: 14px;
  }

  .form-input {
    padding: 14px 14px 14px 46px;
    font-size: 15px;
    border-radius: 12px;
  }

  .input-icon {
    left: 14px;
    width: 20px;
    height: 20px;
  }

  .password-toggle {
    right: 14px;
    width: 36px;
    height: 36px;
  }

  .password-toggle svg {
    width: 20px;
    height: 20px;
  }

  .submit-button {
    padding: 14px 20px;
    font-size: 16px;
    border-radius: 12px;
  }

  .button-arrow,
  .button-spinner {
    width: 20px;
    height: 20px;
  }

  .alert-message {
    padding: 14px 16px;
    font-size: 14px;
  }

  .auth-modal-card {
    padding: 24px 16px;
    border-radius: 20px;
  }

  .auth-modal-icon {
    width: 64px;
    height: 64px;
  }

  .auth-modal-icon svg {
    width: 32px;
    height: 32px;
  }

  .auth-modal-title {
    font-size: 22px;
  }

  .auth-modal-message {
    font-size: 14px;
  }
}
</style>
