<template>
  <div class="export-reports">
    <div class="dashboard-header">
      <div class="header-content">
        <div class="title-section">
          <h1 class="page-title">Export Results</h1>
          <p class="page-subtitle">Live database export preview with professional report organization</p>
        </div>
        <div class="connection-pill" :class="{ online: !loading && !loadError }">
          <span class="status-dot"></span>
          <span>{{ loading ? 'Syncing data' : loadError ? 'Connection issue' : 'Live database connected' }}</span>
        </div>
      </div>

      <div class="controls-row">
        <div class="filter-group">
          <label class="filter-label">Export Type</label>
          <select v-model="exportType" class="filter-select" @change="handleExportTypeChange">
            <option value="detailed">Student Results by Exam</option>
            <option value="students">Student Summary</option>
            <option value="professional">Professional Consolidated Report</option>
          </select>
        </div>

        <div class="filter-group">
          <label class="filter-label">Category</label>
          <select
            v-model="selectedCategory"
            class="filter-select"
            :disabled="exportType !== 'detailed'"
            @change="handleCategoryChange"
          >
            <option v-if="categories.length === 0" value="">No category available</option>
            <option v-for="category in categories" :key="category" :value="category">
              {{ category }}
            </option>
          </select>
        </div>

        <div class="filter-group">
          <label class="filter-label">Exam</label>
          <select
            v-model="selectedExamId"
            class="filter-select"
            :disabled="exportType !== 'detailed' || !selectedCategory"
            @change="loadPreview"
          >
            <option v-if="filteredExams.length === 0" value="">No exam available</option>
            <option v-for="exam in filteredExams" :key="exam.id" :value="String(exam.id)">
              {{ exam.title }}
            </option>
          </select>
        </div>

        <div class="filter-group">
          <label class="filter-label">File Format</label>
          <select v-model="exportFormat" class="filter-select">
            <option value="csv">CSV (Excel Compatible)</option>
            <option value="xlsx">XLSX (Auto-fit Friendly)</option>
          </select>
        </div>

        <button @click="loadPreview" class="btn-secondary" :disabled="loading">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" :class="{ spinning: loading }">
            <path d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
          </svg>
          <span>Refresh</span>
        </button>

        <button @click="exportData" class="btn-primary" :disabled="exporting || previewData.length === 0">
          <div v-if="exporting" class="btn-spinner"></div>
          <template v-else>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
            </svg>
            <span>Export {{ exportFormat.toUpperCase() }}</span>
          </template>
        </button>
      </div>
    </div>

    <div class="dashboard-content">
      <div class="stats-grid">
        <div class="stat-card">
          <div class="stat-label">Students</div>
          <div class="stat-value">{{ formatNumber(summaryMetrics.totalStudents) }}</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Total Attempts</div>
          <div class="stat-value">{{ formatNumber(summaryMetrics.totalAttempts) }}</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Pass Rate</div>
          <div class="stat-value">{{ summaryMetrics.passRate }}</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Rows in Preview</div>
          <div class="stat-value">{{ formatNumber(summaryMetrics.rowCount) }}</div>
        </div>
      </div>

      <div class="preview-section">
        <div class="preview-header">
          <div>
            <h3 class="preview-title">{{ previewTitle }}</h3>
            <p class="preview-subtitle">{{ previewSubtitle }}</p>
          </div>
          <div class="preview-meta">
            <span v-if="lastLoadedAt">Updated {{ formatDateTime(lastLoadedAt) }}</span>
            <span class="dot">•</span>
            <span>Source: Database</span>
          </div>
        </div>

        <div v-if="loading" class="loading-container">
          <div class="loading-spinner"></div>
          <p>Loading live records from the database...</p>
        </div>

        <div v-else-if="loadError" class="error-container">
          <h4>Unable to load export preview</h4>
          <p>{{ loadError }}</p>
          <button @click="loadPreview" class="btn-secondary">Try Again</button>
        </div>

        <div v-else-if="previewData.length === 0" class="empty-state">
          <h4>No records available</h4>
          <p>No export records were returned from the database for this view.</p>
        </div>

        <div v-else-if="exportType === 'professional'" class="table-container">
          <table class="preview-table professional-table">
            <tbody>
              <tr v-for="(row, rowIndex) in paginatedPreview" :key="rowIndex">
                <td
                  v-for="(cell, cellIndex) in row"
                  :key="`${rowIndex}-${cellIndex}`"
                  :class="getProfessionalCellClass(rowIndex, cell)"
                >
                  {{ cell }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div v-else class="table-container">
          <table class="preview-table">
            <thead>
              <tr>
                <th v-for="key in tableHeaders" :key="key" :class="getHeaderClass(key)">
                  {{ key }}
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(row, rowIndex) in paginatedPreview" :key="rowIndex">
                <td v-for="key in tableHeaders" :key="`${rowIndex}-${key}`" :class="getCellClass(key, row[key])">
                  <span v-if="isExamColumn(key)" class="result-pill" :class="getResultClass(row[key])">
                    {{ row[key] }}
                  </span>
                  <span v-else>{{ row[key] }}</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div v-if="previewData.length > itemsPerPage && !loading && !loadError" class="pagination">
          <button @click="currentPage--" :disabled="currentPage === 1" class="pagination-btn">Previous</button>
          <span class="pagination-info">Page {{ currentPage }} of {{ totalPages }}</span>
          <button @click="currentPage++" :disabled="currentPage === totalPages" class="pagination-btn">Next</button>
        </div>
      </div>
    </div>

    <transition name="notification-slide">
      <div v-if="showNotification" class="success-notification">
        <div class="notification-title">{{ notificationTitle }}</div>
        <div class="notification-message">{{ notificationMessage }}</div>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import api from '@/services/api'

const exportType = ref('detailed')
const exportFormat = ref('csv')
const selectedCategory = ref('')
const selectedExamId = ref('')
const categories = ref([])
const exams = ref([])
const previewData = ref([])
const loading = ref(false)
const exporting = ref(false)
const loadError = ref('')
const lastLoadedAt = ref(null)
const showNotification = ref(false)
const notificationTitle = ref('')
const notificationMessage = ref('')
const currentPage = ref(1)
const itemsPerPage = 25
const allAttemptMetrics = ref({
  totalAttempts: 0,
  passedAttempts: 0,
  failedAttempts: 0
})

const totalPages = computed(() => Math.max(1, Math.ceil(previewData.value.length / itemsPerPage)))

const paginatedPreview = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  return previewData.value.slice(start, start + itemsPerPage)
})

const tableHeaders = computed(() => {
  if (!previewData.value.length || exportType.value === 'professional') return []
  return Object.keys(previewData.value[0])
})

const filteredExams = computed(() => {
  if (!selectedCategory.value) return []
  return exams.value.filter(exam => exam.category === selectedCategory.value)
})

const selectedExam = computed(() => {
  if (!selectedExamId.value) return null
  return exams.value.find(exam => String(exam.id) === String(selectedExamId.value)) || null
})

const previewTitle = computed(() => {
  if (exportType.value === 'professional') return 'Professional Consolidated Report'
  if (exportType.value === 'students') return 'Student Summary Preview'
  return 'Student Results by Exam'
})

const previewSubtitle = computed(() => {
  const count = previewData.value.length
  if (!count) return 'No records loaded'
  if (exportType.value === 'detailed') {
    const categoryLabel = selectedCategory.value || 'Selected Category'
    const examLabel = selectedExam.value?.title || 'Selected Exam'
    return `${count} record${count !== 1 ? 's' : ''} loaded from ${categoryLabel} • ${examLabel}`
  }
  return `${count} record${count !== 1 ? 's' : ''} loaded from live database`
})

const summaryMetrics = computed(() => {
  const fallbackStudents = exportType.value === 'professional'
    ? getProfessionalStatistic('Total Students')
    : previewData.value.length

  const totalAttempts = allAttemptMetrics.value.totalAttempts
  const passedAttempts = allAttemptMetrics.value.passedAttempts
  const passRate = totalAttempts > 0 ? `${((passedAttempts / totalAttempts) * 100).toFixed(1)}%` : '0%'

  return {
    totalStudents: fallbackStudents,
    totalAttempts,
    passRate,
    rowCount: previewData.value.length
  }
})

onMounted(async () => {
  await loadCategories()
  await Promise.all([loadPreview(), loadAttemptMetrics()])
})

const exportEndpoints = {
  detailed: '/admin/export/all-results',
  students: '/admin/export/user-performance',
  professional: '/admin/export/professional-results'
}

const baseColumns = new Set([
  'Student Name',
  'Username',
  'First Name',
  'Last Name',
  'Full Name',
  'Email',
  'Status',
  'Registration Date',
  'Total Attempts',
  'Exams Taken',
  'Passed Attempts',
  'Failed Attempts',
  'Average Score',
  'Highest Score',
  'Lowest Score'
])

const normalizeString = (value) => String(value ?? '').toLowerCase()

const isExamColumn = (key) => !baseColumns.has(key)

const getHeaderClass = (key) => {
  if (key === 'Student Name' || key === 'Username') return 'header-student'
  if (isExamColumn(key)) return 'header-exam'
  return ''
}

const getCellClass = (key, value) => {
  if (key === 'Student Name' || key === 'Full Name') return 'cell-strong'
  if (key === 'Username') return 'cell-muted'
  if (!isExamColumn(key)) return ''
  return getResultClass(value)
}

const getResultClass = (value) => {
  const normalized = normalizeString(value)
  if (!normalized || normalized.includes('not taken')) return 'result-not-taken'
  if (normalized.includes('pass')) return 'result-passed'
  if (normalized.includes('fail')) return 'result-failed'
  return ''
}

const isSectionHeader = (cell) => {
  const text = String(cell ?? '').toUpperCase()
  return text.includes('STUDENT INFORMATION') ||
    text.includes('EXAM RESULTS') ||
    text.includes('OVERALL PERFORMANCE') ||
    text.includes('REPORT STATISTICS')
}

const getProfessionalCellClass = (rowIndex, cell) => {
  const text = String(cell ?? '')
  if (rowIndex === 0) return 'title-cell'
  if (rowIndex <= 2) return 'meta-cell'
  if (isSectionHeader(cell)) return 'section-cell'
  if (rowIndex === 5 || rowIndex === 8) return 'column-cell'
  if (!text.trim()) return 'spacer-cell'
  if (text.includes('%')) return 'percentage-cell'
  if (normalizeString(text).includes('pass')) return 'result-passed'
  if (normalizeString(text).includes('fail')) return 'result-failed'
  return ''
}

const getProfessionalStatistic = (label) => {
  const row = previewData.value.find(item => Array.isArray(item) && item[0] === label)
  const numericValue = Number.parseInt(row?.[1], 10)
  return Number.isNaN(numericValue) ? 0 : numericValue
}

const loadAttemptMetrics = async () => {
  try {
    const response = await api.get('/admin/export/all-attempts')
    const attempts = response.data?.success ? response.data.data || [] : []
    const passedAttempts = attempts.filter(attempt => Number(attempt.percentage) >= 90).length
    allAttemptMetrics.value = {
      totalAttempts: attempts.length,
      passedAttempts,
      failedAttempts: Math.max(0, attempts.length - passedAttempts)
    }
  } catch (error) {
    console.error('Failed to load attempt metrics:', error)
  }
}

const loadCategories = async () => {
  try {
    const response = await api.get('/admin/exams')
    const examRows = Array.isArray(response.data?.exams)
      ? response.data.exams
      : Array.isArray(response.data?.data)
        ? response.data.data
        : (Array.isArray(response.data) ? response.data : [])

    exams.value = examRows
      .filter(exam => exam && exam.id && typeof exam.title === 'string')
      .map(exam => ({
        id: exam.id,
        title: exam.title,
        category: typeof exam.category === 'string' ? exam.category.trim() : ''
      }))
      .filter(exam => exam.category !== '')

    categories.value = [...new Set(
      exams.value
        .map(exam => exam?.category)
        .filter(category => typeof category === 'string' && category.trim() !== '')
        .map(category => category.trim())
    )].sort((a, b) => a.localeCompare(b))

    if (!selectedCategory.value || !categories.value.includes(selectedCategory.value)) {
      selectedCategory.value = categories.value[0] || ''
    }
    syncSelectedExam()
  } catch (error) {
    categories.value = []
    exams.value = []
    selectedCategory.value = ''
    selectedExamId.value = ''
    console.error('Failed to load categories:', error)
  }
}

const syncSelectedExam = () => {
  const currentExams = filteredExams.value
  if (!currentExams.length) {
    selectedExamId.value = ''
    return
  }

  const hasCurrent = currentExams.some(exam => String(exam.id) === String(selectedExamId.value))
  if (!hasCurrent) {
    selectedExamId.value = String(currentExams[0].id)
  }
}

const handleCategoryChange = async () => {
  syncSelectedExam()
  await loadPreview()
}

const handleExportTypeChange = async () => {
  if (exportType.value === 'detailed' && !selectedCategory.value) {
    await loadCategories()
  } else if (exportType.value === 'detailed') {
    syncSelectedExam()
  }
  await loadPreview()
}

const loadPreview = async () => {
  loading.value = true
  loadError.value = ''
  currentPage.value = 1

  try {
    const endpoint = exportEndpoints[exportType.value] || exportEndpoints.detailed
    const params = {}
    if (exportType.value === 'detailed' && selectedCategory.value) {
      params.category = selectedCategory.value
      if (selectedExamId.value) {
        params.exam_id = selectedExamId.value
      }
    }

    const response = await api.get(endpoint, { params })
    if (!response.data?.success) {
      throw new Error(response.data?.message || 'Failed to load export preview')
    }
    previewData.value = response.data.data || []
    lastLoadedAt.value = new Date()
  } catch (error) {
    previewData.value = []
    loadError.value = error.response?.data?.message || error.message || 'Unexpected error while loading preview'
  } finally {
    loading.value = false
  }
}

const arrayToCSV = (data) => {
  if (!data || data.length === 0) return ''
  const csvRows = []

  for (const row of data) {
    if (Array.isArray(row)) {
      csvRows.push(row.map(escapeCsvValue).join(','))
      continue
    }

    const headers = Object.keys(row)
    if (csvRows.length === 0) {
      csvRows.push(headers.map(escapeCsvValue).join(','))
    }
    csvRows.push(headers.map(header => escapeCsvValue(row[header])).join(','))
  }

  return csvRows.join('\n')
}

const escapeCsvValue = (value) => `"${String(value ?? '').replace(/"/g, '""')}"`

const exportData = async () => {
  if (previewData.value.length === 0) return
  exporting.value = true

  try {
    if (exportFormat.value === 'xlsx') {
      await exportXlsxFromServer()
      notificationTitle.value = 'Export successful'
      notificationMessage.value = `Saved ${previewData.value.length} row(s) from live database`
      showNotification.value = true
      return
    }

    const csvContent = arrayToCSV(previewData.value)
    const timestamp = new Date().toISOString().slice(0, 10)
    const categorySlug = selectedCategory.value ? slugify(selectedCategory.value) : 'selected-category'
    const examSlug = selectedExam.value?.title ? slugify(selectedExam.value.title) : 'selected-exam'
    const exportNames = {
      detailed: `cfas-student-exam-results-${categorySlug}-${examSlug}-${timestamp}.csv`,
      students: `cfas-student-summary-${timestamp}.csv`,
      professional: `cfas-professional-results-${timestamp}.csv`
    }
    downloadCSV(csvContent, exportNames[exportType.value] || `cfas-export-${timestamp}.csv`)
    notificationTitle.value = 'Export successful'
    notificationMessage.value = `Saved ${previewData.value.length} row(s) from live database`
    showNotification.value = true
  } catch (error) {
    notificationTitle.value = 'Export failed'
    notificationMessage.value = error.message || 'Unable to complete export'
    showNotification.value = true
  } finally {
    exporting.value = false
    setTimeout(() => {
      showNotification.value = false
    }, 3500)
  }
}

const exportXlsxFromServer = async () => {
  const params = getExportParams()
  const response = await api.get('/admin/export/xlsx', {
    params,
    responseType: 'blob'
  })

  const fallbackDate = new Date().toISOString().slice(0, 10)
  const fallbackName = `cfas-export-${fallbackDate}.xlsx`
  const contentDisposition = response.headers?.['content-disposition']
  const filename = parseFilenameFromDisposition(contentDisposition) || fallbackName
  downloadBlob(response.data, filename)
}

const getExportParams = () => {
  const params = { type: exportType.value }
  if (exportType.value === 'detailed' && selectedCategory.value) {
    params.category = selectedCategory.value
    if (selectedExamId.value) {
      params.exam_id = selectedExamId.value
    }
  }
  return params
}

const parseFilenameFromDisposition = (contentDisposition) => {
  if (!contentDisposition || typeof contentDisposition !== 'string') return ''
  const utfMatch = contentDisposition.match(/filename\*=UTF-8''([^;]+)/i)
  if (utfMatch?.[1]) {
    return decodeURIComponent(utfMatch[1].replace(/["']/g, ''))
  }

  const plainMatch = contentDisposition.match(/filename="?([^"]+)"?/i)
  return plainMatch?.[1] || ''
}

const slugify = (value) => String(value ?? '').toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '') || 'export'

const downloadCSV = (csvContent, filename) => {
  const BOM = '\uFEFF'
  const blob = new Blob([BOM + csvContent], { type: 'text/csv;charset=utf-8;' })
  downloadBlob(blob, filename)
}

const downloadBlob = (blobContent, filename) => {
  const blob = blobContent instanceof Blob ? blobContent : new Blob([blobContent])
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = filename
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  URL.revokeObjectURL(url)
}

const formatDateTime = (value) => new Date(value).toLocaleString('en-US', {
  month: 'short',
  day: '2-digit',
  year: 'numeric',
  hour: '2-digit',
  minute: '2-digit'
})

const formatNumber = (value) => new Intl.NumberFormat('en-US').format(Number(value) || 0)
</script>

<style scoped>
.export-reports {
  min-height: 100vh;
  background: #F5F5F7;
}

.dashboard-header {
  background: #FFFFFF;
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
  padding: 24px 32px;
  position: sticky;
  top: 0;
  z-index: 100;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 20px;
  margin-bottom: 20px;
}

.page-title {
  margin: 0;
  font-size: 32px;
  font-weight: 700;
  color: #1D1D1F;
  letter-spacing: -0.8px;
}

.page-subtitle {
  margin: 6px 0 0 0;
  font-size: 15px;
  color: #86868B;
  font-weight: 500;
}

.connection-pill {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 8px 12px;
  border-radius: 999px;
  border: 1px solid rgba(255, 59, 48, 0.2);
  background: rgba(255, 59, 48, 0.08);
  color: #FF3B30;
  font-size: 12px;
  font-weight: 600;
}

.connection-pill.online {
  border-color: rgba(52, 199, 89, 0.24);
  background: rgba(52, 199, 89, 0.1);
  color: #1D1D1F;
}

.status-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #FF3B30;
}

.connection-pill.online .status-dot {
  background: #34C759;
}

.controls-row {
  display: grid;
  grid-template-columns: minmax(220px, 1.1fr) minmax(180px, 1fr) minmax(220px, 1.1fr) minmax(160px, 1fr) auto auto;
  gap: 12px;
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.filter-label {
  font-size: 12px;
  color: #86868B;
  font-weight: 600;
}

.filter-select {
  border: 1px solid rgba(0, 0, 0, 0.1);
  border-radius: 8px;
  background: #FFFFFF;
  font-size: 14px;
  color: #1D1D1F;
  padding: 10px 12px;
}

.filter-select:focus {
  outline: none;
  border-color: #007AFF;
  box-shadow: 0 0 0 3px rgba(0, 122, 255, 0.1);
}

.btn-primary,
.btn-secondary {
  border: none;
  border-radius: 10px;
  padding: 0 18px;
  height: 40px;
  font-size: 14px;
  font-weight: 600;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  align-self: end;
}

.btn-primary {
  background: #007AFF;
  color: #FFFFFF;
}

.btn-primary:hover:not(:disabled) {
  background: #005ed1;
}

.btn-secondary {
  background: #F5F5F7;
  color: #1D1D1F;
  border: 1px solid rgba(0, 0, 0, 0.1);
}

.btn-secondary:hover:not(:disabled) {
  background: #ECECEF;
}

.btn-primary:disabled,
.btn-secondary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-secondary svg,
.btn-primary svg {
  width: 18px;
  height: 18px;
  stroke-width: 2;
}

.spinning {
  animation: spin 1s linear infinite;
}

.btn-spinner {
  width: 16px;
  height: 16px;
  border-radius: 50%;
  border: 2px solid rgba(255, 255, 255, 0.35);
  border-top-color: #FFFFFF;
  animation: spin 0.9s linear infinite;
}

.dashboard-content {
  padding: 24px 32px;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 12px;
  margin-bottom: 16px;
}

.stat-card {
  background: #FFFFFF;
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 12px;
  padding: 14px 16px;
}

.stat-label {
  font-size: 12px;
  font-weight: 600;
  color: #86868B;
  margin-bottom: 6px;
}

.stat-value {
  font-size: 24px;
  font-weight: 700;
  color: #1D1D1F;
}

.preview-section {
  background: #FFFFFF;
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 16px;
  overflow: hidden;
}

.preview-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  padding: 20px;
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
}

.preview-title {
  margin: 0;
  font-size: 20px;
  color: #1D1D1F;
}

.preview-subtitle {
  margin: 6px 0 0 0;
  font-size: 13px;
  color: #86868B;
}

.preview-meta {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  color: #86868B;
}

.dot {
  color: #C7C7CC;
}

.loading-container,
.error-container,
.empty-state {
  padding: 72px 24px;
  text-align: center;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  margin: 0 auto 14px auto;
  border-radius: 50%;
  border: 3px solid #E5E5EA;
  border-top-color: #007AFF;
  animation: spin 1s linear infinite;
}

.error-container h4,
.empty-state h4 {
  margin: 0 0 8px 0;
  font-size: 20px;
  color: #1D1D1F;
}

.error-container p,
.empty-state p,
.loading-container p {
  margin: 0;
  color: #86868B;
}

.table-container {
  overflow: auto;
  max-height: 64vh;
}

.preview-table {
  width: 100%;
  border-collapse: collapse;
}

.preview-table thead {
  position: sticky;
  top: 0;
  z-index: 5;
}

.preview-table th {
  background: #F5F5F7;
  border-bottom: 1px solid rgba(0, 0, 0, 0.08);
  color: #86868B;
  font-size: 12px;
  font-weight: 700;
  text-align: left;
  padding: 12px 14px;
  white-space: nowrap;
}

.preview-table td {
  border-bottom: 1px solid rgba(0, 0, 0, 0.04);
  color: #1D1D1F;
  font-size: 13px;
  padding: 11px 14px;
  white-space: nowrap;
}

.preview-table tbody tr:hover {
  background: #FAFAFB;
}

.header-student {
  color: #007AFF !important;
}

.header-exam {
  color: #FF9500 !important;
}

.cell-strong {
  font-weight: 600;
}

.cell-muted {
  color: #86868B;
}

.result-pill {
  display: inline-flex;
  border-radius: 999px;
  font-weight: 600;
  padding: 3px 10px;
  font-size: 12px;
}

.result-passed {
  color: #22934A;
  background: rgba(52, 199, 89, 0.16);
}

.result-failed {
  color: #D9281A;
  background: rgba(255, 59, 48, 0.16);
}

.result-not-taken {
  color: #6E6E73;
  background: rgba(142, 142, 147, 0.18);
}

.professional-table td {
  white-space: nowrap;
}

.title-cell {
  font-size: 18px !important;
  font-weight: 700;
  background: rgba(0, 122, 255, 0.1);
}

.meta-cell {
  font-size: 12px !important;
  color: #6E6E73 !important;
  background: #F5F5F7;
}

.section-cell {
  font-weight: 700;
  font-size: 14px !important;
  color: #1D1D1F !important;
  background: rgba(52, 199, 89, 0.1);
}

.column-cell {
  background: #F5F5F7;
  font-weight: 600;
  color: #6E6E73;
}

.percentage-cell {
  font-weight: 600;
}

.spacer-cell {
  background: transparent !important;
  border-bottom: none !important;
  height: 10px;
}

.pagination {
  padding: 14px 20px;
  border-top: 1px solid rgba(0, 0, 0, 0.06);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 14px;
}

.pagination-btn {
  border: 1px solid rgba(0, 0, 0, 0.1);
  border-radius: 8px;
  background: #FFFFFF;
  padding: 8px 14px;
  font-size: 13px;
  font-weight: 600;
  color: #1D1D1F;
  cursor: pointer;
}

.pagination-btn:disabled {
  opacity: 0.45;
  cursor: not-allowed;
}

.pagination-info {
  font-size: 13px;
  color: #6E6E73;
  font-weight: 600;
}

.success-notification {
  position: fixed;
  right: 24px;
  top: 24px;
  z-index: 9999;
  background: #FFFFFF;
  border-radius: 12px;
  border: 1px solid rgba(0, 0, 0, 0.08);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
  padding: 12px 16px;
  min-width: 260px;
}

.notification-title {
  font-size: 14px;
  font-weight: 700;
  color: #1D1D1F;
}

.notification-message {
  margin-top: 4px;
  font-size: 13px;
  color: #6E6E73;
}

.notification-slide-enter-active,
.notification-slide-leave-active {
  transition: all 0.25s ease;
}

.notification-slide-enter-from,
.notification-slide-leave-to {
  opacity: 0;
  transform: translateX(25px);
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

@media (max-width: 1100px) {
  .controls-row {
    grid-template-columns: 1fr 1fr;
  }

  .stats-grid {
    grid-template-columns: 1fr 1fr;
  }
}

@media (max-width: 768px) {
  .dashboard-header,
  .dashboard-content {
    padding: 16px;
  }

  .header-content {
    flex-direction: column;
    align-items: flex-start;
  }

  .controls-row {
    grid-template-columns: 1fr;
  }

  .btn-primary,
  .btn-secondary {
    width: 100%;
    justify-content: center;
  }

  .stats-grid {
    grid-template-columns: 1fr;
  }

  .preview-header {
    flex-direction: column;
    align-items: flex-start;
  }
}
</style>
