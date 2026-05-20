import { ref, onUnmounted } from 'vue'

export function useSecurityMonitor(attemptId, reportCallback) {
  const resolveAttemptId = () => {
    if (typeof attemptId === 'function') {
      return attemptId()
    }
    return attemptId
  }

  const violationCount = ref(0)
  const isMonitoring = ref(false)
  const warnings = ref([])
  
  const startMonitoring = () => {
    if (isMonitoring.value) return
    
    isMonitoring.value = true
    window.addEventListener('blur', handleFocusLoss)
    window.addEventListener('keydown', handleProhibitedKey)
    
    // Disable right-click
    document.addEventListener('contextmenu', preventContextMenu)
    // Disable copy/paste
    document.addEventListener('copy', preventCopy)
    document.addEventListener('paste', preventPaste)
    document.addEventListener('cut', preventCut)
    // Disable text selection
    document.addEventListener('selectstart', preventSelection)
    
    // Apply CSS to prevent text selection
    document.body.style.userSelect = 'none'
    document.body.style.webkitUserSelect = 'none'
    document.body.style.msUserSelect = 'none'
  }
  
  const stopMonitoring = () => {
    isMonitoring.value = false
    window.removeEventListener('blur', handleFocusLoss)
    window.removeEventListener('keydown', handleProhibitedKey)
    document.removeEventListener('contextmenu', preventContextMenu)
    document.removeEventListener('copy', preventCopy)
    document.removeEventListener('paste', preventPaste)
    document.removeEventListener('cut', preventCut)
    document.removeEventListener('selectstart', preventSelection)
    
    // Restore CSS
    document.body.style.userSelect = ''
    document.body.style.webkitUserSelect = ''
    document.body.style.msUserSelect = ''
  }
  
  const handleFocusLoss = async () => {
    if (!isMonitoring.value) return
    await reportViolation('focus_loss')
  }
  
  const handleProhibitedKey = async (event) => {
    if (!isMonitoring.value) return
    
    // Detect Alt+Tab
    if (event.altKey && event.key === 'Tab') {
      event.preventDefault()
      await reportViolation('alt_tab')
    }
    
    // Detect other prohibited keys (F12, Ctrl+Shift+I, etc.)
    if (event.key === 'F12' || 
        (event.ctrlKey && event.shiftKey && event.key === 'I') ||
        (event.ctrlKey && event.shiftKey && event.key === 'J') ||
        (event.ctrlKey && event.key === 'U')) {
      event.preventDefault()
      await reportViolation('prohibited_key')
    }
  }
  
  const preventContextMenu = (e) => {
    e.preventDefault()
    return false
  }
  
  const preventCopy = (e) => {
    e.preventDefault()
    return false
  }
  
  const preventPaste = (e) => {
    e.preventDefault()
    return false
  }
  
  const preventCut = (e) => {
    e.preventDefault()
    return false
  }
  
  const preventSelection = (e) => {
    e.preventDefault()
    return false
  }
  
  const reportViolation = async (violationType) => {
    const activeAttemptId = resolveAttemptId()

    if (!reportCallback || !activeAttemptId) {
      console.error('No report callback or attempt ID provided')
      return { error: true }
    }
    
    try {
      const response = await reportCallback(activeAttemptId, violationType)
      
      if (response.success && response.data) {
        violationCount.value = response.data.violation_count || response.data.violationCount || violationCount.value + 1
      } else {
        violationCount.value++
      }
      
      // Add warning message
      const warningMessages = {
        focus_loss: 'Warning: Window focus lost. Please stay on the exam page.',
        alt_tab: 'Warning: Alt+Tab detected. Do not switch windows during the exam.',
        prohibited_key: 'Warning: Prohibited key detected. Developer tools are not allowed.'
      }
      
      warnings.value.push({
        type: violationType,
        message: warningMessages[violationType] || 'Security violation detected',
        timestamp: new Date()
      })
      
      return { success: true, violationCount: violationCount.value }
    } catch (error) {
      console.error('Failed to report violation:', error)
      violationCount.value++
      return { error: true, message: error.message || 'Failed to report violation' }
    }
  }
  
  const clearWarnings = () => {
    warnings.value = []
  }
  
  onUnmounted(() => {
    stopMonitoring()
  })
  
  return {
    violationCount,
    isMonitoring,
    warnings,
    startMonitoring,
    stopMonitoring,
    reportViolation,
    clearWarnings
  }
}
