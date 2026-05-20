import { ref, onUnmounted, watch, unref, computed as vueComputed, isRef } from 'vue'

export function useTimer(initialSeconds) {
  // Handle both raw values and computed refs
  const getInitialValue = () => {
    if (isRef(initialSeconds)) {
      return unref(initialSeconds) || 3600
    }
    return initialSeconds || 3600
  }
  
  const remainingTime = ref(getInitialValue())
  const isRunning = ref(false)
  let intervalId = null
  
  const startTimer = () => {
    if (isRunning.value) return
    
    isRunning.value = true
    intervalId = setInterval(() => {
      remainingTime.value--
      if (remainingTime.value <= 0) {
        stopTimer()
      }
    }, 1000)
  }
  
  const stopTimer = () => {
    isRunning.value = false
    if (intervalId) {
      clearInterval(intervalId)
      intervalId = null
    }
  }
  
  const resetTimer = (newSeconds) => {
    stopTimer()
    const value = newSeconds !== undefined ? newSeconds : getInitialValue()
    remainingTime.value = value
  }
  
  // Watch for changes in initialSeconds if it's a ref
  if (isRef(initialSeconds)) {
    watch(initialSeconds, (newValue) => {
      if (newValue && !isRunning.value) {
        remainingTime.value = newValue
      }
    })
  }
  
  const formatTime = (seconds) => {
    const hours = Math.floor(seconds / 3600)
    const minutes = Math.floor((seconds % 3600) / 60)
    const secs = seconds % 60
    
    if (hours > 0) {
      return `${hours}:${String(minutes).padStart(2, '0')}:${String(secs).padStart(2, '0')}`
    }
    return `${minutes}:${String(secs).padStart(2, '0')}`
  }
  
  onUnmounted(() => {
    stopTimer()
  })
  
  return {
    remainingTime,
    isRunning,
    startTimer,
    stopTimer,
    resetTimer,
    formatTime
  }
}
