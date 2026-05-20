import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import api from '@/services/api'

const AUTH_TOKEN_KEY = 'auth_token'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const hasSession = ref(false)
  
  const isAuthenticated = computed(() => hasSession.value && !!user.value)
  
  const login = async (username, password) => {
    try {
      const response = await api.post('/auth/login', { username, password })
      user.value = response.data.data.user
      const token = response.data?.data?.token
      if (token) {
        localStorage.setItem(AUTH_TOKEN_KEY, token)
      }
      hasSession.value = true
      return { success: true }
    } catch (error) {
      const status = error.response?.status
      const backendMessage = error.response?.data?.message
      const validationErrors = error.response?.data?.errors
      const firstValidationError = validationErrors
        ? Object.values(validationErrors).flat()[0]
        : null

      let message = 'Unable to sign in right now. Please try again.'

      if (!error.response) {
        message = 'Cannot reach server. Check your internet connection and try again.'
      } else if (status === 401) {
        message = 'Wrong username or password. Please try again.'
      } else if (typeof backendMessage === 'string' && backendMessage.toLowerCase().includes('invalid')) {
        message = 'Wrong username or password. Please try again.'
      } else if (status === 422) {
        message = firstValidationError || 'Please fill in both username and password.'
      } else if (status >= 500) {
        message = 'Server error occurred. Please try again in a moment.'
      } else if (backendMessage) {
        message = backendMessage
      }

      return { success: false, error: message, status }
    }
  }
  
  const logout = async () => {
    try {
      await api.post('/auth/logout')
    } catch (error) {
      console.error('Logout error:', error)
    } finally {
      localStorage.removeItem(AUTH_TOKEN_KEY)
      hasSession.value = false
      user.value = null
    }
  }
  
  const validateSession = async () => {
    try {
      const response = await api.get('/auth/validate')
      user.value = response.data.user
      hasSession.value = true
      return true
    } catch (error) {
      // Only clear session if it's a 401 (Unauthorized) error
      // Don't logout for network errors or other temporary issues
      if (error.response?.status === 401) {
        localStorage.removeItem(AUTH_TOKEN_KEY)
        hasSession.value = false
        user.value = null
        return false
      }
      
      // For other errors (network, timeout, 500, etc.), keep the session
      // The user is still logged in, just the validation request failed
      console.warn('Session validation failed, but keeping session:', error.message)
      return hasSession.value // Return current session state
    }
  }

  const changePassword = async (currentPassword, newPassword, newPasswordConfirmation) => {
    try {
      await api.post('/auth/change-password', {
        current_password: currentPassword,
        new_password: newPassword,
        new_password_confirmation: newPasswordConfirmation
      })
      
      // Update user object to reflect password change
      if (user.value) {
        user.value.require_password_change = false
      }
      
      return { success: true }
    } catch (error) {
      return { 
        success: false, 
        error: error.response?.data?.message || error.response?.data?.errors?.new_password?.[0] || 'Password change failed' 
      }
    }
  }
  
  return {
    user,
    hasSession,
    isAuthenticated,
    login,
    logout,
    validateSession,
    changePassword
  }
})
