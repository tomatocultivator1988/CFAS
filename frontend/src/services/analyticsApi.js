import axios from 'axios'
import ConfigManager from '../config/configManager'

const AUTH_TOKEN_KEY = 'auth_token'

class AnalyticsApiService {
  constructor() {
    this.client = null
    this.initialized = false
    this.failedRequests = new Map() // Track failed requests for retry
    this.configurationResolved = false
    this.initializeClient()
  }

  /**
   * Initialize the axios client with proper configuration
   */
  async initializeClient() {
    try {
      const apiUrl = await ConfigManager.getApiUrlWithFallback()
      
      this.client = axios.create({
        baseURL: `${apiUrl}/analytics`,
        timeout: 30000,
        withCredentials: true,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0'
        }
      })

      // Request interceptor for cache-busting metadata
      this.client.interceptors.request.use(
        (config) => {
          // Keep auth behavior consistent with the main API client.
          if (typeof window !== 'undefined') {
            const token = localStorage.getItem(AUTH_TOKEN_KEY)
            if (token) {
              config.headers = config.headers || {}
              config.headers.Authorization = `Bearer ${token}`
            }
          }

          // Add timestamp to prevent browser caching
          config.params = {
            ...config.params,
            _t: Date.now()
          }
          return config
        },
        (error) => Promise.reject(error)
      )

      // Add response interceptor for error handling
      this.client.interceptors.response.use(
        (response) => response,
        async (error) => {
          if (error.response?.status === 401) {
            if (typeof window !== 'undefined') {
              localStorage.removeItem(AUTH_TOKEN_KEY)

              // Respect Vite base path to avoid broken redirects on subpaths.
              const loginPath = `${import.meta.env.BASE_URL || '/'}login`
              if (!window.location.pathname.includes('/login')) {
                window.location.href = loginPath
              }
            }
          } else if (this.shouldAttemptAutoCorrection(error)) {
            // Try auto-correction for connection issues
            console.warn('[AnalyticsApi] Connection failed, attempting auto-correction...')
            const correctedUrl = await ConfigManager.autoCorrectConfiguration()
            if (correctedUrl) {
              // Reinitialize client with corrected URL
              await this.initializeClient()
              // Mark this request for retry
              error.config._autoRetryAttempted = true
              return this.client.request(error.config)
            }
          }
          return Promise.reject(error)
        }
      )

      this.initialized = true
      this.configurationResolved = true
      
      const environment = await ConfigManager.getEnvironment()
      console.log(`[AnalyticsApi] Initialized for ${environment} environment: ${apiUrl}`)
      
      // Retry any failed requests now that configuration is resolved
      await this.retryFailedRequests()
      
    } catch (error) {
      console.error('[AnalyticsApi] Failed to initialize client:', error)
      this.configurationResolved = false
      throw new Error('Failed to initialize analytics API client')
    }
  }

  /**
   * Ensure client is initialized before making requests
   */
  async ensureInitialized() {
    if (!this.initialized || !this.client) {
      await this.initializeClient()
    }
  }

  /**
   * Check if error should trigger auto-correction attempt
   * @param {Error} error - The error to check
   * @returns {boolean}
   */
  shouldAttemptAutoCorrection(error) {
    // Don't retry if we already attempted auto-correction for this request
    if (error.config?._autoRetryAttempted) {
      return false
    }

    // Check for connection-related errors
    const connectionErrors = [
      'ECONNREFUSED',
      'ERR_CONNECTION_REFUSED', 
      'ERR_NETWORK',
      'Network Error',
      'ERR_NAME_NOT_RESOLVED'
    ]

    return connectionErrors.some(errorType => 
      error.code === errorType || 
      error.message?.includes(errorType)
    )
  }

  /**
   * Retry a failed request with exponential backoff
   * @param {Function} requestFn - Function that makes the request
   * @param {number} maxRetries - Maximum number of retries
   * @param {number} baseDelay - Base delay in milliseconds
   * @returns {Promise} Request result
   */
  async retryRequest(requestFn, maxRetries = 3, baseDelay = 1000) {
    let lastError = null
    
    for (let attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        return await requestFn()
      } catch (error) {
        lastError = error
        
        if (attempt === maxRetries) {
          break
        }
        
        // Exponential backoff
        const delay = baseDelay * Math.pow(2, attempt)
        console.log(`[AnalyticsApi] Request failed, retrying in ${delay}ms (attempt ${attempt + 1}/${maxRetries + 1})`)
        await new Promise(resolve => setTimeout(resolve, delay))
      }
    }
    
    throw lastError
  }

  /**
   * Track a failed request for potential retry
   * @param {string} requestId - Unique identifier for the request
   * @param {Function} requestFn - Function to retry the request
   * @param {Function} onSuccess - Callback for successful retry
   * @param {Function} onError - Callback for failed retry
   */
  trackFailedRequest(requestId, requestFn, onSuccess, onError) {
    this.failedRequests.set(requestId, {
      requestFn,
      onSuccess,
      onError,
      timestamp: Date.now()
    })
    
    // Clean up old failed requests (older than 5 minutes)
    const fiveMinutesAgo = Date.now() - (5 * 60 * 1000)
    for (const [id, request] of this.failedRequests.entries()) {
      if (request.timestamp < fiveMinutesAgo) {
        this.failedRequests.delete(id)
      }
    }
  }

  /**
   * Retry all failed requests when configuration is resolved
   */
  async retryFailedRequests() {
    if (this.failedRequests.size === 0) {
      return
    }

    console.log(`[AnalyticsApi] Retrying ${this.failedRequests.size} failed requests...`)
    
    const retryPromises = []
    
    for (const [requestId, { requestFn, onSuccess, onError }] of this.failedRequests.entries()) {
      const retryPromise = requestFn()
        .then(result => {
          console.log(`[AnalyticsApi] Successfully retried request: ${requestId}`)
          this.failedRequests.delete(requestId)
          if (onSuccess) onSuccess(result)
          return result
        })
        .catch(error => {
          console.warn(`[AnalyticsApi] Retry failed for request: ${requestId}`, error)
          if (onError) onError(error)
          // Keep the request in the map for potential future retry
        })
      
      retryPromises.push(retryPromise)
    }
    
    // Wait for all retries to complete (but don't fail if some fail)
    await Promise.allSettled(retryPromises)
  }

  /**
   * Clear all tracked failed requests
   */
  clearFailedRequests() {
    this.failedRequests.clear()
  }

  /**
   * Get system overview metrics
   * @param {string} timeFilter - '7days', '30days', '3months', 'all'
   * @returns {Promise<Object>} Overview metrics data
   */
  async getOverviewMetrics(timeFilter = 'all') {
    try {
      await this.ensureInitialized()
      const response = await this.client.get('/overview', {
        params: { timeFilter }
      })
      return response.data
    } catch (error) {
      throw this.handleError(error, 'Failed to fetch overview metrics')
    }
  }

  /**
   * Get exam performance list with pagination and sorting
   * @param {Object} params - Query parameters
   * @param {string} params.timeFilter - Time filter
   * @param {number} params.page - Page number
   * @param {string} params.sortBy - Sort field
   * @param {string} params.order - Sort order
   * @returns {Promise<Object>} Exam performance data
   */
  async getExamPerformance({ timeFilter = 'all', page = 1, sortBy = 'attempts', order = 'desc' } = {}) {
    try {
      await this.ensureInitialized()
      const response = await this.client.get('/exams', {
        params: { timeFilter, page, sortBy, order }
      })
      return response.data
    } catch (error) {
      throw this.handleError(error, 'Failed to fetch exam performance data')
    }
  }

  /**
   * Get exam details with score distribution
   * @param {number} examId - Exam ID
   * @param {string} timeFilter - Time filter
   * @param {Object} options - Request options
   * @param {boolean} options.bypassCache - Request fresh data from DB
   * @returns {Promise<Object>} Exam details and score distribution
   */
  async getExamDetails(examId, timeFilter = 'all', { bypassCache = false } = {}) {
    try {
      await this.ensureInitialized()
      const response = await this.client.get(`/exams/${examId}/details`, {
        params: { timeFilter, bypassCache }
      })
      return response.data
    } catch (error) {
      throw this.handleError(error, 'Failed to fetch exam details')
    }
  }

  /**
   * Get student performance list with filtering and pagination
   * @param {Object} params - Query parameters
   * @param {string} params.timeFilter - Time filter
   * @param {string} params.level - Performance level filter
   * @param {number} params.page - Page number
   * @returns {Promise<Object>} Student performance data
   */
  async getStudentPerformance({ timeFilter = 'all', level = 'all', page = 1 } = {}) {
    try {
      await this.ensureInitialized()
      const response = await this.client.get('/students', {
        params: { timeFilter, level, page }
      })
      return response.data
    } catch (error) {
      throw this.handleError(error, 'Failed to fetch student performance data')
    }
  }

  /**
   * Get individual student trend data
   * @param {number} studentId - Student ID
   * @param {string} timeFilter - Time filter
   * @param {Object} options - Request options
   * @param {boolean} options.bypassCache - Request fresh data from backend cache layer
   * @returns {Promise<Object>} Student trend data
   */
  async getStudentTrend(studentId, timeFilter = 'all', { bypassCache = false } = {}) {
    try {
      await this.ensureInitialized()
      const response = await this.client.get(`/students/${studentId}/trend`, {
        params: { timeFilter, bypassCache }
      })
      return response.data
    } catch (error) {
      throw this.handleError(error, 'Failed to fetch student trend data')
    }
  }

  /**
   * Get question analysis for an exam
   * @param {number} examId - Exam ID
   * @param {Object} params - Query parameters
   * @param {string} params.timeFilter - Time filter
   * @param {string} params.difficulty - Difficulty filter
   * @returns {Promise<Object>} Question analysis data
   */
  async getQuestionAnalysis(examId, { timeFilter = 'all', difficulty = 'all' } = {}) {
    try {
      await this.ensureInitialized()
      const response = await this.client.get(`/questions/${examId}`, {
        params: { timeFilter, difficulty }
      })
      return response.data
    } catch (error) {
      throw this.handleError(error, 'Failed to fetch question analysis data')
    }
  }

  /**
   * Get top 10 performers by average score
   * @param {string} timeFilter - Time filter
   * @returns {Promise<Object>} Top performers data
   */
  async getTopPerformers(timeFilter = 'all') {
    try {
      await this.ensureInitialized()
      const response = await this.client.get('/top-performers', {
        params: { timeFilter }
      })
      return response.data
    } catch (error) {
      throw this.handleError(error, 'Failed to fetch top performers data')
    }
  }

  /**
   * Get comprehensive dashboard summary with all key metrics
   * @param {string} timeFilter - Time filter
   * @returns {Promise<Object>} Dashboard summary data
   */
  async getDashboardSummary(timeFilter = 'all') {
    try {
      await this.ensureInitialized()
      const response = await this.client.get('/dashboard-summary', {
        params: { timeFilter }
      })
      return response.data
    } catch (error) {
      throw this.handleError(error, 'Failed to fetch dashboard summary data')
    }
  }

  /**
   * Get trend analysis data with category comparison
   * @param {Object} params - Query parameters
   * @param {string} params.timeFilter - Time filter
   * @param {Array|string} params.categories - Categories to include
   * @returns {Promise<Object>} Trend analysis data
   */
  async getTrendData({ timeFilter = 'all', categories = 'all' } = {}) {
    try {
      await this.ensureInitialized()
      const categoriesParam = Array.isArray(categories) ? categories.join(',') : categories
      const response = await this.client.get('/trends', {
        params: { timeFilter, categories: categoriesParam }
      })
      return response.data
    } catch (error) {
      throw this.handleError(error, 'Failed to fetch trend analysis data')
    }
  }

  async getMlPredictions({ timeFilter = 'all', model = 'random_forest' } = {}) {
    try {
      await this.ensureInitialized()
      const response = await this.client.get('/ml-predictions', {
        params: { timeFilter, model }
      })
      return response.data
    } catch (error) {
      throw this.handleError(error, 'Failed to fetch ML predictions')
    }
  }

  /**
   * Export analytics data to CSV
   * @param {Object} exportParams - Export parameters
   * @param {string} exportParams.type - Export type ('exams', 'students', 'questions', 'trends')
   * @param {string} exportParams.timeFilter - Time filter
   * @param {Object} exportParams.filters - Additional filters
   * @returns {Promise<Blob>} CSV file blob
   */
  async exportData(exportParams) {
    try {
      await this.ensureInitialized()
      const response = await this.client.post('/export', exportParams, {
        responseType: 'blob',
        headers: {
          'Accept': 'text/csv'
        }
      })
      
      // Create blob from response
      const blob = new Blob([response.data], { type: 'text/csv' })
      return blob
    } catch (error) {
      throw this.handleError(error, 'Failed to export data')
    }
  }

  /**
   * Download exported CSV file
   * @param {Blob} blob - CSV blob
   * @param {string} filename - Filename for download
   */
  downloadCsv(blob, filename) {
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = filename
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    window.URL.revokeObjectURL(url)
  }

  /**
   * Handle API errors consistently
   * @param {Error} error - Axios error
   * @param {string} defaultMessage - Default error message
   * @returns {Error} Formatted error
   */
  handleError(error, defaultMessage) {
    if (error.response) {
      // Server responded with error status
      const message = error.response.data?.message || defaultMessage
      const status = error.response.status
      return new Error(`${message} (Status: ${status})`)
    } else if (error.request) {
      // Request made but no response received
      const url = error.config?.baseURL || 'unknown'
      if (error.code === 'ECONNREFUSED' || error.message.includes('ERR_CONNECTION_REFUSED')) {
        return new Error(`Connection refused: Unable to connect to analytics API at ${url}. Please check if the backend server is running.`)
      } else if (error.code === 'ENOTFOUND' || error.message.includes('ERR_NAME_NOT_RESOLVED')) {
        return new Error(`DNS resolution failed: Cannot resolve hostname for ${url}. Please check your network connection.`)
      } else {
        return new Error(`Network error: Unable to connect to analytics API at ${url}`)
      }
    } else {
      // Something else happened
      return new Error(error.message || defaultMessage)
    }
  }

  /**
   * Get loading state helper
   * @returns {Object} Loading state object
   */
  createLoadingState() {
    return {
      loading: false,
      error: null,
      data: null
    }
  }

  /**
   * Validate time filter parameter
   * @param {string} timeFilter - Time filter to validate
   * @returns {boolean} Is valid
   */
  isValidTimeFilter(timeFilter) {
    return ['7days', '30days', '3months', 'all'].includes(timeFilter)
  }

  /**
   * Validate sort parameters
   * @param {string} sortBy - Sort field
   * @param {string} order - Sort order
   * @returns {boolean} Is valid
   */
  isValidSort(sortBy, order) {
    const validSortFields = ['attempts', 'avgScore', 'passRate', 'difficulty']
    const validOrders = ['asc', 'desc']
    return validSortFields.includes(sortBy) && validOrders.includes(order)
  }

  /**
   * Validate performance level filter
   * @param {string} level - Performance level
   * @returns {boolean} Is valid
   */
  isValidPerformanceLevel(level) {
    return ['all', 'struggling', 'average', 'top'].includes(level)
  }
}

// Create singleton instance
const analyticsApi = new AnalyticsApiService()

export default analyticsApi
