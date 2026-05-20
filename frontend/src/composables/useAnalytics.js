import { ref, reactive, computed, onUnmounted } from 'vue'
import analyticsApi from '@/services/analyticsApi'

/**
 * Composable for managing analytics data fetching and state
 * 
 * CRITICAL: All refs MUST be declared BEFORE computed properties to avoid TDZ errors
 */
export function useAnalytics() {
  // ===== STEP 1: DECLARE ALL REFS FIRST =====
  // Data stores for different analytics sections
  const overviewData = ref(null)
  const examData = ref(null)
  const studentData = ref(null)
  const questionData = ref(null)
  const trendData = ref(null)

  // Loading states for each section
  const loadingStates = reactive({
    overview: false,
    exams: false,
    students: false,
    questions: false,
    trends: false
  })

  // Error states for each section
  const errorStates = reactive({
    overview: null,
    exams: null,
    students: null,
    questions: null,
    trends: null
  })

  // Pagination states
  const paginationStates = reactive({
    exams: { currentPage: 1, totalPages: 1, total: 0 },
    students: { currentPage: 1, totalPages: 1, total: 0 }
  })

  // Filter states
  const filterStates = reactive({
    exams: { sortBy: 'attempts', order: 'desc' },
    students: { level: 'all' },
    questions: { examId: null, difficulty: 'all' },
    trends: { categories: 'all' }
  })

  // Auto-refresh configuration
  const autoRefresh = reactive({
    enabled: false,
    interval: 300000, // 5 minutes
    timerId: null
  })

  // ===== STEP 2: DECLARE COMPUTED PROPERTIES AFTER ALL REFS =====
  const hasAnyData = computed(() => {
    return overviewData.value || examData.value || studentData.value || 
           questionData.value || trendData.value
  })

  const isAnyLoading = computed(() => {
    return Object.values(loadingStates).some(loading => loading)
  })

  const hasAnyError = computed(() => {
    return Object.values(errorStates).some(error => error !== null)
  })

  // Helper function to set loading state
  const setLoading = (section, loading) => {
    loadingStates[section] = loading
    if (loading) {
      errorStates[section] = null
    }
  }

  // Helper function to set error state
  const setError = (section, error) => {
    errorStates[section] = error
    loadingStates[section] = false
  }

  // Overview metrics methods
  const fetchOverviewMetrics = async (timeFilter = 'all') => {
    setLoading('overview', true)
    try {
      // Use dashboard summary for richer data
      const response = await analyticsApi.getDashboardSummary(timeFilter)
      // API returns { success: true, data: {...} } - extract the nested data
      const responseData = response.data?.data || response.data
      // Merge overview with pass rate from dashboard summary
      const data = {
        ...(responseData?.overview || responseData),
        topExams: responseData?.topExams || [],
        topPerformers: responseData?.topPerformers || [],
        recentActivity: responseData?.recentActivity || [],
        categoryBreakdown: responseData?.categoryBreakdown || []
      }
      overviewData.value = data
      return data
    } catch (error) {
      // Fallback to basic overview if dashboard summary fails
      try {
        const fallbackResponse = await analyticsApi.getOverviewMetrics(timeFilter)
        const data = fallbackResponse.data?.data || fallbackResponse.data
        overviewData.value = data
        return data
      } catch (fallbackError) {
        setError('overview', fallbackError.message)
        throw fallbackError
      }
    } finally {
      setLoading('overview', false)
    }
  }

  // Exam performance methods
  const fetchExamPerformance = async (timeFilter = 'all', page = 1) => {
    setLoading('exams', true)
    try {
      const params = {
        timeFilter,
        page,
        sortBy: filterStates.exams.sortBy,
        order: filterStates.exams.order
      }
      const response = await analyticsApi.getExamPerformance(params)
      // API returns { success: true, data: {...} } - extract the nested data
      const data = response.data?.data || response.data
      examData.value = data
      
      // Update pagination
      if (data?.pagination) {
        paginationStates.exams = {
          currentPage: data.pagination.currentPage,
          totalPages: data.pagination.totalPages,
          total: data.pagination.total
        }
      }
      
      return data
    } catch (error) {
      setError('exams', error.message)
      throw error
    } finally {
      setLoading('exams', false)
    }
  }

  const fetchExamDetails = async (examId, timeFilter = 'all', { bypassCache = false } = {}) => {
    setLoading('exams', true)
    try {
      const response = await analyticsApi.getExamDetails(examId, timeFilter, { bypassCache })
      // API returns { success: true, data: {...} } - extract the nested data
      return response.data?.data || response.data
    } catch (error) {
      setError('exams', error.message)
      throw error
    } finally {
      setLoading('exams', false)
    }
  }

  const setExamSort = (sortBy, order) => {
    filterStates.exams.sortBy = sortBy
    filterStates.exams.order = order
  }

  // Student performance methods
  const fetchStudentPerformance = async (timeFilter = 'all', page = 1) => {
    setLoading('students', true)
    try {
      const params = {
        timeFilter,
        page,
        level: filterStates.students.level
      }
      const response = await analyticsApi.getStudentPerformance(params)
      // API returns { success: true, data: {...} } - extract the nested data
      const data = response.data?.data || response.data
      studentData.value = data
      
      // Update pagination
      if (data?.pagination) {
        paginationStates.students = {
          currentPage: data.pagination.currentPage,
          totalPages: data.pagination.totalPages,
          total: data.pagination.total
        }
      }
      
      return data
    } catch (error) {
      setError('students', error.message)
      throw error
    } finally {
      setLoading('students', false)
    }
  }

  const fetchStudentTrend = async (studentId, timeFilter = 'all', { bypassCache = false } = {}) => {
    setLoading('students', true)
    try {
      const response = await analyticsApi.getStudentTrend(studentId, timeFilter, { bypassCache })
      // API returns { success: true, data: {...} } - extract the nested data
      return response.data?.data || response.data
    } catch (error) {
      setError('students', error.message)
      throw error
    } finally {
      setLoading('students', false)
    }
  }

  // Top performers method
  const fetchTopPerformers = async (timeFilter = 'all') => {
    try {
      const response = await analyticsApi.getTopPerformers(timeFilter)
      // API returns { success: true, data: [...] } - extract the nested data
      const data = response.data?.data || response.data
      if (studentData.value) {
        studentData.value = { ...studentData.value, topPerformers: data }
      } else {
        studentData.value = { topPerformers: data }
      }
      return data
    } catch (error) {
      console.error('Failed to fetch top performers:', error.message)
      return []
    }
  }

  const setStudentLevel = (level) => {
    filterStates.students.level = level
  }

  // Question analysis methods
  const fetchQuestionAnalysis = async (examId, timeFilter = 'all') => {
    if (!examId) return null
    
    setLoading('questions', true)
    try {
      const params = {
        timeFilter,
        difficulty: filterStates.questions.difficulty
      }
      const response = await analyticsApi.getQuestionAnalysis(examId, params)
      // API returns { success: true, data: {...} } - extract the nested data
      const data = response.data?.data || response.data
      questionData.value = data
      filterStates.questions.examId = examId
      return data
    } catch (error) {
      setError('questions', error.message)
      throw error
    } finally {
      setLoading('questions', false)
    }
  }

  const setQuestionDifficulty = (difficulty) => {
    filterStates.questions.difficulty = difficulty
  }

  // Trend analysis methods
  const fetchTrendData = async (timeFilter = 'all') => {
    setLoading('trends', true)
    try {
      const params = {
        timeFilter,
        categories: filterStates.trends.categories
      }
      const response = await analyticsApi.getTrendData(params)
      // API returns { success: true, data: {...} } - extract the nested data
      const responseData = response.data?.data || response.data
      // trendData stores the full response including trendData array and availableCategories
      trendData.value = responseData
      return responseData
    } catch (error) {
      setError('trends', error.message)
      throw error
    } finally {
      setLoading('trends', false)
    }
  }

  const setTrendCategories = (categories) => {
    filterStates.trends.categories = categories
  }

  // Export methods removed - use dedicated Export Reports page instead

  // Refresh methods
  const refreshSection = async (section, timeFilter = 'all') => {
    switch (section) {
      case 'overview':
        return await fetchOverviewMetrics(timeFilter)
      case 'exams':
        return await fetchExamPerformance(timeFilter, paginationStates.exams.currentPage)
      case 'students':
        return await fetchStudentPerformance(timeFilter, paginationStates.students.currentPage)
      case 'questions':
        if (filterStates.questions.examId) {
          return await fetchQuestionAnalysis(filterStates.questions.examId, timeFilter)
        }
        break
      case 'trends':
        return await fetchTrendData(timeFilter)
    }
  }

  const refreshAllSections = async (timeFilter = 'all') => {
    const promises = [
      fetchOverviewMetrics(timeFilter),
      fetchExamPerformance(timeFilter, 1),
      fetchStudentPerformance(timeFilter, 1),
      fetchTrendData(timeFilter)
    ]
    
    // Only fetch questions if exam is selected
    if (filterStates.questions.examId) {
      promises.push(fetchQuestionAnalysis(filterStates.questions.examId, timeFilter))
    }
    
    try {
      await Promise.allSettled(promises)
    } catch (error) {
      console.error('Error refreshing analytics data:', error)
    }
  }

  // Auto-refresh methods
  const startAutoRefresh = (timeFilter = 'all') => {
    if (autoRefresh.timerId) {
      clearInterval(autoRefresh.timerId)
    }
    
    autoRefresh.enabled = true
    autoRefresh.timerId = setInterval(() => {
      refreshAllSections(timeFilter)
    }, autoRefresh.interval)
  }

  const stopAutoRefresh = () => {
    if (autoRefresh.timerId) {
      clearInterval(autoRefresh.timerId)
      autoRefresh.timerId = null
    }
    autoRefresh.enabled = false
  }

  // Clear methods
  const clearSection = (section) => {
    switch (section) {
      case 'overview':
        overviewData.value = null
        break
      case 'exams':
        examData.value = null
        break
      case 'students':
        studentData.value = null
        break
      case 'questions':
        questionData.value = null
        break
      case 'trends':
        trendData.value = null
        break
    }
    errorStates[section] = null
    loadingStates[section] = false
  }

  const clearAllData = () => {
    overviewData.value = null
    examData.value = null
    studentData.value = null
    questionData.value = null
    trendData.value = null
    
    Object.keys(errorStates).forEach(key => {
      errorStates[key] = null
    })
    Object.keys(loadingStates).forEach(key => {
      loadingStates[key] = false
    })
  }

  // Cleanup on unmount
  onUnmounted(() => {
    stopAutoRefresh()
  })

  return {
    // Data
    overviewData,
    examData,
    studentData,
    questionData,
    trendData,
    
    // States
    loadingStates,
    errorStates,
    paginationStates,
    filterStates,
    autoRefresh,
    
    // Computed
    hasAnyData,
    isAnyLoading,
    hasAnyError,
    
    // Overview methods
    fetchOverviewMetrics,
    
    // Exam methods
    fetchExamPerformance,
    fetchExamDetails,
    setExamSort,
    
    // Student methods
    fetchStudentPerformance,
    fetchStudentTrend,
    fetchTopPerformers,
    setStudentLevel,
    
    // Question methods
    fetchQuestionAnalysis,
    setQuestionDifficulty,
    
    // Trend methods
    fetchTrendData,
    setTrendCategories,
    
    // Refresh methods
    refreshSection,
    refreshAllSections,
    startAutoRefresh,
    stopAutoRefresh,
    
    // Clear methods
    clearSection,
    clearAllData
  }
}
