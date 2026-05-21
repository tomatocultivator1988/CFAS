<template>
  <div class="view-scores">
    <!-- Header -->
    <div class="scores-header">
      <div class="header-content">
        <h2 class="page-title">Student Scores</h2>
        <p class="page-subtitle">Click on a student to view their categories and exam results</p>
      </div>
      <div class="header-actions">
        <button @click="refreshData" class="btn-refresh" :disabled="loading">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
          </svg>
          <span>Refresh</span>
        </button>
        <div class="auto-refresh-status">
          <div class="status-indicator" :class="{ 'active': autoRefreshActive }"></div>
          <span class="status-text">Auto-refresh {{ autoRefreshActive ? 'ON' : 'OFF' }}</span>
        </div>
      </div>
    </div>

    <!-- Search Filter -->
    <div class="filters-section">
      <div class="filter-group">
        <label>Search Student</label>
        <input 
          v-model="searchStudent" 
          type="text" 
          placeholder="Search by name or username..." 
          class="filter-input"
        />
      </div>
      <div class="filter-actions">
        <button
          @click="openBulkSendConfirm"
          class="btn-send-bulk"
          :disabled="sendingBulk || filteredStudentData.length === 0"
        >
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M4 4h16v16H4z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
            <path d="M4 7l8 6 8-6" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
          </svg>
          <span>{{ sendingBulk ? 'Sending...' : 'Send Summaries' }}</span>
        </button>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading-container">
      <div class="spinner-ring"></div>
      <p>Loading scores...</p>
    </div>

    <!-- Students Grid -->
    <div v-else-if="studentData.length > 0" class="students-grid">
      <div 
        v-for="(student, index) in filteredStudentData" 
        :key="student.student_id"
        class="student-card"
        :style="{ animationDelay: `${Math.min(index * 0.03, 0.6)}s` }"
        role="button"
        tabindex="0"
        :aria-label="`View details for ${student.name}. ${student.total_exams} exams taken, ${student.pass_rate}% pass rate`"
        @click="viewStudentDetails(student)"
        @keydown.enter="viewStudentDetails(student)"
      >
        <!-- Row 1: Name and Username -->
        <div class="card-row-1">
          <div class="student-name-section">
            <div class="student-card-name">{{ student.name }}</div>
            <div class="student-card-username">@{{ student.username }}</div>
          </div>
        </div>
        
        <!-- Row 2: Stats -->
        <div class="card-row-2">
          <div class="stat-compact">
            <span class="stat-value">{{ student.total_exams }}</span>
            <span class="stat-label">Exams</span>
          </div>
          <div class="card-arrow">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M9 5l7 7-7 7" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
            </svg>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="empty-state">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
        <path d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
      </svg>
      <h3>No Data Found</h3>
      <p>No student data available.</p>
    </div>

    <!-- Student Details Modal (Categories) -->
    <transition name="modal-fade">
      <div v-if="showStudentModal" class="modal-overlay-review">
        <transition name="modal-scale">
          <div v-if="showStudentModal" class="details-modal">
            <div class="details-header">
              <div class="details-header-content">
                <div class="student-avatar-large">
                  {{ getInitials(selectedStudent?.name) }}
                </div>
                <div>
                  <h2 class="details-title">{{ selectedStudent?.name }}</h2>
                  <p class="details-subtitle">@{{ selectedStudent?.username }} | {{ selectedStudent?.email || 'No email set' }}</p>
                </div>
              </div>
              <div class="details-actions">
                <button
                  @click="sendSelectedSummary"
                  class="btn-send-summary"
                  :disabled="sendingStudentId === selectedStudent?.student_id || !selectedStudent?.email"
                  :title="selectedStudent?.email ? 'Send score summary' : 'Add an email before sending'"
                >
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <path d="M4 4h16v16H4z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                    <path d="M4 7l8 6 8-6" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                  </svg>
                  <span>{{ sendingStudentId === selectedStudent?.student_id ? 'Sending...' : 'Send Summary' }}</span>
                </button>
                <button @click="closeStudentModal" class="btn-close-review">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <path d="M6 18L18 6M6 6l12 12" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                  </svg>
                </button>
              </div>
            </div>
            
            <div class="details-summary">
              <div class="summary-stat">
                <div class="summary-stat-label">Total Exams</div>
                <div class="summary-stat-value">{{ selectedStudent?.total_exams }}</div>
              </div>
              <div class="summary-stat">
                <div class="summary-stat-label">Pass Rate</div>
                <div class="summary-stat-value">{{ selectedStudent?.pass_rate }}%</div>
              </div>
            </div>
            
            <div class="categories-list">
              <div 
                v-for="category in selectedStudent?.categories" 
                :key="category.category"
                class="category-card"
                @click="viewCategoryExams(category)"
              >
                <div class="category-header">
                  <div class="category-icon">{{ category.category_icon }}</div>
                  <div class="category-info">
                    <div class="category-name">{{ category.category }}</div>
                    <div class="category-status" :class="getStatusClass(category.status)">
                      {{ category.status }}
                    </div>
                  </div>
                  <div class="category-card-arrow">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                      <path d="M9 5l7 7-7 7" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                    </svg>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </transition>
      </div>
    </transition>

    <!-- Category Exams Modal -->
    <transition name="modal-fade">
      <div v-if="showCategoryModal" class="modal-overlay-review">
        <transition name="modal-scale">
          <div v-if="showCategoryModal" class="details-modal">
            <div class="details-header">
              <div class="details-header-content">
                <div class="category-icon-large">
                  {{ selectedCategory?.category_icon }}
                </div>
                <div>
                  <h2 class="details-title">{{ selectedCategory?.category }}</h2>
                  <p class="details-subtitle">{{ selectedStudent?.name }}</p>
                </div>
              </div>
              <button @click="closeCategoryModal" class="btn-close-review">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <path d="M6 18L18 6M6 6l12 12" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                </svg>
              </button>
            </div>
            
            <div class="categories-list">
              <div 
                v-for="exam in selectedCategory?.exams" 
                :key="exam.exam_id"
                class="category-card"
              >
                <div class="category-header">
                  <div class="category-icon">📝</div>
                  <div class="category-info">
                    <div class="category-name">{{ exam.exam_title }}</div>
                    <div class="category-status" :class="getStatusClass(exam.status)">
                      {{ exam.status }}
                    </div>
                  </div>
                </div>
                
                <div v-if="exam.attempts && exam.attempts.length > 0" class="attempts-list">
                  <div 
                    v-for="attempt in exam.attempts" 
                    :key="attempt.attempt_id"
                    class="attempt-item"
                    @click="viewAttemptReview(attempt.attempt_id)"
                  >
                    <div class="attempt-info">
                      <span class="attempt-label">Try {{ attempt.attempt_number }}</span>
                      <span class="attempt-score">{{ attempt.score }}/{{ attempt.total }}</span>
                    </div>
                    <div class="attempt-result">
                      <span class="attempt-percentage" :style="{ color: getPercentageColor(attempt.percentage) }">
                        {{ attempt.percentage }}%
                      </span>
                      <span class="attempt-badge" :class="attempt.passed ? 'passed' : 'failed'">
                        {{ attempt.passed ? 'PASSED' : 'FAILED' }}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </transition>
      </div>
    </transition>

    <!-- Exam Review Modal -->
    <transition name="modal-fade">
      <div v-if="showReviewModal" class="modal-overlay-review">
        <transition name="modal-scale">
          <div v-if="showReviewModal" class="review-modal">
            <!-- Loading State -->
            <div v-if="!reviewData" class="review-loading">
              <div class="spinner-ring"></div>
              <p>Loading exam review...</p>
            </div>

            <!-- Review Content -->
            <template v-else>
              <div class="review-header">
                <div>
                  <h2 class="review-title">{{ reviewData?.attempt?.exam_title }}</h2>
                  <p class="review-subtitle">
                    {{ reviewData?.attempt?.student_name }} • Attempt #{{ reviewData?.attempt?.attempt_number }}
                  </p>
                </div>
                <button @click="closeReviewModal" class="btn-close-review">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <path d="M6 18L18 6M6 6l12 12" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                  </svg>
                </button>
              </div>
              
              <div class="review-score-summary">
                <div class="summary-item">
                  <div class="summary-icon" :class="getScoreClassForReview(reviewData?.attempt?.percentage)">
                    {{ reviewData?.attempt?.percentage }}%
                  </div>
                  <div class="summary-info">
                    <div class="summary-label">Final Score</div>
                    <div class="summary-value">{{ reviewData?.attempt?.score }}/{{ reviewData?.attempt?.total_questions }}</div>
                  </div>
                </div>
              </div>
              
              <div class="review-questions">
                <div 
                  v-for="(question, index) in reviewData?.questions" 
                  :key="question.id" 
                  class="review-question-card"
                  :class="{ 'correct': question.is_correct, 'incorrect': !question.is_correct }"
                >
                  <div class="question-header-review">
                    <div class="question-number-badge" :class="question.is_correct ? 'correct-badge' : 'incorrect-badge'">
                      <svg v-if="question.is_correct" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                        <path d="M5 13l4 4L19 7" stroke-linecap="round" stroke-linejoin="round" stroke-width="3"/>
                      </svg>
                      <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor">
                        <path d="M6 18L18 6M6 6l12 12" stroke-linecap="round" stroke-linejoin="round" stroke-width="3"/>
                      </svg>
                    </div>
                    <span class="question-number">Question {{ index + 1 }}</span>
                  </div>
                  
                  <div class="question-text-review">{{ question.question_text }}</div>
                  
                  <div class="choices-review">
                    <div 
                      v-for="choice in question.choices" 
                      :key="choice.id"
                      class="choice-review"
                      :class="{
                        'user-choice': choice.id === question.user_answer_id,
                        'correct-choice': choice.is_correct,
                        'wrong-choice': choice.id === question.user_answer_id && !choice.is_correct
                      }"
                    >
                      <div class="choice-indicator">
                        <svg v-if="choice.is_correct" viewBox="0 0 24 24" fill="currentColor">
                          <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                        </svg>
                        <svg v-else-if="choice.id === question.user_answer_id" viewBox="0 0 24 24" fill="currentColor">
                          <path d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                        </svg>
                        <div v-else class="empty-circle"></div>
                      </div>
                      <div class="choice-content">
                        <div class="choice-text-review">{{ choice.choice_text }}</div>
                        <div v-if="choice.is_correct" class="choice-label correct-label">Correct Answer</div>
                        <div v-else-if="choice.id === question.user_answer_id" class="choice-label your-label">Student's Answer</div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </template>
          </div>
        </transition>
      </div>
    </transition>

    <transition name="modal-fade">
      <div v-if="showBulkConfirm" class="modal-overlay-review">
        <transition name="modal-scale">
          <div v-if="showBulkConfirm" class="send-confirm-modal">
            <div class="send-confirm-header">
              <div>
                <h3>Send Score Summaries?</h3>
                <p>This will email {{ filteredStudentData.length }} filtered reviewee{{ filteredStudentData.length === 1 ? '' : 's' }}.</p>
              </div>
              <button @click="showBulkConfirm = false" class="btn-close-review">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <path d="M6 18L18 6M6 6l12 12" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                </svg>
              </button>
            </div>
            <div class="send-confirm-actions">
              <button @click="showBulkConfirm = false" class="btn-cancel-send" :disabled="sendingBulk">Cancel</button>
              <button @click="confirmBulkSend" class="btn-confirm-send" :disabled="sendingBulk">
                {{ sendingBulk ? 'Sending...' : 'Send Emails' }}
              </button>
            </div>
          </div>
        </transition>
      </div>
    </transition>

    <transition name="notification-slide">
      <div v-if="sendNotice.show" class="send-notification" :class="sendNotice.type">
        <div class="send-notification-title">{{ sendNotice.title }}</div>
        <div class="send-notification-message">{{ sendNotice.message }}</div>
        <button @click="sendNotice.show = false" class="send-notification-close">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M6 18L18 6M6 6l12 12" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
          </svg>
        </button>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import api from '@/services/api'
import { useAdminAutoRefresh } from '@/composables/useComponentAutoRefresh'

const loading = ref(true)
const categoryData = ref([])
const studentData = ref([])
const searchStudent = ref('')
const selectedStudent = ref(null)
const selectedCategory = ref(null)
const showStudentModal = ref(false)
const showCategoryModal = ref(false)
const showReviewModal = ref(false)
const reviewData = ref(null)
const sendingStudentId = ref(null)
const sendingBulk = ref(false)
const showBulkConfirm = ref(false)
const sendNotice = ref({
  show: false,
  type: 'success',
  title: '',
  message: ''
})

// Filter students based on search
const filteredStudentData = computed(() => {
  let filtered = studentData.value
  
  if (searchStudent.value) {
    const search = searchStudent.value.toLowerCase()
    filtered = filtered.filter(s => 
      s.name.toLowerCase().includes(search) ||
      s.username.toLowerCase().includes(search) ||
      (s.email || '').toLowerCase().includes(search)
    )
  }
  
  return filtered.sort((a, b) => a.name.localeCompare(b.name))
})

const getPercentageColor = (percentage) => {
  if (percentage >= 90) return '#34C759'
  if (percentage >= 75) return '#FF9500'
  return '#FF3B30'
}

const getPassRateColor = (rate) => {
  if (rate >= 75) return '#34C759'  // Green
  if (rate >= 50) return '#FF9500'  // Orange
  return '#FF3B30'  // Red
}

const getStatusClass = (status) => {
  if (status.includes('Passed')) return 'status-passed'
  if (status.includes('Failed')) return 'status-failed'
  return 'status-not-taken'
}

const getInitials = (name) => {
  if (!name) return '?'
  const parts = name.trim().split(' ')
  if (parts.length >= 2) {
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase()
  }
  return name.substring(0, 2).toUpperCase()
}

const getCategoryIcon = (category) => {
  const cat = category.toLowerCase()
  if (cat.includes('aquaculture')) return '🐟'
  if (cat.includes('capture')) return '🎣'
  if (cat.includes('post')) return '📦'
  if (cat.includes('aquatic')) return '🌊'
  return '📚'
}

const loadData = async () => {
  loading.value = true
  try {
    const response = await api.get('/admin/export/category-exam-data')
    
    if (response.data.success) {
      categoryData.value = response.data.data
      
      // Reorganize data by students
      const studentsMap = new Map()
      
      // Iterate through categories and exams to build student-centric data
      categoryData.value.forEach(categoryItem => {
        categoryItem.exams.forEach(exam => {
          exam.students.forEach(student => {
            if (!studentsMap.has(student.student_id)) {
              studentsMap.set(student.student_id, {
                student_id: student.student_id,
                username: student.username,
                email: student.email || null,
                name: student.name,
                categories: new Map(),
                total_exams: 0,
                passed_exams: 0
              })
            }
            
            const studentEntry = studentsMap.get(student.student_id)
            
            // Add category if not exists
            if (!studentEntry.categories.has(categoryItem.category)) {
              studentEntry.categories.set(categoryItem.category, {
                category: categoryItem.category,
                category_icon: categoryItem.category_icon,
                exams: [],
                passed: 0,
                failed: 0,
                not_taken: 0
              })
            }
            
            const categoryEntry = studentEntry.categories.get(categoryItem.category)
            
            // Add exam to category
            categoryEntry.exams.push({
              exam_id: exam.exam_id,
              exam_title: exam.exam_title,
              status: student.status,
              attempts: student.attempts || []
            })
            
            // Update counts
            if (student.status !== 'Not Taken') {
              studentEntry.total_exams++
              if (student.status.includes('Passed')) {
                studentEntry.passed_exams++
                categoryEntry.passed++
              } else {
                categoryEntry.failed++
              }
            } else {
              categoryEntry.not_taken++
            }
          })
        })
      })
      
      // Convert to array and calculate pass rates
      studentData.value = Array.from(studentsMap.values()).map(student => {
        const categories = Array.from(student.categories.values()).map(cat => {
          const totalExams = cat.exams.length
          const status = totalExams === cat.not_taken ? 'Not Taken' :
                        cat.passed > 0 ? `${cat.passed}/${totalExams} Passed` :
                        'All Failed'
          
          return {
            ...cat,
            status
          }
        })
        
        const pass_rate = student.total_exams > 0 
          ? Math.round((student.passed_exams / student.total_exams) * 100)
          : 0
        
        return {
          ...student,
          categories,
          pass_rate
        }
      })
    }
  } catch (error) {
    console.error('Failed to load category exam data:', error)
  } finally {
    loading.value = false
  }
}

const refreshData = () => {
  selectedStudent.value = null
  selectedCategory.value = null
  showStudentModal.value = false
  showCategoryModal.value = false
  loadData()
}

const viewStudentDetails = (student) => {
  selectedStudent.value = student
  showStudentModal.value = true
}

const closeStudentModal = () => {
  showStudentModal.value = false
  selectedStudent.value = null
}

const viewCategoryExams = (category) => {
  selectedCategory.value = category
  showCategoryModal.value = true
}

const closeCategoryModal = () => {
  showCategoryModal.value = false
  selectedCategory.value = null
}

const viewAttemptReview = async (attemptId) => {
  if (!attemptId) return
  
  reviewData.value = null
  showReviewModal.value = true
  
  try {
    const response = await api.get(`/analytics/attempts/${attemptId}/review`)
    reviewData.value = response.data
  } catch (error) {
    console.error('Failed to load review:', error)
    showReviewModal.value = false
  }
}

const closeReviewModal = () => {
  showReviewModal.value = false
  reviewData.value = null
}

const showSendNotice = (type, title, message) => {
  sendNotice.value = { show: true, type, title, message }
  window.setTimeout(() => {
    sendNotice.value.show = false
  }, 6000)
}

const sendSelectedSummary = async () => {
  if (!selectedStudent.value || !selectedStudent.value.email) {
    showSendNotice('error', 'Email Required', 'Add an email address for this student before sending.')
    return
  }

  sendingStudentId.value = selectedStudent.value.student_id
  try {
    const response = await api.post(`/admin/users/${selectedStudent.value.student_id}/send-score-summary`)
    showSendNotice('success', 'Summary Sent', response.data?.message || `Sent to ${selectedStudent.value.email}.`)
  } catch (error) {
    showSendNotice('error', 'Send Failed', error.response?.data?.message || 'Failed to send score summary.')
  } finally {
    sendingStudentId.value = null
  }
}

const openBulkSendConfirm = () => {
  if (filteredStudentData.value.length === 0) return
  showBulkConfirm.value = true
}

const confirmBulkSend = async () => {
  sendingBulk.value = true
  try {
    const userIds = filteredStudentData.value.map(student => student.student_id)
    const response = await api.post('/admin/users/send-score-summary-bulk', {
      user_ids: userIds,
      search: searchStudent.value || null
    })
    const result = response.data?.data || {}
    const message = [
      `${result.sent || 0} sent`,
      `${result.skipped_no_email || 0} no email`,
      `${result.skipped_no_scores || 0} no scores`,
      `${result.failed || 0} failed`
    ].join(' | ')

    showBulkConfirm.value = false
    showSendNotice((result.failed || 0) > 0 ? 'error' : 'success', 'Bulk Send Complete', message)
  } catch (error) {
    showSendNotice('error', 'Bulk Send Failed', error.response?.data?.message || 'Failed to send score summaries.')
  } finally {
    sendingBulk.value = false
  }
}

const getScoreClassForReview = (percentage) => {
  if (percentage >= 90) return 'score-excellent'
  if (percentage >= 50) return 'score-good'
  return 'score-poor'
}

onMounted(() => {
  loadData()
})

// Auto-refresh setup using the simpler composable
const { isRegistered: autoRefreshActive, refreshNow } = useAdminAutoRefresh.scores(loadData)
</script>

<style scoped>
.view-scores {
  padding: 40px 48px;
  max-width: 1600px;
  margin: 0 auto;
  background: #F5F5F7;
  min-height: calc(100vh - 120px);
}

.scores-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 32px;
}

.page-title {
  font-size: 34px;
  font-weight: 700;
  color: #1D1D1F;
  margin: 0 0 8px 0;
  letter-spacing: -0.8px;
}

.page-subtitle {
  font-size: 17px;
  color: #86868B;
  margin: 0;
  font-weight: 500;
  letter-spacing: -0.2px;
}

.header-actions {
  display: flex;
  gap: 12px;
  align-items: center;
}

.btn-refresh {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 20px;
  background: #FFFFFF;
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 12px;
  color: #1D1D1F;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-refresh svg {
  width: 20px;
  height: 20px;
  stroke-width: 2;
  transition: transform 0.3s ease;
}

.btn-refresh svg.spinning {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.btn-refresh:hover {
  background: #F5F5F7;
  transform: translateY(-1px);
}

.btn-refresh:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.auto-refresh-status {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  background: #F5F5F7;
  border-radius: 10px;
  font-size: 13px;
}

.status-indicator {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #86868B;
  transition: all 0.2s;
}

.status-indicator.active {
  background: #34C759;
  box-shadow: 0 0 8px rgba(52, 199, 89, 0.4);
}

.status-text {
  font-weight: 500;
  color: #1D1D1F;
  letter-spacing: -0.1px;
}

.btn-toggle-auto {
  padding: 4px 8px;
  background: #FFFFFF;
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 6px;
  font-size: 12px;
  font-weight: 600;
  color: #007AFF;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-toggle-auto:hover {
  background: rgba(0, 122, 255, 0.08);
}

/* Filters */
.filters-section {
  display: grid;
  grid-template-columns: minmax(0, 1fr) auto;
  align-items: end;
  gap: 20px;
  margin-bottom: 32px;
  padding: 24px;
  background: #FFFFFF;
  border-radius: 16px;
  border: 1px solid rgba(0, 0, 0, 0.04);
}

.filter-group label {
  display: block;
  font-size: 13px;
  font-weight: 600;
  color: #86868B;
  margin-bottom: 8px;
  letter-spacing: -0.1px;
}

.filter-input {
  width: 100%;
  padding: 12px 16px;
  background: #F5F5F7;
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 10px;
  font-size: 15px;
  color: #1D1D1F;
  transition: all 0.2s;
}

.filter-input:focus {
  outline: none;
  border-color: #007AFF;
  background: #FFFFFF;
}

.filter-actions {
  display: flex;
  justify-content: flex-end;
}

.btn-send-bulk,
.btn-send-summary,
.btn-confirm-send,
.btn-cancel-send {
  border: none;
  border-radius: 10px;
  font-size: 14px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.btn-send-bulk {
  height: 46px;
  padding: 0 18px;
  background: #111827;
  color: #FFFFFF;
  white-space: nowrap;
}

.btn-send-bulk:hover:not(:disabled),
.btn-confirm-send:hover:not(:disabled),
.btn-send-summary:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 6px 16px rgba(17, 24, 39, 0.18);
}

.btn-send-bulk:disabled,
.btn-send-summary:disabled,
.btn-confirm-send:disabled,
.btn-cancel-send:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}

.btn-send-bulk svg,
.btn-send-summary svg {
  width: 18px;
  height: 18px;
  stroke-width: 2;
}

/* Loading */
.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80px 20px;
  gap: 20px;
}

.spinner-ring {
  width: 48px;
  height: 48px;
  border: 4px solid rgba(0, 0, 0, 0.1);
  border-top-color: #007AFF;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Students Grid */
.students-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(420px, 1fr));
  gap: 16px;
  margin-bottom: 32px;
}

.student-card {
  background: #FFFFFF;
  border-radius: 12px;
  border: 1px solid rgba(0, 0, 0, 0.08);
  padding: 16px 20px;
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  flex-direction: column;
  gap: 12px;
  min-height: 70px;
  user-select: none;
  position: relative;
  animation: fadeInUp 0.2s ease backwards;
}

.student-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  border-color: #1D1D1F;
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(8px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Row 1: Name and Username */
.card-row-1 {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.student-name-section {
  flex: 1;
  min-width: 0;
}

.student-card-name {
  font-size: 17px;
  font-weight: 600;
  color: #1D1D1F;
  margin-bottom: 2px;
  letter-spacing: -0.3px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  line-height: 1.3;
}

.student-card-username {
  font-size: 13px;
  color: #86868B;
  font-weight: 400;
  letter-spacing: -0.1px;
  line-height: 1.3;
}

/* Row 2: Stats and Arrow */
.card-row-2 {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-top: 8px;
  border-top: 1px solid rgba(0, 0, 0, 0.06);
}

.stat-compact {
  display: flex;
  align-items: baseline;
  gap: 6px;
}

.stat-value {
  font-size: 16px;
  font-weight: 600;
  color: #1D1D1F;
  letter-spacing: -0.2px;
  line-height: 1;
}

.stat-label {
  font-size: 12px;
  color: #86868B;
  font-weight: 400;
  letter-spacing: -0.1px;
  line-height: 1;
}

.card-arrow {
  margin-left: auto;
  width: 20px;
  height: 20px;
  flex-shrink: 0;
  transition: transform 0.2s ease;
}

.card-arrow svg {
  width: 100%;
  height: 100%;
  stroke-width: 2;
  color: #1D1D1F;
}

.student-card:hover .card-arrow {
  transform: translateX(4px);
}

/* Focus State for Accessibility */
.student-card:focus-visible {
  outline: 2px solid #1D1D1F;
  outline-offset: 2px;
}

/* Responsive Breakpoints */
@media (max-width: 1400px) {
  .students-grid {
    grid-template-columns: repeat(auto-fill, minmax(380px, 1fr));
    gap: 14px;
  }
}

@media (max-width: 1024px) {
  .view-scores {
    padding: 32px 24px;
  }
  
  .students-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 12px;
  }
}

@media (max-width: 768px) {
  .filters-section {
    grid-template-columns: 1fr;
  }

  .filter-actions,
  .btn-send-bulk {
    width: 100%;
  }

  .students-grid {
    grid-template-columns: 1fr;
    gap: 10px;
  }
  
  .student-card {
    padding: 14px 16px;
  }

  .details-header {
    flex-direction: column;
    gap: 14px;
  }

  .details-actions {
    width: 100%;
    justify-content: space-between;
  }
}
.empty-state {
  text-align: center;
  padding: 80px 20px;
}

.empty-state svg {
  width: 64px;
  height: 64px;
  color: #86868B;
  margin-bottom: 20px;
  stroke-width: 1.5;
}

.empty-state h3 {
  font-size: 22px;
  font-weight: 600;
  color: #1D1D1F;
  margin: 0 0 8px 0;
}

.empty-state p {
  font-size: 15px;
  color: #86868B;
  margin: 0;
}

/* Student Details Modal */
.details-modal {
  background: #FFFFFF;
  border-radius: 16px;
  max-width: 700px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.12);
}

.details-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 24px 24px 20px;
  background: #FFFFFF;
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
  position: sticky;
  top: 0;
  z-index: 10;
}

.details-header-content {
  display: flex;
  align-items: center;
  gap: 16px;
  min-width: 0;
}

.details-actions {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-shrink: 0;
}

.btn-send-summary {
  min-height: 36px;
  padding: 0 14px;
  background: #111827;
  color: #FFFFFF;
  white-space: nowrap;
}

.details-title {
  font-size: 22px;
  font-weight: 700;
  color: #1D1D1F;
  margin: 0 0 4px 0;
  letter-spacing: -0.4px;
}

.details-subtitle {
  font-size: 15px;
  color: #86868B;
  margin: 0;
  font-weight: 500;
  letter-spacing: -0.1px;
  overflow-wrap: anywhere;
}

.details-summary {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  padding: 20px 24px;
  background: #F5F5F7;
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
}

.summary-stat {
  text-align: center;
}

.summary-stat-label {
  font-size: 13px;
  color: #86868B;
  font-weight: 500;
  margin-bottom: 6px;
  letter-spacing: -0.1px;
}

.summary-stat-value {
  font-size: 24px;
  font-weight: 700;
  color: #1D1D1F;
  letter-spacing: -0.6px;
}

.categories-list {
  padding: 20px 24px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.category-card {
  background: #F5F5F7;
  border-radius: 12px;
  padding: 16px;
  border-left: 4px solid transparent;
  cursor: pointer;
  transition: all 0.2s;
}

.category-card:hover {
  background: #FFFFFF;
  border-left-color: #007AFF;
  transform: translateX(4px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.category-card:has(.status-passed) {
  border-left-color: #34C759;
}

.category-card:has(.status-failed) {
  border-left-color: #FF3B30;
}

.category-card:has(.status-not-taken) {
  border-left-color: #86868B;
}

.category-header {
  display: flex;
  align-items: center;
  gap: 12px;
}

.category-icon {
  font-size: 28px;
  flex-shrink: 0;
}

.category-icon-large {
  width: 56px;
  height: 56px;
  border-radius: 50%;
  background: linear-gradient(135deg, #007AFF 0%, #0051D5 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  flex-shrink: 0;
}

.category-info {
  flex: 1;
}

.category-name {
  font-size: 16px;
  font-weight: 600;
  color: #1D1D1F;
  margin-bottom: 4px;
  letter-spacing: -0.2px;
}

.category-status {
  font-size: 14px;
  font-weight: 500;
  letter-spacing: -0.1px;
}

.status-passed {
  color: #34C759;
}

.status-failed {
  color: #FF3B30;
}

.status-not-taken {
  color: #86868B;
}

.category-card-arrow {
  width: 24px;
  height: 24px;
  flex-shrink: 0;
  transition: transform 0.3s;
}

.category-card-arrow svg {
  width: 100%;
  height: 100%;
  stroke-width: 2;
  color: #86868B;
}

.attempts-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
  margin-top: 12px;
}

.attempt-item {
  background: #FFFFFF;
  border-radius: 8px;
  padding: 12px 14px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border: 1px solid rgba(0, 0, 0, 0.06);
  cursor: pointer;
  transition: all 0.2s;
}

.attempt-item:hover {
  border-color: #007AFF;
  transform: translateX(4px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.attempt-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.attempt-label {
  font-size: 14px;
  font-weight: 600;
  color: #1D1D1F;
  letter-spacing: -0.1px;
}

.attempt-score {
  font-size: 13px;
  color: #86868B;
  font-weight: 500;
}

.attempt-result {
  display: flex;
  align-items: center;
  gap: 10px;
}

.attempt-percentage {
  font-size: 16px;
  font-weight: 700;
  letter-spacing: -0.3px;
}

.attempt-badge {
  display: inline-block;
  padding: 4px 10px;
  border-radius: 6px;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.3px;
}

.attempt-badge.passed {
  background: rgba(52, 199, 89, 0.12);
  color: #34C759;
}

.attempt-badge.failed {
  background: rgba(255, 59, 48, 0.12);
  color: #FF3B30;
}

/* Empty State */
.modal-overlay-review {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.4);
  backdrop-filter: blur(8px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10000;
  padding: 20px;
  overflow-y: auto;
}

.review-modal {
  background: #FFFFFF;
  border-radius: 16px;
  max-width: 800px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.12);
}

.review-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80px 40px;
  gap: 20px;
}

.review-loading p {
  font-size: 15px;
  font-weight: 500;
  color: #86868B;
  letter-spacing: -0.2px;
}

.review-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 24px 24px 20px;
  background: #FFFFFF;
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
  position: sticky;
  top: 0;
  z-index: 10;
}

.review-title {
  font-size: 20px;
  font-weight: 700;
  color: #1D1D1F;
  margin: 0 0 4px 0;
  letter-spacing: -0.4px;
}

.review-subtitle {
  font-size: 14px;
  color: #86868B;
  margin: 0;
  font-weight: 400;
  letter-spacing: -0.1px;
}

.btn-close-review {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: #F5F5F7;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s;
  flex-shrink: 0;
}

.btn-close-review:hover {
  background: #E8E8ED;
}

.btn-close-review:active {
  transform: scale(0.95);
}

.btn-close-review svg {
  width: 18px;
  height: 18px;
  color: #1D1D1F;
  stroke-width: 2;
}

.review-score-summary {
  padding: 20px 24px;
  background: #F5F5F7;
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
}

.summary-item {
  display: flex;
  align-items: center;
  gap: 16px;
}

.summary-icon {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  font-weight: 700;
  color: white;
  letter-spacing: -0.5px;
  flex-shrink: 0;
}

.summary-icon.score-excellent {
  background: #34C759;
}

.summary-icon.score-good {
  background: #FF9500;
}

.summary-icon.score-poor {
  background: #FF3B30;
}

.summary-info {
  flex: 1;
}

.summary-label {
  font-size: 13px;
  color: #86868B;
  font-weight: 500;
  margin-bottom: 2px;
  letter-spacing: -0.1px;
}

.summary-value {
  font-size: 24px;
  font-weight: 700;
  color: #1D1D1F;
  letter-spacing: -0.6px;
}

.review-questions {
  padding: 20px 24px 24px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.review-question-card {
  background: #F5F5F7;
  border-radius: 12px;
  padding: 16px;
  border-left: 3px solid transparent;
  transition: all 0.2s;
}

.review-question-card.correct {
  border-left-color: #34C759;
}

.review-question-card.incorrect {
  border-left-color: #FF3B30;
}

.question-header-review {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 12px;
}

.question-number-badge {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.correct-badge {
  background: #34C759;
}

.incorrect-badge {
  background: #FF3B30;
}

.question-number-badge svg {
  width: 16px;
  height: 16px;
  color: white;
  stroke-width: 2.5;
}

.question-number {
  font-size: 14px;
  font-weight: 600;
  color: #1D1D1F;
  letter-spacing: -0.2px;
}

.question-text-review {
  font-size: 15px;
  color: #1D1D1F;
  font-weight: 500;
  line-height: 1.5;
  margin-bottom: 12px;
  letter-spacing: -0.2px;
}

.choices-review {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.choice-review {
  display: flex;
  gap: 10px;
  padding: 12px;
  border-radius: 8px;
  background: #FFFFFF;
  border: 1px solid rgba(0, 0, 0, 0.06);
  transition: all 0.2s;
}

.choice-review.correct-choice {
  background: rgba(52, 199, 89, 0.08);
  border-color: #34C759;
}

.choice-review.wrong-choice {
  background: rgba(255, 59, 48, 0.08);
  border-color: #FF3B30;
}

.choice-indicator {
  flex-shrink: 0;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.choice-indicator svg {
  width: 24px;
  height: 24px;
}

.correct-choice .choice-indicator svg {
  color: #34C759;
}

.wrong-choice .choice-indicator svg {
  color: #FF3B30;
}

.empty-circle {
  width: 18px;
  height: 18px;
  border-radius: 50%;
  border: 2px solid #D2D2D7;
}

.choice-content {
  flex: 1;
}

.choice-text-review {
  font-size: 14px;
  color: #1D1D1F;
  font-weight: 400;
  line-height: 1.4;
  letter-spacing: -0.1px;
}

.choice-label {
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.3px;
  margin-top: 4px;
}

.correct-label {
  color: #34C759;
}

.your-label {
  color: #FF3B30;
}

.send-confirm-modal {
  background: #FFFFFF;
  border-radius: 16px;
  width: min(460px, 100%);
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.16);
  overflow: hidden;
}

.send-confirm-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 18px;
  padding: 24px;
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
}

.send-confirm-header h3 {
  margin: 0 0 6px;
  font-size: 20px;
  color: #111827;
  letter-spacing: -0.3px;
}

.send-confirm-header p {
  margin: 0;
  font-size: 14px;
  color: #6B7280;
  line-height: 1.5;
}

.send-confirm-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  padding: 18px 24px 24px;
}

.btn-cancel-send {
  padding: 10px 16px;
  background: #F3F4F6;
  color: #111827;
}

.btn-confirm-send {
  padding: 10px 16px;
  background: #111827;
  color: #FFFFFF;
}

.send-notification {
  position: fixed;
  right: 24px;
  bottom: 24px;
  z-index: 11000;
  width: min(420px, calc(100vw - 32px));
  background: #FFFFFF;
  border-radius: 14px;
  padding: 16px 48px 16px 18px;
  box-shadow: 0 14px 40px rgba(0, 0, 0, 0.18);
  border-left: 4px solid #16A34A;
}

.send-notification.error {
  border-left-color: #DC2626;
}

.send-notification-title {
  font-size: 14px;
  font-weight: 800;
  color: #111827;
  margin-bottom: 4px;
}

.send-notification-message {
  font-size: 13px;
  color: #4B5563;
  line-height: 1.45;
}

.send-notification-close {
  position: absolute;
  top: 12px;
  right: 12px;
  width: 28px;
  height: 28px;
  border: none;
  border-radius: 50%;
  background: #F3F4F6;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
}

.send-notification-close svg {
  width: 15px;
  height: 15px;
}

.notification-slide-enter-active,
.notification-slide-leave-active {
  transition: all 0.25s ease;
}

.notification-slide-enter-from,
.notification-slide-leave-to {
  opacity: 0;
  transform: translateY(12px);
}

/* Modal Animations */
.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.3s ease;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}

.modal-scale-enter-active {
  transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.modal-scale-leave-active {
  transition: all 0.2s ease;
}

.modal-scale-enter-from {
  opacity: 0;
  transform: scale(0.9) translateY(20px);
}

.modal-scale-leave-to {
  opacity: 0;
  transform: scale(0.95) translateY(-10px);
}
</style>
