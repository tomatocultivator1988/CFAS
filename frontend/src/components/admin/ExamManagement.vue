<template>
  <div class="exam-management">
    <!-- Header Section -->
    <div class="management-header">
      <div class="header-content">
        <div class="header-text">
          <p class="header-subtitle">{{ filteredExams.length }} of {{ adminStore.exams.length }} Exams</p>
        </div>
        <button @click="showCreateModal = true" class="btn-create">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M12 4v16m8-8H4" stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5"/>
          </svg>
          <span>Create Exam</span>
        </button>
      </div>
    </div>

    <!-- Search and Filter Bar -->
    <div v-if="adminStore.exams.length > 0" class="search-filter-bar">
      <div class="search-box">
        <svg class="search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
        </svg>
        <input 
          v-model="searchQuery" 
          type="text" 
          placeholder="Search exams by title or description..." 
          class="search-input"
        />
        <button v-if="searchQuery" @click="searchQuery = ''" class="clear-search">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M6 18L18 6M6 6l12 12" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
          </svg>
        </button>
      </div>
      
      <div class="filter-group">
        <select v-model="statusFilter" class="filter-select">
          <option value="">All Status</option>
          <option value="active">Active</option>
          <option value="inactive">Inactive</option>
        </select>
      </div>
    </div>

    <!-- Category Tabs -->
    <div v-if="adminStore.exams.length > 0" class="category-tabs">
      <button 
        v-for="cat in categories" 
        :key="cat.value"
        @click="selectedCategory = cat.value"
        class="category-tab"
        :class="{ active: selectedCategory === cat.value }"
      >
        <span class="tab-icon">{{ cat.icon }}</span>
        <span class="tab-label">{{ cat.label }}</span>
        <span class="tab-count">{{ getCategoryCount(cat.value) }}</span>
      </button>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading-container">
      <div class="loading-spinner">
        <div class="spinner-ring"></div>
        <div class="spinner-ring"></div>
        <div class="spinner-ring"></div>
      </div>
      <p class="loading-text">Loading exams...</p>
    </div>
    
    <!-- Empty State -->
    <div v-else-if="adminStore.exams.length === 0" class="empty-state">
      <div class="empty-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
        </svg>
      </div>
      <h3>No Exams Yet</h3>
      <p>Create your first exam to get started with assessments.</p>
      <button @click="showCreateModal = true" class="btn-empty-action">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path d="M12 4v16m8-8H4" stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5"/>
        </svg>
        <span>Create First Exam</span>
      </button>
    </div>

    <!-- Exam Grid -->
    <div v-else class="exam-grid">
      <div 
        v-for="(exam, index) in filteredExams" 
        :key="exam.id" 
        class="exam-card"
        :style="{ animationDelay: `${index * 0.08}s` }"
      >
        <!-- Card Content -->
        <div class="card-content">
          <div class="card-header">
            <div class="exam-icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
              </svg>
            </div>
            <div class="exam-badge" :class="`badge-${exam.status || 'inactive'}`">
              <span class="badge-dot"></span>
              <span>{{ formatStatus(exam.status) }}</span>
            </div>
          </div>

          <h3 class="exam-title">{{ exam.title }}</h3>
          <p class="exam-description">{{ exam.description || 'No description provided' }}</p>
          
          <!-- Stats with Icons -->
          <div class="exam-stats">
            <div class="stat-item">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <circle cx="12" cy="12" r="10" stroke-width="2"/>
                <path d="M12 6v6l4 2" stroke-linecap="round" stroke-width="2"/>
              </svg>
              <span>{{ exam.time_limit_minutes }} min</span>
            </div>
            <div class="stat-item">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
              </svg>
              <span>{{ exam.questions_count || 0 }} questions</span>
            </div>
            <div class="stat-item">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
              </svg>
              <span>{{ exam.max_attempts || 3 }} attempts</span>
            </div>
          </div>
        </div>

        <!-- Actions with Labels -->
        <div class="card-actions">
          <button @click="manageQuestions(exam)" class="action-btn action-primary">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
            </svg>
            <span>Questions</span>
          </button>
          <button @click="editExam(exam)" class="action-btn">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
            </svg>
            <span>Edit</span>
          </button>
          <button @click="toggleStatusConfirm(exam)" class="action-btn" :class="{ 'action-success': exam.status === 'active' }">
            <svg v-if="exam.status === 'active'" viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M10 9v6m4-6v6m7-3a9 9 0 11-18 0 9 9 0 0118 0z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
            </svg>
            <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
              <path d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
            </svg>
            <span>{{ exam.status === 'active' ? 'Deactivate' : 'Activate' }}</span>
          </button>
          <button @click="deleteExamConfirm(exam)" class="action-btn action-danger">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
            </svg>
            <span>Delete</span>
          </button>
        </div>

        <!-- Shine Effect -->
        <div class="card-shine"></div>
      </div>
    </div>

    <!-- Create/Edit Modal -->
    <ExamForm
      v-if="showCreateModal || showEditModal"
      :exam="selectedExam"
      @close="closeModals"
      @save="handleSave"
    />

    <!-- Status Toggle Confirmation Modal -->
    <transition name="modal-fade">
      <div v-if="showStatusModal" class="modal-overlay">
        <transition name="modal-scale">
          <div v-if="showStatusModal" class="status-modal">
            <div class="modal-icon-wrapper" :class="examToToggle?.status === 'active' ? 'icon-warning' : 'icon-success'">
              <svg v-if="examToToggle?.status === 'active'" class="modal-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M10 9v6m4-6v6m7-3a9 9 0 11-18 0 9 9 0 0118 0z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
              </svg>
              <svg v-else class="modal-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                <path d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
              </svg>
            </div>
            
            <h3 class="modal-title">{{ examToToggle?.status === 'active' ? 'Deactivate Exam?' : 'Activate Exam?' }}</h3>
            <p class="modal-message">
              <template v-if="examToToggle?.status === 'active'">
                Are you sure you want to deactivate "<strong>{{ examToToggle?.title }}</strong>"? Reviewees will no longer be able to see or take this exam.
              </template>
              <template v-else>
                Are you sure you want to activate "<strong>{{ examToToggle?.title }}</strong>"? All reviewees will be able to see and take this exam.
              </template>
            </p>
            
            <div class="modal-actions">
              <button @click="cancelToggleStatus" class="modal-btn modal-btn-cancel" :disabled="togglingStatus">
                Cancel
              </button>
              <button @click="confirmToggleStatus" class="modal-btn" :class="examToToggle?.status === 'active' ? 'modal-btn-warning' : 'modal-btn-success'" :disabled="togglingStatus">
                <div v-if="togglingStatus" class="btn-spinner">
                  <div class="spinner-ring-small"></div>
                </div>
                <template v-else>
                  <svg v-if="examToToggle?.status === 'active'" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <path d="M10 9v6m4-6v6m7-3a9 9 0 11-18 0 9 9 0 0118 0z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                  </svg>
                  <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <path d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                    <path d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                  </svg>
                  <span>{{ examToToggle?.status === 'active' ? 'Deactivate' : 'Activate' }}</span>
                </template>
              </button>
            </div>
          </div>
        </transition>
      </div>
    </transition>

    <!-- Delete Confirmation Modal -->
    <transition name="modal-fade">
      <div v-if="showDeleteModal" class="modal-overlay">
        <transition name="modal-scale">
          <div v-if="showDeleteModal" class="delete-modal">
            <div class="modal-icon-wrapper">
              <svg class="modal-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
              </svg>
            </div>
            
            <h3 class="modal-title">Delete Exam?</h3>
            <p class="modal-message">
              Are you sure you want to delete "<strong>{{ examToDelete?.title }}</strong>"? This action cannot be undone.
            </p>
            
            <div class="modal-actions">
              <button @click="cancelDelete" class="modal-btn modal-btn-cancel" :disabled="deletingExam">
                Cancel
              </button>
              <button @click="confirmDelete" class="modal-btn modal-btn-delete" :disabled="deletingExam">
                <div v-if="deletingExam" class="btn-spinner">
                  <div class="spinner-ring-small"></div>
                </div>
                <template v-else>
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <path d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                  </svg>
                  <span>Delete</span>
                </template>
              </button>
            </div>
          </div>
        </transition>
      </div>
    </transition>

    <!-- Success Notification -->
    <transition name="notification-slide">
      <div v-if="showSuccessNotification" class="success-notification">
        <div class="notification-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
          </svg>
        </div>
        <div class="notification-content">
          <div class="notification-title">{{ successTitle }}</div>
          <div class="notification-message">{{ successMessage }}</div>
        </div>
        <button @click="hideSuccessNotification" class="notification-close">
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
import { useRouter } from 'vue-router'
import { useAdminStore } from '@/stores/admin'
import ExamForm from './ExamForm.vue'
import { useAdminAutoRefresh } from '@/composables/useComponentAutoRefresh'

const router = useRouter()
const adminStore = useAdminStore()
const loading = ref(false)
const searchQuery = ref('')
const statusFilter = ref('')
const selectedCategory = ref('all')
const showCreateModal = ref(false)
const showEditModal = ref(false)
const showDeleteModal = ref(false)
const showStatusModal = ref(false)
const deletingExam = ref(false)
const togglingStatus = ref(false)
const selectedExam = ref(null)
const examToDelete = ref(null)
const examToToggle = ref(null)
const showSuccessNotification = ref(false)
const successTitle = ref('')
const successMessage = ref('')
let notificationTimeout = null

// Categories with icons
const categories = [
  { value: 'all', label: 'All Exams', icon: '📚' },
  { value: 'Aquaculture', label: 'Aquaculture', icon: '🐟' },
  { value: 'Capture Fisheries', label: 'Capture Fisheries', icon: '🎣' },
  { value: 'Aquatic Resources and Ecology', label: 'Aquatic Resources', icon: '🌊' },
  { value: 'Post Harvest Fisheries', label: 'Post Harvest', icon: '📦' }
]

// Get count for each category
const getCategoryCount = (category) => {
  if (category === 'all') return adminStore.exams.length
  return adminStore.exams.filter(e => e.category === category).length
}

// Filtered exams based on search, status, and category
const filteredExams = computed(() => {
  let exams = adminStore.exams

  // Filter by category
  if (selectedCategory.value !== 'all') {
    exams = exams.filter(exam => exam.category === selectedCategory.value)
  }

  // Filter by search query
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    exams = exams.filter(exam => 
      exam.title.toLowerCase().includes(query) ||
      (exam.description && exam.description.toLowerCase().includes(query))
    )
  }

  // Filter by status
  if (statusFilter.value) {
    exams = exams.filter(exam => exam.status === statusFilter.value)
  }

  return exams
})

onMounted(async () => {
  loading.value = true
  await adminStore.loadExams()
  loading.value = false
})

// Auto-refresh setup
const { isRegistered: autoRefreshActive, refreshNow } = useAdminAutoRefresh.exams(() => adminStore.loadExams())

const manageQuestions = (exam) => {
  router.push(`/admin/exams/${exam.id}`)
}

const hideSuccessNotification = () => {
  showSuccessNotification.value = false
  if (notificationTimeout) {
    clearTimeout(notificationTimeout)
    notificationTimeout = null
  }
}

const showSuccess = (title, message) => {
  successTitle.value = title
  successMessage.value = message
  showSuccessNotification.value = true
  if (notificationTimeout) {
    clearTimeout(notificationTimeout)
  }
  notificationTimeout = setTimeout(() => {
    showSuccessNotification.value = false
    notificationTimeout = null
  }, 4000)
}

const editExam = (exam) => {
  selectedExam.value = { ...exam }
  showEditModal.value = true
}

const toggleStatusConfirm = (exam) => {
  examToToggle.value = exam
  showStatusModal.value = true
}

const cancelToggleStatus = () => {
  showStatusModal.value = false
  setTimeout(() => {
    examToToggle.value = null
  }, 300)
}

const confirmToggleStatus = async () => {
  if (!examToToggle.value) return
  
  togglingStatus.value = true
  
  try {
    const result = await adminStore.toggleExamStatus(examToToggle.value.id)
    
    if (result.success) {
      // Update local exam status
      const index = adminStore.exams.findIndex(e => e.id === examToToggle.value.id)
      if (index !== -1) {
        adminStore.exams[index].status = result.data.exam.status
      }
      
      const newStatus = result.data.exam.status
      const statusText = newStatus.charAt(0).toUpperCase() + newStatus.slice(1)
      showStatusModal.value = false
      
      // Trigger auto-refresh immediately
      await refreshNow()
      
      // Show success notification after modal closes
      setTimeout(() => {
        examToToggle.value = null
        showSuccess('Exam Updated', `Exam status changed to ${statusText}`)
      }, 300)
    } else {
      alert(result.error || 'Failed to toggle exam status')
    }
  } finally {
    togglingStatus.value = false
  }
}

const deleteExamConfirm = (exam) => {
  examToDelete.value = exam
  showDeleteModal.value = true
}

const cancelDelete = () => {
  showDeleteModal.value = false
  setTimeout(() => {
    examToDelete.value = null
  }, 300)
}

const confirmDelete = async () => {
  if (!examToDelete.value) return
  
  deletingExam.value = true
  
  try {
    const result = await adminStore.deleteExam(examToDelete.value.id)
    
    if (result.success) {
      const deletedTitle = examToDelete.value.title
      showDeleteModal.value = false
      
      // Trigger auto-refresh immediately
      await refreshNow()
      
      // Show success notification after modal closes
      setTimeout(() => {
        examToDelete.value = null
        showSuccess('Exam Deleted', `"${deletedTitle}" has been deleted successfully`)
      }, 300)
    } else {
      alert(result.error)
    }
  } finally {
    deletingExam.value = false
  }
}

const closeModals = () => {
  showCreateModal.value = false
  showEditModal.value = false
  selectedExam.value = null
}

const handleSave = async () => {
  const action = selectedExam.value ? 'updated' : 'created'
  const examTitle = selectedExam.value?.title
  closeModals()
  await adminStore.loadExams()
  
  // Trigger auto-refresh immediately
  await refreshNow()

  if (action === 'updated') {
    showSuccess('Exam Updated', examTitle ? `"${examTitle}" has been updated successfully` : 'Exam has been updated successfully')
  } else {
    showSuccess('Exam Created', 'New exam has been created successfully')
  }
}

const formatStatus = (status) => {
  if (!status) return 'Inactive'
  return status.charAt(0).toUpperCase() + status.slice(1)
}
</script>

<style scoped>
/* iOS-Style Exam Management */
.exam-management {
  padding: 40px 48px;
  max-width: 1440px;
  margin: 0 auto;
  background: #F5F5F7;
  min-height: calc(100vh - 120px);
}

/* Header */
.management-header {
  margin-bottom: 32px;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-subtitle {
  font-size: 15px;
  color: #86868B;
  margin: 0;
  font-weight: 500;
  letter-spacing: -0.2px;
}

.btn-create {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 24px;
  background: #007AFF;
  color: white;
  border: none;
  border-radius: 12px;
  font-size: 15px;
  font-weight: 600;
  letter-spacing: -0.2px;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 4px 12px rgba(0, 122, 255, 0.3);
}

.btn-create svg {
  width: 20px;
  height: 20px;
  stroke-width: 2.5;
}

.btn-create:hover {
  background: #0051D5;
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(0, 122, 255, 0.4);
}

.btn-create:active {
  transform: translateY(0) scale(0.96);
}

/* Search and Filter Bar */
.search-filter-bar {
  display: flex;
  gap: 16px;
  margin-bottom: 24px;
  align-items: center;
}

.search-box {
  flex: 1;
  position: relative;
  display: flex;
  align-items: center;
}

.search-icon {
  position: absolute;
  left: 16px;
  width: 20px;
  height: 20px;
  color: #86868B;
  stroke-width: 2;
  pointer-events: none;
}

.search-input {
  width: 100%;
  padding: 14px 48px 14px 48px;
  background: #FFFFFF;
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 12px;
  font-size: 15px;
  color: #1D1D1F;
  letter-spacing: -0.2px;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

.search-input::placeholder {
  color: #86868B;
}

.search-input:focus {
  outline: none;
  border-color: #007AFF;
  background: #FFFFFF;
  box-shadow: 0 0 0 4px rgba(0, 122, 255, 0.1);
}

.clear-search {
  position: absolute;
  right: 12px;
  width: 28px;
  height: 28px;
  background: rgba(134, 134, 139, 0.1);
  border: none;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s;
}

.clear-search svg {
  width: 14px;
  height: 14px;
  color: #86868B;
  stroke-width: 2;
}

.clear-search:hover {
  background: rgba(134, 134, 139, 0.2);
}

.clear-search:active {
  transform: scale(0.9);
}

.filter-group {
  min-width: 180px;
}

.filter-select {
  width: 100%;
  padding: 14px 16px;
  background: #FFFFFF;
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 12px;
  font-size: 15px;
  color: #1D1D1F;
  font-weight: 500;
  letter-spacing: -0.2px;
  cursor: pointer;
  transition: all 0.2s;
}

.filter-select:focus {
  outline: none;
  border-color: #007AFF;
  box-shadow: 0 0 0 4px rgba(0, 122, 255, 0.1);
}

.filter-select:hover {
  border-color: rgba(0, 0, 0, 0.1);
}

/* Category Tabs */
.category-tabs {
  display: flex;
  gap: 12px;
  margin-bottom: 24px;
  overflow-x: auto;
  padding-bottom: 4px;
}

.category-tabs::-webkit-scrollbar {
  height: 4px;
}

.category-tabs::-webkit-scrollbar-track {
  background: transparent;
}

.category-tabs::-webkit-scrollbar-thumb {
  background: rgba(0, 0, 0, 0.1);
  border-radius: 2px;
}

.category-tab {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 20px;
  background: #FFFFFF;
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 12px;
  font-size: 15px;
  font-weight: 600;
  color: #86868B;
  letter-spacing: -0.2px;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  white-space: nowrap;
}

.category-tab:hover {
  background: #F5F5F7;
  border-color: rgba(0, 0, 0, 0.1);
  transform: translateY(-1px);
}

.category-tab.active {
  background: #007AFF;
  color: white;
  border-color: #007AFF;
  box-shadow: 0 4px 12px rgba(0, 122, 255, 0.3);
}

.category-tab.active:hover {
  background: #0051D5;
  border-color: #0051D5;
}

.tab-icon {
  font-size: 18px;
  line-height: 1;
}

.tab-label {
  font-size: 15px;
}

.tab-count {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 24px;
  height: 24px;
  padding: 0 8px;
  background: rgba(0, 0, 0, 0.06);
  border-radius: 12px;
  font-size: 13px;
  font-weight: 600;
}

.category-tab.active .tab-count {
  background: rgba(255, 255, 255, 0.2);
  color: white;
}

/* Loading State */
.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80px 32px;
}

.loading-spinner {
  position: relative;
  width: 64px;
  height: 64px;
  margin-bottom: 20px;
}

.spinner-ring {
  position: absolute;
  width: 100%;
  height: 100%;
  border: 3px solid transparent;
  border-top-color: #1D1D1F;
  border-radius: 50%;
  animation: spin 1s cubic-bezier(0.68, -0.55, 0.265, 1.55) infinite;
}

.spinner-ring:nth-child(2) {
  border-top-color: #86868B;
  animation-delay: -0.33s;
  width: 85%;
  height: 85%;
  top: 7.5%;
  left: 7.5%;
}

.spinner-ring:nth-child(3) {
  border-top-color: #D2D2D7;
  animation-delay: -0.66s;
  width: 70%;
  height: 70%;
  top: 15%;
  left: 15%;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.loading-text {
  font-size: 17px;
  font-weight: 600;
  color: #1D1D1F;
  letter-spacing: -0.4px;
}

/* Empty State */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80px 32px;
  text-align: center;
}

.empty-icon {
  width: 80px;
  height: 80px;
  background: linear-gradient(135deg, #F5F5F7 0%, #E8E8ED 100%);
  border-radius: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 24px;
}

.empty-icon svg {
  width: 40px;
  height: 40px;
  color: #1D1D1F;
  stroke-width: 2;
}

.empty-state h3 {
  font-size: 24px;
  font-weight: 700;
  color: #1D1D1F;
  margin: 0 0 8px 0;
  letter-spacing: -0.5px;
}

.empty-state p {
  font-size: 15px;
  color: #86868B;
  margin: 0 0 24px 0;
  letter-spacing: -0.2px;
}

.btn-empty-action {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 24px;
  background: #007AFF;
  color: white;
  border: none;
  border-radius: 12px;
  font-size: 15px;
  font-weight: 600;
  letter-spacing: -0.2px;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 4px 12px rgba(0, 122, 255, 0.3);
}

.btn-empty-action svg {
  width: 20px;
  height: 20px;
  stroke-width: 2.5;
}

.btn-empty-action:hover {
  background: #0051D5;
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(0, 122, 255, 0.4);
}

/* Exam Grid */
.exam-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  gap: 16px;
}

.exam-card {
  position: relative;
  background: #FFFFFF;
  border-radius: 16px;
  border: 1px solid rgba(0, 0, 0, 0.04);
  overflow: hidden;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  animation: fadeInUp 0.6s cubic-bezier(0.34, 1.56, 0.64, 1) backwards;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.exam-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 32px rgba(0, 0, 0, 0.1);
  border-color: rgba(0, 0, 0, 0.08);
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(24px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Card Content */
.card-content {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.exam-icon {
  width: 44px;
  height: 44px;
  background: linear-gradient(135deg, #F5F5F7 0%, #E8E8ED 100%);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.exam-card:hover .exam-icon {
  transform: scale(1.08) rotate(5deg);
}

.exam-icon svg {
  width: 22px;
  height: 22px;
  color: #1D1D1F;
  stroke-width: 2;
}

.exam-badge {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 4px 10px;
  border-radius: 8px;
  font-size: 11px;
  font-weight: 600;
  letter-spacing: -0.1px;
}

.badge-active {
  background: rgba(52, 199, 89, 0.1);
  color: #34C759;
}

.badge-active .badge-dot {
  background: #34C759;
  animation: pulse 2s ease-in-out infinite;
}

.badge-inactive {
  background: rgba(134, 134, 139, 0.1);
  color: #86868B;
}

.badge-inactive .badge-dot {
  background: #86868B;
}

.badge-archived {
  background: rgba(255, 149, 0, 0.1);
  color: #FF9500;
}

.badge-archived .badge-dot {
  background: #FF9500;
}

.badge-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
}

@keyframes pulse {
  0%, 100% {
    opacity: 0.3;
    transform: scale(1);
  }
  50% {
    opacity: 0.5;
    transform: scale(1.4);
  }
}

.exam-title {
  font-size: 17px;
  font-weight: 600;
  color: #1D1D1F;
  margin: 0 0 8px 0;
  letter-spacing: -0.3px;
  line-height: 1.3;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.exam-description {
  font-size: 13px;
  color: #86868B;
  margin: 0 0 12px 0;
  line-height: 1.4;
  letter-spacing: -0.1px;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

/* Stats with Icons */
.exam-stats {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: #86868B;
  font-weight: 500;
  letter-spacing: -0.1px;
}

.stat-item svg {
  width: 16px;
  height: 16px;
  color: #86868B;
  stroke-width: 2;
  flex-shrink: 0;
}

/* Card Actions */
.card-actions {
  padding: 12px;
  border-top: 1px solid rgba(0, 0, 0, 0.06);
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 8px;
  background: #FAFAFA;
}

.action-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  padding: 10px 12px;
  background: #FFFFFF;
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 10px;
  font-size: 13px;
  font-weight: 600;
  color: #1D1D1F;
  letter-spacing: -0.1px;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

.action-btn svg {
  width: 16px;
  height: 16px;
  stroke-width: 2;
}

.action-btn:hover {
  background: #F5F5F7;
  border-color: rgba(0, 0, 0, 0.1);
  transform: translateY(-1px);
}

.action-btn:active {
  transform: scale(0.96);
}

.action-primary {
  background: rgba(0, 122, 255, 0.1);
  color: #007AFF;
  border-color: rgba(0, 122, 255, 0.2);
}

.action-primary:hover {
  background: rgba(0, 122, 255, 0.15);
  border-color: rgba(0, 122, 255, 0.3);
}

.action-danger {
  background: rgba(255, 59, 48, 0.1);
  color: #FF3B30;
  border-color: rgba(255, 59, 48, 0.2);
}

.action-danger:hover {
  background: rgba(255, 59, 48, 0.15);
  border-color: rgba(255, 59, 48, 0.3);
}

.action-success {
  background: rgba(52, 199, 89, 0.1);
  color: #34C759;
  border-color: rgba(52, 199, 89, 0.2);
}

.action-success:hover {
  background: rgba(52, 199, 89, 0.15);
  border-color: rgba(52, 199, 89, 0.3);
}

/* Shine Effect */
.card-shine {
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.6), transparent);
  transition: left 0.5s ease;
  pointer-events: none;
}

.exam-card:hover .card-shine {
  left: 100%;
}

/* Responsive */
@media (max-width: 1024px) {
  .exam-management {
    padding: 32px 24px;
  }
  
  .exam-grid {
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  }
}

@media (max-width: 768px) {
  .exam-management {
    padding: 24px 20px;
  }
  
  .exam-grid {
    grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  }
  
  .header-content {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }
}

/* iOS-Style Status Toggle Modal */
.status-modal {
  background: #FFFFFF;
  border-radius: 20px;
  padding: 32px;
  max-width: 400px;
  width: 100%;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  text-align: center;
}

.icon-warning {
  background: linear-gradient(135deg, rgba(255, 149, 0, 0.1) 0%, rgba(255, 149, 0, 0.15) 100%);
}

.icon-warning .modal-icon {
  color: #FF9500;
}

.icon-success {
  background: linear-gradient(135deg, rgba(52, 199, 89, 0.1) 0%, rgba(52, 199, 89, 0.15) 100%);
}

.icon-success .modal-icon {
  color: #34C759;
}

.modal-btn-warning {
  background: #FF9500;
  color: white;
  box-shadow: 0 4px 12px rgba(255, 149, 0, 0.3);
}

.modal-btn-warning:hover {
  background: #E68600;
  transform: translateY(-1px);
  box-shadow: 0 6px 16px rgba(255, 149, 0, 0.4);
}

.modal-btn-warning:active {
  transform: scale(0.96);
}

.modal-btn-success {
  background: #34C759;
  color: white;
  box-shadow: 0 4px 12px rgba(52, 199, 89, 0.3);
}

.modal-btn-success:hover {
  background: #2DB04A;
  transform: translateY(-1px);
  box-shadow: 0 6px 16px rgba(52, 199, 89, 0.4);
}

.modal-btn-success:active {
  transform: scale(0.96);
}

/* iOS-Style Delete Modal */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.4);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10000;
  padding: 20px;
}

.delete-modal {
  background: #FFFFFF;
  border-radius: 20px;
  padding: 32px;
  max-width: 400px;
  width: 100%;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  text-align: center;
}

.modal-icon-wrapper {
  width: 64px;
  height: 64px;
  background: linear-gradient(135deg, rgba(255, 59, 48, 0.1) 0%, rgba(255, 59, 48, 0.15) 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 20px;
}

.modal-icon {
  width: 32px;
  height: 32px;
  color: #FF3B30;
  stroke-width: 2;
}

.modal-title {
  font-size: 22px;
  font-weight: 700;
  color: #1D1D1F;
  margin: 0 0 12px 0;
  letter-spacing: -0.5px;
}

.modal-message {
  font-size: 15px;
  color: #86868B;
  line-height: 1.5;
  margin: 0 0 28px 0;
  letter-spacing: -0.2px;
}

.modal-message strong {
  color: #1D1D1F;
  font-weight: 600;
}

.modal-actions {
  display: flex;
  gap: 12px;
}

.modal-btn {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 14px 20px;
  border: none;
  border-radius: 12px;
  font-size: 15px;
  font-weight: 600;
  letter-spacing: -0.2px;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

.modal-btn svg {
  width: 18px;
  height: 18px;
  stroke-width: 2;
}

.modal-btn-cancel {
  background: #F5F5F7;
  color: #1D1D1F;
}

.modal-btn-cancel:hover {
  background: #E8E8ED;
  transform: translateY(-1px);
}

.modal-btn-cancel:active {
  transform: scale(0.96);
}

.modal-btn-delete {
  background: #FF3B30;
  color: white;
  box-shadow: 0 4px 12px rgba(255, 59, 48, 0.3);
}

.modal-btn-delete:hover {
  background: #D70015;
  transform: translateY(-1px);
  box-shadow: 0 6px 16px rgba(255, 59, 48, 0.4);
}

.modal-btn-delete:active {
  transform: scale(0.96);
}

/* Modal Animations */
.modal-fade-enter-active {
  transition: opacity 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.modal-fade-leave-active {
  transition: opacity 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}

.modal-scale-enter-active {
  transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.modal-scale-leave-active {
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

.modal-scale-enter-from {
  opacity: 0;
  transform: scale(0.9) translateY(20px);
}

.modal-scale-leave-to {
  opacity: 0;
  transform: scale(0.95) translateY(-10px);
}

@media (max-width: 480px) {
  .delete-modal {
    padding: 28px 24px;
  }
  
  .modal-actions {
    flex-direction: column;
  }
  
  .modal-btn {
    width: 100%;
  }
}

/* Button Loading Spinner - Simple iOS Dashed Circle */
.btn-spinner {
  display: flex;
  align-items: center;
  justify-content: center;
}

.spinner-ring-small {
  width: 18px;
  height: 18px;
  border: 2px dashed rgba(255, 255, 255, 0.8);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.modal-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.modal-btn:disabled:hover {
  transform: none;
}

/* Success Notification */
.success-notification {
  position: fixed;
  top: 24px;
  right: 24px;
  background: #FFFFFF;
  border-radius: 16px;
  padding: 16px 20px;
  display: flex;
  align-items: center;
  gap: 14px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.12);
  border: 1px solid rgba(0, 0, 0, 0.06);
  max-width: 420px;
  z-index: 10001;
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
}

.notification-icon {
  width: 40px;
  height: 40px;
  background: linear-gradient(135deg, rgba(52, 199, 89, 0.1) 0%, rgba(52, 199, 89, 0.15) 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.notification-icon svg {
  width: 22px;
  height: 22px;
  color: #34C759;
  stroke-width: 2.5;
}

.notification-content {
  flex: 1;
  min-width: 0;
}

.notification-title {
  font-size: 15px;
  font-weight: 600;
  color: #1D1D1F;
  margin-bottom: 2px;
  letter-spacing: -0.2px;
}

.notification-message {
  font-size: 13px;
  color: #86868B;
  line-height: 1.4;
  letter-spacing: -0.1px;
}

.notification-close {
  width: 28px;
  height: 28px;
  background: transparent;
  border: none;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  flex-shrink: 0;
  color: #86868B;
}

.notification-close svg {
  width: 16px;
  height: 16px;
  stroke-width: 2;
}

.notification-close:hover {
  background: #F5F5F7;
  color: #1D1D1F;
}

.notification-close:active {
  transform: scale(0.9);
}

/* Notification Animation */
.notification-slide-enter-active {
  transition: all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.notification-slide-leave-active {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.notification-slide-enter-from {
  opacity: 0;
  transform: translateX(100%) translateY(-20px);
}

.notification-slide-leave-to {
  opacity: 0;
  transform: translateX(100%);
}

@media (max-width: 768px) {
  .success-notification {
    top: 16px;
    right: 16px;
    left: 16px;
    max-width: none;
  }
  
  .notification-slide-enter-from {
    transform: translateY(-100%);
  }
  
  .notification-slide-leave-to {
    transform: translateY(-100%);
  }
}
</style>
