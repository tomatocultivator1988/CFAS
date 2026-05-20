<template>
  <div class="diagnostic-page">
    <div class="diagnostic-container">
      <div class="diagnostic-header">
        <h1>System Diagnostics</h1>
        <p>Environment configuration and connectivity status</p>
      </div>

      <button @click="runDiagnostics" class="run-button" :disabled="loading">
        <span v-if="loading">Running diagnostics...</span>
        <span v-else>Run Diagnostics</span>
      </button>

      <div v-if="results" class="results-container">
        <!-- Summary -->
        <div class="summary-card">
          <h2>Summary</h2>
          <div class="summary-stats">
            <div class="stat passed">
              <span class="stat-value">{{ results.summary.passed }}</span>
              <span class="stat-label">Passed</span>
            </div>
            <div class="stat failed">
              <span class="stat-value">{{ results.summary.failed }}</span>
              <span class="stat-label">Failed</span>
            </div>
            <div class="stat warnings">
              <span class="stat-value">{{ results.summary.warnings }}</span>
              <span class="stat-label">Warnings</span>
            </div>
          </div>
        </div>

        <!-- Environment Check -->
        <div class="check-card">
          <h3>
            <span :class="['status-icon', results.checks.environment.status]">
              {{ getStatusIcon(results.checks.environment.status) }}
            </span>
            Environment Detection
          </h3>
          <p class="check-message">{{ results.checks.environment.message }}</p>
          <div v-if="results.checks.environment.details" class="check-details">
            <div class="detail-item">
              <strong>Environment:</strong> {{ results.checks.environment.details.environment }}
            </div>
            <div class="detail-item">
              <strong>Hostname:</strong> {{ results.checks.environment.details.hostname }}
            </div>
          </div>
        </div>

        <!-- Configuration Check -->
        <div class="check-card">
          <h3>
            <span :class="['status-icon', results.checks.configuration.status]">
              {{ getStatusIcon(results.checks.configuration.status) }}
            </span>
            Configuration
          </h3>
          <p class="check-message">{{ results.checks.configuration.message }}</p>
          <div v-if="results.checks.configuration.details" class="check-details">
            <div class="detail-item">
              <strong>API URL:</strong> {{ results.checks.configuration.details.apiUrl }}
            </div>
            <div class="detail-item">
              <strong>Base Path:</strong> {{ results.checks.configuration.details.basePath }}
            </div>
            <div class="detail-item">
              <strong>Debug Mode:</strong> {{ results.checks.configuration.details.debug ? 'Enabled' : 'Disabled' }}
            </div>
          </div>
        </div>

        <!-- Assets Check -->
        <div class="check-card">
          <h3>
            <span :class="['status-icon', results.checks.assets.status]">
              {{ getStatusIcon(results.checks.assets.status) }}
            </span>
            Critical Assets
          </h3>
          <p class="check-message">{{ results.checks.assets.message }}</p>
          <div v-if="results.checks.assets.assets" class="assets-list">
            <div v-for="asset in results.checks.assets.assets" :key="asset.path" class="asset-item">
              <span :class="['asset-status', asset.exists ? 'exists' : 'missing']">
                {{ asset.exists ? '✓' : '✗' }}
              </span>
              <span class="asset-path">{{ asset.path }}</span>
            </div>
          </div>
        </div>

        <!-- API Check -->
        <div class="check-card">
          <h3>
            <span :class="['status-icon', results.checks.api.status]">
              {{ getStatusIcon(results.checks.api.status) }}
            </span>
            API Connectivity
          </h3>
          <p class="check-message">{{ results.checks.api.message }}</p>
          <div v-if="results.checks.api.details" class="check-details">
            <div class="detail-item">
              <strong>Endpoint:</strong> {{ results.checks.api.details.endpoint }}
            </div>
            <div v-if="results.checks.api.details.responseTime" class="detail-item">
              <strong>Response Time:</strong> {{ results.checks.api.details.responseTime }}ms
            </div>
            <div v-if="results.checks.api.details.statusCode" class="detail-item">
              <strong>Status Code:</strong> {{ results.checks.api.details.statusCode }}
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import ConfigManager from '@/config/configManager'
import EnvironmentDetector from '@/config/environmentDetector'
import { getCriticalAssets, verifyAsset, getPublicAssetPath } from '@/utils/assetPath'
import { testApiConnection, getApiBaseUrl } from '@/services/api'

const loading = ref(false)
const results = ref(null)

const getStatusIcon = (status) => {
  switch (status) {
    case 'pass': return '✓'
    case 'fail': return '✗'
    case 'warning': return '⚠'
    default: return '?'
  }
}

const runDiagnostics = async () => {
  loading.value = true
  
  const diagnosticResults = {
    timestamp: new Date().toISOString(),
    environment: ConfigManager.getEnvironment(),
    checks: {
      environment: await checkEnvironment(),
      configuration: checkConfiguration(),
      assets: await checkAssets(),
      api: await checkApiConnection()
    },
    summary: {
      passed: 0,
      failed: 0,
      warnings: 0
    }
  }

  // Calculate summary
  Object.values(diagnosticResults.checks).forEach(check => {
    if (check.status === 'pass') diagnosticResults.summary.passed++
    else if (check.status === 'fail') diagnosticResults.summary.failed++
    else if (check.status === 'warning') diagnosticResults.summary.warnings++
  })

  results.value = diagnosticResults
  loading.value = false
}

const checkEnvironment = async () => {
  try {
    const environment = EnvironmentDetector.detectEnvironment()
    const hostname = EnvironmentDetector.getHostname()

    return {
      status: 'pass',
      message: `Environment detected successfully as "${environment}"`,
      details: {
        environment,
        hostname
      }
    }
  } catch (error) {
    return {
      status: 'fail',
      message: `Failed to detect environment: ${error.message}`,
      details: null
    }
  }
}

const checkConfiguration = () => {
  try {
    const config = ConfigManager.getAll()

    return {
      status: 'pass',
      message: 'Configuration loaded successfully',
      details: {
        apiUrl: config.apiUrl,
        basePath: config.basePath,
        debug: config.debug
      }
    }
  } catch (error) {
    return {
      status: 'fail',
      message: `Configuration error: ${error.message}`,
      details: null
    }
  }
}

const checkAssets = async () => {
  try {
    const criticalAssets = getCriticalAssets()
    const assetChecks = []

    for (const asset of criticalAssets) {
      const assetPath = getPublicAssetPath(asset)
      const exists = await verifyAsset(assetPath)
      assetChecks.push({
        path: asset,
        exists
      })
    }

    const missingAssets = assetChecks.filter(a => !a.exists)

    if (missingAssets.length === 0) {
      return {
        status: 'pass',
        message: 'All critical assets are accessible',
        assets: assetChecks
      }
    } else if (missingAssets.length < criticalAssets.length) {
      return {
        status: 'warning',
        message: `${missingAssets.length} critical asset(s) missing`,
        assets: assetChecks
      }
    } else {
      return {
        status: 'fail',
        message: 'All critical assets are missing',
        assets: assetChecks
      }
    }
  } catch (error) {
    return {
      status: 'fail',
      message: `Asset check failed: ${error.message}`,
      assets: []
    }
  }
}

const checkApiConnection = async () => {
  const startTime = Date.now()
  
  try {
    const isConnected = await testApiConnection()
    const responseTime = Date.now() - startTime

    if (isConnected) {
      return {
        status: 'pass',
        message: 'API is reachable',
        details: {
          endpoint: getApiBaseUrl(),
          responseTime,
          statusCode: 200
        }
      }
    } else {
      return {
        status: 'fail',
        message: 'API is not reachable',
        details: {
          endpoint: getApiBaseUrl(),
          responseTime
        }
      }
    }
  } catch (error) {
    return {
      status: 'fail',
      message: `API connection failed: ${error.message}`,
      details: {
        endpoint: getApiBaseUrl()
      }
    }
  }
}
</script>

<style scoped>
.diagnostic-page {
  min-height: 100vh;
  background: #f5f5f7;
  padding: 2rem;
}

.diagnostic-container {
  max-width: 1200px;
  margin: 0 auto;
}

.diagnostic-header {
  text-align: center;
  margin-bottom: 2rem;
}

.diagnostic-header h1 {
  font-size: 2.5rem;
  font-weight: 700;
  color: #1d1d1f;
  margin-bottom: 0.5rem;
}

.diagnostic-header p {
  font-size: 1.125rem;
  color: #6e6e73;
}

.run-button {
  display: block;
  margin: 0 auto 2rem;
  padding: 1rem 2rem;
  background: #0071e3;
  color: white;
  border: none;
  border-radius: 12px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.run-button:hover:not(:disabled) {
  background: #0077ed;
  transform: translateY(-2px);
}

.run-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.results-container {
  display: grid;
  gap: 1.5rem;
}

.summary-card,
.check-card {
  background: white;
  border-radius: 16px;
  padding: 2rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.summary-card h2,
.check-card h3 {
  font-size: 1.5rem;
  font-weight: 600;
  color: #1d1d1f;
  margin-bottom: 1rem;
}

.summary-stats {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1rem;
}

.stat {
  text-align: center;
  padding: 1rem;
  border-radius: 12px;
}

.stat.passed {
  background: #e8f5e9;
}

.stat.failed {
  background: #ffebee;
}

.stat.warnings {
  background: #fff3e0;
}

.stat-value {
  display: block;
  font-size: 2rem;
  font-weight: 700;
  margin-bottom: 0.25rem;
}

.stat.passed .stat-value {
  color: #2e7d32;
}

.stat.failed .stat-value {
  color: #c62828;
}

.stat.warnings .stat-value {
  color: #f57c00;
}

.stat-label {
  display: block;
  font-size: 0.875rem;
  color: #6e6e73;
}

.status-icon {
  display: inline-block;
  width: 24px;
  height: 24px;
  line-height: 24px;
  text-align: center;
  border-radius: 50%;
  margin-right: 0.5rem;
  font-weight: 700;
}

.status-icon.pass {
  background: #4caf50;
  color: white;
}

.status-icon.fail {
  background: #f44336;
  color: white;
}

.status-icon.warning {
  background: #ff9800;
  color: white;
}

.check-message {
  color: #6e6e73;
  margin-bottom: 1rem;
}

.check-details,
.assets-list {
  background: #f5f5f7;
  border-radius: 8px;
  padding: 1rem;
}

.detail-item {
  padding: 0.5rem 0;
  border-bottom: 1px solid #e5e5e7;
}

.detail-item:last-child {
  border-bottom: none;
}

.detail-item strong {
  color: #1d1d1f;
  margin-right: 0.5rem;
}

.asset-item {
  display: flex;
  align-items: center;
  padding: 0.5rem 0;
  border-bottom: 1px solid #e5e5e7;
}

.asset-item:last-child {
  border-bottom: none;
}

.asset-status {
  width: 24px;
  height: 24px;
  line-height: 24px;
  text-align: center;
  border-radius: 50%;
  margin-right: 0.75rem;
  font-weight: 700;
}

.asset-status.exists {
  background: #4caf50;
  color: white;
}

.asset-status.missing {
  background: #f44336;
  color: white;
}

.asset-path {
  color: #6e6e73;
  font-family: 'SF Mono', 'Monaco', 'Courier New', monospace;
  font-size: 0.875rem;
}
</style>
