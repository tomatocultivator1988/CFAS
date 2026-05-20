/**
 * Environment Detector
 * Automatically detects the deployment environment based on hostname and backend connectivity
 */

class EnvironmentDetector {
  static #cachedEnvironment = null
  static #cachedTimestamp = null
  static #cacheTimeout = 5 * 60 * 1000 // 5 minutes

  /**
   * Detect the current environment
   * @returns {'apache' | 'local' | 'lan' | 'production'}
   */
  static async detectEnvironment() {
    // Return cached value if available and not expired
    if (this.#cachedEnvironment && this.#isCacheValid()) {
      return this.#cachedEnvironment
    }

    // Check for explicit dev mode environment variable (highest priority)
    if (import.meta.env.VITE_DEV_MODE === 'true') {
      console.log('[EnvironmentDetector] VITE_DEV_MODE detected - forcing local development environment')
      this.#setCachedEnvironment('local')
      return 'local'
    }

    const hostname = this.getHostname()

    // Local development (Laravel dev server) - check before Apache
    if (hostname === 'localhost' || hostname === '127.0.0.1') {
      // In local environment, check if local backend is available first
      const localBackendAvailable = await this.validateBackendConnectivity('http://127.0.0.1:8000/api/health')
      if (localBackendAvailable) {
        console.log('[EnvironmentDetector] Local development backend detected at 127.0.0.1:8000')
        this.#setCachedEnvironment('local')
        return 'local'
      }
    }

    // Check for Apache backend if local backend not available
    const apacheDetected = await this.detectApacheBackend()
    if (apacheDetected) {
      this.#setCachedEnvironment('apache')
      return 'apache'
    }

    // LAN deployment (private IP ranges)
    if (this.isPrivateIP(hostname)) {
      this.#setCachedEnvironment('lan')
      return 'lan'
    }

    // Production (public domain or IP)
    this.#setCachedEnvironment('production')
    return 'production'
  }

  /**
   * Detect Apache backend by testing connectivity
   * @returns {Promise<boolean>}
   */
  static async detectApacheBackend() {
    const apacheUrls = [
      'http://192.168.11.40/exam-backend/public/api/health',
      'http://localhost/exam-backend/public/api/health',
      'http://127.0.0.1/exam-backend/public/api/health'
    ]

    for (const url of apacheUrls) {
      if (await this.validateBackendConnectivity(url)) {
        console.log(`[EnvironmentDetector] Apache backend detected at: ${url}`)
        return true
      }
    }

    return false
  }

  /**
   * Validate backend connectivity
   * @param {string} url - Backend URL to test
   * @returns {Promise<boolean>}
   */
  static async validateBackendConnectivity(url) {
    try {
      const controller = new AbortController()
      const timeoutId = setTimeout(() => controller.abort(), 3000) // 3 second timeout

      const response = await fetch(url, {
        method: 'GET',
        signal: controller.signal,
        headers: {
          'Accept': 'application/json'
        }
      })

      clearTimeout(timeoutId)
      
      // Consider 200, 401, 404 as valid responses (server is responding)
      return response.status === 200 || response.status === 401 || response.status === 404
    } catch (error) {
      // Network error, timeout, or CORS - backend not available
      return false
    }
  }

  /**
   * Check if running in local environment
   * @returns {boolean}
   */
  static isLocal() {
    return this.detectEnvironment() === 'local'
  }

  /**
   * Check if running in LAN environment
   * @returns {boolean}
   */
  static isLAN() {
    return this.detectEnvironment() === 'lan'
  }

  /**
   * Check if running in production environment
   * @returns {boolean}
   */
  static isProduction() {
    return this.detectEnvironment() === 'production'
  }

  /**
   * Get the current hostname
   * @returns {string}
   */
  static getHostname() {
    if (typeof window !== 'undefined' && window.location) {
      return window.location.hostname
    }
    return 'localhost' // Default for SSR or testing
  }

  /**
   * Check if hostname is a private IP
   * @param {string} hostname
   * @returns {boolean}
   */
  static isPrivateIP(hostname) {
    // Check for private IP ranges:
    // 192.168.0.0 - 192.168.255.255
    // 10.0.0.0 - 10.255.255.255
    // 172.16.0.0 - 172.31.255.255
    const privateRanges = [
      /^192\.168\.\d{1,3}\.\d{1,3}$/,
      /^10\.\d{1,3}\.\d{1,3}\.\d{1,3}$/,
      /^172\.(1[6-9]|2\d|3[01])\.\d{1,3}\.\d{1,3}$/
    ]

    return privateRanges.some(regex => regex.test(hostname))
  }

  /**
   * Check if running in Apache environment
   * @returns {Promise<boolean>}
   */
  static async isApache() {
    const env = await this.detectEnvironment()
    return env === 'apache'
  }

  /**
   * Set cached environment value
   * @param {string} environment
   */
  static #setCachedEnvironment(environment) {
    this.#cachedEnvironment = environment
    this.#cachedTimestamp = Date.now()
  }

  /**
   * Check if cached value is still valid
   * @returns {boolean}
   */
  static #isCacheValid() {
    if (!this.#cachedTimestamp) {
      return false
    }
    return (Date.now() - this.#cachedTimestamp) < this.#cacheTimeout
  }

  /**
   * Clear cached environment (useful for testing)
   */
  static clearCache() {
    this.#cachedEnvironment = null
    this.#cachedTimestamp = null
  }
}

export default EnvironmentDetector
