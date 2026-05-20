<template>
  <div class="user-management">
    <!-- Header Section -->
    <div class="management-header">
      <div class="header-content">
        <p class="header-subtitle">
          {{ filteredUsers.length }} {{ filterStatus === 'active' ? 'Active' : filterStatus === 'inactive' ? 'Inactive' : 'Total' }} Users
        </p>
      </div>
      <button @click="showCreateModal = true" class="btn-create">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path d="M12 4v16m8-8H4" stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5"/>
        </svg>
        <span>Create User</span>
      </button>
    </div>

    <!-- Filters Section -->
    <div class="filters-section">
      <div class="search-wrapper">
        <svg class="search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
        </svg>
        <input 
          v-model="searchQuery" 
          type="text" 
          placeholder="Search users..." 
          class="search-input"
        />
      </div>
      <select v-model="filterRole" class="filter-select">
        <option value="">All Roles</option>
        <option value="admin">Admin</option>
        <option value="reviewee">Reviewee</option>
      </select>
      <select v-model="filterStatus" class="filter-select">
        <option value="active">Active Only</option>
        <option value="inactive">Inactive Only</option>
        <option value="">All Users</option>
      </select>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading-container">
      <div class="loading-spinner">
        <div class="spinner-ring"></div>
        <div class="spinner-ring"></div>
        <div class="spinner-ring"></div>
      </div>
      <p class="loading-text">Loading users...</p>
    </div>
    
    <!-- Empty State -->
    <div v-else-if="filteredUsers.length === 0" class="empty-state">
      <div class="empty-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
        </svg>
      </div>
      <h3>{{ searchQuery || filterRole ? 'No Users Found' : 'No Users Yet' }}</h3>
      <p>{{ searchQuery || filterRole ? 'Try adjusting your search or filters.' : 'Create your first user to get started.' }}</p>
      <button v-if="!searchQuery && !filterRole" @click="showCreateModal = true" class="btn-empty-action">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path d="M12 4v16m8-8H4" stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5"/>
        </svg>
        <span>Create First User</span>
      </button>
    </div>

    <!-- User Grid - Optimized for Fast Loading -->
    <TransitionGroup v-else name="list" tag="div" class="user-grid">
      <div 
        v-for="(user, index) in filteredUsers" 
        :key="user.id" 
        class="user-card"
        :class="{ 'fast-load': index < 20 }"
        :style="{ animationDelay: `${Math.min(index * 0.03, 0.6)}s` }"
      >
        <!-- Row 1: Name and Username -->
        <div class="card-row-1">
          <div class="user-name-section">
            <h3 class="user-card-name">{{ getUserFullName(user) }}</h3>
            <p class="user-card-username">@{{ user.username }}</p>
          </div>
        </div>

        <!-- Row 2: Badges and Actions -->
        <div class="card-row-2">
          <div class="status-badges">
            <span :class="['role-badge', user.role]">
              {{ user.role === 'admin' ? 'Admin' : 'Reviewee' }}
            </span>
            <span v-if="user.is_active !== false" class="status-badge active">
              Active
            </span>
            <span v-else class="status-badge inactive">Inactive</span>
          </div>
          
          <div class="card-actions">
            <button @click="editUser(user)" class="action-btn action-primary" title="Edit">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
              </svg>
            </button>
            <button @click="resetPasswordConfirm(user)" class="action-btn" title="Reset Password">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
              </svg>
            </button>
            <button 
              v-if="user.is_active !== false"
              @click="deactivateUserConfirm(user)" 
              class="action-btn action-danger"
              title="Deactivate"
            >
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
              </svg>
            </button>
            <button 
              v-if="user.is_active === false"
              @click="deletePermanentlyConfirm(user)" 
              class="action-btn action-danger-permanent"
              title="Delete Permanently"
            >
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
              </svg>
            </button>
          </div>
        </div>
      </div>
    </TransitionGroup>

    <!-- Create/Edit Modal -->
    <Transition name="modal">
      <UserForm
        v-if="showCreateModal || showEditModal"
        :user="selectedUser"
        @close="closeModals"
        @save="handleSave"
      />
    </Transition>

    <!-- Reset Password Confirmation Modal -->
    <transition name="modal-fade">
      <div v-if="showResetConfirmModal" class="modal-overlay">
        <transition name="modal-scale">
          <div v-if="showResetConfirmModal" class="confirm-modal modern-modal">
            <!-- Animated icon -->
            <div class="modal-icon-wrapper warning-modern">
              <div class="icon-glow-effect"></div>
              <div class="rotating-ring"></div>
              <svg class="modal-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
              </svg>
            </div>
            
            <h3 class="modal-title-modern">🔄 Reset Password</h3>
            <p class="modal-message-modern">
              Reset password to <span class="highlight-text">password123</span> for<br>
              <strong class="user-highlight">{{ userToReset?.username }}</strong>?
            </p>
            
            <div class="info-box">
              <span class="info-icon">ℹ️</span>
              <span class="info-text">User will be required to change password on next login</span>
            </div>
            
            <div class="modal-actions-modern">
              <button @click="cancelReset" class="modal-btn-modern modal-btn-cancel-modern" :disabled="resettingPassword">
                <span>Cancel</span>
              </button>
              <button @click="confirmReset" class="modal-btn-modern modal-btn-warning-modern" :disabled="resettingPassword">
                <div v-if="resettingPassword" class="btn-spinner-modern">
                  <div class="spinner-ring-small"></div>
                </div>
                <template v-else>
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <path d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                  </svg>
                  <span>Reset Password</span>
                </template>
              </button>
            </div>
          </div>
        </transition>
      </div>
    </transition>

    <!-- Deactivate User Confirmation Modal -->
    <transition name="modal-fade">
      <div v-if="showDeactivateModal" class="modal-overlay">
        <transition name="modal-scale">
          <div v-if="showDeactivateModal" class="confirm-modal">
            <div class="modal-icon-wrapper danger">
              <svg class="modal-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
              </svg>
            </div>
            
            <h3 class="modal-title">Deactivate User?</h3>
            <p class="modal-message">
              Are you sure you want to deactivate "<strong>{{ userToDeactivate?.username }}</strong>"? They will no longer be able to access the system.
            </p>
            
            <div class="modal-actions">
              <button @click="cancelDeactivate" class="modal-btn modal-btn-cancel" :disabled="deactivatingUser">
                Cancel
              </button>
              <button @click="confirmDeactivate" class="modal-btn modal-btn-danger" :disabled="deactivatingUser">
                <div v-if="deactivatingUser" class="btn-spinner">
                  <div class="spinner-ring-small"></div>
                </div>
                <template v-else>
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <path d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                  </svg>
                  <span>Deactivate</span>
                </template>
              </button>
            </div>
          </div>
        </transition>
      </div>
    </transition>

    <!-- Delete Permanently Confirmation Modal -->
    <transition name="modal-fade">
      <div v-if="showDeletePermanentlyModal" class="modal-overlay">
        <transition name="modal-scale">
          <div v-if="showDeletePermanentlyModal" class="confirm-modal">
            <div class="modal-icon-wrapper danger-permanent">
              <svg class="modal-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
              </svg>
            </div>
            
            <h3 class="modal-title">Delete Permanently?</h3>
            <p class="modal-message">
              Are you sure you want to <strong>permanently delete</strong> "<strong>{{ userToDeletePermanently?.username }}</strong>"?
            </p>
            <p class="modal-warning">
              ⚠️ This action cannot be undone! All exam attempts, answers, and related data will be permanently deleted.
            </p>
            
            <div class="modal-actions">
              <button @click="cancelDeletePermanently" class="modal-btn modal-btn-cancel" :disabled="deletingPermanently">
                Cancel
              </button>
              <button @click="confirmDeletePermanently" class="modal-btn modal-btn-danger-permanent" :disabled="deletingPermanently">
                <div v-if="deletingPermanently" class="btn-spinner">
                  <div class="spinner-ring-small"></div>
                </div>
                <template v-else>
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                    <path d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                  </svg>
                  <span>Delete Permanently</span>
                </template>
              </button>
            </div>
          </div>
        </transition>
      </div>
    </transition>

    <!-- Password Reset Success Modal -->
    <Transition name="modal-fade">
      <div v-if="showSuccessModal" class="modal-overlay">
        <Transition name="modal-scale">
          <div v-if="showSuccessModal" class="success-modal">
            <div class="success-icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
              </svg>
            </div>
            
            <h3 class="success-title">Password Reset Successfully</h3>
            <p class="success-message">
              Password reset to default for <strong>{{ resetUserName }}</strong>
            </p>
            
            <p class="success-note">User must change password on next login.</p>
            
            <button @click="showSuccessModal = false" class="success-btn">
              OK
            </button>
          </div>
        </Transition>
      </div>
    </Transition>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAdminStore } from '@/stores/admin'
import UserForm from '@/components/admin/UserForm.vue'
import { useAdminAutoRefresh } from '@/composables/useComponentAutoRefresh'

const adminStore = useAdminStore()
const loading = ref(false)
const showCreateModal = ref(false)
const showEditModal = ref(false)
const showResetConfirmModal = ref(false)
const showDeactivateModal = ref(false)
const showDeletePermanentlyModal = ref(false)
const showSuccessModal = ref(false)
const selectedUser = ref(null)
const userToReset = ref(null)
const userToDeactivate = ref(null)
const userToDeletePermanently = ref(null)
const resetUserName = ref('')
const searchQuery = ref('')
const filterRole = ref('')
const filterStatus = ref('active') // Default to showing only active users
const resettingPassword = ref(false)
const deactivatingUser = ref(false)
const deletingPermanently = ref(false)

onMounted(async () => {
  loading.value = true
  userFullNameCache.clear() // Clear cache on fresh load
  await adminStore.loadUsers()
  loading.value = false
})

// Fast refresh function for after operations
const fastRefresh = async () => {
  try {
    // Clear name cache for fresh data
    userFullNameCache.clear()
    await adminStore.loadUsers()
  } finally {
    // Cards will re-render with faster animations
  }
}

// Auto-refresh setup
const { isRegistered: autoRefreshActive } = useAdminAutoRefresh.users(() => adminStore.loadUsers())

// Optimized filtering with memoization and alphabetical sorting
const filteredUsers = computed(() => {
  const users = adminStore.users
  if (!users.length) return []

  // Pre-filter by status first (most selective)
  let filtered = users
  if (filterStatus.value === 'active') {
    filtered = users.filter(u => u.is_active !== false)
  } else if (filterStatus.value === 'inactive') {
    filtered = users.filter(u => u.is_active === false)
  }

  // Then filter by role if needed
  if (filterRole.value) {
    filtered = filtered.filter(u => u.role === filterRole.value)
  }

  // Finally apply search filter
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(u => {
      const fullName = getUserFullName(u).toLowerCase()
      return (
        u.username?.toLowerCase().includes(query) ||
        u.first_name?.toLowerCase().includes(query) ||
        u.last_name?.toLowerCase().includes(query) ||
        fullName.includes(query)
      )
    })
  }

  // Sort alphabetically by last name
  return filtered.sort((a, b) => {
    const lastNameA = (a.last_name || '').toLowerCase()
    const lastNameB = (b.last_name || '').toLowerCase()
    
    // If last names are the same, sort by first name
    if (lastNameA === lastNameB) {
      const firstNameA = (a.first_name || '').toLowerCase()
      const firstNameB = (b.first_name || '').toLowerCase()
      return firstNameA.localeCompare(firstNameB)
    }
    
    return lastNameA.localeCompare(lastNameB)
  })
})

// Memoized user full name function for better performance
const userFullNameCache = new Map()
const getUserFullName = (user) => {
  if (!user) return ''
  
  const cacheKey = `${user.id}-${user.first_name}-${user.middle_initial}-${user.last_name}`
  if (userFullNameCache.has(cacheKey)) {
    return userFullNameCache.get(cacheKey)
  }
  
  const parts = [user.first_name, user.middle_initial, user.last_name].filter(Boolean)
  const fullName = parts.join(' ') || user.full_name || 'No Name'
  
  userFullNameCache.set(cacheKey, fullName)
  return fullName
}

// Get user initials for avatar - REMOVED (reverted to original SVG design)

const editUser = (user) => {
  selectedUser.value = { ...user }
  showEditModal.value = true
}

const resetPasswordConfirm = (user) => {
  userToReset.value = user
  showResetConfirmModal.value = true
}

const cancelReset = () => {
  showResetConfirmModal.value = false
  setTimeout(() => {
    userToReset.value = null
  }, 300)
}

const confirmReset = async () => {
  if (!userToReset.value) return
  
  resettingPassword.value = true
  
  try {
    const result = await adminStore.resetPassword(userToReset.value.id)
    
    if (result.success) {
      showResetConfirmModal.value = false
      
      setTimeout(() => {
        resetUserName.value = userToReset.value.username
        userToReset.value = null
        showSuccessModal.value = true
      }, 300)
      
      await fastRefresh()
    } else {
      alert(result.error)
    }
  } finally {
    resettingPassword.value = false
  }
}

const deactivateUserConfirm = (user) => {
  userToDeactivate.value = user
  showDeactivateModal.value = true
}

const cancelDeactivate = () => {
  showDeactivateModal.value = false
  setTimeout(() => {
    userToDeactivate.value = null
  }, 300)
}

const confirmDeactivate = async () => {
  if (!userToDeactivate.value) return
  
  deactivatingUser.value = true
  
  try {
    const result = await adminStore.deleteUser(userToDeactivate.value.id)
    
    if (result.success) {
      showDeactivateModal.value = false
      setTimeout(() => {
        userToDeactivate.value = null
      }, 300)
      await fastRefresh()
    } else {
      alert(result.error)
    }
  } finally {
    deactivatingUser.value = false
  }
}

const deletePermanentlyConfirm = (user) => {
  userToDeletePermanently.value = user
  showDeletePermanentlyModal.value = true
}

const cancelDeletePermanently = () => {
  showDeletePermanentlyModal.value = false
  setTimeout(() => {
    userToDeletePermanently.value = null
  }, 300)
}

const confirmDeletePermanently = async () => {
  if (!userToDeletePermanently.value) return
  
  deletingPermanently.value = true
  
  try {
    const result = await adminStore.permanentlyDeleteUser(userToDeletePermanently.value.id)
    
    if (result.success) {
      showDeletePermanentlyModal.value = false
      setTimeout(() => {
        userToDeletePermanently.value = null
      }, 300)
      await fastRefresh()
    } else {
      alert(result.error)
    }
  } finally {
    deletingPermanently.value = false
  }
}

const closeModals = () => {
  showCreateModal.value = false
  showEditModal.value = false
  selectedUser.value = null
}

const handleSave = async () => {
  closeModals()
  await fastRefresh()
}
</script>

<style scoped>
/* iOS White & Black Design */
.user-management {
  padding: 40px 48px;
  max-width: 1400px;
  margin: 0 auto;
  background: #F2F2F7;
  min-height: calc(100vh - 120px);
  position: relative;
}

/* Header */
.management-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.header-subtitle {
  font-size: 15px;
  color: #86868B;
  margin: 0;
  font-weight: 500;
  letter-spacing: -0.2px;
}

/* Classic iOS White & Black Theme with Light Accents */
.btn-create {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 14px 28px;
  background: #1C1C1E;
  color: #FFFFFF;
  border: none;
  border-radius: 14px;
  font-size: 15px;
  font-weight: 600;
  letter-spacing: -0.1px;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.25, 0.46, 0.45, 0.94);
  box-shadow: 0 4px 16px rgba(28, 28, 30, 0.25);
  position: relative;
  overflow: hidden;
}

.btn-create::before {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(45deg, transparent 30%, rgba(255, 255, 255, 0.1) 50%, transparent 70%);
  transform: translateX(-100%);
  transition: transform 0.6s;
}

.btn-create:hover::before {
  transform: translateX(100%);
}

.btn-create svg {
  width: 18px;
  height: 18px;
  stroke-width: 2.5;
  z-index: 1;
  position: relative;
}

.btn-create:hover {
  background: #2C2C2E;
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(28, 28, 30, 0.35);
}

.btn-create:active {
  transform: translateY(0) scale(0.98);
  background: #1C1C1E;
}

/* Classic iOS White & Black Filters */
.filters-section {
  display: flex;
  gap: 12px;
  margin-bottom: 32px;
}

.search-wrapper {
  position: relative;
  flex: 1;
}

.search-icon {
  position: absolute;
  left: 16px;
  top: 50%;
  transform: translateY(-50%);
  width: 20px;
  height: 20px;
  color: #86868B;
  stroke-width: 2;
  pointer-events: none;
}

.search-input {
  width: 100%;
  padding: 12px 16px 12px 48px;
  background: #FFFFFF;
  border: 1px solid #E5E5EA;
  border-radius: 12px;
  font-size: 14px;
  font-weight: 400;
  color: #1C1C1E;
  letter-spacing: 0;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
}

.search-input::placeholder {
  color: #86868B;
}

.search-input:focus {
  outline: none;
  border-color: #1C1C1E;
  background: #FFFFFF;
  box-shadow: 0 0 0 3px rgba(28, 28, 30, 0.1);
}

.filter-select {
  padding: 12px 16px;
  background: #FFFFFF;
  border: 1px solid #E5E5EA;
  border-radius: 12px;
  font-size: 14px;
  font-weight: 400;
  color: #1C1C1E;
  letter-spacing: 0;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);
  min-width: 150px;
}

.filter-select:hover {
  background: #FAFAFA;
  border-color: #D1D1D6;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.08);
}

.filter-select:focus {
  outline: none;
  border-color: #1C1C1E;
  background: #FFFFFF;
  box-shadow: 0 0 0 3px rgba(28, 28, 30, 0.1);
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

/* Empty State - iOS White & Black */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80px 32px;
  text-align: center;
  animation: fadeInUp 0.6s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.empty-icon {
  width: 80px;
  height: 80px;
  background: #FFFFFF;
  border: 1px solid #E5E5EA;
  border-radius: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.empty-icon svg {
  width: 40px;
  height: 40px;
  color: #1C1C1E;
  stroke-width: 2;
}

.empty-state h3 {
  font-size: 24px;
  font-weight: 700;
  color: #1C1C1E;
  margin: 0 0 8px 0;
  letter-spacing: -0.5px;
}

.empty-state p {
  font-size: 15px;
  color: #86868B;
  margin: 0 0 24px 0;
  letter-spacing: -0.2px;
}

/* Classic iOS Empty State Button */
.btn-empty-action {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 24px;
  background: #1C1C1E;
  color: #FFFFFF;
  border: none;
  border-radius: 14px;
  font-size: 15px;
  font-weight: 600;
  letter-spacing: -0.2px;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 4px 12px rgba(28, 28, 30, 0.25);
}

.btn-empty-action svg {
  width: 20px;
  height: 20px;
  stroke-width: 2.5;
}

.btn-empty-action:hover {
  background: #2C2C2E;
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(28, 28, 30, 0.35);
}

/* Classic iOS White Cards - Minimalistic 2-Row Layout */
.user-card {
  background: #FFFFFF;
  border: 1px solid rgba(0, 0, 0, 0.08);
  border-radius: 12px;
  overflow: visible;
  transition: all 0.2s ease;
  animation: fadeInUp 0.2s ease backwards;
  position: relative;
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 16px 20px;
  min-height: 70px;
  will-change: transform;
  backface-visibility: hidden;
}

.user-card.fast-load {
  animation-duration: 0.15s;
}

.user-card:hover {
  transform: translateY(-2px);
  border-color: #1D1D1F;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
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

.user-name-section {
  flex: 1;
  min-width: 0;
}

.user-card-name {
  font-size: 17px;
  font-weight: 600;
  color: #1D1D1F;
  margin: 0 0 2px 0;
  letter-spacing: -0.3px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  line-height: 1.3;
}

.user-card-username {
  font-size: 13px;
  color: #86868B;
  margin: 0;
  font-weight: 400;
  letter-spacing: -0.1px;
  line-height: 1.3;
}

/* Row 2: Badges and Actions */
.card-row-2 {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-top: 8px;
  border-top: 1px solid rgba(0, 0, 0, 0.06);
}

.status-badges {
  display: flex;
  gap: 8px;
  align-items: center;
}

/* Classic iOS Status Badges - Minimalistic */
.role-badge {
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  white-space: nowrap;
}

.status-badge {
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 10px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  white-space: nowrap;
}

.role-badge.admin {
  background: #1C1C1E;
  color: #FFFFFF;
}

.role-badge.reviewee {
  background: #F2F2F7;
  color: #1C1C1E;
}

.status-badge.active {
  background: #E8F5E8;
  color: #34C759;
}

.status-badge.inactive {
  background: #FFEBEE;
  color: #FF3B30;
}

/* Classic iOS Action Buttons - Icon Only */
.card-actions {
  display: flex;
  gap: 8px;
  align-items: center;
}

.action-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0;
  width: 36px;
  height: 36px;
  background: #FFFFFF;
  border: 1px solid rgba(0, 0, 0, 0.08);
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s ease;
  position: relative;
  color: #1C1C1E;
  flex-shrink: 0;
}

.action-btn svg {
  width: 18px;
  height: 18px;
  stroke-width: 2;
}

.action-btn:hover {
  transform: scale(1.05);
  background: #F5F5F7;
  border-color: #1D1D1F;
}

.action-primary {
  background: #1C1C1E !important;
  color: #FFFFFF !important;
  border-color: #1C1C1E !important;
}

.action-primary:hover {
  background: #2C2C2E !important;
  transform: scale(1.1);
}

.action-danger {
  background: #FFF5F5;
  color: #FF3B30;
  border-color: #FF3B30;
}

.action-danger:hover {
  background: #FF3B30;
  color: #FFFFFF;
  transform: scale(1.1);
}

.action-danger-permanent {
  background: #F5F5F7;
  color: #8E8E93;
  border-color: #E5E5EA;
}

.action-danger-permanent:hover {
  background: #8E8E93;
  color: #FFFFFF;
  border-color: #8E8E93;
  transform: scale(1.1);
}

/* Confirmation Modals */
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

.confirm-modal {
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
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 20px;
}

.modal-icon-wrapper.warning {
  background: linear-gradient(135deg, rgba(255, 149, 0, 0.1) 0%, rgba(255, 149, 0, 0.15) 100%);
}

.modal-icon-wrapper.warning .modal-icon {
  color: #FF9500;
}

/* Enhanced Modern Modal Styles */
.modern-modal {
  background: rgba(255, 255, 255, 0.98);
  backdrop-filter: blur(40px);
  border: 1px solid rgba(255, 255, 255, 0.5);
  box-shadow: 
    0 30px 90px rgba(0, 0, 0, 0.25),
    0 0 0 1px rgba(255, 255, 255, 0.5) inset;
}

.modern-modal::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: linear-gradient(90deg, #FF9500, #FF6B00, #FF9500);
  background-size: 200% 100%;
  animation: gradientShift 3s ease infinite;
}

@keyframes gradientShift {
  0%, 100% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
}

.warning-modern {
  position: relative;
  width: 90px;
  height: 90px;
  background: linear-gradient(135deg, #FF9500, #FF6B00);
  border-radius: 22px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 24px;
  box-shadow: 0 12px 32px rgba(255, 149, 0, 0.4);
  animation: iconBounce 2s ease-in-out infinite;
}

@keyframes iconBounce {
  0%, 100% { transform: translateY(0) scale(1); }
  50% { transform: translateY(-8px) scale(1.05); }
}

.icon-glow-effect {
  position: absolute;
  width: 110px;
  height: 110px;
  background: radial-gradient(circle, rgba(255, 149, 0, 0.4), transparent 70%);
  border-radius: 50%;
  animation: glowPulse 2s ease-in-out infinite;
}

@keyframes glowPulse {
  0%, 100% { transform: scale(1); opacity: 0.6; }
  50% { transform: scale(1.2); opacity: 0.9; }
}

.rotating-ring {
  position: absolute;
  width: 100px;
  height: 100px;
  border: 3px solid transparent;
  border-top-color: rgba(255, 149, 0, 0.5);
  border-right-color: rgba(255, 149, 0, 0.3);
  border-radius: 50%;
  animation: rotateRing 3s linear infinite;
}

@keyframes rotateRing {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.warning-modern .modal-icon {
  color: white;
  width: 40px;
  height: 40px;
  stroke-width: 2.5;
  position: relative;
  z-index: 2;
  filter: drop-shadow(0 2px 8px rgba(0, 0, 0, 0.2));
}

.modal-title-modern {
  font-size: 26px;
  font-weight: 800;
  background: linear-gradient(135deg, #1D1D1F, #FF9500);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin: 0 0 16px 0;
  letter-spacing: -0.8px;
  animation: titleSlide 0.5s ease-out;
}

@keyframes titleSlide {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.modal-message-modern {
  font-size: 16px;
  color: #86868B;
  line-height: 1.6;
  margin: 0 0 20px 0;
  letter-spacing: -0.2px;
  animation: titleSlide 0.5s ease-out 0.1s both;
}

.modal-message-modern strong {
  color: #1D1D1F;
  font-weight: 700;
}

.highlight-text {
  display: inline-block;
  padding: 2px 8px;
  background: linear-gradient(135deg, rgba(255, 149, 0, 0.15), rgba(255, 149, 0, 0.25));
  border-radius: 6px;
  color: #FF9500;
  font-weight: 700;
  font-family: 'Courier New', monospace;
  font-size: 15px;
}

.user-highlight {
  color: #1C1C1E;
  font-weight: 700;
}

.info-box {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 14px 16px;
  background: linear-gradient(135deg, rgba(28, 28, 30, 0.08), rgba(28, 28, 30, 0.08));
  border: 1px solid rgba(28, 28, 30, 0.2);
  border-radius: 12px;
  margin-bottom: 24px;
  animation: titleSlide 0.5s ease-out 0.2s both;
}

.info-icon {
  font-size: 20px;
  flex-shrink: 0;
}

.info-text {
  font-size: 13px;
  color: #1C1C1E;
  font-weight: 600;
  line-height: 1.4;
  letter-spacing: -0.1px;
}

.modal-actions-modern {
  display: flex;
  gap: 12px;
  animation: titleSlide 0.5s ease-out 0.3s both;
}

.modal-btn-modern {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 16px 24px;
  border: none;
  border-radius: 14px;
  font-size: 15px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  letter-spacing: -0.3px;
  position: relative;
  overflow: hidden;
}

.modal-btn-modern::before {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  width: 0;
  height: 0;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.3);
  transform: translate(-50%, -50%);
  transition: width 0.6s, height 0.6s;
}

.modal-btn-modern:hover::before {
  width: 300px;
  height: 300px;
}

.modal-btn-cancel-modern {
  background: #F5F5F7;
  color: #1D1D1F;
  border: 2px solid rgba(0, 0, 0, 0.06);
}

.modal-btn-cancel-modern:hover:not(:disabled) {
  background: #E8E8ED;
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.1);
}

.modal-btn-warning-modern {
  background: linear-gradient(135deg, #FF9500, #FF6B00);
  color: #FFFFFF;
  box-shadow: 0 8px 24px rgba(255, 149, 0, 0.4);
}

.modal-btn-warning-modern:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 12px 32px rgba(255, 149, 0, 0.5);
}

.modal-btn-warning-modern svg {
  width: 20px;
  height: 20px;
  stroke-width: 2.5;
  position: relative;
  z-index: 1;
}

.modal-btn-modern:active:not(:disabled) {
  transform: translateY(0);
}

.modal-btn-modern:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none;
}

.modal-btn-modern span {
  position: relative;
  z-index: 1;
}

.btn-spinner-modern {
  width: 20px;
  height: 20px;
  position: relative;
  z-index: 1;
}

.btn-spinner-modern .spinner-ring-small {
  width: 20px;
  height: 20px;
  border: 3px solid rgba(255, 255, 255, 0.3);
  border-top-color: #FFFFFF;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Simple Success Modal */
.success-modal {
  background: #FFFFFF;
  border-radius: 20px;
  padding: 40px;
  max-width: 440px;
  width: 100%;
  text-align: center;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

.success-icon {
  width: 80px;
  height: 80px;
  margin: 0 auto 24px;
  background: linear-gradient(135deg, #34C759, #30D158);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8px 24px rgba(52, 199, 89, 0.3);
}

.success-icon svg {
  width: 48px;
  height: 48px;
  color: white;
  stroke-width: 2.5;
}

.success-title {
  font-size: 24px;
  font-weight: 700;
  color: #1D1D1F;
  margin: 0 0 12px 0;
  letter-spacing: -0.5px;
}

.success-message {
  font-size: 16px;
  color: #86868B;
  margin: 0 0 8px 0;
  line-height: 1.5;
}

.success-message strong {
  color: #34C759;
  font-weight: 600;
}

.success-note {
  font-size: 14px;
  color: #FF9500;
  background: rgba(255, 149, 0, 0.1);
  padding: 12px 16px;
  border-radius: 12px;
  margin: 20px 0;
  border: 1px solid rgba(255, 149, 0, 0.2);
}

/* Classic iOS Success Button */
.success-btn {
  width: 100%;
  padding: 16px;
  background: #1C1C1E;
  color: #FFFFFF;
  border: 1px solid #1C1C1E;
  border-radius: 14px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: 0 4px 12px rgba(28, 28, 30, 0.25);
}

.success-btn:hover {
  background: #2C2C2E;
  transform: translateY(-1px);
  box-shadow: 0 6px 16px rgba(28, 28, 30, 0.35);
}

.modal-icon-wrapper.danger {
  background: linear-gradient(135deg, rgba(255, 59, 48, 0.1) 0%, rgba(255, 59, 48, 0.15) 100%);
}

.modal-icon-wrapper.danger .modal-icon {
  color: #FF3B30;
}

.modal-icon-wrapper.danger-permanent {
  background: linear-gradient(135deg, rgba(139, 0, 0, 0.1) 0%, rgba(139, 0, 0, 0.15) 100%);
}

.modal-icon-wrapper.danger-permanent .modal-icon {
  color: #8B0000;
}

.modal-icon {
  width: 32px;
  height: 32px;
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

.modal-warning {
  font-size: 14px;
  color: #8B0000;
  background: rgba(139, 0, 0, 0.05);
  padding: 12px 16px;
  border-radius: 8px;
  border-left: 3px solid #8B0000;
  margin: 16px 0 24px 0;
  line-height: 1.5;
  font-weight: 500;
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

/* Classic iOS Modal Buttons */
.modal-btn {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 14px 20px;
  border: 1px solid #E5E5EA;
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
  background: #FFFFFF;
  color: #1C1C1E;
  border-color: #E5E5EA;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.modal-btn-cancel:hover:not(:disabled) {
  background: #F2F2F7;
  border-color: #D1D1D6;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.modal-btn-cancel:active:not(:disabled) {
  transform: scale(0.96);
}

.modal-btn-warning {
  background: #1C1C1E;
  color: #FFFFFF;
  border-color: #1C1C1E;
  box-shadow: 0 4px 12px rgba(28, 28, 30, 0.25);
}

.modal-btn-warning:hover:not(:disabled) {
  background: #2C2C2E;
  transform: translateY(-1px);
  box-shadow: 0 6px 16px rgba(28, 28, 30, 0.35);
}

.modal-btn-warning:active:not(:disabled) {
  transform: scale(0.96);
}

.modal-btn-danger {
  background: #FF3B30;
  color: #FFFFFF;
  border-color: #FF3B30;
  box-shadow: 0 4px 12px rgba(255, 59, 48, 0.25);
}

.modal-btn-danger:hover:not(:disabled) {
  background: #D70015;
  transform: translateY(-1px);
  box-shadow: 0 6px 16px rgba(255, 59, 48, 0.35);
}

.modal-btn-danger:active:not(:disabled) {
  transform: scale(0.96);
}

.modal-btn-danger-permanent {
  background: #8E8E93;
  color: #FFFFFF;
  border-color: #8E8E93;
  box-shadow: 0 4px 12px rgba(142, 142, 147, 0.25);
}

.modal-btn-danger-permanent:hover:not(:disabled) {
  background: #6D6D70;
  transform: translateY(-1px);
  box-shadow: 0 6px 16px rgba(142, 142, 147, 0.35);
}

.modal-btn-danger-permanent:active:not(:disabled) {
  transform: scale(0.96);
}

.modal-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.modal-btn:disabled:hover {
  transform: none;
}

/* Button Loading Spinner */
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

/* Password Modal */

.password-display {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: 16px 20px;
  background: #F5F5F7;
  border-radius: 12px;
  margin-bottom: 16px;
}

.password-text {
  flex: 1;
  font-size: 18px;
  font-weight: 700;
  color: #1D1D1F;
  letter-spacing: 2px;
  font-family: 'Courier New', monospace;
}

.copy-btn {
  width: 36px;
  height: 36px;
  background: #FFFFFF;
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

.copy-btn svg {
  width: 18px;
  height: 18px;
  color: #007AFF;
  stroke-width: 2;
}

.copy-btn:hover {
  background: #007AFF;
  border-color: #007AFF;
}

.copy-btn:hover svg {
  color: white;
}

.copy-btn:active {
  transform: scale(0.9);
}

.modal-note {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 12px 16px;
  background: rgba(255, 149, 0, 0.1);
  border-radius: 10px;
  font-size: 13px;
  color: #FF9500;
  font-weight: 500;
  margin-bottom: 24px;
  letter-spacing: -0.1px;
}

.modal-note svg {
  width: 18px;
  height: 18px;
  stroke-width: 2;
  flex-shrink: 0;
}

.modal-btn-close {
  width: 100%;
  padding: 14px 20px;
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

.modal-btn-close:hover {
  background: #0051D5;
  transform: translateY(-1px);
  box-shadow: 0 6px 16px rgba(0, 122, 255, 0.4);
}

.modal-btn-close:active {
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

/* Password Success Modal Specific Styles */
.password-modal {
  background: #FFFFFF;
  border-radius: 20px;
  padding: 32px;
  max-width: 480px;
  width: 100%;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  text-align: center;
}

.password-modal .modal-icon-wrapper {
  background: linear-gradient(135deg, rgba(52, 199, 89, 0.1) 0%, rgba(52, 199, 89, 0.15) 100%);
}

.password-modal .modal-icon {
  color: #34C759;
}

.password-display {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: 16px 20px;
  background: #F5F5F7;
  border-radius: 12px;
  margin-bottom: 16px;
}

.password-text {
  flex: 1;
  font-size: 18px;
  font-weight: 700;
  color: #1D1D1F;
  letter-spacing: 2px;
  font-family: 'Courier New', monospace;
}

.copy-btn {
  width: 36px;
  height: 36px;
  background: #FFFFFF;
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

.copy-btn svg {
  width: 18px;
  height: 18px;
  color: #007AFF;
  stroke-width: 2;
}

.copy-btn:hover {
  background: #007AFF;
  border-color: #007AFF;
}

.copy-btn:hover svg {
  color: white;
}

.copy-btn:active {
  transform: scale(0.9);
}

.modal-note {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 12px 16px;
  background: rgba(255, 149, 0, 0.1);
  border-radius: 10px;
  font-size: 13px;
  color: #FF9500;
  font-weight: 500;
  margin-bottom: 24px;
  letter-spacing: -0.1px;
}

.modal-note svg {
  width: 18px;
  height: 18px;
  stroke-width: 2;
  flex-shrink: 0;
}

.modal-btn-close {
  width: 100%;
  padding: 14px 20px;
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

.modal-btn-close:hover {
  background: #0051D5;
  transform: translateY(-1px);
  box-shadow: 0 6px 16px rgba(0, 122, 255, 0.4);
}

.modal-btn-close:active {
  transform: scale(0.96);
}

/* List Transitions - Optimized for Speed */
.list-enter-active {
  transition: all 0.15s cubic-bezier(0.4, 0, 0.2, 1);
}

.list-leave-active {
  transition: all 0.1s cubic-bezier(0.4, 0, 0.2, 1);
}

.list-enter-from {
  opacity: 0;
  transform: translateY(8px) scale(0.98);
}

.list-leave-to {
  opacity: 0;
  transform: translateY(-4px) scale(0.99);
}

.list-move {
  transition: transform 0.15s cubic-bezier(0.4, 0, 0.2, 1);
}

/* User Grid */
.user-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(480px, 1fr));
  gap: 16px;
  padding: 0;
}

/* Responsive */
@media (max-width: 1400px) {
  .user-grid {
    grid-template-columns: repeat(auto-fill, minmax(420px, 1fr));
    gap: 14px;
  }
}

@media (max-width: 1024px) {
  .user-management {
    padding: 32px 24px;
  }
  
  .user-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 12px;
  }
}

@media (max-width: 768px) {
  .user-management {
    padding: 24px 20px;
  }
  
  .user-grid {
    grid-template-columns: 1fr;
    gap: 10px;
  }
  
  .user-card {
    padding: 14px 16px;
  }
  
  .filters-section {
    flex-direction: column;
  }
  
  .filter-select {
    width: 100%;
  }
  
  .management-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }
  
  .btn-create {
    width: 100%;
  }
}
</style>
