import { defineStore } from 'pinia'
import { ref } from 'vue'
import api from '@/services/api'

const getPendingAnswersKey = (attemptId) => `exam_${attemptId}_pending_answers`
const getPendingSubmitKey = (attemptId) => `exam_${attemptId}_pending_submit`

export const useExamStore = defineStore('exam', () => {
  const assignedExams = ref([])
  const currentExam = ref(null)
  const currentAttempt = ref(null)
  const examResult = ref(null)
  const loading = ref(false)
  const error = ref(null)
  
  const loadAssignedExams = async () => {
    loading.value = true
    error.value = null
    try {
      const response = await api.get('/reviewee/exams')
      assignedExams.value = response.data.exams || response.data
      return { success: true }
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to load exams'
      return { success: false, error: error.value }
    } finally {
      loading.value = false
    }
  }
  
  const startExam = async (examId) => {
    loading.value = true
    error.value = null
    try {
      const response = await api.post(`/reviewee/exams/${examId}/start`)
      currentAttempt.value = response.data.attempt
      currentExam.value = response.data.exam || response.data.attempt.exam
      return { success: true, data: response.data }
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to start exam'
      return { success: false, error: error.value }
    } finally {
      loading.value = false
    }
  }
  
  const getAttempt = async (attemptId) => {
    loading.value = true
    error.value = null
    try {
      const response = await api.get(`/reviewee/attempts/${attemptId}`)
      // Store attempt with questions merged in
      currentAttempt.value = {
        ...response.data.attempt,
        questions: response.data.questions
      }
      return { success: true, data: response.data }
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to get attempt'
      return { success: false, error: error.value }
    } finally {
      loading.value = false
    }
  }
  
  const submitAnswer = async (attemptId, questionId, choiceId) => {
    try {
      await api.post(`/reviewee/attempts/${attemptId}/answers`, {
        question_id: questionId,
        choice_id: choiceId
      })
      return { success: true }
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to submit answer'
      const status = err.response?.status
      const message = String(error.value || '').toLowerCase()
      const isAttemptClosed = status === 400 && (
        message.includes('already been completed') ||
        message.includes('time has expired')
      )
      return { success: false, error: error.value, status, isAttemptClosed }
    }
  }

  const queuePendingAnswer = (attemptId, questionId, choiceId) => {
    if (!attemptId || !questionId || !choiceId) return

    let pendingAnswers = {}
    try {
      const raw = localStorage.getItem(getPendingAnswersKey(attemptId))
      pendingAnswers = raw ? JSON.parse(raw) : {}
    } catch {
      pendingAnswers = {}
    }

    pendingAnswers[questionId] = choiceId
    localStorage.setItem(getPendingAnswersKey(attemptId), JSON.stringify(pendingAnswers))
  }

  const getPendingAnswers = (attemptId) => {
    if (!attemptId) return {}

    try {
      const raw = localStorage.getItem(getPendingAnswersKey(attemptId))
      return raw ? JSON.parse(raw) : {}
    } catch {
      return {}
    }
  }

  const clearPendingAnswers = (attemptId) => {
    if (!attemptId) return
    localStorage.removeItem(getPendingAnswersKey(attemptId))
  }

  const markAnswerSynced = (attemptId, questionId) => {
    if (!attemptId || !questionId) return

    const pendingAnswers = getPendingAnswers(attemptId)
    if (!pendingAnswers[questionId]) return

    delete pendingAnswers[questionId]

    if (Object.keys(pendingAnswers).length === 0) {
      clearPendingAnswers(attemptId)
      return
    }

    localStorage.setItem(getPendingAnswersKey(attemptId), JSON.stringify(pendingAnswers))
  }

  const flushPendingAnswers = async (attemptId) => {
    const pendingAnswers = getPendingAnswers(attemptId)
    const entries = Object.entries(pendingAnswers)

    if (entries.length === 0) {
      return { success: true, synced: 0 }
    }

    const remaining = {}
    let synced = 0

    for (const [questionId, choiceId] of entries) {
      const result = await submitAnswer(attemptId, Number(questionId), Number(choiceId))
      if (result.success) {
        synced++
      } else if (result.isAttemptClosed) {
        clearPendingAnswers(attemptId)
        return { success: false, attemptClosed: true, synced, pending: 0, error: result.error }
      } else {
        remaining[questionId] = choiceId
      }
    }

    if (Object.keys(remaining).length > 0) {
      localStorage.setItem(getPendingAnswersKey(attemptId), JSON.stringify(remaining))
      return { success: false, synced, pending: Object.keys(remaining).length }
    }

    clearPendingAnswers(attemptId)
    return { success: true, synced }
  }

  const queuePendingSubmit = (attemptId) => {
    if (!attemptId) return
    localStorage.setItem(getPendingSubmitKey(attemptId), '1')
  }

  const hasPendingSubmit = (attemptId) => {
    if (!attemptId) return false
    return localStorage.getItem(getPendingSubmitKey(attemptId)) === '1'
  }

  const clearPendingSubmit = (attemptId) => {
    if (!attemptId) return
    localStorage.removeItem(getPendingSubmitKey(attemptId))
  }
  
  const submitExam = async (attemptId) => {
    loading.value = true
    error.value = null
    try {
      const response = await api.post(`/reviewee/attempts/${attemptId}/submit`)
      
      examResult.value = response.data.result || response.data
      // Don't clear currentAttempt here - let component do it after modal closes
      clearPendingSubmit(attemptId)
      
      return { success: true, data: response.data }
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to submit exam'
      return { success: false, error: error.value }
    } finally {
      loading.value = false
    }
  }
  
  const getRemainingTime = async (attemptId) => {
    try {
      const response = await api.get(`/reviewee/attempts/${attemptId}/time`)
      return { success: true, data: response.data }
    } catch (err) {
      return { success: false, error: err.response?.data?.message || 'Failed to get time' }
    }
  }
  
  const reportViolation = async (attemptId, violationType) => {
    try {
      const response = await api.post(`/reviewee/attempts/${attemptId}/violations`, {
        violation_type: violationType
      })
      return { success: true, data: response.data }
    } catch (err) {
      return { success: false, error: err.response?.data?.message || 'Failed to report violation' }
    }
  }
  
  const loadExamHistory = async () => {
    try {
      const response = await api.get('/reviewee/exam-history')
      return { success: true, data: response.data.history }
    } catch (err) {
      return { success: false, error: err.response?.data?.message || 'Failed to load exam history' }
    }
  }
  
  const getAttemptReview = async (attemptId) => {
    try {
      const response = await api.get(`/reviewee/attempts/${attemptId}/review`)
      return { success: true, data: response.data }
    } catch (err) {
      return { success: false, error: err.response?.data?.message || 'Failed to load attempt review' }
    }
  }
  
  const clearExamData = () => {
    currentExam.value = null
    currentAttempt.value = null
    examResult.value = null
    error.value = null
  }
  
  return {
    assignedExams,
    currentExam,
    currentAttempt,
    examResult,
    loading,
    error,
    loadAssignedExams,
    startExam,
    getAttempt,
    submitAnswer,
    submitExam,
    getRemainingTime,
    reportViolation,
    queuePendingAnswer,
    getPendingAnswers,
    clearPendingAnswers,
    markAnswerSynced,
    flushPendingAnswers,
    queuePendingSubmit,
    hasPendingSubmit,
    clearPendingSubmit,
    loadExamHistory,
    getAttemptReview,
    clearExamData
  }
})
