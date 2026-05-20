import { defineStore } from 'pinia'
import { ref } from 'vue'
import api from '@/services/api'

export const useAdminStore = defineStore('admin', () => {
  const exams = ref([])
  const questions = ref([])
  const users = ref([])
  const analytics = ref(null)
  const loading = ref(false)
  const error = ref(null)
  
  // Exam Management
  const loadExams = async () => {
    loading.value = true
    error.value = null
    try {
      const response = await api.get('/admin/exams')
      exams.value = response.data.exams || response.data
      return { success: true }
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to load exams'
      return { success: false, error: error.value }
    } finally {
      loading.value = false
    }
  }
  
  const getExam = async (examId) => {
    try {
      const response = await api.get(`/admin/exams/${examId}`)
      return { success: true, data: response.data }
    } catch (err) {
      return { success: false, error: err.response?.data?.message || 'Failed to get exam' }
    }
  }
  
  const createExam = async (examData) => {
    loading.value = true
    error.value = null
    try {
      const response = await api.post('/admin/exams', examData)
      exams.value.push(response.data.exam || response.data)
      return { success: true, data: response.data }
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to create exam'
      return { success: false, error: error.value }
    } finally {
      loading.value = false
    }
  }
  
  const updateExam = async (examId, examData) => {
    loading.value = true
    error.value = null
    try {
      const response = await api.put(`/admin/exams/${examId}`, examData)
      const index = exams.value.findIndex(e => e.id === examId)
      if (index !== -1) exams.value[index] = response.data.exam || response.data
      return { success: true, data: response.data }
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to update exam'
      return { success: false, error: error.value }
    } finally {
      loading.value = false
    }
  }
  
  const deleteExam = async (examId) => {
    loading.value = true
    error.value = null
    try {
      await api.delete(`/admin/exams/${examId}`)
      exams.value = exams.value.filter(e => e.id !== examId)
      return { success: true }
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to delete exam'
      return { success: false, error: error.value }
    } finally {
      loading.value = false
    }
  }
  
  const assignExam = async (examId, revieweeIds) => {
    try {
      const response = await api.post(`/admin/exams/${examId}/assign`, { reviewee_ids: revieweeIds })
      return { success: true, data: response.data }
    } catch (err) {
      return { success: false, error: err.response?.data?.message || 'Failed to assign exam' }
    }
  }
  
  const toggleExamStatus = async (examId) => {
    try {
      const response = await api.post(`/admin/exams/${examId}/toggle-status`)
      return { success: true, data: response.data }
    } catch (err) {
      return { success: false, error: err.response?.data?.message || 'Failed to toggle exam status' }
    }
  }
  
  // Question Management
  const loadQuestions = async () => {
    loading.value = true
    error.value = null
    try {
      const response = await api.get('/admin/questions')
      questions.value = response.data.questions || response.data
      return { success: true }
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to load questions'
      return { success: false, error: error.value }
    } finally {
      loading.value = false
    }
  }
  
  const getQuestion = async (questionId) => {
    try {
      const response = await api.get(`/admin/questions/${questionId}`)
      return { success: true, data: response.data }
    } catch (err) {
      return { success: false, error: err.response?.data?.message || 'Failed to get question' }
    }
  }
  
  const createQuestion = async (questionData) => {
    loading.value = true
    error.value = null
    try {
      const response = await api.post('/admin/questions', questionData)
      questions.value.push(response.data.question || response.data)
      return { success: true, data: response.data }
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to create question'
      return { success: false, error: error.value }
    } finally {
      loading.value = false
    }
  }
  
  const updateQuestion = async (questionId, questionData) => {
    loading.value = true
    error.value = null
    try {
      const response = await api.put(`/admin/questions/${questionId}`, questionData)
      const index = questions.value.findIndex(q => q.id === questionId)
      if (index !== -1) questions.value[index] = response.data.question || response.data
      return { success: true, data: response.data }
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to update question'
      return { success: false, error: error.value }
    } finally {
      loading.value = false
    }
  }
  
  const deleteQuestion = async (questionId) => {
    loading.value = true
    error.value = null
    try {
      await api.delete(`/admin/questions/${questionId}`)
      questions.value = questions.value.filter(q => q.id !== questionId)
      return { success: true }
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to delete question'
      return { success: false, error: error.value }
    } finally {
      loading.value = false
    }
  }
  
  // User Management
  const loadUsers = async () => {
    loading.value = true
    error.value = null
    try {
      const response = await api.get('/admin/users')
      users.value = response.data.users || response.data
      return { success: true }
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to load users'
      return { success: false, error: error.value }
    } finally {
      loading.value = false
    }
  }
  
  const getUser = async (userId) => {
    try {
      const response = await api.get(`/admin/users/${userId}`)
      return { success: true, data: response.data }
    } catch (err) {
      return { success: false, error: err.response?.data?.message || 'Failed to get user' }
    }
  }
  
  const createUser = async (userData) => {
    loading.value = true
    error.value = null
    try {
      const response = await api.post('/admin/users', userData)
      users.value.push(response.data.user || response.data)
      return { success: true, data: response.data }
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to create user'
      return { success: false, error: error.value }
    } finally {
      loading.value = false
    }
  }
  
  const updateUser = async (userId, userData) => {
    loading.value = true
    error.value = null
    try {
      const response = await api.put(`/admin/users/${userId}`, userData)
      const index = users.value.findIndex(u => u.id === userId)
      if (index !== -1) users.value[index] = response.data.user || response.data
      return { success: true, data: response.data }
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to update user'
      return { success: false, error: error.value }
    } finally {
      loading.value = false
    }
  }
  
  const deleteUser = async (userId) => {
    loading.value = true
    error.value = null
    try {
      await api.delete(`/admin/users/${userId}`)
      users.value = users.value.filter(u => u.id !== userId)
      return { success: true }
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to delete user'
      return { success: false, error: error.value }
    } finally {
      loading.value = false
    }
  }
  
  const permanentlyDeleteUser = async (userId) => {
    loading.value = true
    error.value = null
    try {
      await api.delete(`/admin/users/${userId}/permanent`)
      users.value = users.value.filter(u => u.id !== userId)
      return { success: true }
    } catch (err) {
      error.value = err.response?.data?.message || 'Failed to permanently delete user'
      return { success: false, error: error.value }
    } finally {
      loading.value = false
    }
  }
  
  const resetPassword = async (userId) => {
    try {
      const response = await api.post(`/admin/users/${userId}/reset-password`)
      return { success: true, data: response.data }
    } catch (err) {
      return { success: false, error: err.response?.data?.message || 'Failed to reset password' }
    }
  }
  
  const getUserAuditLog = async (userId) => {
    try {
      const response = await api.get(`/admin/users/${userId}/audit-log`)
      return { success: true, data: response.data }
    } catch (err) {
      return { success: false, error: err.response?.data?.message || 'Failed to get audit log' }
    }
  }
  
  // Analytics
  const getRevieweeScores = async (revieweeId) => {
    try {
      const response = await api.get(`/admin/analytics/reviewees/${revieweeId}/scores`)
      return { success: true, data: response.data }
    } catch (err) {
      return { success: false, error: err.response?.data?.message || 'Failed to load scores' }
    }
  }
  
  const getExamAverage = async (examId) => {
    try {
      const response = await api.get(`/admin/analytics/exams/${examId}/average`)
      return { success: true, data: response.data }
    } catch (err) {
      return { success: false, error: err.response?.data?.message || 'Failed to load exam average' }
    }
  }
  
  const getPerformanceTrends = async (revieweeId) => {
    try {
      const response = await api.get(`/admin/analytics/reviewees/${revieweeId}/trends`)
      return { success: true, data: response.data }
    } catch (err) {
      return { success: false, error: err.response?.data?.message || 'Failed to load trends' }
    }
  }
  
  const getTopicPerformance = async (revieweeId) => {
    try {
      const response = await api.get(`/admin/analytics/reviewees/${revieweeId}/topics`)
      return { success: true, data: response.data }
    } catch (err) {
      return { success: false, error: err.response?.data?.message || 'Failed to load topic performance' }
    }
  }
  
  const getComparativeRankings = async (examId) => {
    try {
      const response = await api.get(`/admin/analytics/exams/${examId}/rankings`)
      return { success: true, data: response.data }
    } catch (err) {
      return { success: false, error: err.response?.data?.message || 'Failed to load rankings' }
    }
  }
  
  return {
    exams,
    questions,
    users,
    analytics,
    loading,
    error,
    // Exam methods
    loadExams,
    getExam,
    createExam,
    updateExam,
    deleteExam,
    assignExam,
    toggleExamStatus,
    // Question methods
    loadQuestions,
    getQuestion,
    createQuestion,
    updateQuestion,
    deleteQuestion,
    // User methods
    loadUsers,
    getUser,
    createUser,
    updateUser,
    deleteUser,
    permanentlyDeleteUser,
    resetPassword,
    getUserAuditLog,
    // Analytics methods
    getRevieweeScores,
    getExamAverage,
    getPerformanceTrends,
    getTopicPerformance,
    getComparativeRankings
  }
})
