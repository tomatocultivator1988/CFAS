<template>
  <div class="mlp">
    <header class="mlp-hero">
      <div class="mlp-hero__main">
        <div class="mlp-hero__title">
          <h1>ML Predictive</h1>
          <p class="mlp-hero__subtitle">Board readiness, risk scoring, and model-backed intervention priorities.</p>
          <div class="mlp-meta">
            <span class="mlp-chip">
              <span class="mlp-chip__k">Model</span>
              <span class="mlp-chip__v">{{ displayModelName(data.model) }}</span>
            </span>
            <span class="mlp-chip">
              <span class="mlp-chip__k">Status</span>
              <span class="mlp-chip__v">{{ modelStatusLabel }}</span>
            </span>
            <span class="mlp-chip">
              <span class="mlp-chip__k">Trained</span>
              <span class="mlp-chip__v">{{ formatDateTime(data.trainedAt) }}</span>
            </span>
            <span class="mlp-chip">
              <span class="mlp-chip__k">Passing Target</span>
              <span class="mlp-chip__v">{{ formatPercentage(boardPassingRate) }}</span>
            </span>
            <span v-if="isFallbackModel" class="mlp-chip mlp-chip--warn">
              <span class="mlp-chip__v">Fallback Mode</span>
            </span>
          </div>
        </div>

        <div class="mlp-hero__actions">
          <button class="mlp-btn mlp-btn--ghost" :disabled="loading" @click="resetFilters">Reset</button>
          <button class="mlp-btn mlp-btn--primary" :disabled="loading" @click="fetchPredictions">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" :class="{ spinning: loading }">
              <path
                d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
              />
            </svg>
            <span>{{ loading ? 'Refreshing...' : 'Refresh' }}</span>
          </button>
        </div>
      </div>

      <div class="mlp-kpis">
        <div class="mlp-kpi">
          <div class="mlp-kpi__label">Total Reviewees</div>
          <div class="mlp-kpi__value">{{ totalStudents }}</div>
          <div class="mlp-kpi__hint">Students with prediction output</div>
        </div>
        <div class="mlp-kpi mlp-kpi--danger">
          <div class="mlp-kpi__label">High Risk Rate</div>
          <div class="mlp-kpi__value">{{ formatPercentage(highRiskRate) }}</div>
          <div class="mlp-kpi__hint">{{ riskCounts.high }} high-risk reviewees</div>
        </div>
        <div class="mlp-kpi">
          <div class="mlp-kpi__label">Avg Predicted Pass</div>
          <div class="mlp-kpi__value">{{ formatPercentage(summary.avgPassProbability) }}</div>
          <div class="mlp-kpi__hint">Model predicted board passing</div>
        </div>
        <div class="mlp-kpi">
          <div class="mlp-kpi__label">Training Samples</div>
          <div class="mlp-kpi__value">{{ summary.trainingSamples }}</div>
          <div class="mlp-kpi__hint">Dataset size used in training</div>
        </div>
        <div class="mlp-kpi mlp-kpi--amber">
          <div class="mlp-kpi__label">Needs Attention</div>
          <div class="mlp-kpi__value">{{ formatPercentage(summary.attentionRate) }}</div>
          <div class="mlp-kpi__hint">High + medium risk share</div>
        </div>
      </div>

      <div class="mlp-models" aria-label="Model comparison">
        <button
          v-for="modelOption in modelOptions"
          :key="modelOption.key"
          class="mlp-model-card"
          :class="{ active: selectedModel === modelOption.key }"
          type="button"
          @click="selectModel(modelOption.key)"
        >
          <span class="mlp-model-card__top">
            <span>
              <strong>{{ modelOption.name }}</strong>
              <small>{{ modelOption.description }}</small>
            </span>
            <span class="mlp-model-card__badge">{{ modelOption.badge }}</span>
          </span>
          <span class="mlp-model-card__metrics">
            <span>
              <small>Accuracy</small>
              <strong>{{ metricValue(modelOption.key, 'accuracy') }}</strong>
            </span>
            <span>
              <small>F1</small>
              <strong>{{ metricValue(modelOption.key, 'f1') }}</strong>
            </span>
            <span>
              <small>AUC</small>
              <strong>{{ metricValue(modelOption.key, 'auc') }}</strong>
            </span>
          </span>
        </button>
      </div>

      <div class="mlp-filters">
        <div class="mlp-filter">
          <label>Time Range</label>
          <select v-model="timeFilter" @change="fetchPredictions">
            <option value="7days">Last 7 Days</option>
            <option value="30days">Last 30 Days</option>
            <option value="3months">Last 3 Months</option>
            <option value="all">All Time</option>
          </select>
        </div>
        <div class="mlp-filter">
          <label>Model</label>
          <select v-model="selectedModel" @change="fetchPredictions">
            <option value="logistic_regression">Logistic Regression</option>
            <option value="random_forest">Random Forest</option>
            <option value="ensemble">Ensemble</option>
          </select>
        </div>
        <div class="mlp-filter mlp-filter--search">
          <label>Student Search</label>
          <div class="mlp-search">
            <input v-model="searchQuery" type="text" placeholder="Search by name" />
          </div>
        </div>
        <div class="mlp-filter">
          <label>Risk Filter</label>
          <select v-model="riskFilter">
            <option value="all">All</option>
            <option value="High">High</option>
            <option value="Medium">Medium</option>
            <option value="Low">Low</option>
          </select>
        </div>

        <div class="mlp-quick">
          <button class="mlp-pill" :class="{ active: riskFilter === 'all' }" @click="riskFilter = 'all'">
            All <span>{{ totalStudents }}</span>
          </button>
          <button class="mlp-pill mlp-pill--danger" :class="{ active: riskFilter === 'High' }" @click="riskFilter = 'High'">
            High <span>{{ riskCounts.high }}</span>
          </button>
          <button class="mlp-pill mlp-pill--amber" :class="{ active: riskFilter === 'Medium' }" @click="riskFilter = 'Medium'">
            Medium <span>{{ riskCounts.medium }}</span>
          </button>
          <button class="mlp-pill mlp-pill--good" :class="{ active: riskFilter === 'Low' }" @click="riskFilter = 'Low'">
            Low <span>{{ riskCounts.low }}</span>
          </button>
        </div>
      </div>
    </header>

    <div v-if="error" class="error-state">
      <h3>Unable to load ML predictions</h3>
      <p>{{ error }}</p>
      <button @click="fetchPredictions">Try Again</button>
    </div>

    <div v-else-if="loading" class="loading-state">
      <div class="spinner"></div>
      <p>Running prediction model...</p>
    </div>
    <div v-else>
      <div v-if="filteredStudents.length === 0" class="empty-state">
        <h3>No students found</h3>
        <p>Try changing filters or wait until students complete more exams.</p>
      </div>

      <template v-else>
        <section class="mlp-visuals" aria-label="Predictive analytics visual summary">
          <div class="visual-card visual-card--readiness">
            <div class="visual-card__head">
              <div>
                <h2>Board Readiness</h2>
                <p>{{ displayModelName(data.model) }} average pass probability</p>
              </div>
              <span class="visual-chip">{{ modelStatusLabel }}</span>
            </div>
            <div class="readiness-wrap">
              <div class="readiness-gauge" :style="readinessGaugeStyle">
                <div class="readiness-gauge__inner">
                  <strong>{{ formatPercentage(summary.avgPassProbability) }}</strong>
                  <span>Predicted pass</span>
                </div>
              </div>
              <div class="readiness-notes">
                <div>
                  <span>Target</span>
                  <strong>{{ formatPercentage(boardPassingRate) }}</strong>
                </div>
                <div>
                  <span>At or above target</span>
                  <strong>{{ readinessCounts.ready }}</strong>
                </div>
                <div>
                  <span>Below target</span>
                  <strong>{{ readinessCounts.notReady }}</strong>
                </div>
              </div>
            </div>
          </div>

          <div class="visual-card">
            <div class="visual-card__head">
              <div>
                <h2>Risk Distribution</h2>
                <p>High, medium, and low risk reviewees</p>
              </div>
            </div>
            <div class="risk-donut-wrap">
              <div class="risk-donut" :style="riskDonutStyle">
                <div class="risk-donut__inner">
                  <strong>{{ totalStudents }}</strong>
                  <span>Reviewees</span>
                </div>
              </div>
              <div class="risk-legend">
                <button type="button" @click="riskFilter = 'High'">
                  <span class="legend-dot legend-dot--high"></span>
                  <span>High</span>
                  <strong>{{ riskCounts.high }}</strong>
                </button>
                <button type="button" @click="riskFilter = 'Medium'">
                  <span class="legend-dot legend-dot--medium"></span>
                  <span>Medium</span>
                  <strong>{{ riskCounts.medium }}</strong>
                </button>
                <button type="button" @click="riskFilter = 'Low'">
                  <span class="legend-dot legend-dot--low"></span>
                  <span>Low</span>
                  <strong>{{ riskCounts.low }}</strong>
                </button>
              </div>
            </div>
          </div>

          <div class="visual-card visual-card--wide">
            <div class="visual-card__head">
              <div>
                <h2>Algorithm Performance</h2>
                <p>Accuracy, F1, and AUC comparison across the three model modes</p>
              </div>
            </div>
            <div class="model-bars">
              <div v-for="modelRow in modelMetricRows" :key="modelRow.key" class="model-bar-row">
                <div class="model-bar-row__name">
                  <strong>{{ modelRow.name }}</strong>
                  <span>{{ modelRow.badge }}</span>
                </div>
                <div class="metric-bars">
                  <div v-for="metric in modelRow.metrics" :key="metric.key" class="metric-bar">
                    <span>{{ metric.label }}</span>
                    <div class="metric-bar__track">
                      <div class="metric-bar__fill" :style="{ width: `${metric.value}%` }"></div>
                    </div>
                    <strong>{{ metric.display }}</strong>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        <section class="mlp-insights">
          <div class="visual-card visual-card--matrix">
            <div class="visual-card__head">
              <div>
                <h2>Student Risk Matrix</h2>
                <p>Average score vs predicted pass probability</p>
              </div>
            </div>
            <div class="risk-matrix">
              <span class="matrix-axis matrix-axis--y">Predicted pass</span>
              <span class="matrix-axis matrix-axis--x">Average score</span>
              <span class="matrix-guide matrix-guide--vertical"></span>
              <span class="matrix-guide matrix-guide--horizontal"></span>
              <span
                v-for="student in scatterStudents"
                :key="`point-${student.studentId}`"
                class="matrix-point"
                :class="`matrix-point--${safeRisk(student.riskLevel)}`"
                :style="scatterPointStyle(student)"
                :title="`${student.studentName}: ${formatPercentage(student.predictedPassProbability)} predicted pass`"
              ></span>
            </div>
          </div>

          <div class="priority-board">
            <div class="visual-card__head priority-board__head">
              <div>
                <h2>Priority Reviewees</h2>
                <p>Students surfaced by prediction confidence, risk, and model disagreement</p>
              </div>
            </div>
            <div class="priority-grid">
              <article v-for="item in priorityCards" :key="item.title" class="priority-card">
                <div class="priority-card__top">
                  <span class="priority-icon" :class="`priority-icon--${item.tone}`">{{ item.initials }}</span>
                  <div>
                    <span>{{ item.title }}</span>
                    <strong>{{ item.student?.studentName || 'No student yet' }}</strong>
                  </div>
                </div>
                <div class="priority-card__stats" v-if="item.student">
                  <div>
                    <span>Pred pass</span>
                    <strong>{{ formatPercentage(item.student.predictedPassProbability) }}</strong>
                  </div>
                  <div>
                    <span>Attempts</span>
                    <strong>{{ item.student.totalAttempts }}</strong>
                  </div>
                  <div>
                    <span>Action</span>
                    <strong>{{ interventionLabel(item.student) }}</strong>
                  </div>
                </div>
              </article>
            </div>
          </div>
        </section>

      <div class="mlp-panel">
        <div class="mlp-panel__head">
          <div class="mlp-panel__left">
            <div class="mlp-panel__title">Detailed Reviewee Predictions</div>
            <div class="mlp-panel__sub">
              Showing <strong>{{ filteredStudents.length }}</strong> of <strong>{{ totalStudents }}</strong>
            </div>
          </div>
          <div class="mlp-panel__right">
            <div class="mlp-selected">
              <span>Selected model</span>
              <strong>{{ displayModelName(data.model) }}</strong>
            </div>
            <div class="view-toggle">
              <button :class="{ active: viewMode === 'table' }" @click="viewMode = 'table'">Table</button>
              <button :class="{ active: viewMode === 'cards' }" @click="viewMode = 'cards'">Cards</button>
            </div>
            <div class="sort-label">Sorted by {{ sortLabel }}</div>
          </div>
        </div>

          <div v-if="viewMode === 'table'" class="table-wrapper">
            <table class="mlp-table">
              <thead>
                <tr>
                  <th class="sortable" @click="setSort('studentName')">Student</th>
                  <th class="sortable" @click="setSort('totalAttempts')">Attempts</th>
                  <th class="sortable" @click="setSort('latestScore')">Latest</th>
                  <th class="sortable" @click="setSort('averageScore')">Average</th>
                  <th class="sortable" @click="setSort('actualPassRate')">Actual Pass</th>
                  <th class="sortable" @click="setSort('logisticProbability')">LR Pass</th>
                  <th class="sortable" @click="setSort('randomForestProbability')">RF Pass</th>
                  <th class="sortable" @click="setSort('predictedPassProbability')">Pred Pass</th>
                  <th class="sortable" @click="setSort('predictedFailProbability')">Pred Fail</th>
                  <th class="sortable" @click="setSort('riskLevel')">Risk</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="student in filteredStudents" :key="student.studentId">
                  <td class="student-name">{{ student.studentName }}</td>
                  <td>{{ student.totalAttempts }}</td>
                  <td :class="scoreClass(student.latestScore)">{{ formatPercentage(student.latestScore) }}</td>
                  <td :class="scoreClass(student.averageScore)">{{ formatPercentage(student.averageScore) }}</td>
                  <td :class="scoreClass(student.actualPassRate)">{{ formatPercentage(student.actualPassRate) }}</td>
                  <td :class="scoreClass(student.logisticProbability)">{{ formatPercentage(student.logisticProbability) }}</td>
                  <td :class="scoreClass(student.randomForestProbability)">{{ formatPercentage(student.randomForestProbability) }}</td>
                  <td>
                    <div class="probability-cell">
                      <strong :class="scoreClass(student.predictedPassProbability)">
                        {{ formatPercentage(student.predictedPassProbability) }}
                      </strong>
                      <span class="probability-track" aria-hidden="true">
                        <span class="probability-fill" :style="{ width: `${Number(student.predictedPassProbability || 0)}%` }"></span>
                      </span>
                    </div>
                  </td>
                  <td :class="failScoreClass(student.predictedFailProbability)">{{ formatPercentage(student.predictedFailProbability) }}</td>
                  <td><span class="risk-badge" :class="`risk-${safeRisk(student.riskLevel)}`">{{ student.riskLevel }}</span></td>
                </tr>
              </tbody>
            </table>
          </div>

          <div v-else class="card-grid">
            <article
              v-for="student in filteredStudents"
              :key="student.studentId"
              class="student-card"
              :class="`student-card--${safeRisk(student.riskLevel)}`"
            >
              <div class="student-card-head">
                <div class="student-identity">
                  <div class="student-name">{{ student.studentName }}</div>
                  <div class="student-subtitle">
                    <span>{{ student.totalAttempts }} attempts</span>
                    <span>{{ interventionLabel(student) }}</span>
                  </div>
                </div>
                <span class="risk-badge" :class="`risk-${safeRisk(student.riskLevel)}`">{{ student.riskLevel }} risk</span>
              </div>

              <div class="student-forecast">
                <div class="student-forecast__primary">
                  <strong :class="scoreClass(student.predictedPassProbability)">
                    {{ formatPercentage(student.predictedPassProbability) }}
                  </strong>
                  <span>Predicted pass</span>
                </div>
                <div class="student-forecast__secondary">
                  <strong :class="failScoreClass(student.predictedFailProbability)">
                    {{ formatPercentage(student.predictedFailProbability) }}
                  </strong>
                  <span>Fail risk</span>
                </div>
              </div>

              <div class="student-readiness__bar" aria-hidden="true">
                <div
                  class="student-readiness__fill"
                  :style="modelMiniBarStyle(student.predictedPassProbability)"
                ></div>
              </div>

              <div class="student-stats">
                <div>
                  <strong :class="scoreClass(student.latestScore)">{{ formatPercentage(student.latestScore) }}</strong>
                  <span>Latest</span>
                </div>
                <div>
                  <strong :class="scoreClass(student.averageScore)">{{ formatPercentage(student.averageScore) }}</strong>
                  <span>Average</span>
                </div>
                <div>
                  <strong :class="scoreClass(student.actualPassRate)">{{ formatPercentage(student.actualPassRate) }}</strong>
                  <span>Actual pass</span>
                </div>
                <div>
                  <strong :class="failScoreClass(student.predictedFailProbability)">
                    {{ formatPercentage(student.predictedFailProbability) }}
                  </strong>
                  <span>Fail risk</span>
                </div>
              </div>

              <div class="student-model-summary">
                <span>Signals</span>
                <strong>LR {{ formatPercentage(student.logisticProbability) }}</strong>
                <strong>RF {{ formatPercentage(student.randomForestProbability) }}</strong>
              </div>

            </article>
          </div>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import analyticsApi from '@/services/analyticsApi'

const loading = ref(false)
const error = ref('')
const timeFilter = ref('all')
const selectedModel = ref('random_forest')
const riskFilter = ref('all')
const searchQuery = ref('')
const viewMode = ref('cards')
const sortKey = ref('predictedFailProbability')
const sortDirection = ref('desc')
const data = ref({
  model: 'random_forest',
  trainedAt: null,
  training: { samples: 0, studentsEvaluated: 0 },
  metrics: {},
  students: []
})

const modelOptions = [
  {
    key: 'logistic_regression',
    name: 'Logistic Regression',
    description: 'Interpretable linear baseline',
    badge: 'LR'
  },
  {
    key: 'random_forest',
    name: 'Random Forest',
    description: 'Nonlinear pattern detector',
    badge: 'RF'
  },
  {
    key: 'ensemble',
    name: 'Ensemble',
    description: 'Balanced average of both models',
    badge: 'AVG'
  }
]

const totalStudents = computed(() => (data.value.students || []).length)

const riskCounts = computed(() => {
  const students = data.value.students || []
  return {
    high: students.filter((student) => student.riskLevel === 'High').length,
    medium: students.filter((student) => student.riskLevel === 'Medium').length,
    low: students.filter((student) => student.riskLevel === 'Low').length
  }
})

const filteredStudents = computed(() => {
  const query = searchQuery.value.trim().toLowerCase()
  const filtered = (data.value.students || []).filter((student) => {
    const matchesRisk = riskFilter.value === 'all' || student.riskLevel === riskFilter.value
    const matchesSearch = query.length === 0 || String(student.studentName || '').toLowerCase().includes(query)
    return matchesRisk && matchesSearch
  })

  const sorted = [...filtered].sort((a, b) => {
    const aValue = a[sortKey.value]
    const bValue = b[sortKey.value]

    if (sortKey.value === 'studentName') {
      const result = String(aValue || '').localeCompare(String(bValue || ''))
      return sortDirection.value === 'asc' ? result : -result
    }

    if (sortKey.value === 'riskLevel') {
      const riskRank = { High: 3, Medium: 2, Low: 1 }
      const result = (riskRank[aValue] || 0) - (riskRank[bValue] || 0)
      return sortDirection.value === 'asc' ? result : -result
    }

    const result = Number(aValue || 0) - Number(bValue || 0)
    return sortDirection.value === 'asc' ? result : -result
  })

  return sorted
})

const summary = computed(() => {
  const students = data.value.students || []
  const highRisk = students.filter((student) => student.riskLevel === 'High').length
  const mediumRisk = students.filter((student) => student.riskLevel === 'Medium').length
  const totalPredictedPass = students.reduce((sum, student) => sum + Number(student.predictedPassProbability || 0), 0)
  return {
    studentsEvaluated: data.value.training?.studentsEvaluated || students.length,
    trainingSamples: data.value.training?.samples || 0,
    highRisk,
    avgPassProbability: students.length > 0 ? totalPredictedPass / students.length : 0,
    attentionRate: students.length > 0 ? ((highRisk + mediumRisk) / students.length) * 100 : 0
  }
})

const boardPassingRate = computed(() => {
  const students = data.value.students || []
  if (students.length === 0) return 75
  const total = students.reduce((sum, student) => sum + Number(student.averagePassingScore || 75), 0)
  return total / students.length
})

const highRiskRate = computed(() => {
  if (totalStudents.value === 0) return 0
  return (riskCounts.value.high / totalStudents.value) * 100
})

const readinessCounts = computed(() => {
  const threshold = Number(boardPassingRate.value || 75)
  const students = data.value.students || []
  return {
    ready: students.filter((student) => Number(student.predictedPassProbability || 0) >= threshold).length,
    notReady: students.filter((student) => Number(student.predictedPassProbability || 0) < threshold).length
  }
})

const readinessGaugeStyle = computed(() => {
  const value = clampNumber(summary.value.avgPassProbability)
  return {
    background: `conic-gradient(#248F3F 0 ${value}%, rgba(118, 118, 128, 0.14) ${value}% 100%)`
  }
})

const riskDonutStyle = computed(() => {
  if (totalStudents.value === 0) {
    return { background: 'conic-gradient(rgba(118, 118, 128, 0.18) 0 100%)' }
  }

  const high = clampNumber((riskCounts.value.high / totalStudents.value) * 100)
  const medium = clampNumber(((riskCounts.value.high + riskCounts.value.medium) / totalStudents.value) * 100)

  return {
    background: `conic-gradient(#D70015 0 ${high}%, #CC7A00 ${high}% ${medium}%, #248F3F ${medium}% 100%)`
  }
})

const modelMetricRows = computed(() => modelOptions.map((option) => {
  const metrics = ['accuracy', 'f1', 'auc'].map((metricKey) => {
    const value = metricNumber(option.key, metricKey)
    return {
      key: metricKey,
      label: metricKey === 'f1' ? 'F1' : metricKey.toUpperCase(),
      value,
      display: value > 0 ? `${value.toFixed(1)}%` : 'N/A'
    }
  })

  return {
    ...option,
    metrics
  }
}))

const scatterStudents = computed(() => {
  return [...(data.value.students || [])]
    .sort((a, b) => Number(b.predictedFailProbability || 0) - Number(a.predictedFailProbability || 0))
    .slice(0, 80)
})

const priorityCards = computed(() => {
  const students = data.value.students || []
  const sortedByRisk = [...students].sort((a, b) => Number(b.predictedFailProbability || 0) - Number(a.predictedFailProbability || 0))
  const sortedByReadiness = [...students].sort((a, b) => Number(b.predictedPassProbability || 0) - Number(a.predictedPassProbability || 0))
  const sortedByAttemptsRisk = [...students].sort((a, b) => {
    const aScore = Number(a.totalAttempts || 0) * Number(a.predictedFailProbability || 0)
    const bScore = Number(b.totalAttempts || 0) * Number(b.predictedFailProbability || 0)
    return bScore - aScore
  })
  const sortedByDisagreement = [...students].sort((a, b) => modelDisagreement(b) - modelDisagreement(a))

  return [
    {
      title: 'Highest Risk',
      tone: 'danger',
      student: sortedByRisk[0],
      initials: studentInitials(sortedByRisk[0])
    },
    {
      title: 'Board Ready',
      tone: 'good',
      student: sortedByReadiness[0],
      initials: studentInitials(sortedByReadiness[0])
    },
    {
      title: 'Needs Coaching',
      tone: 'amber',
      student: sortedByAttemptsRisk[0],
      initials: studentInitials(sortedByAttemptsRisk[0])
    },
    {
      title: 'Model Disagreement',
      tone: 'blue',
      student: sortedByDisagreement[0],
      initials: studentInitials(sortedByDisagreement[0])
    }
  ]
})

const sortLabel = computed(() => {
  const labels = {
    studentName: 'Name',
    totalAttempts: 'Attempts',
    latestScore: 'Latest Score',
    averageScore: 'Average Score',
    actualPassRate: 'Actual Pass',
    logisticProbability: 'Logistic Pass',
    randomForestProbability: 'Random Forest Pass',
    predictedPassProbability: 'Predicted Pass',
    predictedFailProbability: 'Predicted Fail',
    riskLevel: 'Risk Level'
  }
  return `${labels[sortKey.value] || sortKey.value} (${sortDirection.value === 'asc' ? 'ASC' : 'DESC'})`
})

const isFallbackModel = computed(() => data.value.metrics?.model_type === 'heuristic_fallback')

const modelStatusLabel = computed(() => {
  if (isFallbackModel.value) return 'Heuristic fallback'
  if (data.value.metrics?.evaluation_method) return 'Cross-validated'
  if (data.value.metrics?.model_type) return 'Model ready'
  return 'Pending data'
})

const metricValue = (modelKey, metricKey) => {
  if (isFallbackModel.value) return 'N/A'
  const metric = metricNumber(modelKey, metricKey)
  return metric > 0 ? `${metric.toFixed(1)}%` : 'N/A'
}

const selectModel = async (modelKey) => {
  if (selectedModel.value === modelKey) return
  selectedModel.value = modelKey
  await fetchPredictions()
}

const fetchPredictions = async () => {
  loading.value = true
  error.value = ''
  try {
    const response = await analyticsApi.getMlPredictions({
      timeFilter: timeFilter.value,
      model: selectedModel.value
    })
    const payload = response?.data || response
    if (response?.success === false) {
      throw new Error(response?.message || 'Failed to fetch predictions')
    }
    data.value = {
      model: payload?.model || selectedModel.value,
      trainedAt: payload?.trainedAt || null,
      training: payload?.training || { samples: 0, studentsEvaluated: 0 },
      metrics: payload?.metrics || {},
      students: Array.isArray(payload?.students) ? payload.students : []
    }
  } catch (err) {
    error.value = err?.message || 'Failed to fetch predictions'
    data.value = {
      model: selectedModel.value,
      trainedAt: null,
      training: { samples: 0, studentsEvaluated: 0 },
      metrics: {},
      students: []
    }
  } finally {
    loading.value = false
  }
}

const resetFilters = () => {
  searchQuery.value = ''
  riskFilter.value = 'all'
  sortKey.value = 'predictedFailProbability'
  sortDirection.value = 'desc'
}

const setSort = (key) => {
  if (sortKey.value === key) {
    sortDirection.value = sortDirection.value === 'asc' ? 'desc' : 'asc'
    return
  }
  sortKey.value = key
  sortDirection.value = key === 'studentName' ? 'asc' : 'desc'
}

const formatPercentage = (value) => `${Number(value || 0).toFixed(2)}%`
const formatDateTime = (value) => {
  if (!value) return 'N/A'
  return new Date(value).toLocaleString()
}

const scoreClass = (score) => {
  const num = Number(score || 0)
  const passingThreshold = Number(boardPassingRate.value || 75)
  const warningThreshold = Math.max(45, passingThreshold - 20)
  if (num >= passingThreshold) return 'score-good'
  if (num >= warningThreshold) return 'score-mid'
  return 'score-bad'
}

const failScoreClass = (score) => {
  const num = Number(score || 0)
  if (num >= 55) return 'score-bad'
  if (num >= 25) return 'score-mid'
  return 'score-good'
}

const safeRisk = (riskLevel) => String(riskLevel || 'medium').toLowerCase()

const clampNumber = (value, min = 0, max = 100) => Math.max(min, Math.min(max, Number(value || 0)))

const metricNumber = (modelKey, metricKey) => {
  if (isFallbackModel.value) return 0
  const metric = data.value.metrics?.[modelKey]?.[metricKey]
  return typeof metric === 'number' ? clampNumber(metric) : 0
}

const scatterPointStyle = (student) => ({
  left: `${clampNumber(student.averageScore)}%`,
  bottom: `${clampNumber(student.predictedPassProbability)}%`
})

const probabilityColor = (value) => {
  const probability = Number(value || 0)
  if (probability >= Number(boardPassingRate.value || 75)) return '#248F3F'
  if (probability >= 45) return '#CC7A00'
  return '#D70015'
}

const modelMiniBarStyle = (value) => {
  const probability = clampNumber(value)
  return {
    width: `${probability}%`,
    background: `linear-gradient(90deg, ${probabilityColor(probability)} 0%, rgba(10, 132, 255, 0.82) 100%)`
  }
}

const modelDisagreement = (student) => {
  return Math.abs(Number(student?.logisticProbability || 0) - Number(student?.randomForestProbability || 0))
}

const interventionLabel = (student) => {
  const passProbability = Number(student?.predictedPassProbability || 0)
  const attempts = Number(student?.totalAttempts || 0)
  if (passProbability >= Number(boardPassingRate.value || 75)) return 'Mock board'
  if (passProbability < 45 && attempts >= 5) return 'Coaching'
  if (passProbability < 45) return 'Foundations'
  if (modelDisagreement(student) >= 20) return 'Review data'
  return 'Monitor'
}

const studentInitials = (student) => {
  if (!student?.studentName) return 'NA'
  return String(student.studentName)
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part.charAt(0).toUpperCase())
    .join('')
}

const displayModelName = (modelKey) => {
  if (modelKey === 'logistic_regression') return 'Logistic Regression'
  if (modelKey === 'random_forest') return 'Random Forest'
  if (modelKey === 'ensemble') return 'Ensemble'
  return modelKey
}

onMounted(() => {
  fetchPredictions()
})
</script>

<style scoped>
.mlp {
  padding: 22px 26px 26px;
  background: #EEF2F6;
  min-height: 100%;
  display: flex;
  flex-direction: column;
  gap: 16px;
  font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}

.mlp-hero {
  background: rgba(255, 255, 255, 0.78);
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 18px;
  padding: 18px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
  backdrop-filter: blur(14px);
  -webkit-backdrop-filter: blur(14px);
}

.mlp-hero__main {
  display: flex;
  justify-content: space-between;
  gap: 14px;
  align-items: flex-start;
}

.mlp-hero__title h1 {
  margin: 0;
  font-size: 28px;
  letter-spacing: -0.6px;
  color: #111114;
}

.mlp-hero__subtitle {
  margin: 6px 0 0;
  color: rgba(60, 60, 67, 0.62);
  font-size: 14px;
  line-height: 1.4;
}

.mlp-meta {
  margin-top: 12px;
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.mlp-chip {
  display: inline-flex;
  align-items: baseline;
  gap: 8px;
  background: rgba(118, 118, 128, 0.10);
  border: 1px solid rgba(60, 60, 67, 0.10);
  color: rgba(60, 60, 67, 0.82);
  padding: 7px 10px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 600;
}

.mlp-chip__k {
  color: rgba(60, 60, 67, 0.58);
  font-weight: 700;
  letter-spacing: 0.02em;
}

.mlp-chip__v {
  color: #1D1D1F;
}

.mlp-chip--warn {
  background: rgba(255, 149, 0, 0.14);
  border-color: rgba(255, 149, 0, 0.18);
}

.mlp-hero__actions {
  display: flex;
  gap: 8px;
  justify-content: flex-end;
  align-items: center;
}

.mlp-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  border-radius: 12px;
  padding: 10px 14px;
  font-weight: 700;
  cursor: pointer;
  border: 1px solid rgba(0, 0, 0, 0.08);
  transition: transform 0.12s ease, box-shadow 0.12s ease, background-color 0.12s ease, border-color 0.12s ease,
    color 0.12s ease;
}

.mlp-btn:active {
  transform: scale(0.98);
}

.mlp-btn svg {
  width: 16px;
  height: 16px;
}

.mlp-btn--primary {
  background: #111114;
  color: #FFFFFF;
  border-color: rgba(0, 0, 0, 0.12);
  box-shadow: 0 10px 24px rgba(0, 0, 0, 0.14);
}

.mlp-btn--ghost {
  background: rgba(255, 255, 255, 0.75);
  color: #1D1D1F;
}

.mlp-btn:disabled {
  opacity: 0.55;
  cursor: not-allowed;
  transform: none;
}

.mlp-btn svg.spinning {
  animation: spin 1s linear infinite;
}

.mlp-kpis {
  margin-top: 14px;
  display: grid;
  grid-template-columns: repeat(5, minmax(0, 1fr));
  gap: 10px;
}

.mlp-kpi {
  background: rgba(255, 255, 255, 0.82);
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 14px;
  padding: 12px 12px 11px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.04);
  min-height: 84px;
}

.mlp-kpi__label {
  font-size: 12px;
  color: rgba(60, 60, 67, 0.62);
  font-weight: 700;
  letter-spacing: -0.1px;
}

.mlp-kpi__value {
  margin-top: 6px;
  font-size: 24px;
  font-weight: 800;
  color: #111114;
  letter-spacing: -0.4px;
}

.mlp-kpi__hint {
  margin-top: 4px;
  font-size: 12px;
  color: rgba(60, 60, 67, 0.52);
}

.mlp-kpi--danger {
  background: linear-gradient(180deg, rgba(255, 59, 48, 0.10), rgba(255, 255, 255, 0.85));
  border-color: rgba(255, 59, 48, 0.16);
}

.mlp-kpi--amber {
  background: linear-gradient(180deg, rgba(255, 149, 0, 0.10), rgba(255, 255, 255, 0.86));
  border-color: rgba(255, 149, 0, 0.16);
}

.mlp-models {
  margin-top: 12px;
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 10px;
}

.mlp-model-card {
  border: 1px solid rgba(60, 60, 67, 0.10);
  background: rgba(255, 255, 255, 0.74);
  border-radius: 14px;
  padding: 12px;
  text-align: left;
  color: #1D1D1F;
  cursor: pointer;
  transition: border-color 0.15s ease, box-shadow 0.15s ease, transform 0.12s ease, background-color 0.15s ease;
}

.mlp-model-card:hover,
.mlp-model-card.active {
  border-color: rgba(10, 132, 255, 0.34);
  background: rgba(255, 255, 255, 0.92);
  box-shadow: 0 10px 24px rgba(10, 132, 255, 0.10);
}

.mlp-model-card:active {
  transform: scale(0.99);
}

.mlp-model-card__top {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 12px;
}

.mlp-model-card__top strong,
.mlp-model-card__top small,
.mlp-model-card__metrics span,
.mlp-model-card__metrics small,
.mlp-model-card__metrics strong {
  display: block;
}

.mlp-model-card__top strong {
  font-size: 14px;
  letter-spacing: -0.1px;
}

.mlp-model-card__top small {
  margin-top: 3px;
  color: rgba(60, 60, 67, 0.58);
  font-size: 12px;
}

.mlp-model-card__badge {
  min-width: 38px;
  border-radius: 999px;
  padding: 5px 8px;
  background: rgba(10, 132, 255, 0.10);
  color: #007AFF;
  font-size: 11px;
  font-weight: 800;
  text-align: center;
}

.mlp-model-card__metrics {
  margin-top: 12px;
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 8px;
}

.mlp-model-card__metrics span {
  border-radius: 10px;
  padding: 8px;
  background: rgba(118, 118, 128, 0.08);
}

.mlp-model-card__metrics small {
  color: rgba(60, 60, 67, 0.56);
  font-size: 10px;
  font-weight: 700;
  text-transform: uppercase;
}

.mlp-model-card__metrics strong {
  margin-top: 3px;
  font-size: 13px;
}

.mlp-filters {
  margin-top: 12px;
  background: rgba(255, 255, 255, 0.78);
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 16px;
  padding: 12px;
  display: grid;
  grid-template-columns: repeat(12, minmax(0, 1fr));
  gap: 10px;
}

.mlp-filter {
  display: flex;
  flex-direction: column;
  gap: 6px;
  grid-column: span 3;
}

.mlp-filter--search {
  grid-column: span 4;
}

.mlp-filter label {
  font-size: 12px;
  font-weight: 700;
  color: rgba(60, 60, 67, 0.58);
}

.mlp-filter select,
.mlp-filter input {
  border: 1px solid rgba(60, 60, 67, 0.14);
  border-radius: 12px;
  padding: 10px 12px;
  font-size: 14px;
  background: rgba(118, 118, 128, 0.08);
  color: #111114;
  width: 100%;
  box-sizing: border-box;
  transition: border-color 0.15s ease, background-color 0.15s ease;
}

.mlp-filter select {
  appearance: none;
  -webkit-appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='%238E8E93' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 10px center;
  padding-right: 34px;
}

.mlp-filter select:focus,
.mlp-filter input:focus {
  outline: none;
  border-color: rgba(10, 132, 255, 0.42);
  background-color: rgba(10, 132, 255, 0.09);
}

.mlp-search {
  position: relative;
}

.mlp-search::before {
  content: '';
  position: absolute;
  left: 12px;
  top: 50%;
  transform: translateY(-50%);
  width: 14px;
  height: 14px;
  pointer-events: none;
  opacity: 0.85;
  background-repeat: no-repeat;
  background-size: 14px 14px;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='%238E8E93' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Ccircle cx='11' cy='11' r='7'/%3E%3Cline x1='21' y1='21' x2='16.65' y2='16.65'/%3E%3C/svg%3E");
}

.mlp-search input {
  width: 100%;
  padding-left: 36px;
}

.mlp-quick {
  grid-column: 1 / -1;
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  padding-top: 2px;
}

.mlp-pill {
  border: 1px solid rgba(60, 60, 67, 0.12);
  background: rgba(118, 118, 128, 0.08);
  border-radius: 999px;
  padding: 8px 12px;
  font-size: 13px;
  font-weight: 700;
  color: rgba(60, 60, 67, 0.72);
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 6px;
  transition: background-color 0.15s ease, border-color 0.15s ease, color 0.15s ease, transform 0.12s ease;
}

.mlp-pill:active {
  transform: scale(0.96);
}

.mlp-pill span {
  background: rgba(255, 255, 255, 0.85);
  padding: 2px 7px;
  border-radius: 999px;
  font-size: 12px;
}

.mlp-pill.active {
  border-color: rgba(10, 132, 255, 0.36);
  color: #007AFF;
  background: rgba(10, 132, 255, 0.12);
}

.mlp-pill--danger.active {
  border-color: rgba(255, 59, 48, 0.34);
  color: #FF3B30;
  background: rgba(255, 59, 48, 0.12);
}

.mlp-pill--amber.active {
  border-color: rgba(255, 149, 0, 0.34);
  color: #FF9500;
  background: rgba(255, 149, 0, 0.12);
}

.mlp-pill--good.active {
  border-color: rgba(52, 199, 89, 0.34);
  color: #34C759;
  background: rgba(52, 199, 89, 0.12);
}

.mlp-visuals,
.mlp-insights {
  display: grid;
  gap: 14px;
}

.mlp-visuals {
  grid-template-columns: 1.05fr 0.95fr 1.35fr;
  margin-bottom: 14px;
}

.mlp-insights {
  grid-template-columns: 1.15fr 0.85fr;
  margin-bottom: 14px;
}

.visual-card,
.priority-board {
  background: rgba(255, 255, 255, 0.92);
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 16px;
  padding: 15px;
  box-shadow: 0 10px 28px rgba(0, 0, 0, 0.05);
  min-width: 0;
}

.visual-card--wide {
  min-height: 246px;
}

.visual-card__head,
.priority-board__head {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  align-items: flex-start;
  margin-bottom: 14px;
}

.visual-card__head h2,
.priority-board__head h2 {
  margin: 0;
  color: #111114;
  font-size: 15px;
  font-weight: 850;
  letter-spacing: -0.2px;
}

.visual-card__head p,
.priority-board__head p {
  margin: 4px 0 0;
  color: rgba(60, 60, 67, 0.58);
  font-size: 12px;
  line-height: 1.35;
}

.visual-chip {
  flex: 0 0 auto;
  border-radius: 999px;
  padding: 5px 8px;
  background: rgba(10, 132, 255, 0.10);
  color: #007AFF;
  font-size: 11px;
  font-weight: 800;
}

.readiness-wrap,
.risk-donut-wrap {
  display: grid;
  grid-template-columns: auto 1fr;
  gap: 16px;
  align-items: center;
}

.readiness-gauge,
.risk-donut {
  width: 152px;
  height: 152px;
  border-radius: 50%;
  display: grid;
  place-items: center;
  box-shadow: inset 0 0 0 1px rgba(0, 0, 0, 0.04);
}

.readiness-gauge__inner,
.risk-donut__inner {
  width: 106px;
  height: 106px;
  border-radius: 50%;
  background: #FFFFFF;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
}

.readiness-gauge__inner strong,
.risk-donut__inner strong {
  color: #111114;
  font-size: 24px;
  font-weight: 900;
  letter-spacing: -0.5px;
}

.readiness-gauge__inner span,
.risk-donut__inner span {
  margin-top: 2px;
  color: #86868B;
  font-size: 11px;
  font-weight: 700;
}

.readiness-notes,
.risk-legend {
  display: grid;
  gap: 8px;
}

.readiness-notes div,
.risk-legend button {
  border: 1px solid rgba(60, 60, 67, 0.08);
  border-radius: 12px;
  padding: 9px 10px;
  background: rgba(118, 118, 128, 0.06);
}

.readiness-notes span,
.readiness-notes strong,
.risk-legend span,
.risk-legend strong {
  display: block;
}

.readiness-notes span {
  color: rgba(60, 60, 67, 0.58);
  font-size: 11px;
  font-weight: 700;
}

.readiness-notes strong {
  margin-top: 2px;
  color: #111114;
  font-size: 18px;
  font-weight: 850;
}

.risk-legend button {
  display: grid;
  grid-template-columns: auto 1fr auto;
  gap: 8px;
  align-items: center;
  color: #1D1D1F;
  cursor: pointer;
  text-align: left;
}

.risk-legend button:hover {
  border-color: rgba(10, 132, 255, 0.24);
  background: rgba(10, 132, 255, 0.07);
}

.risk-legend span {
  font-size: 12px;
  font-weight: 750;
}

.risk-legend strong {
  font-size: 14px;
  font-weight: 900;
}

.legend-dot {
  width: 9px;
  height: 9px;
  border-radius: 50%;
}

.legend-dot--high {
  background: #D70015;
}

.legend-dot--medium {
  background: #CC7A00;
}

.legend-dot--low {
  background: #248F3F;
}

.model-bars {
  display: grid;
  gap: 12px;
}

.model-bar-row {
  display: grid;
  grid-template-columns: 150px 1fr;
  gap: 14px;
  align-items: center;
}

.model-bar-row__name strong,
.model-bar-row__name span {
  display: block;
}

.model-bar-row__name strong {
  color: #111114;
  font-size: 13px;
  font-weight: 850;
}

.model-bar-row__name span {
  width: fit-content;
  margin-top: 5px;
  border-radius: 999px;
  padding: 3px 7px;
  background: rgba(10, 132, 255, 0.10);
  color: #007AFF;
  font-size: 10px;
  font-weight: 900;
}

.metric-bars {
  display: grid;
  gap: 7px;
}

.metric-bar {
  display: grid;
  grid-template-columns: 64px 1fr 52px;
  gap: 8px;
  align-items: center;
}

.metric-bar span,
.metric-bar strong {
  color: rgba(60, 60, 67, 0.70);
  font-size: 11px;
  font-weight: 800;
}

.metric-bar strong {
  color: #111114;
  text-align: right;
}

.metric-bar__track {
  height: 8px;
  border-radius: 999px;
  overflow: hidden;
  background: rgba(118, 118, 128, 0.12);
}

.metric-bar__fill {
  height: 100%;
  border-radius: inherit;
  background: linear-gradient(90deg, #007AFF 0%, #34C759 100%);
}

.risk-matrix {
  position: relative;
  height: 320px;
  border-radius: 14px;
  overflow: hidden;
  background:
    linear-gradient(90deg, rgba(60, 60, 67, 0.08) 1px, transparent 1px) 0 0 / 25% 100%,
    linear-gradient(0deg, rgba(60, 60, 67, 0.08) 1px, transparent 1px) 0 0 / 100% 25%,
    linear-gradient(135deg, rgba(255, 59, 48, 0.12), rgba(255, 149, 0, 0.08) 45%, rgba(52, 199, 89, 0.14));
  border: 1px solid rgba(60, 60, 67, 0.10);
}

.matrix-axis {
  position: absolute;
  z-index: 3;
  border-radius: 999px;
  padding: 4px 8px;
  background: rgba(255, 255, 255, 0.82);
  color: #6D6D72;
  font-size: 10px;
  font-weight: 850;
  text-transform: uppercase;
}

.matrix-axis--y {
  left: 10px;
  top: 10px;
}

.matrix-axis--x {
  right: 10px;
  bottom: 10px;
}

.matrix-guide {
  position: absolute;
  pointer-events: none;
  background: rgba(17, 17, 20, 0.12);
}

.matrix-guide--vertical {
  left: 75%;
  top: 0;
  width: 1px;
  height: 100%;
}

.matrix-guide--horizontal {
  left: 0;
  bottom: 75%;
  width: 100%;
  height: 1px;
}

.matrix-point {
  position: absolute;
  width: 12px;
  height: 12px;
  border-radius: 50%;
  border: 2px solid #FFFFFF;
  transform: translate(-50%, 50%);
  box-shadow: 0 8px 18px rgba(0, 0, 0, 0.18);
}

.matrix-point--high {
  background: #D70015;
}

.matrix-point--medium {
  background: #CC7A00;
}

.matrix-point--low {
  background: #248F3F;
}

.priority-board {
  display: flex;
  flex-direction: column;
}

.priority-grid {
  display: grid;
  gap: 10px;
}

.priority-card {
  border: 1px solid rgba(60, 60, 67, 0.08);
  border-radius: 14px;
  padding: 12px;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.86), rgba(248, 248, 250, 0.92));
}

.priority-card__top {
  display: flex;
  gap: 10px;
  align-items: center;
}

.priority-card__top span,
.priority-card__top strong {
  display: block;
}

.priority-card__top span {
  color: rgba(60, 60, 67, 0.58);
  font-size: 11px;
  font-weight: 800;
  text-transform: uppercase;
}

.priority-card__top strong {
  margin-top: 2px;
  color: #111114;
  font-size: 14px;
  font-weight: 850;
}

.priority-icon {
  width: 38px;
  height: 38px;
  border-radius: 12px;
  display: grid;
  place-items: center;
  color: #FFFFFF;
  font-size: 12px;
  font-weight: 900;
  flex: 0 0 auto;
}

.priority-icon--danger {
  background: #D70015;
}

.priority-icon--good {
  background: #248F3F;
}

.priority-icon--amber {
  background: #CC7A00;
}

.priority-icon--blue {
  background: #007AFF;
}

.priority-card__stats {
  margin-top: 10px;
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 8px;
}

.priority-card__stats div {
  min-width: 0;
  border-radius: 10px;
  padding: 8px;
  background: rgba(118, 118, 128, 0.07);
}

.priority-card__stats span,
.priority-card__stats strong {
  display: block;
}

.priority-card__stats span {
  color: rgba(60, 60, 67, 0.56);
  font-size: 10px;
  font-weight: 800;
}

.priority-card__stats strong {
  margin-top: 3px;
  color: #111114;
  font-size: 12px;
  font-weight: 850;
  overflow-wrap: anywhere;
}

.mlp-panel {
  background: #F6F8FB;
  border: 1px solid #DDE3EC;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 8px 24px rgba(15, 23, 42, 0.06);
}

.mlp-panel__head {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  align-items: center;
  padding: 14px 14px;
  border-bottom: 1px solid #E1E7EF;
}

.mlp-panel__title {
  font-weight: 800;
  color: #111114;
  letter-spacing: -0.2px;
}

.mlp-panel__sub {
  font-size: 12px;
  color: rgba(60, 60, 67, 0.60);
  margin-top: 2px;
}

.mlp-panel__right {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 10px;
  flex-wrap: wrap;
}

.mlp-selected {
  border-radius: 10px;
  padding: 7px 10px;
  background: rgba(10, 132, 255, 0.08);
  color: #1D1D1F;
}

.mlp-selected span,
.mlp-selected strong {
  display: block;
}

.mlp-selected span {
  color: rgba(60, 60, 67, 0.58);
  font-size: 10px;
  font-weight: 800;
  text-transform: uppercase;
}

.mlp-selected strong {
  margin-top: 2px;
  font-size: 12px;
}

.view-toggle {
  background: #F2F2F7;
  border-radius: 10px;
  padding: 3px;
  display: inline-flex;
}

.view-toggle button {
  border: none;
  background: transparent;
  color: #6D6D72;
  padding: 7px 12px;
  border-radius: 8px;
  font-weight: 700;
  cursor: pointer;
}

.view-toggle button.active {
  background: #FFFFFF;
  color: #1D1D1F;
}

.sort-label {
  font-size: 12px;
  color: #86868B;
  font-weight: 600;
}

.table-wrapper {
  overflow-x: auto;
}

.mlp-table {
  width: 100%;
  border-collapse: collapse;
}

.mlp-table th,
.mlp-table td {
  text-align: left;
  padding: 12px 14px;
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
  white-space: nowrap;
  font-size: 14px;
}

.mlp-table th {
  position: sticky;
  top: 0;
  z-index: 2;
  background: rgba(255, 255, 255, 0.94);
  backdrop-filter: blur(10px);
  font-size: 12px;
  color: #86868B;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.3px;
}

.mlp-table th.sortable {
  cursor: pointer;
}

.mlp-table th.sortable:hover {
  color: #1D1D1F;
}

.mlp-table tbody tr:nth-child(2n) td {
  background: rgba(118, 118, 128, 0.04);
}

.mlp-table tbody tr:hover td {
  background: rgba(10, 132, 255, 0.06);
}

.student-name {
  font-weight: 600;
  color: #1D1D1F;
}

.probability-cell {
  min-width: 118px;
}

.probability-track {
  display: block;
  width: 100%;
  height: 5px;
  margin-top: 6px;
  border-radius: 999px;
  background: rgba(118, 118, 128, 0.14);
  overflow: hidden;
}

.probability-fill {
  display: block;
  height: 100%;
  border-radius: inherit;
  background: linear-gradient(90deg, #248F3F 0%, #34C759 100%);
}

.card-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 16px;
  padding: 18px;
  align-items: stretch;
  background: #EEF2F6;
}

.student-card {
  position: relative;
  display: flex;
  flex-direction: column;
  min-height: 206px;
  border: 1px solid #D8E0EA;
  border-radius: 12px;
  padding: 18px 18px 16px;
  background: #F8FAFC;
  box-shadow: 0 2px 8px rgba(15, 23, 42, 0.06);
  transition: border-color 160ms ease, box-shadow 160ms ease, transform 160ms ease;
}

.student-card:hover {
  transform: translateY(-1px);
  border-color: #C8D2DF;
  box-shadow: 0 10px 24px rgba(15, 23, 42, 0.10);
}

.student-card-head {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 16px;
}

.student-identity {
  min-width: 0;
}

.student-card .student-name {
  color: #111827;
  font-size: 15px;
  font-weight: 800;
  line-height: 1.25;
}

.student-subtitle {
  display: flex;
  flex-wrap: wrap;
  gap: 4px 10px;
  margin-top: 6px;
  color: #6B7280;
  font-size: 12px;
  font-weight: 550;
  line-height: 1.35;
}

.student-subtitle span + span {
  position: relative;
}

.student-subtitle span + span::before {
  content: '';
  position: absolute;
  left: -6px;
  top: 50%;
  width: 2px;
  height: 2px;
  border-radius: 50%;
  background: #D1D5DB;
}

.student-forecast {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  gap: 18px;
  margin-top: 22px;
}

.student-forecast__primary,
.student-forecast__secondary {
  min-width: 0;
}

.student-forecast__primary strong,
.student-forecast__primary span,
.student-forecast__secondary strong,
.student-forecast__secondary span {
  display: block;
}

.student-forecast__primary strong {
  color: #DC2626;
  font-size: 25px;
  font-weight: 800;
  line-height: 1;
}

.student-forecast__primary span,
.student-forecast__secondary span {
  margin-top: 6px;
  color: #9CA3AF;
  font-size: 11px;
  font-weight: 600;
  line-height: 1.2;
}

.student-forecast__secondary {
  text-align: right;
}

.student-forecast__secondary strong {
  color: #111827;
  font-size: 15px;
  font-weight: 800;
  line-height: 1;
}

.student-readiness__bar {
  height: 4px;
  margin-top: 14px;
  border-radius: 999px;
  background: #DDE3EC;
  overflow: hidden;
}

.student-readiness__fill {
  height: 100%;
  border-radius: inherit;
  background: #DC2626 !important;
}

.student-stats {
  margin-top: 20px;
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 14px;
}

.student-stats div {
  min-width: 0;
}

.student-stats div strong,
.student-stats div span {
  display: block;
}

.student-stats div strong {
  color: #111827;
  font-size: 13.5px;
  font-weight: 800;
  line-height: 1.2;
}

.student-stats div span {
  margin-top: 5px;
  color: #9CA3AF;
  font-size: 11px;
  font-weight: 600;
  line-height: 1.2;
}

.student-model-summary {
  margin-top: auto;
  padding-top: 18px;
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px 10px;
  color: #6B7280;
  font-size: 11px;
  font-weight: 600;
}

.student-model-summary span,
.student-model-summary strong {
  border-radius: 999px;
  padding: 5px 9px;
  line-height: 1;
}

.student-model-summary span {
  color: #9CA3AF;
  background: transparent;
  padding-left: 0;
}

.student-model-summary strong {
  color: #4B5563;
  background: #E9EEF5;
  font-weight: 700;
}
.risk-badge {
  display: inline-block;
  border-radius: 999px;
  font-size: 11px;
  font-weight: 800;
  padding: 5px 9px;
  line-height: 1;
}

.risk-low {
  color: #FFFFFF;
  background: #10B981;
}

.risk-medium {
  color: #FFFFFF;
  background: #F59E0B;
}

.risk-high {
  color: #FFFFFF;
  background: #DC2626;
}

.risk-mid {
  color: #CC7A00;
}

.score-good {
  color: #248F3F;
  font-weight: 700;
}

.score-mid {
  color: #CC7A00;
  font-weight: 700;
}

.score-bad {
  color: #B91C1C;
  font-weight: 700;
}

.loading-state,
.error-state,
.empty-state {
  background: rgba(255, 255, 255, 0.92);
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 16px;
  padding: 36px;
  text-align: center;
}

.spinner {
  width: 28px;
  height: 28px;
  border: 3px solid #E5E5EA;
  border-top-color: #007AFF;
  border-radius: 50%;
  margin: 0 auto 12px;
  animation: spin 0.8s linear infinite;
}

.error-state h3,
.empty-state h3 {
  margin: 0;
  color: #1D1D1F;
}

.error-state p,
.empty-state p,
.loading-state p {
  margin: 8px 0 0;
  color: #6D6D72;
}

.error-state button {
  margin-top: 14px;
  border: none;
  border-radius: 10px;
  background: #1D1D1F;
  color: #FFFFFF;
  padding: 10px 14px;
  font-weight: 600;
  cursor: pointer;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

@media (prefers-color-scheme: dark) {
  .mlp {
    background: #0F0F12;
  }

  .mlp-hero,
  .mlp-panel,
  .visual-card,
  .priority-board,
  .student-card,
  .loading-state,
  .error-state,
  .empty-state {
    background: rgba(22, 22, 28, 0.82);
    border-color: rgba(255, 255, 255, 0.10);
  }

  .mlp-kpi,
  .mlp-model-card,
  .mlp-filters {
    background: rgba(22, 22, 28, 0.74);
    border-color: rgba(255, 255, 255, 0.10);
  }

  .mlp-model-card:hover,
  .mlp-model-card.active {
    background: rgba(28, 28, 34, 0.92);
    border-color: rgba(77, 163, 255, 0.38);
  }

  .card-grid {
    background: rgba(255, 255, 255, 0.04);
  }

  .student-card {
    border-color: rgba(255, 255, 255, 0.12);
    box-shadow: 0 10px 28px rgba(0, 0, 0, 0.28);
  }

  .student-card:hover {
    border-color: rgba(255, 255, 255, 0.20);
    box-shadow: 0 16px 36px rgba(0, 0, 0, 0.34);
  }

  .mlp-hero__title h1,
  .mlp-chip__v,
  .mlp-kpi__value,
  .visual-card__head h2,
  .priority-board__head h2,
  .readiness-gauge__inner strong,
  .risk-donut__inner strong,
  .readiness-notes strong,
  .risk-legend button,
  .model-bar-row__name strong,
  .metric-bar strong,
  .priority-card__top strong,
  .priority-card__stats strong,
  .student-forecast__secondary strong,
  .student-stats div strong,
  .mlp-panel__title,
  .mlp-model-card__top strong,
  .mlp-model-card__metrics strong,
  .mlp-selected,
  .student-name {
    color: rgba(242, 242, 247, 0.92);
  }

  .mlp-hero__subtitle,
  .mlp-chip__k,
  .mlp-kpi__label,
  .mlp-kpi__hint,
  .visual-card__head p,
  .priority-board__head p,
  .readiness-gauge__inner span,
  .risk-donut__inner span,
  .readiness-notes span,
  .metric-bar span,
  .priority-card__top span,
  .priority-card__stats span,
  .student-subtitle,
  .student-forecast__primary span,
  .student-forecast__secondary span,
  .student-stats div span,
  .student-model-summary,
  .mlp-panel__sub,
  .mlp-model-card__top small,
  .mlp-model-card__metrics small,
  .mlp-selected span,
  .sort-label,
  .error-state p,
  .empty-state p,
  .loading-state p {
    color: rgba(235, 235, 245, 0.62);
  }

  .mlp-filter label {
    color: rgba(235, 235, 245, 0.62);
  }

  .mlp-filter select,
  .mlp-filter input {
    background: rgba(44, 44, 50, 0.78);
    border-color: rgba(255, 255, 255, 0.14);
    color: rgba(242, 242, 247, 0.92);
  }

  .mlp-filter select {
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='%23A1A1AA' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E");
  }

  .mlp-search::before {
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='%23A1A1AA' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Ccircle cx='11' cy='11' r='7'/%3E%3Cline x1='21' y1='21' x2='16.65' y2='16.65'/%3E%3C/svg%3E");
  }

  .mlp-chip {
    background: rgba(118, 118, 128, 0.18);
    border-color: rgba(255, 255, 255, 0.10);
    color: rgba(235, 235, 245, 0.72);
  }

  .mlp-model-card__metrics span,
  .mlp-selected,
  .readiness-notes div,
  .risk-legend button,
  .priority-card__stats div,
  .student-readiness__bar,
  .probability-track {
    background: rgba(118, 118, 128, 0.16);
  }

  .student-model-summary span {
    color: rgba(235, 235, 245, 0.68);
  }

  .student-model-summary strong {
    background: rgba(118, 118, 128, 0.16);
    color: rgba(235, 235, 245, 0.76);
  }

  .readiness-gauge__inner,
  .risk-donut__inner,
  .matrix-axis,
  .priority-card {
    background: rgba(22, 22, 28, 0.96);
    border-color: rgba(255, 255, 255, 0.10);
  }

  .risk-matrix {
    border-color: rgba(255, 255, 255, 0.10);
    background:
      linear-gradient(90deg, rgba(255, 255, 255, 0.08) 1px, transparent 1px) 0 0 / 25% 100%,
      linear-gradient(0deg, rgba(255, 255, 255, 0.08) 1px, transparent 1px) 0 0 / 100% 25%,
      linear-gradient(135deg, rgba(255, 123, 114, 0.14), rgba(255, 180, 87, 0.10) 45%, rgba(98, 215, 132, 0.14));
  }

  .mlp-pill span {
    background: rgba(255, 255, 255, 0.14);
    color: rgba(242, 242, 247, 0.90);
  }

  .mlp-pill {
    background: rgba(118, 118, 128, 0.18);
    border-color: rgba(255, 255, 255, 0.10);
    color: rgba(235, 235, 245, 0.72);
  }

  .mlp-pill.active {
    color: #4DA3FF;
    background: rgba(77, 163, 255, 0.16);
    border-color: rgba(77, 163, 255, 0.36);
  }

  .mlp-pill--danger.active {
    color: #FF7B72;
    background: rgba(255, 123, 114, 0.16);
    border-color: rgba(255, 123, 114, 0.36);
  }

  .mlp-pill--amber.active {
    color: #FFB457;
    background: rgba(255, 180, 87, 0.16);
    border-color: rgba(255, 180, 87, 0.36);
  }

  .mlp-pill--good.active {
    color: #62D784;
    background: rgba(98, 215, 132, 0.16);
    border-color: rgba(98, 215, 132, 0.36);
  }

  .mlp-table th {
    background: rgba(22, 22, 28, 0.86);
    border-bottom-color: rgba(255, 255, 255, 0.10);
  }

  .mlp-table td {
    border-bottom-color: rgba(255, 255, 255, 0.08);
    color: rgba(242, 242, 247, 0.86);
  }

  .mlp-table tbody tr:nth-child(2n) td {
    background: rgba(118, 118, 128, 0.08);
  }

  .mlp-table tbody tr:hover td {
    background: rgba(77, 163, 255, 0.12);
  }
}

@media (max-width: 1200px) {
  .mlp-hero__main {
    flex-direction: column;
  }

  .mlp-kpis {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }

  .mlp-models {
    grid-template-columns: 1fr;
  }

  .mlp-visuals,
  .mlp-insights {
    grid-template-columns: 1fr;
  }

  .mlp-filter {
    grid-column: span 6;
  }

  .mlp-filter--search {
    grid-column: span 12;
  }
}

@media (max-width: 760px) {
  .mlp {
    padding: 16px;
  }

  .mlp-kpis {
    grid-template-columns: 1fr;
  }

  .mlp-models {
    grid-template-columns: 1fr;
  }

  .readiness-wrap,
  .risk-donut-wrap,
  .model-bar-row {
    grid-template-columns: 1fr;
  }

  .readiness-gauge,
  .risk-donut {
    margin: 0 auto;
  }

  .risk-matrix {
    height: 260px;
  }

  .priority-card__stats {
    grid-template-columns: 1fr;
  }

  .student-stats {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .mlp-filters {
    grid-template-columns: 1fr;
  }

  .mlp-filter,
  .mlp-filter--search {
    grid-column: span 1;
  }

  .mlp-panel__head {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }

  .card-grid {
    grid-template-columns: 1fr;
  }
}
</style>



