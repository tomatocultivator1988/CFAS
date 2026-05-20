import axios from 'axios'

const AUTH_TOKEN_KEY = 'auth_token'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://127.0.0.1:8000/api',
  timeout: 60000,
  withCredentials: true,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
})

// Always send bearer token when available (cookie remains primary).
api.interceptors.request.use((config) => {
  if (typeof window === 'undefined') {
    return config
  }

  const token = localStorage.getItem(AUTH_TOKEN_KEY)
  if (token) {
    config.headers = config.headers || {}
    config.headers.Authorization = `Bearer ${token}`
  }

  return config
})

// Track last activity time for token validation
let lastActivityTime = Date.now()
const TOKEN_CHECK_INTERVAL = 5 * 60 * 1000 // Check every 5 minutes
const ACTIVITY_TIMEOUT = 25 * 60 * 1000 // 25 minutes (before 30 min token expiry)

// Update activity time on user interaction
const updateActivity = () => {
  lastActivityTime = Date.now()
}

// Listen for user activity
if (typeof window !== 'undefined') {
  ['mousedown', 'keydown', 'scroll', 'touchstart'].forEach(event => {
    window.addEventListener(event, updateActivity, { passive: true })
  })
}

// Periodic token validation - DISABLED to prevent auto-logout issues
// The validation will happen naturally when user makes API requests
// if (typeof window !== 'undefined') {
//   setInterval(async () => {
//     const timeSinceActivity = Date.now() - lastActivityTime
//     
//     // Only validate if user has been active
//     if (timeSinceActivity < ACTIVITY_TIMEOUT) {
//       try {
//         await api.get('/auth/validate')
//       } catch (error) {
//         // Token validation failed, will be handled by response interceptor
//         console.warn('Token validation failed')
//       }
//     }
//   }, TOKEN_CHECK_INTERVAL)
// }

// Response interceptor for error handling with retry logic
api.interceptors.response.use(
  (response) => {
    return response
  },
  async (error) => {
    const config = error.config
    const requestUrl = config?.url || ''
    const isLoginRequest = requestUrl.includes('/auth/login')
    const isValidateRequest = requestUrl.includes('/auth/validate')

    // Handle 401 Unauthorized - but NOT for validation requests
    // Validation requests failing should not trigger logout
    if (error.response?.status === 401 && !isLoginRequest && !isValidateRequest) {
      if (typeof window !== 'undefined') {
        localStorage.removeItem(AUTH_TOKEN_KEY)
        
        // Only redirect to login if not already on login page
        if (!window.location.pathname.includes('/login')) {
          const loginPath = `${import.meta.env.BASE_URL || '/'}login`
          window.location.href = loginPath
        }
      }
      return Promise.reject(error)
    }

    // Retry logic for network errors
    if (!config || !config.retry) {
      config.retry = 0
    }

    const maxRetries = 3
    
    if (config.retry < maxRetries && (!error.response || error.response.status >= 500)) {
      config.retry += 1
      
      // Exponential backoff
      const delay = Math.pow(2, config.retry) * 1000
      
      await new Promise(resolve => setTimeout(resolve, delay))
      
      return api(config)
    }

    return Promise.reject(error)
  }
)

/**
 * Get API base URL for current environment
 * @returns {string}
 */
export function getApiBaseUrl() {
  return import.meta.env.VITE_API_URL || 'http://127.0.0.1:8000/api'
}

/**
 * Test API connectivity
 * @returns {Promise<boolean>}
 */
export async function testApiConnection() {
  try {
    const response = await api.get('/health')
    return response.status === 200
  } catch (error) {
    console.error('[API] Connection test failed:', error)
    return false
  }
}

export default api
