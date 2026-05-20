<template>
  <div class="ml-dashboard-container">
    <!-- Embedded Python ML Dashboard -->
    <iframe 
      src="http://localhost:5000" 
      class="ml-dashboard-iframe"
      frameborder="0"
      title="ML Analytics Dashboard"
    ></iframe>
  </div>
</template>

<script>
export default {
  name: 'MLDashboard'
}
</script>

<style scoped>
.ml-dashboard-container {
  width: 100%;
  height: calc(100vh - 60px);
  padding: 0;
  margin: 0;
  overflow: hidden;
}

.ml-dashboard-iframe {
  width: 100%;
  height: 100%;
  border: none;
  display: block;
}
</style>

<!-- OLD CODE BELOW - KEEPING FOR REFERENCE -->
<!--
<template>
  <div class="ios-ml-dashboard">
    <!-- Header -->
    <div class="ios-header">
      <div class="header-content">
        <h1>ML Predictions</h1>
        <p>AI-powered performance insights</p>
      </div>
      <button @click="refreshAll" class="refresh-btn" :class="{ spinning: loading }">
        <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
          <path d="M17.5 10C17.5 14.1421 14.1421 17.5 10 17.5C5.85786 17.5 2.5 14.1421 2.5 10C2.5 5.85786 5.85786 2.5 10 2.5C12.0711 2.5 13.9461 3.35714 15.3033 4.75" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
          <path d="M15 2.5V5H12.5" stroke="currentColor" stro

    <!-- Stats Cards -->
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-value">{{ allStudents.length }}</div>
        <div class="stat-label">Students</div>
      </div>
      <div class="stat-card">
        <div class="stat-value">{{ atRiskCount }}</div>
        <div class="stat-label">At Risk</div>
      </div>
      <div class="stat-card">
        <div class="stat-value">{{ metrics?.accuracy || 0 }}%</div>
        <div class="stat-label">Accuracy</div>
      </div>
      <div class="stat-card">
        <div class="stat-value">{{ goodCount }}</div>
        <div class="stat-label">Good</div>
      </div>
    </div>

    <!-- Filter Chips -->
    <div class="filter-section">
      <button 
        @click="filterStatus = 'all'" 
        class="filter-chip"
        :class="{ active: filterStatus === 'all' }"
      >
        All
      </button>
      <button 
        @click="filterStatus = 'at-risk'" 
        class="filter-chip risk"
        :class="{ active: filterStatus === 'at-risk' }"
      >
        At Risk
      </button>
      <button 
        @click="filterStatus = 'good'" 
        class="filter-chip good"
        :class="{ active: filterStatus === 'good' }"
      >
        Good
      </button>
    </div>

    <!-- Enhanced Analysis Section -->
    <div class="analysis-section">
      <div class="analysis-controls">
        <select v-model="selectedStudentId" class="student-select">
          <option value="">-- Select a Student --</option>
          <option v-for="student in allStudents" :key="student.student_id" :value="student.student_id">
            {{ student.full_name }} ({{ student.total_attempts || 0 }} exams)
          </option>
        </select>
        <button @click="analyzeStudent" class="analyze-btn" :disabled="!selectedStudentId">
          <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
            <path d="M8 2V14M2 8H14" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
          </svg>
          Analyze Student
        </button>
        <button @click="analyzeQuestions" class="analyze-btn secondary">
          <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
            <path d="M2 4H14M2 8H14M2 12H14" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
          </svg>
          Analyze Questions
        </button>
      </div>

      <!-- Analysis Results -->
      <div v-if="analysisLoading" class="analysis-loading">
        <div class="loading-spinner"></div>
        <p>{{ analysisMessage }}</p>
      </div>

      <!-- Student Analysis Results -->
      <div v-if="studentAnalysis" class="analysis-results">
        <div class="analysis-cards">
          <!-- Board Exam Readiness -->
          <div class="analysis-card readiness" :style="{ borderLeftColor: getReadinessColor(studentAnalysis.board_readiness.passing_probability) }">
            <h3>🎓 Board Exam Readiness</h3>
            
            <div class="metric-group">
              <span class="metric-label">Readiness Level</span>
              <span class="metric-value large" :style="{ color: getReadinessColor(studentAnalysis.board_readiness.passing_probability) }">
                {{ formatReadinessLevel(studentAnalysis.board_readiness.readiness_level) }}
              </span>
            </div>

            <div class="metric-group">
              <span class="metric-label">Passing Probability</span>
              <span class="metric-value xlarge" :style="{ color: getReadinessColor(studentAnalysis.board_readiness.passing_probability) }">
                {{ studentAnalysis.board_readiness.passing_probability.toFixed(1) }}%
              </span>
              <div class="progress-bar-container">
                <div class="progress-bar-fill" 
                     :style="{ 
                       width: studentAnalysis.board_readiness.passing_probability + '%',
                       background: getReadinessColor(studentAnalysis.board_readiness.passing_probability)
                     }">
                </div>
              </div>
              <span class="metric-hint">Chance of scoring 75%+ on board exam</span>
            </div>

            <div class="metric-group">
              <span class="metric-label">Predicted Board Score</span>
              <span class="metric-value large">{{ studentAnalysis.board_readiness.predicted_score.toFixed(1) }}%</span>
              <span class="metric-hint">Expected actual score on board exam</span>
            </div>

            <div class="metric-details">
              <p><strong>Confidence Range:</strong> {{ studentAnalysis.board_readiness.confidence_interval.lower_bound.toFixed(0) }}% - {{ studentAnalysis.board_readiness.confidence_interval.upper_bound.toFixed(0) }}%</p>
              <p><strong>Ready Date:</strong> {{ studentAnalysis.board_readiness.estimated_ready_date }}</p>
              <p><strong>Practice Exams:</strong> {{ studentAnalysis.total_attempts }}</p>
            </div>

            <div v-if="studentAnalysis.board_readiness.recommendations.length > 0" class="recommendations">
              <p class="rec-title">💡 Recommendations:</p>
              <ul>
                <li v-for="(rec, i) in studentAnalysis.board_readiness.recommendations.slice(0, 3)" :key="i">{{ rec }}</li>
              </ul>
            </div>
          </div>

          <!-- Next Attempt Prediction -->
          <div class="analysis-card next-attempt">
            <h3>📈 Next Attempt Prediction</h3>

            <div class="metric-group">
              <span class="metric-label">Predicted Score</span>
              <span class="metric-value xlarge" style="color: #3b82f6;">
                {{ studentAnalysis.next_attempt.predicted_score.toFixed(1) }}%
              </span>
              <div class="progress-bar-container">
                <div class="progress-bar-fill" 
                     :style="{ 
                       width: studentAnalysis.next_attempt.predicted_score + '%',
                       background: '#3b82f6'
                     }">
                </div>
              </div>
            </div>

            <div class="metric-group">
              <span class="metric-label">Prediction Confidence</span>
              <span class="metric-value large">{{ studentAnalysis.next_attempt.confidence.toFixed(1) }}%</span>
            </div>

            <div class="metric-group">
              <span class="metric-label">Expected Change</span>
              <span class="metric-value large" :style="{ color: studentAnalysis.next_attempt.improvement > 0 ? '#10b981' : '#ef4444' }">
                {{ studentAnalysis.next_attempt.improvement > 0 ? '+' : '' }}{{ studentAnalysis.next_attempt.improvement.toFixed(1) }}%
              </span>
            </div>

            <div class="metric-details">
              <p><strong>Score Range:</strong> {{ studentAnalysis.next_attempt.confidence_interval.lower_bound.toFixed(0) }}% - {{ studentAnalysis.next_attempt.confidence_interval.upper_bound.toFixed(0) }}%</p>
              <p><strong>Difficulty:</strong> {{ studentAnalysis.next_attempt.expected_difficulty }}</p>
              <p><strong>Study Time:</strong> {{ studentAnalysis.next_attempt.optimal_study_time }}</p>
            </div>

            <div v-if="studentAnalysis.next_attempt.recommendations.length > 0" class="recommendations blue">
              <p class="rec-title">💡 Preparation Tips:</p>
              <ul>
                <li v-for="(rec, i) in studentAnalysis.next_attempt.recommendations.slice(0, 3)" :key="i">{{ rec }}</li>
              </ul>
            </div>
          </div>

          <!-- Performance Statistics -->
          <div class="analysis-card statistics">
            <h3>📊 Performance Statistics</h3>

            <div class="metric-group">
              <span class="metric-label">Total Exams</span>
              <span class="metric-value large">{{ studentAnalysis.total_attempts }}</span>
            </div>

            <div class="metric-group">
              <span class="metric-label">Average Score</span>
              <span class="metric-value large">{{ studentAnalysis.statistics.average_score.toFixed(1) }}%</span>
            </div>

            <div class="metric-details">
              <p><strong>Highest:</strong> {{ studentAnalysis.statistics.highest_score.toFixed(1) }}%</p>
              <p><strong>Lowest:</strong> {{ studentAnalysis.statistics.lowest_score.toFixed(1) }}%</p>
              <p><strong>Latest:</strong> {{ studentAnalysis.statistics.latest_score.toFixed(1) }}%</p>
            </div>

            <div class="metric-group">
              <span class="metric-label">Performance Trend</span>
              <span class="metric-value large" :style="{ color: getTrendColor(studentAnalysis.statistics.score_trend) }">
                {{ getTrendIcon(studentAnalysis.statistics.score_trend) }} {{ formatTrend(studentAnalysis.statistics.score_trend) }}
              </span>
            </div>
          </div>
        </div>
      </div>

      <!-- Question Analysis Results -->
      <div v-if="questionAnalysis" class="question-analysis">
        <h3 style="color: #ef4444; margin-bottom: 10px;">🔴 Hardest Questions (Top 10)</h3>
        <p style="color: #666; font-size: 14px; margin-bottom: 20px;">Questions with lowest success rates - students frequently get these wrong</p>
        
        <div class="question-table-container">
          <table class="question-table">
            <thead>
              <tr>
                <th>#</th>
                <th>Question ID</th>
                <th>Question</th>
                <th>Success Rate</th>
                <th>Attempts</th>
                <th>Difficulty</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(q, i) in questionAnalysis.hardest_questions.slice(0, 10)" :key="q.question_id">
                <td>{{ i + 1 }}</td>
                <td>{{ q.question_id }}</td>
                <td>{{ q.question_text.substring(0, 80) }}...</td>
                <td>
                  <span class="success-badge" :class="getSuccessClass(q.success_rate)">
                    {{ q.success_rate.toFixed(1) }}%
                  </span>
                </td>
                <td>{{ q.total_attempts }}</td>
                <td>
                  <span class="difficulty-badge" :class="getDifficultyClass(q.difficulty_category)">
                    {{ formatDifficulty(q.difficulty_category) }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div v-if="questionAnalysis.analysis.recommendations.length > 0" class="recommendations warning">
          <p class="rec-title">💡 Teaching Recommendations</p>
          <ul>
            <li v-for="(rec, i) in questionAnalysis.analysis.recommendations" :key="i">{{ rec }}</li>
          </ul>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loadingStudents" class="loading-container">
      <div class="loading-content">
        <div class="loading-spinner" :class="{ 'error-spinner': loadingMessage.includes('Error') }"></div>
        <p class="loading-text" :class="{ 'error-text': loadingMessage.includes('Error') }">{{ loadingMessage }}</p>
        <p class="loading-subtext">{{ loadingSubtext }}</p>
        <div v-if="!loadingMessage.includes('Error')" class="progress-bar">
          <div class="progress-fill" :style="{ width: loadingProgress + '%' }"></div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else-if="filteredStudents.length === 0" class="empty-state">
      <svg width="64" height="64" viewBox="0 0 64 64" fill="none">
        <circle cx="32" cy="32" r="28" stroke="#C7C7CC" stroke-width="2"/>
        <path d="M32 20V36M32 40V44" stroke="#C7C7CC" stroke-width="2" stroke-linecap="round"/>
      </svg>
      <p class="empty-text">No predictions found</p>
      <button @click="refreshAll" class="retry-btn">Try Again</button>
    </div>

    <!-- Students List -->
    <div v-else class="students-list">
      <div 
        v-for="student in filteredStudents" 
        :key="student.student_id"
        class="student-card"
        @click="viewStudentDetails(student.student_id)"
      >
        <div class="card-header">
          <div class="avatar">{{ getInitials(student.full_name) }}</div>
          <div class="student-info">
            <h3>{{ student.full_name }}</h3>
            <p>@{{ student.username }}</p>
          </div>
          <div class="risk-dot" :class="getRiskClass(student.pass_probability)"></div>
        </div>

        <div class="card-body">
          <div class="score-display">
            <div class="score-number">
              <span class="score-value">{{ (student.pass_probability * 100).toFixed(0) }}</span>
              <span class="score-unit">%</span>
            </div>
            <div class="score-label">Pass Probability</div>
            <div class="progress-bar-container">
              <div 
                class="progress-bar-fill" 
                :class="getRiskClass(student.pass_probability)"
                :style="{ width: (student.pass_probability * 100) + '%' }"
              ></div>
            </div>
          </div>

          <div class="metrics">
            <div class="metric-row">
              <span class="metric-label">Confidence</span>
              <span class="metric-value">{{ (student.confidence * 100).toFixed(0) }}%</span>
            </div>
            <div class="metric-row">
              <span class="metric-label">Attempts</span>
              <span class="metric-value">{{ student.total_attempts || 0 }}</span>
            </div>
            <div class="metric-row">
              <span class="metric-label">Avg Score</span>
              <span class="metric-value">{{ (student.avg_score || 0).toFixed(1) }}%</span>
            </div>
          </div>
        </div>

        <div class="card-footer">
          <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
            <path d="M6 4L10 8L6 12" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
        </div>
      </div>
    </div>

    <!-- Details Modal -->
    <transition name="modal">
      <div v-if="showPredictionModal" class="modal-overlay" @click="closePredictionModal">
        <div class="modal-container" @click.stop>
          <div class="modal-header">
            <h2>Details</h2>
            <button @click="closePredictionModal" class="close-btn">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                <path d="M6 6L18 18M18 6L6 18" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
              </svg>
            </button>
          </div>
          
          <div v-if="selectedPrediction" class="modal-body">
            <div class="modal-student">
              <div class="modal-avatar">{{ getInitials(selectedPrediction.full_name) }}</div>
              <div>
                <h3>{{ selectedPrediction.full_name }}</h3>
                <p>@{{ selectedPrediction.username }}</p>
              </div>
            </div>

            <div class="modal-section">
              <h4>Performance</h4>
              <div class="modal-metrics">
                <div class="modal-metric">
                  <span class="label">Pass Probability</span>
                  <span class="value">{{ (selectedPrediction.prediction.pass_probability * 100).toFixed(1) }}%</span>
                </div>
                <div class="modal-metric">
                  <span class="label">Confidence</span>
                  <span class="value">{{ (selectedPrediction.prediction.confidence * 100).toFixed(1) }}%</span>
                </div>
                <div class="modal-metric">
                  <span class="label">Risk Level</span>
                  <span class="value">{{ selectedPrediction.prediction.risk_level.toUpperCase() }}</span>
                </div>
              </div>
            </div>

            <div class="modal-section">
              <h4>History</h4>
              <div class="modal-metrics">
                <div class="modal-metric">
                  <span class="label">Total Attempts</span>
                  <span class="value">{{ selectedPrediction.student_stats.total_attempts }}</span>
                </div>
                <div class="modal-metric">
                  <span class="label">Average Score</span>
                  <span class="value">{{ selectedPrediction.student_stats.avg_score }}%</span>
                </div>
                <div class="modal-metric">
                  <span class="label">Pass Rate</span>
                  <span class="value">{{ selectedPrediction.student_stats.pass_rate }}%</span>
                </div>
              </div>
            </div>

            <div class="modal-recommendation">
              <p>{{ selectedPrediction.recommendation }}</p>
            </div>
          </div>
          
          <div v-else class="modal-loading">
            <div class="loading-spinner"></div>
            <p>Loading student details...</p>
          </div>
        </div>
      </div>
    </transition>
  </div>
</template>

<script>
import { ref, onMounted, computed } from 'vue'
import api from '@/services/api'

export default {
  name: 'MLDashboard',
  setup() {
    const metrics = ref(null)
    const allStudents = ref([])
    const loading = ref(false)
    const loadingStudents = ref(false)
    const showPredictionModal = ref(false)
    const selectedPrediction = ref(null)
    const filterStatus = ref('all')
    const loadingMessage = ref('Loading predictions...')
    const loadingSubtext = ref('Please wait')
    const loadingProgress = ref(0)
    const selectedStudentId = ref('')
    const studentAnalysis = ref(null)
    const questionAnalysis = ref(null)
    const analysisLoading = ref(false)
    const analysisMessage = ref('')

    const atRiskCount = computed(() => {
      return allStudents.value.filter(s => s.pass_probability < 0.6).length
    })

    const goodCount = computed(() => {
      return allStudents.value.filter(s => s.pass_probability >= 0.6).length
    })

    const filteredStudents = computed(() => {
      if (filterStatus.value === 'all') {
        return allStudents.value
      } else if (filterStatus.value === 'at-risk') {
        return allStudents.value.filter(s => s.pass_probability < 0.6)
      } else if (filterStatus.value === 'good') {
        return allStudents.value.filter(s => s.pass_probability >= 0.6)
      }
      return allStudents.value
    })

    const loadMetrics = async () => {
      try {
        const response = await api.get('/admin/ml/metrics')
        if (response.data.success) {
          metrics.value = response.data.data
        }
      } catch (error) {
        console.error('Error loading metrics:', error)
      }
    }

    const loadAllStudents = async () => {
      try {
        loadingStudents.value = true
        loadingMessage.value = 'Fetching students...'
        loadingSubtext.value = 'Please wait'
        loadingProgress.value = 0
        
        const usersResponse = await api.get('/admin/users')
        
        loadingProgress.value = 20
        loadingMessage.value = 'Loading student data...'
        
        let reviewees = []
        if (Array.isArray(usersResponse.data)) {
          reviewees = usersResponse.data.filter(u => u.role === 'reviewee')
        } else if (usersResponse.data.data && Array.isArray(usersResponse.data.data)) {
          reviewees = usersResponse.data.data.filter(u => u.role === 'reviewee')
        } else if (usersResponse.data.users && Array.isArray(usersResponse.data.users)) {
          reviewees = usersResponse.data.users.filter(u => u.role === 'reviewee')
        }
        
        if (reviewees.length === 0) {
          allStudents.value = []
          return
        }
        
        loadingProgress.value = 40
        loadingMessage.value = 'Generating predictions...'
        loadingSubtext.value = `Processing ${reviewees.length} students`
        
        // Parallel loading with batch processing (5 at a time to avoid overwhelming server)
        const batchSize = 5
        const predictions = []
        const totalStudents = reviewees.length
        let processedCount = 0
        
        for (let i = 0; i < reviewees.length; i += batchSize) {
          const batch = reviewees.slice(i, i + batchSize)
          
          // Process batch in parallel
          const batchPromises = batch.map(async (reviewee) => {
            try {
              const predResponse = await api.get(`/admin/ml/predict/${reviewee.id}`)
              if (predResponse.data.success) {
                const data = predResponse.data.data
                return {
                  student_id: reviewee.id,
                  username: data.username,
                  full_name: data.full_name,
                  pass_probability: data.prediction.pass_probability,
                  fail_probability: data.prediction.fail_probability,
                  confidence: data.prediction.confidence,
                  risk_level: data.prediction.risk_level,
                  will_pass: data.prediction.will_pass,
                  total_attempts: data.student_stats.total_attempts,
                  avg_score: data.student_stats.avg_score,
                  total_passes: data.student_stats.total_passes,
                  pass_rate: data.student_stats.pass_rate
                }
              }
            } catch (error) {
              console.error(`Error loading prediction for ${reviewee.username}:`, error)
              return null
            }
          })
          
          const batchResults = await Promise.all(batchPromises)
          predictions.push(...batchResults.filter(r => r !== null))
          
          processedCount += batch.length
          const progress = 40 + (processedCount / totalStudents) * 50
          loadingProgress.value = Math.round(progress)
          loadingSubtext.value = `${processedCount} of ${totalStudents} students processed`
        }
        
        loadingProgress.value = 95
        loadingMessage.value = 'Finalizing...'
        loadingSubtext.value = 'Almost done'
        
        allStudents.value = predictions.sort((a, b) => a.pass_probability - b.pass_probability)
        
        loadingProgress.value = 100
        
      } catch (error) {
        console.error('Error loading students:', error)
        loadingMessage.value = 'Error loading data'
        loadingSubtext.value = error.response?.data?.message || error.message || 'Failed to load predictions'
        
        // Show error for 3 seconds then hide loading
        setTimeout(() => {
          loadingStudents.value = false
        }, 3000)
        return
      } finally {
        setTimeout(() => {
          loadingStudents.value = false
        }, 300)
      }
    }

    const viewStudentDetails = async (studentId) => {
      try {
        showPredictionModal.value = true
        selectedPrediction.value = null
        
        const response = await api.get(`/admin/ml/predict/${studentId}`)
        if (response.data.success) {
          selectedPrediction.value = response.data.data
        }
      } catch (error) {
        console.error('Error loading prediction:', error)
        showPredictionModal.value = false
      }
    }

    const closePredictionModal = () => {
      showPredictionModal.value = false
      selectedPrediction.value = null
    }

    const refreshAll = () => {
      loading.value = true
      Promise.all([loadMetrics(), loadAllStudents()]).finally(() => {
        loading.value = false
      })
    }

    const getInitials = (name) => {
      return name
        .split(' ')
        .map(n => n[0])
        .join('')
        .toUpperCase()
        .slice(0, 2)
    }

    const getRiskClass = (probability) => {
      if (probability >= 0.7) return 'good'
      if (probability >= 0.4) return 'medium'
      return 'risk'
    }

    const getScoreColor = (probability) => {
      if (probability >= 0.7) return '#007AFF'
      if (probability >= 0.4) return '#8E8E93'
      return '#C7C7CC'
    }

    const analyzeStudent = async () => {
      if (!selectedStudentId.value) {
        return
      }

      try {
        analysisLoading.value = true
        analysisMessage.value = 'Analyzing student performance...'
        studentAnalysis.value = null
        questionAnalysis.value = null

        const response = await fetch(`http://localhost:5000/api/analyze/${selectedStudentId.value}`)
        const data = await response.json()

        if (data.success) {
          studentAnalysis.value = data
        } else {
          console.error('Analysis failed:', data.error)
          alert('Failed to analyze student: ' + data.error)
        }
      } catch (error) {
        console.error('Error analyzing student:', error)
        alert('Error: Make sure Python API is running at http://localhost:5000\n\nRun: python dashboard_server.py')
      } finally {
        analysisLoading.value = false
      }
    }

    const analyzeQuestions = async () => {
      try {
        analysisLoading.value = true
        analysisMessage.value = 'Analyzing question difficulty...'
        studentAnalysis.value = null
        questionAnalysis.value = null

        const response = await fetch('http://localhost:5000/api/questions/hardest')
        const data = await response.json()

        if (data.success) {
          questionAnalysis.value = data
        } else {
          console.error('Question analysis failed:', data.error)
          alert('Failed to analyze questions: ' + data.error)
        }
      } catch (error) {
        console.error('Error analyzing questions:', error)
        alert('Error: Make sure Python API is running at http://localhost:5000\n\nRun: python dashboard_server.py')
      } finally {
        analysisLoading.value = false
      }
    }

    const getReadinessColor = (probability) => {
      if (probability >= 75) return '#10b981'
      if (probability >= 60) return '#f59e0b'
      return '#ef4444'
    }

    const formatReadinessLevel = (level) => {
      return level.replace('_', ' ').toUpperCase()
    }

    const getTrendColor = (trend) => {
      if (trend === 'improving') return '#10b981'
      if (trend === 'declining') return '#ef4444'
      return '#f59e0b'
    }

    const getTrendIcon = (trend) => {
      if (trend === 'improving') return '↗️'
      if (trend === 'declining') return '↘️'
      return '→'
    }

    const formatTrend = (trend) => {
      return trend.toUpperCase()
    }

    const getSuccessClass = (rate) => {
      if (rate < 30) return 'danger'
      if (rate < 60) return 'warning'
      return 'success'
    }

    const getDifficultyClass = (category) => {
      if (category === 'very_hard') return 'danger'
      return 'warning'
    }

    const formatDifficulty = (category) => {
      return category.replace('_', ' ').toUpperCase()
    }

    onMounted(() => {
      loadMetrics()
      loadAllStudents()
    })

    return {
      metrics,
      allStudents,
      loading,
      loadingStudents,
      showPredictionModal,
      selectedPrediction,
      filterStatus,
      loadingMessage,
      loadingSubtext,
      loadingProgress,
      selectedStudentId,
      studentAnalysis,
      questionAnalysis,
      analysisLoading,
      analysisMessage,
      atRiskCount,
      goodCount,
      filteredStudents,
      refreshAll,
      viewStudentDetails,
      closePredictionModal,
      getInitials,
      getRiskClass,
      getScoreColor,
      analyzeStudent,
      analyzeQuestions,
      getReadinessColor,
      formatReadinessLevel,
      getTrendColor,
      getTrendIcon,
      formatTrend,
      getSuccessClass,
      getDifficultyClass,
      formatDifficulty
    }
  }
}
</script>

<style scoped>
/* iOS Design System */
:root {
  --ios-blue: #007AFF;
  --ios-black: #000000;
  --ios-white: #FFFFFF;
  --ios-grey-1: #8E8E93;
  --ios-grey-2: #AEAEB2;
  --ios-grey-3: #C7C7CC;
  --ios-grey-4: #D1D1D6;
  --ios-grey-5: #E5E5EA;
  --ios-grey-6: #F2F2F7;
  --ios-bg: #F2F2F7;
}

* {
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

.ios-ml-dashboard {
  min-height: 100vh;
  background: var(--ios-bg);
  padding: 20px;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', sans-serif;
  will-change: scroll-position;
  -webkit-overflow-scrolling: touch;
}

/* Header */
.ios-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  animation: slideDown 0.4s cubic-bezier(0.16, 1, 0.3, 1);
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.header-content h1 {
  font-size: 34px;
  font-weight: 800;
  letter-spacing: -0.5px;
  color: var(--ios-black);
  margin: 0 0 4px 0;
}

.header-content p {
  font-size: 17px;
  color: var(--ios-grey-1);
  margin: 0;
  font-weight: 500;
}

.refresh-btn {
  width: 44px;
  height: 44px;
  border-radius: 22px;
  background: var(--ios-white);
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s;
  color: var(--ios-blue);
}

.refresh-btn:hover {
  background: var(--ios-grey-6);
}

.refresh-btn:active {
  transform: scale(0.95);
}

.refresh-btn.spinning {
  pointer-events: none;
}

.refresh-btn.spinning svg {
  animation: spin 1s cubic-bezier(0.68, -0.55, 0.265, 1.55) infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

/* Stats Grid */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 12px;
  margin-bottom: 24px;
  animation: fadeIn 0.5s cubic-bezier(0.16, 1, 0.3, 1) 0.1s both;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.stat-card {
  background: var(--ios-white);
  border-radius: 16px;
  padding: 20px;
  text-align: center;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
  will-change: transform;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.08);
}

.stat-card:active {
  transform: scale(0.98);
}

.stat-value {
  font-size: 32px;
  font-weight: 800;
  letter-spacing: -1px;
  color: var(--ios-black);
  margin-bottom: 4px;
}

.stat-label {
  font-size: 13px;
  color: var(--ios-grey-1);
  font-weight: 600;
}

/* Filter Section */
.filter-section {
  display: flex;
  gap: 8px;
  margin-bottom: 24px;
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
  animation: fadeIn 0.5s cubic-bezier(0.16, 1, 0.3, 1) 0.2s both;
}

.filter-section::-webkit-scrollbar {
  display: none;
}

.filter-chip {
  padding: 8px 16px;
  border-radius: 20px;
  background: var(--ios-white);
  border: none;
  font-size: 15px;
  font-weight: 500;
  color: var(--ios-black);
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
  white-space: nowrap;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
  will-change: transform, background-color;
}

.filter-chip:hover {
  background: var(--ios-grey-6);
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.06);
}

.filter-chip:active {
  transform: scale(0.96);
}

.filter-chip.active {
  background: var(--ios-blue);
  color: var(--ios-white);
  box-shadow: 0 4px 12px rgba(0, 122, 255, 0.3);
}

/* Loading */
.loading-container {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 80px 20px;
  animation: fadeIn 0.3s ease;
}

.loading-content {
  text-align: center;
  max-width: 300px;
}

.loading-spinner {
  width: 48px;
  height: 48px;
  border: 4px solid var(--ios-grey-5);
  border-top-color: var(--ios-blue);
  border-radius: 50%;
  animation: spin 0.8s cubic-bezier(0.68, -0.55, 0.265, 1.55) infinite;
  margin: 0 auto 20px;
}

.loading-text {
  font-size: 17px;
  font-weight: 700;
  color: var(--ios-black);
  margin: 0 0 8px 0;
  letter-spacing: -0.3px;
}

.loading-subtext {
  font-size: 15px;
  color: var(--ios-grey-1);
  margin: 0;
  font-weight: 600;
}

.progress-bar {
  width: 100%;
  max-width: 300px;
  height: 4px;
  background: var(--ios-grey-5);
  border-radius: 2px;
  margin-top: 16px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: var(--ios-blue);
  border-radius: 2px;
  transition: width 0.3s ease;
}

.error-spinner {
  border-top-color: #FF3B30 !important;
}

.error-text {
  color: #FF3B30 !important;
}

.retry-btn {
  margin-top: 16px;
  padding: 10px 24px;
  background: var(--ios-blue);
  color: white;
  border: none;
  border-radius: 12px;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.retry-btn:hover {
  background: #0051D5;
  transform: translateY(-1px);
}

.retry-btn:active {
  transform: scale(0.98);
}

/* Modal Loading */
.modal-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  background: var(--ios-white);
}

.modal-loading .loading-spinner {
  width: 40px;
  height: 40px;
  border-width: 3px;
  margin-bottom: 16px;
}

.modal-loading p {
  font-size: 15px;
  color: var(--ios-black);
  margin: 0;
  font-weight: 700;
}

/* Empty State */
.empty-state {
  text-align: center;
  padding: 60px 20px;
  animation: fadeIn 0.5s ease;
}

.empty-state svg {
  animation: pulse 2s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% {
    opacity: 0.4;
  }
  50% {
    opacity: 0.8;
  }
}

.empty-text {
  margin-top: 16px;
  font-size: 17px;
  color: var(--ios-grey-1);
  font-weight: 600;
}

/* Students List */
.students-list {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 16px;
  animation: fadeIn 0.5s cubic-bezier(0.16, 1, 0.3, 1) 0.3s both;
}

.student-card {
  background: var(--ios-white);
  border-radius: 16px;
  padding: 20px;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  border: 1px solid var(--ios-grey-5);
  will-change: transform;
  animation: slideUp 0.4s cubic-bezier(0.16, 1, 0.3, 1) both;
}

.student-card:nth-child(1) { animation-delay: 0.05s; }
.student-card:nth-child(2) { animation-delay: 0.1s; }
.student-card:nth-child(3) { animation-delay: 0.15s; }
.student-card:nth-child(4) { animation-delay: 0.2s; }
.student-card:nth-child(5) { animation-delay: 0.25s; }
.student-card:nth-child(6) { animation-delay: 0.3s; }

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.student-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 24px rgba(0, 0, 0, 0.1);
}

.student-card:active {
  transform: translateY(-2px) scale(0.98);
  transition: all 0.1s cubic-bezier(0.16, 1, 0.3, 1);
}

.card-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 20px;
}

.avatar {
  width: 48px;
  height: 48px;
  border-radius: 24px;
  background: linear-gradient(135deg, var(--ios-grey-5) 0%, var(--ios-grey-4) 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 17px;
  font-weight: 600;
  color: var(--ios-grey-1);
  letter-spacing: -0.5px;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}

.student-card:hover .avatar {
  transform: scale(1.05);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.student-info {
  flex: 1;
}

.student-info h3 {
  font-size: 17px;
  font-weight: 700;
  color: var(--ios-black);
  margin: 0 0 2px 0;
  letter-spacing: -0.3px;
}

.student-info p {
  font-size: 15px;
  color: var(--ios-grey-1);
  margin: 0;
  font-weight: 500;
}

.risk-dot {
  width: 12px;
  height: 12px;
  border-radius: 6px;
  background: var(--ios-grey-3);
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
  box-shadow: 0 0 0 0 rgba(0, 122, 255, 0.4);
}

.risk-dot.good {
  background: var(--ios-blue);
  animation: pulse-blue 2s ease-in-out infinite;
}

.risk-dot.medium {
  background: var(--ios-grey-2);
}

.risk-dot.risk {
  background: var(--ios-grey-3);
}

@keyframes pulse-blue {
  0%, 100% {
    box-shadow: 0 0 0 0 rgba(0, 122, 255, 0.4);
  }
  50% {
    box-shadow: 0 0 0 4px rgba(0, 122, 255, 0);
  }
}

.card-body {
  margin-bottom: 16px;
}

.score-display {
  text-align: center;
  padding: 20px;
  background: var(--ios-white);
  border-radius: 12px;
  margin-bottom: 16px;
  border: 1px solid var(--ios-grey-5);
}

.score-number {
  margin-bottom: 8px;
}

.score-value {
  font-size: 48px;
  font-weight: 800;
  letter-spacing: -2px;
  color: var(--ios-black);
}

.score-unit {
  font-size: 24px;
  font-weight: 700;
  color: var(--ios-grey-1);
  margin-left: 4px;
}

.score-label {
  font-size: 13px;
  color: var(--ios-grey-1);
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin-bottom: 12px;
}

.progress-bar-container {
  width: 100%;
  height: 8px;
  background: var(--ios-grey-6);
  border-radius: 4px;
  overflow: hidden;
}

.progress-bar-fill {
  height: 100%;
  border-radius: 4px;
  transition: width 1s cubic-bezier(0.16, 1, 0.3, 1);
}

.progress-bar-fill.good {
  background: linear-gradient(90deg, #007AFF 0%, #0051D5 100%);
}

.progress-bar-fill.medium {
  background: linear-gradient(90deg, #8E8E93 0%, #636366 100%);
}

.progress-bar-fill.risk {
  background: linear-gradient(90deg, #C7C7CC 0%, #AEAEB2 100%);
}

.score-circle {
  position: relative;
  width: 100px;
  height: 100px;
  flex-shrink: 0;
}

.score-circle svg {
  transform: rotate(-90deg);
}

.score-circle .progress-ring {
  transition: stroke-dashoffset 1s cubic-bezier(0.16, 1, 0.3, 1);
}

.score-text {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  text-align: center;
  animation: fadeIn 0.5s ease 0.3s both;
}

.score-value {
  font-size: 28px;
  font-weight: 700;
  letter-spacing: -1px;
  color: var(--ios-black);
}

.score-unit {
  font-size: 17px;
  font-weight: 600;
  color: var(--ios-grey-1);
}

.metrics {
  background: var(--ios-white);
  border-radius: 12px;
  padding: 12px;
  border: 1px solid var(--ios-grey-5);
}

.metric-row {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
  border-bottom: 1px solid var(--ios-grey-6);
}

.metric-row:last-child {
  border-bottom: none;
}

.metric-label {
  font-size: 15px;
  color: var(--ios-grey-1);
  font-weight: 600;
}

.metric-value {
  font-size: 15px;
  color: var(--ios-black);
  font-weight: 700;
}

.card-footer {
  display: flex;
  justify-content: flex-end;
  color: var(--ios-grey-2);
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}

.student-card:hover .card-footer {
  color: var(--ios-blue);
  transform: translateX(4px);
}

/* Modal */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
}

.modal-container {
  background: var(--ios-white);
  border-radius: 20px;
  max-width: 500px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  -webkit-overflow-scrolling: touch;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  border-bottom: 1px solid var(--ios-grey-5);
  background: var(--ios-white);
}

.modal-header h2 {
  font-size: 22px;
  font-weight: 800;
  letter-spacing: -0.5px;
  color: var(--ios-black);
  margin: 0;
}

.close-btn {
  width: 32px;
  height: 32px;
  border-radius: 16px;
  background: var(--ios-grey-6);
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: var(--ios-grey-1);
  transition: all 0.2s;
}

.close-btn:hover {
  background: var(--ios-grey-5);
  transform: rotate(90deg);
}

.close-btn:active {
  transform: rotate(90deg) scale(0.95);
}

.modal-body {
  padding: 24px;
  animation: fadeIn 0.3s ease 0.1s both;
  background: #F2F2F7;
}

.modal-student {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 24px;
  padding: 20px;
  background: #FFFFFF;
  border-radius: 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.modal-avatar {
  width: 72px;
  height: 72px;
  border-radius: 36px;
  background: linear-gradient(135deg, #007AFF 0%, #0051D5 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  font-weight: 800;
  color: #FFFFFF;
  box-shadow: 0 4px 12px rgba(0, 122, 255, 0.3);
  letter-spacing: -1px;
}

.modal-student h3 {
  font-size: 22px;
  font-weight: 800;
  color: #000000;
  margin: 0 0 4px 0;
  letter-spacing: -0.5px;
}

.modal-student p {
  font-size: 17px;
  color: #8E8E93;
  margin: 0;
  font-weight: 600;
}

.modal-section {
  margin-bottom: 20px;
}

.modal-section h4 {
  font-size: 13px;
  font-weight: 700;
  color: #8E8E93;
  margin: 0 0 12px 0;
  letter-spacing: 0.5px;
  text-transform: uppercase;
}

.modal-metrics {
  background: #FFFFFF;
  border-radius: 16px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  animation: slideUp 0.3s ease both;
}

.modal-metric {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
  transition: all 0.2s ease;
  border-bottom: 1px solid #F2F2F7;
}

.modal-metric:last-child {
  border-bottom: none;
  padding-bottom: 0;
}

.modal-metric:first-child {
  padding-top: 0;
}

.modal-metric:hover {
  padding-left: 4px;
}

.modal-metric .label {
  font-size: 16px;
  color: #8E8E93;
  font-weight: 600;
}

.modal-metric .value {
  font-size: 18px;
  color: #000000;
  font-weight: 800;
  letter-spacing: -0.5px;
}

.modal-recommendation {
  background: #FFFFFF;
  border-radius: 16px;
  padding: 20px;
  border-left: 4px solid #007AFF;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  animation: slideUp 0.3s ease 0.1s both;
}

.modal-recommendation p {
  font-size: 16px;
  color: #000000;
  line-height: 1.6;
  margin: 0;
  font-weight: 600;
}

/* Modal Transitions */
.modal-enter-active {
  transition: opacity 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}

.modal-leave-active {
  transition: opacity 0.2s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-active .modal-container {
  animation: modalSlideUp 0.4s cubic-bezier(0.16, 1, 0.3, 1);
}

.modal-leave-active .modal-container {
  animation: modalSlideDown 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}

@keyframes modalSlideUp {
  from {
    opacity: 0;
    transform: translateY(40px) scale(0.95);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

@keyframes modalSlideDown {
  from {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
  to {
    opacity: 0;
    transform: translateY(40px) scale(0.95);
  }
}

/* Responsive */
@media (max-width: 768px) {
  .ios-ml-dashboard {
    padding: 16px;
  }

  .header-content h1 {
    font-size: 28px;
  }

  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .students-list {
    grid-template-columns: 1fr;
  }
  
  .modal-container {
    margin: 0 16px;
  }
}

/* Enhanced Analysis Section */
.analysis-section {
  margin-top: 24px;
  animation: fadeIn 0.5s cubic-bezier(0.16, 1, 0.3, 1) 0.4s both;
}

.analysis-controls {
  display: flex;
  gap: 12px;
  margin-bottom: 24px;
  flex-wrap: wrap;
  align-items: center;
}

.student-select {
  flex: 1;
  min-width: 250px;
  padding: 12px 16px;
  border-radius: 12px;
  border: 1px solid var(--ios-grey-5);
  background: var(--ios-white);
  font-size: 15px;
  font-weight: 500;
  color: var(--ios-black);
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', sans-serif;
  transition: all 0.2s;
  cursor: pointer;
}

.student-select:hover {
  border-color: var(--ios-grey-4);
}

.student-select:focus {
  outline: none;
  border-color: var(--ios-blue);
  box-shadow: 0 0 0 3px rgba(0, 122, 255, 0.1);
}

.analyze-btn {
  padding: 12px 20px;
  border-radius: 12px;
  border: none;
  background: var(--ios-blue);
  color: var(--ios-white);
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  gap: 8px;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', sans-serif;
}

.analyze-btn:hover:not(:disabled) {
  background: #0051D5;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 122, 255, 0.3);
}

.analyze-btn:active:not(:disabled) {
  transform: scale(0.98);
}

.analyze-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.analyze-btn.secondary {
  background: var(--ios-grey-6);
  color: var(--ios-black);
}

.analyze-btn.secondary:hover:not(:disabled) {
  background: var(--ios-grey-5);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.analysis-loading {
  text-align: center;
  padding: 40px 20px;
  background: var(--ios-white);
  border-radius: 16px;
  animation: fadeIn 0.3s ease;
}

.analysis-loading .loading-spinner {
  width: 40px;
  height: 40px;
  border-width: 3px;
  margin: 0 auto 16px;
}

.analysis-loading p {
  font-size: 15px;
  color: var(--ios-grey-1);
  font-weight: 600;
}

.analysis-results {
  animation: fadeIn 0.5s ease;
}

.analysis-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
  gap: 20px;
  margin-bottom: 24px;
}

.analysis-card {
  background: var(--ios-white);
  border-radius: 16px;
  padding: 24px;
  border-left: 4px solid var(--ios-blue);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  animation: slideUp 0.4s cubic-bezier(0.16, 1, 0.3, 1) both;
}

.analysis-card.readiness {
  border-left-color: #10b981;
}

.analysis-card.next-attempt {
  border-left-color: #3b82f6;
}

.analysis-card.statistics {
  border-left-color: #8b5cf6;
}

.analysis-card h3 {
  font-size: 18px;
  font-weight: 800;
  color: var(--ios-black);
  margin: 0 0 20px 0;
  letter-spacing: -0.3px;
}

.metric-group {
  margin-bottom: 20px;
}

.metric-label {
  display: block;
  font-size: 13px;
  color: var(--ios-grey-1);
  font-weight: 600;
  margin-bottom: 6px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.metric-value {
  display: block;
  font-size: 17px;
  font-weight: 700;
  color: var(--ios-black);
  letter-spacing: -0.3px;
}

.metric-value.large {
  font-size: 20px;
  font-weight: 800;
}

.metric-value.xlarge {
  font-size: 28px;
  font-weight: 800;
  letter-spacing: -1px;
}

.metric-hint {
  display: block;
  font-size: 11px;
  color: var(--ios-grey-2);
  margin-top: 4px;
  font-weight: 500;
}

.metric-details {
  background: var(--ios-grey-6);
  padding: 12px;
  border-radius: 8px;
  margin: 16px 0;
}

.metric-details p {
  font-size: 13px;
  color: var(--ios-grey-1);
  margin: 6px 0;
  font-weight: 500;
}

.metric-details strong {
  color: var(--ios-black);
  font-weight: 700;
}

.recommendations {
  background: var(--ios-grey-6);
  padding: 12px;
  border-radius: 8px;
  margin-top: 16px;
}

.recommendations.blue {
  background: #eff6ff;
}

.recommendations.warning {
  background: #fef3c7;
  border-left: 4px solid #f59e0b;
}

.rec-title {
  font-size: 13px;
  font-weight: 700;
  color: var(--ios-black);
  margin: 0 0 8px 0;
}

.recommendations ul {
  margin: 0;
  padding-left: 20px;
  font-size: 12px;
  color: var(--ios-grey-1);
}

.recommendations ul li {
  margin: 4px 0;
  font-weight: 500;
}

.question-analysis {
  background: var(--ios-white);
  border-radius: 16px;
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  animation: fadeIn 0.5s ease;
}

.question-table-container {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
  border-radius: 12px;
  margin-bottom: 20px;
}

.question-table {
  width: 100%;
  border-collapse: collapse;
  background: var(--ios-white);
  border-radius: 12px;
  overflow: hidden;
}

.question-table thead {
  background: var(--ios-grey-6);
}

.question-table th {
  padding: 12px;
  text-align: left;
  font-size: 13px;
  font-weight: 700;
  color: var(--ios-grey-1);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.question-table td {
  padding: 12px;
  font-size: 13px;
  color: var(--ios-black);
  border-bottom: 1px solid var(--ios-grey-6);
  font-weight: 500;
}

.question-table tbody tr:last-child td {
  border-bottom: none;
}

.question-table tbody tr:hover {
  background: var(--ios-grey-6);
}

.success-badge,
.difficulty-badge {
  display: inline-block;
  padding: 4px 10px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.3px;
}

.success-badge.danger {
  background: #fee2e2;
  color: #991b1b;
}

.success-badge.warning {
  background: #fef3c7;
  color: #92400e;
}

.success-badge.success {
  background: #d1fae5;
  color: #065f46;
}

.difficulty-badge.danger {
  background: #fee2e2;
  color: #991b1b;
}

.difficulty-badge.warning {
  background: #fef3c7;
  color: #92400e;
}

/* Performance Optimizations */
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}

/* Smooth Scrolling */
.modal-container,
.students-list {
  scroll-behavior: smooth;
}

/* Hardware Acceleration */
.student-card,
.stat-card,
.filter-chip,
.modal-container {
  transform: translateZ(0);
  backface-visibility: hidden;
  perspective: 1000px;
}
</style>
