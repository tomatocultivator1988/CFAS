<template>
  <div class="modal-overlay">
    <!-- Animated background particles -->
    <div class="particles">
      <div class="particle" v-for="i in 20" :key="i" :style="getParticleStyle(i)"></div>
    </div>

    <div class="modal-container">
      <!-- Lock icon with animation -->
      <div class="icon-container">
        <div class="lock-icon">
          <svg width="64" height="64" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path class="lock-body" d="M19 11H5C3.89543 11 3 11.8954 3 13V20C3 21.1046 3.89543 22 5 22H19C20.1046 22 21 21.1046 21 20V13C21 11.8954 20.1046 11 19 11Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            <path class="lock-shackle" d="M7 11V7C7 5.67392 7.52678 4.40215 8.46447 3.46447C9.40215 2.52678 10.6739 2 12 2C13.3261 2 14.5979 2.52678 15.5355 3.46447C16.4732 4.40215 17 5.67392 17 7V11" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            <circle class="lock-keyhole" cx="12" cy="16" r="1.5" fill="currentColor"/>
          </svg>
        </div>
        <div class="icon-glow"></div>
      </div>

      <div class="modal-header">
        <h2>🔐 Secure Your Account</h2>
        <p class="subtitle">Create a strong password to protect your account</p>
        <div class="security-badge">
          <span class="badge-icon">🛡️</span>
          <span class="badge-text">First Time Login</span>
        </div>
      </div>

      <form @submit.prevent="handleSubmit" class="password-form">
        <div class="form-group" :class="{ 'has-value': formData.current_password }">
          <label for="current_password">
            <span class="label-icon">🔑</span>
            Current Password
          </label>
          <div class="input-wrapper">
            <input
              id="current_password"
              v-model="formData.current_password"
              :type="showCurrentPassword ? 'text' : 'password'"
              placeholder="Enter current password"
              required
            />
            <button 
              type="button" 
              class="toggle-password"
              @click="showCurrentPassword = !showCurrentPassword"
            >
              {{ showCurrentPassword ? '👁️' : '👁️‍🗨️' }}
            </button>
          </div>
        </div>

        <div class="form-group" :class="{ 'has-value': formData.new_password, 'is-valid': isPasswordValid }">
          <label for="new_password">
            <span class="label-icon">✨</span>
            New Password
          </label>
          <div class="input-wrapper">
            <input
              id="new_password"
              v-model="formData.new_password"
              :type="showNewPassword ? 'text' : 'password'"
              placeholder="Enter new password (min 6 characters)"
              required
              minlength="6"
              @input="checkPasswordStrength"
            />
            <button 
              type="button" 
              class="toggle-password"
              @click="showNewPassword = !showNewPassword"
            >
              {{ showNewPassword ? '👁️' : '👁️‍🗨️' }}
            </button>
          </div>
          
          <!-- Password strength indicator -->
          <div v-if="formData.new_password" class="password-strength">
            <div class="strength-bar">
              <div class="strength-fill" :class="passwordStrength.class" :style="{ width: passwordStrength.width }"></div>
            </div>
            <p class="strength-text" :class="passwordStrength.class">{{ passwordStrength.text }}</p>
          </div>

          <div class="password-requirements">
            <div class="requirement" :class="{ 'met': formData.new_password.length >= 6 }">
              <span class="check-icon">{{ formData.new_password.length >= 6 ? '✓' : '○' }}</span>
              At least 6 characters
            </div>
            <div class="requirement" :class="{ 'met': formData.new_password !== 'password123' && formData.new_password !== '' }">
              <span class="check-icon">{{ formData.new_password !== 'password123' && formData.new_password !== '' ? '✓' : '○' }}</span>
              Not the default password
            </div>
          </div>
        </div>

        <div class="form-group" :class="{ 'has-value': formData.new_password_confirmation, 'is-valid': passwordsMatch }">
          <label for="new_password_confirmation">
            <span class="label-icon">🔒</span>
            Confirm New Password
          </label>
          <div class="input-wrapper">
            <input
              id="new_password_confirmation"
              v-model="formData.new_password_confirmation"
              :type="showConfirmPassword ? 'text' : 'password'"
              placeholder="Confirm new password"
              required
            />
            <button 
              type="button" 
              class="toggle-password"
              @click="showConfirmPassword = !showConfirmPassword"
            >
              {{ showConfirmPassword ? '👁️' : '👁️‍🗨️' }}
            </button>
          </div>
          <p v-if="formData.new_password_confirmation && passwordsMatch" class="match-indicator success">
            ✓ Passwords match!
          </p>
          <p v-else-if="formData.new_password_confirmation && !passwordsMatch" class="match-indicator error">
            ✗ Passwords don't match
          </p>
        </div>

        <div v-if="error" class="error-message">
          <span class="error-icon">⚠️</span>
          {{ error }}
        </div>

        <div class="form-actions">
          <button type="submit" class="btn btn-primary" :disabled="loading || !canSubmit">
            <span v-if="loading" class="spinner"></span>
            <span v-else class="btn-content">
              <span class="btn-icon">🚀</span>
              <span>Change Password</span>
            </span>
          </button>
        </div>

        <div class="security-note">
          <span class="note-icon">💡</span>
          <p>Choose a password you'll remember but others can't guess</p>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useAuthStore } from '@/stores/auth'

const emit = defineEmits(['password-changed'])

const authStore = useAuthStore()

const formData = ref({
  current_password: '',
  new_password: '',
  new_password_confirmation: ''
})

const loading = ref(false)
const error = ref(null)
const showCurrentPassword = ref(false)
const showNewPassword = ref(false)
const showConfirmPassword = ref(false)

const passwordsMatch = computed(() => {
  return formData.value.new_password === formData.value.new_password_confirmation && 
         formData.value.new_password_confirmation !== ''
})

const isPasswordValid = computed(() => {
  return formData.value.new_password.length >= 6 && 
         formData.value.new_password !== 'password123'
})

const canSubmit = computed(() => {
  return formData.value.current_password !== '' &&
         isPasswordValid.value &&
         passwordsMatch.value &&
         !loading.value
})

const passwordStrength = computed(() => {
  const password = formData.value.new_password
  if (!password) return { width: '0%', class: '', text: '' }
  
  let strength = 0
  if (password.length >= 6) strength++
  if (password.length >= 8) strength++
  if (/[A-Z]/.test(password)) strength++
  if (/[0-9]/.test(password)) strength++
  if (/[^A-Za-z0-9]/.test(password)) strength++
  
  if (strength <= 1) return { width: '25%', class: 'weak', text: 'Weak' }
  if (strength === 2) return { width: '50%', class: 'fair', text: 'Fair' }
  if (strength === 3) return { width: '75%', class: 'good', text: 'Good' }
  return { width: '100%', class: 'strong', text: 'Strong' }
})

const checkPasswordStrength = () => {
  // Trigger reactivity
  passwordStrength.value
}

const getParticleStyle = (index) => {
  const size = Math.random() * 4 + 2
  const duration = Math.random() * 20 + 15
  const delay = Math.random() * 5
  const left = Math.random() * 100
  
  return {
    width: `${size}px`,
    height: `${size}px`,
    left: `${left}%`,
    animationDuration: `${duration}s`,
    animationDelay: `${delay}s`
  }
}

const handleSubmit = async () => {
  error.value = null

  // Client-side validation
  if (formData.value.new_password !== formData.value.new_password_confirmation) {
    error.value = 'Passwords do not match'
    return
  }

  if (formData.value.new_password.length < 6) {
    error.value = 'Password must be at least 6 characters'
    return
  }

  if (formData.value.new_password === 'password123') {
    error.value = 'You cannot use the default password'
    return
  }

  loading.value = true

  const result = await authStore.changePassword(
    formData.value.current_password,
    formData.value.new_password,
    formData.value.new_password_confirmation
  )

  loading.value = false

  if (result.success) {
    emit('password-changed')
  } else {
    error.value = result.error
  }
}
</script>

<style scoped>
* {
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(10px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  padding: 20px;
}

.modal-container {
  background: #FFFFFF;
  border-radius: 20px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  max-width: 500px;
  width: 100%;
  padding: 40px;
  animation: slideUp 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.modal-header {
  margin-bottom: 32px;
  text-align: center;
}

.modal-header h2 {
  font-size: 28px;
  font-weight: 700;
  color: #1D1D1F;
  margin: 0 0 8px 0;
  letter-spacing: -0.6px;
}

.subtitle {
  font-size: 15px;
  color: #86868B;
  margin: 0;
  font-weight: 400;
  letter-spacing: -0.2px;
}

.password-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-group label {
  font-size: 14px;
  font-weight: 600;
  color: #1D1D1F;
  letter-spacing: -0.2px;
}

.form-group input {
  padding: 14px 16px;
  border: 1px solid rgba(0, 0, 0, 0.1);
  border-radius: 12px;
  font-size: 15px;
  color: #1D1D1F;
  background: #F5F5F7;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  letter-spacing: -0.2px;
}

.form-group input:focus {
  outline: none;
  border-color: #007AFF;
  background: #FFFFFF;
  box-shadow: 0 0 0 4px rgba(0, 122, 255, 0.1);
}

.field-hint {
  font-size: 13px;
  color: #86868B;
  margin: 0;
  letter-spacing: -0.1px;
}

.error-message {
  padding: 14px 16px;
  background: rgba(255, 59, 48, 0.1);
  border: 1px solid rgba(255, 59, 48, 0.2);
  border-radius: 12px;
  color: #FF3B30;
  font-size: 14px;
  font-weight: 500;
  letter-spacing: -0.2px;
}

.form-actions {
  margin-top: 12px;
}

.btn {
  width: 100%;
  padding: 16px 24px;
  border: none;
  border-radius: 12px;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  letter-spacing: -0.2px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.btn-primary {
  background: #007AFF;
  color: #FFFFFF;
  box-shadow: 0 4px 12px rgba(0, 122, 255, 0.3);
}

.btn-primary:hover:not(:disabled) {
  background: #0051D5;
  transform: translateY(-1px);
  box-shadow: 0 6px 16px rgba(0, 122, 255, 0.4);
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.spinner {
  width: 16px;
  height: 16px;
  border: 2px solid transparent;
  border-top-color: #FFFFFF;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

@media (max-width: 768px) {
  .modal-container {
    padding: 32px 24px;
  }

  .modal-header h2 {
    font-size: 24px;
  }
}
</style>


<style scoped>
* {
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, rgba(0, 122, 255, 0.1) 0%, rgba(88, 86, 214, 0.1) 100%);
  backdrop-filter: blur(20px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  padding: 20px;
  animation: fadeIn 0.4s ease-out;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

/* Animated particles */
.particles {
  position: absolute;
  width: 100%;
  height: 100%;
  overflow: hidden;
  pointer-events: none;
}

.particle {
  position: absolute;
  background: linear-gradient(135deg, #007AFF, #5856D6);
  border-radius: 50%;
  opacity: 0.3;
  animation: float linear infinite;
}

@keyframes float {
  0% {
    transform: translateY(100vh) rotate(0deg);
    opacity: 0;
  }
  10% {
    opacity: 0.3;
  }
  90% {
    opacity: 0.3;
  }
  100% {
    transform: translateY(-100px) rotate(360deg);
    opacity: 0;
  }
}

.modal-container {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(40px);
  border-radius: 28px;
  box-shadow: 
    0 30px 90px rgba(0, 0, 0, 0.2),
    0 0 0 1px rgba(255, 255, 255, 0.5) inset;
  max-width: 540px;
  width: 100%;
  padding: 48px;
  animation: slideUp 0.5s cubic-bezier(0.34, 1.56, 0.64, 1);
  position: relative;
  overflow: hidden;
}

.modal-container::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(90deg, #007AFF, #5856D6, #FF2D55, #FF9500);
  background-size: 200% 100%;
  animation: gradientShift 3s ease infinite;
}

@keyframes gradientShift {
  0%, 100% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(40px) scale(0.95);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

/* Lock icon */
.icon-container {
  position: relative;
  display: flex;
  justify-content: center;
  margin-bottom: 24px;
}

.lock-icon {
  width: 80px;
  height: 80px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #007AFF, #5856D6);
  border-radius: 20px;
  color: white;
  position: relative;
  z-index: 2;
  animation: lockPulse 2s ease-in-out infinite;
  box-shadow: 0 10px 30px rgba(0, 122, 255, 0.4);
}

@keyframes lockPulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.05); }
}

.lock-shackle {
  animation: shackleShake 3s ease-in-out infinite;
  transform-origin: center top;
}

@keyframes shackleShake {
  0%, 100% { transform: rotate(0deg); }
  25% { transform: rotate(-2deg); }
  75% { transform: rotate(2deg); }
}

.icon-glow {
  position: absolute;
  width: 100px;
  height: 100px;
  background: radial-gradient(circle, rgba(0, 122, 255, 0.3), transparent 70%);
  border-radius: 50%;
  animation: glowPulse 2s ease-in-out infinite;
  z-index: 1;
}

@keyframes glowPulse {
  0%, 100% { transform: scale(1); opacity: 0.5; }
  50% { transform: scale(1.2); opacity: 0.8; }
}

.modal-header {
  margin-bottom: 32px;
  text-align: center;
}

.modal-header h2 {
  font-size: 32px;
  font-weight: 800;
  background: linear-gradient(135deg, #1D1D1F, #007AFF);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin: 0 0 12px 0;
  letter-spacing: -1px;
  animation: titleSlide 0.6s ease-out 0.2s both;
}

@keyframes titleSlide {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.subtitle {
  font-size: 16px;
  color: #86868B;
  margin: 0 0 16px 0;
  font-weight: 400;
  letter-spacing: -0.2px;
  animation: titleSlide 0.6s ease-out 0.3s both;
}

.security-badge {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  background: linear-gradient(135deg, rgba(0, 122, 255, 0.1), rgba(88, 86, 214, 0.1));
  border: 1px solid rgba(0, 122, 255, 0.2);
  border-radius: 20px;
  font-size: 13px;
  font-weight: 600;
  color: #007AFF;
  animation: titleSlide 0.6s ease-out 0.4s both;
}

.badge-icon {
  font-size: 16px;
  animation: badgeBounce 2s ease-in-out infinite;
}

@keyframes badgeBounce {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-3px); }
}

.password-form {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 10px;
  animation: formSlide 0.5s ease-out both;
}

.form-group:nth-child(1) { animation-delay: 0.5s; }
.form-group:nth-child(2) { animation-delay: 0.6s; }
.form-group:nth-child(3) { animation-delay: 0.7s; }

@keyframes formSlide {
  from {
    opacity: 0;
    transform: translateX(-20px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

.form-group label {
  font-size: 14px;
  font-weight: 700;
  color: #1D1D1F;
  letter-spacing: -0.2px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.label-icon {
  font-size: 18px;
  animation: iconSpin 3s ease-in-out infinite;
}

@keyframes iconSpin {
  0%, 100% { transform: rotate(0deg); }
  50% { transform: rotate(10deg); }
}

.input-wrapper {
  position: relative;
}

.form-group input {
  width: 100%;
  padding: 16px 50px 16px 18px;
  border: 2px solid rgba(0, 0, 0, 0.08);
  border-radius: 14px;
  font-size: 15px;
  color: #1D1D1F;
  background: #F9F9FB;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  letter-spacing: -0.2px;
  font-weight: 500;
}

.form-group input:focus {
  outline: none;
  border-color: #007AFF;
  background: #FFFFFF;
  box-shadow: 0 0 0 4px rgba(0, 122, 255, 0.1), 0 8px 20px rgba(0, 122, 255, 0.15);
  transform: translateY(-2px);
}

.form-group.has-value input {
  border-color: rgba(0, 122, 255, 0.3);
  background: #FFFFFF;
}

.form-group.is-valid input {
  border-color: #34C759;
  background: rgba(52, 199, 89, 0.05);
}

.toggle-password {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  font-size: 20px;
  cursor: pointer;
  padding: 8px;
  border-radius: 8px;
  transition: all 0.2s;
  opacity: 0.6;
}

.toggle-password:hover {
  opacity: 1;
  background: rgba(0, 0, 0, 0.05);
}

/* Password strength indicator */
.password-strength {
  margin-top: 8px;
}

.strength-bar {
  height: 6px;
  background: rgba(0, 0, 0, 0.06);
  border-radius: 10px;
  overflow: hidden;
  margin-bottom: 8px;
}

.strength-fill {
  height: 100%;
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  border-radius: 10px;
}

.strength-fill.weak {
  background: linear-gradient(90deg, #FF3B30, #FF6B6B);
}

.strength-fill.fair {
  background: linear-gradient(90deg, #FF9500, #FFCC00);
}

.strength-fill.good {
  background: linear-gradient(90deg, #007AFF, #5AC8FA);
}

.strength-fill.strong {
  background: linear-gradient(90deg, #34C759, #30D158);
}

.strength-text {
  font-size: 13px;
  font-weight: 600;
  margin: 0;
  letter-spacing: -0.1px;
}

.strength-text.weak { color: #FF3B30; }
.strength-text.fair { color: #FF9500; }
.strength-text.good { color: #007AFF; }
.strength-text.strong { color: #34C759; }

/* Password requirements */
.password-requirements {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-top: 8px;
}

.requirement {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: #86868B;
  transition: all 0.3s;
}

.requirement.met {
  color: #34C759;
  font-weight: 600;
}

.check-icon {
  font-size: 16px;
  font-weight: bold;
  transition: all 0.3s;
}

.requirement.met .check-icon {
  animation: checkPop 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}

@keyframes checkPop {
  0% { transform: scale(0); }
  50% { transform: scale(1.2); }
  100% { transform: scale(1); }
}

/* Match indicator */
.match-indicator {
  font-size: 13px;
  font-weight: 600;
  margin: 4px 0 0 0;
  display: flex;
  align-items: center;
  gap: 6px;
  animation: slideIn 0.3s ease-out;
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateX(-10px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

.match-indicator.success {
  color: #34C759;
}

.match-indicator.error {
  color: #FF3B30;
}

.error-message {
  padding: 16px 18px;
  background: linear-gradient(135deg, rgba(255, 59, 48, 0.1), rgba(255, 45, 85, 0.1));
  border: 2px solid rgba(255, 59, 48, 0.3);
  border-radius: 14px;
  color: #FF3B30;
  font-size: 14px;
  font-weight: 600;
  letter-spacing: -0.2px;
  display: flex;
  align-items: center;
  gap: 10px;
  animation: errorShake 0.5s ease-out;
}

@keyframes errorShake {
  0%, 100% { transform: translateX(0); }
  25% { transform: translateX(-10px); }
  75% { transform: translateX(10px); }
}

.error-icon {
  font-size: 20px;
  animation: errorPulse 1s ease-in-out infinite;
}

@keyframes errorPulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.1); }
}

.form-actions {
  margin-top: 8px;
}

.btn {
  width: 100%;
  padding: 18px 28px;
  border: none;
  border-radius: 14px;
  font-size: 16px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  letter-spacing: -0.3px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  position: relative;
  overflow: hidden;
}

.btn::before {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  width: 0;
  height: 0;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.3);
  transform: translate(-50%, -50%);
  transition: width 0.6s, height 0.6s;
}

.btn:hover::before {
  width: 300px;
  height: 300px;
}

.btn-primary {
  background: linear-gradient(135deg, #007AFF, #5856D6);
  color: #FFFFFF;
  box-shadow: 0 8px 24px rgba(0, 122, 255, 0.4);
}

.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 12px 32px rgba(0, 122, 255, 0.5);
}

.btn-primary:active:not(:disabled) {
  transform: translateY(0);
}

.btn-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none;
}

.btn-content {
  display: flex;
  align-items: center;
  gap: 10px;
  position: relative;
  z-index: 1;
}

.btn-icon {
  font-size: 20px;
  animation: rocketFloat 2s ease-in-out infinite;
}

@keyframes rocketFloat {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-4px); }
}

.spinner {
  width: 20px;
  height: 20px;
  border: 3px solid rgba(255, 255, 255, 0.3);
  border-top-color: #FFFFFF;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  position: relative;
  z-index: 1;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.security-note {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 16px;
  background: linear-gradient(135deg, rgba(255, 204, 0, 0.1), rgba(255, 149, 0, 0.1));
  border: 1px solid rgba(255, 204, 0, 0.3);
  border-radius: 14px;
  margin-top: 8px;
  animation: formSlide 0.5s ease-out 0.8s both;
}

.note-icon {
  font-size: 20px;
  flex-shrink: 0;
  animation: lightBulb 2s ease-in-out infinite;
}

@keyframes lightBulb {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.6; }
}

.security-note p {
  font-size: 13px;
  color: #86868B;
  margin: 0;
  line-height: 1.5;
  font-weight: 500;
}

@media (max-width: 768px) {
  .modal-container {
    padding: 36px 28px;
    border-radius: 24px;
  }

  .modal-header h2 {
    font-size: 26px;
  }

  .lock-icon {
    width: 70px;
    height: 70px;
  }

  .lock-icon svg {
    width: 56px;
    height: 56px;
  }
}
</style>
