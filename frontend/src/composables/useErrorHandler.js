import { ref } from 'vue'

export function useErrorHandler() {
  const error = ref(null)
  const isError = ref(false)
  
  const handleError = (err, context = '') => {
    console.error(`Error in ${context}:`, err)
    error.value = err.response?.data?.message || err.message || 'An unexpected error occurred'
    isError.value = true
    
    // Auto-clear error after 5 seconds
    setTimeout(() => {
      clearError()
    }, 5000)
  }
  
  const clearError = () => {
    error.value = null
    isError.value = false
  }
  
  const saveToLocalStorage = (key, data) => {
    try {
      localStorage.setItem(key, JSON.stringify(data))
      return true
    } catch (err) {
      console.error('Failed to save to localStorage:', err)
      return false
    }
  }
  
  const loadFromLocalStorage = (key) => {
    try {
      const data = localStorage.getItem(key)
      return data ? JSON.parse(data) : null
    } catch (err) {
      console.error('Failed to load from localStorage:', err)
      return null
    }
  }
  
  return {
    error,
    isError,
    handleError,
    clearError,
    saveToLocalStorage,
    loadFromLocalStorage
  }
}
