/**
 * Configuration Manager
 * Centralize configuration management with environment-specific overrides
 */

import EnvironmentDetector from './environmentDetector'

class ConfigManager {
  static #initialized = false
  static #config = null
  static #environment = null

  /**
   * Base configuration (applies to all environments)
   */
  static #baseConfig = {
    appName: 'CFAS Exam System',
    timeout: 60000,
    retryAttempts: 3
  }

  /**
   * Environment-specific overrides
   */
  static #environmentConfigs = {
    apache: {
      apiUrl: 'http://192.168.11.40/api',
      basePath: '/frontend/',
      debug: false,
      sourceMaps: false
    },
    local: {
      apiUrl: 'http://127.0.0.1:8000/api',
      basePath: '/',
      debug: true,
      sourceMaps: true
    },
    lan: {
      // Dynamic API URL based on current hostname
      apiUrl: 'http://192.168.11.40/api',
      basePath: '/frontend/',
      debug: false,
      sourceMaps: false
    },
    production: {
      apiUrl: 'https://yourdomain.com/api', // TODO: Update with actual production domain
      basePath: '/exam-frontend/',
      debug: false,
      sourceMaps: false
    }
  }

  /**
   * Initialize configuration with environment detection
   */
  static async initialize() {
    if (this.#initialized) {
      return
    }

    this.#environment = await EnvironmentDetector.detectEnvironment()
    
    // Get environment-specific config
    const envConfig = { ...this.#environmentConfigs[this.#environment] }

    // Handle dynamic LAN API URL
    if (this.#environment === 'lan' && !envConfig.apiUrl) {
      const hostname = EnvironmentDetector.getHostname()
      envConfig.apiUrl = `http://${hostname}:8000/api`
    }

    // Merge base config with environment config
    this.#config = {
      ...this.#baseConfig,
      ...envConfig,
      environment: this.#environment
    }

    // Validate configuration
    this.validate()

    // Validate connectivity for Apache environment
    if (this.#environment === 'apache') {
      await this.validateConnectivity()
    }

    this.#initialized = true

    // Log environment detection (only in development)
    if (this.#config.debug) {
      console.log(`[ConfigManager] Environment detected: ${this.#environment}`)
      console.log(`[ConfigManager] API URL: ${this.#config.apiUrl}`)
      console.log(`[ConfigManager] Base Path: ${this.#config.basePath}`)
    }
  }

  /**
   * Get configuration value
   * @param {string} key - Configuration key
   * @param {any} defaultValue - Default value if key not found
   * @returns {any}
   */
  static async get(key, defaultValue = null) {
    if (!this.#initialized) {
      await this.initialize()
    }

    return this.#config[key] !== undefined ? this.#config[key] : defaultValue
  }

  /**
   * Get API base URL for current environment
   * @returns {Promise<string>}
   */
  static async getApiUrl() {
    return await this.get('apiUrl')
  }

  /**
   * Get API base URL with fallback mechanism
   * @returns {Promise<string>}
   */
  static async getApiUrlWithFallback() {
    const apiUrl = await this.getApiUrl()
    
    // If current URL fails connectivity test, try auto-correction
    if (!(await this.validateConnectivity(apiUrl))) {
      console.warn(`[ConfigManager] Primary API URL failed: ${apiUrl}`)
      const correctedUrl = await this.autoCorrectConfiguration()
      if (correctedUrl) {
        console.log(`[ConfigManager] Auto-corrected to: ${correctedUrl}`)
        return correctedUrl
      }
    }
    
    return apiUrl
  }

  /**
   * Get base path for current environment
   * @returns {Promise<string>}
   */
  static async getBasePath() {
    return await this.get('basePath')
  }

  /**
   * Get current environment
   * @returns {Promise<'apache' | 'local' | 'lan' | 'production'>}
   */
  static async getEnvironment() {
    if (!this.#initialized) {
      await this.initialize()
    }
    return this.#environment
  }

  /**
   * Validate configuration
   * @throws {Error} if configuration is invalid
   */
  static validate() {
    const errors = []

    // Validate required fields
    if (!this.#config.apiUrl) {
      errors.push('API URL is required')
    }

    if (!this.#config.basePath) {
      errors.push('Base path is required')
    }

    // Validate API URL format
    if (this.#config.apiUrl && !this.#isValidUrl(this.#config.apiUrl)) {
      errors.push(`Invalid API URL format: ${this.#config.apiUrl}`)
    }

    // Validate base path format
    if (this.#config.basePath && !this.#isValidPath(this.#config.basePath)) {
      errors.push(`Invalid base path format: ${this.#config.basePath}`)
    }

    if (errors.length > 0) {
      const errorMessage = `Configuration validation failed:\n${errors.join('\n')}`
      console.error(errorMessage)
      throw new Error(errorMessage)
    }
  }

  /**
   * Validate URL format
   * @param {string} url
   * @returns {boolean}
   */
  static #isValidUrl(url) {
    try {
      const urlObj = new URL(url)
      return urlObj.protocol === 'http:' || urlObj.protocol === 'https:'
    } catch {
      return false
    }
  }

  /**
   * Validate path format
   * @param {string} path
   * @returns {boolean}
   */
  static #isValidPath(path) {
    // Path must start with /
    if (!path.startsWith('/')) {
      return false
    }

    // Path must be exactly "/" or end with "/"
    if (path !== '/' && !path.endsWith('/')) {
      return false
    }

    return true
  }

  /**
   * Validate API connectivity
   * @param {string} apiUrl - API URL to validate (optional, uses current config if not provided)
   * @returns {Promise<boolean>}
   */
  static async validateConnectivity(apiUrl = null) {
    const urlToTest = apiUrl || this.#config?.apiUrl
    if (!urlToTest) {
      return false
    }

    try {
      const healthUrl = `${urlToTest}/health`
      const response = await fetch(healthUrl, {
        method: 'GET',
        timeout: 5000,
        headers: {
          'Accept': 'application/json'
        }
      })
      
      const isValid = response.status === 200 || response.status === 401 || response.status === 404
      
      if (this.#config?.debug) {
        console.log(`[ConfigManager] Connectivity test for ${healthUrl}: ${isValid ? 'SUCCESS' : 'FAILED'}`)
      }
      
      return isValid
    } catch (error) {
      if (this.#config?.debug) {
        console.warn(`[ConfigManager] Connectivity test failed:`, error.message)
      }
      return false
    }
  }

  /**
   * Auto-correct configuration by testing alternative URLs
   * @returns {Promise<string|null>} Corrected API URL or null if none found
   */
  static async autoCorrectConfiguration() {
    const alternativeUrls = [
      'http://192.168.11.40/api',
      'http://localhost/api',
      'http://127.0.0.1/api',
      'http://127.0.0.1:8000/api'
    ]

    for (const url of alternativeUrls) {
      if (await this.validateConnectivity(url)) {
        // Update current configuration
        this.#config.apiUrl = url
        
        // Update environment if we found Apache backend
        if (url.includes('192.168.11.40') || url.includes('localhost')) {
          this.#environment = 'apache'
          this.#config.environment = 'apache'
        }
        
        console.log(`[ConfigManager] Auto-corrected API URL to: ${url}`)
        return url
      }
    }

    console.error('[ConfigManager] Auto-correction failed: No working API URL found')
    return null
  }

  /**
   * Get all configuration as object
   * @returns {Promise<object>}
   */
  static async getAll() {
    if (!this.#initialized) {
      await this.initialize()
    }
    return { ...this.#config }
  }

  /**
   * Reset configuration (useful for testing)
   */
  static reset() {
    this.#initialized = false
    this.#config = null
    this.#environment = null
    EnvironmentDetector.clearCache()
  }
}

export default ConfigManager
