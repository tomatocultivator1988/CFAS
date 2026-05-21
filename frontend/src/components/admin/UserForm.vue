<template>
  <div class="modal-overlay">
    <div class="modal-content" @click.stop>
      <div class="modal-header">
        <h2>{{ user ? 'Edit User' : 'Create User' }}</h2>
        <button type="button" @click="$emit('close')" class="close-btn">
          <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
            <path d="M15 5L5 15M5 5L15 15" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
          </svg>
        </button>
      </div>
      
      <form @submit.prevent="handleSubmit">
        <div class="form-group">
          <label>First Name</label>
          <input v-model="formData.first_name" type="text" required placeholder="Enter first name" />
        </div>

        <div class="form-group">
          <label>Last Name</label>
          <input v-model="formData.last_name" type="text" required placeholder="Enter last name" />
        </div>

        <div class="form-group">
          <label>Middle Initial</label>
          <input v-model="formData.middle_initial" type="text" maxlength="10" placeholder="Enter middle initial (optional)" />
        </div>

        <div class="form-group">
          <label>Username</label>
          <input 
            v-model="formData.username" 
            type="text" 
            required 
            :disabled="!!user"
            :placeholder="user ? 'Username cannot be changed' : 'Enter username'"
          />
        </div>

        <div class="form-group">
          <label>Email</label>
          <input
            v-model="formData.email"
            type="email"
            :required="!user"
            placeholder="Enter email address"
          />
        </div>

        <div class="form-group">
          <label>Role</label>
          <select v-model="formData.role" required>
            <option value="reviewee">Reviewee</option>
            <option value="admin">Admin</option>
          </select>
        </div>

        <div v-if="user" class="form-group checkbox-group">
          <label class="checkbox-label">
            <input v-model="formData.is_active" type="checkbox" />
            <span class="checkbox-text">Active Account</span>
          </label>
        </div>

        <div v-if="error" class="error-message">
          <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
            <circle cx="8" cy="8" r="7" stroke="currentColor" stroke-width="1.5"/>
            <path d="M8 4V8M8 11V11.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
          </svg>
          {{ error }}
        </div>

        <div class="modal-actions">
          <button type="button" @click="$emit('close')" class="btn-secondary" :disabled="submitting">
            Cancel
          </button>
          <button type="submit" class="btn-primary" :disabled="submitting">
            <span v-if="!submitting">{{ user ? 'Update' : 'Create' }}</span>
            <div v-else class="loading-spinner"></div>
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, defineProps, defineEmits, watch } from 'vue'
import { useAdminStore } from '@/stores/admin'

const props = defineProps({
  user: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['close', 'save'])
const adminStore = useAdminStore()

const formData = reactive({
  first_name: props.user?.first_name || '',
  last_name: props.user?.last_name || '',
  middle_initial: props.user?.middle_initial || '',
  username: props.user?.username || '',
  email: props.user?.email || '',
  role: props.user?.role || 'reviewee',
  is_active: props.user?.is_active !== false
})

// Watch for changes in props.user to update formData
watch(() => props.user, (newUser) => {
  if (newUser) {
    formData.first_name = newUser.first_name || ''
    formData.last_name = newUser.last_name || ''
    formData.middle_initial = newUser.middle_initial || ''
    formData.username = newUser.username || ''
    formData.email = newUser.email || ''
    formData.role = newUser.role || 'reviewee'
    formData.is_active = newUser.is_active !== false
  } else {
    formData.first_name = ''
    formData.last_name = ''
    formData.middle_initial = ''
    formData.username = ''
    formData.email = ''
    formData.role = 'reviewee'
    formData.is_active = true
  }
}, { immediate: true })

const submitting = ref(false)
const error = ref(null)

const handleSubmit = async () => {
  submitting.value = true
  error.value = null

  // Prepare data - don't send username for updates
  const data = { ...formData }
  if (props.user) {
    delete data.username // Username can't be changed
  }

  const result = props.user
    ? await adminStore.updateUser(props.user.id, data)
    : await adminStore.createUser(data)

  if (result.success) {
    emit('save')
  } else {
    error.value = result.error
  }
  
  submitting.value = false
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.4);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  animation: fadeIn 0.2s ease-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

.modal-content {
  background: #FFFFFF;
  border-radius: 16px;
  padding: 0;
  max-width: 480px;
  width: 90%;
  max-height: 90vh;
  overflow: hidden;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
  animation: slideUp 0.3s ease-out;
}

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

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 24px 24px 20px 24px;
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
}

.modal-header h2 {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', sans-serif;
  font-size: 22px;
  font-weight: 600;
  color: #1D1D1F;
  letter-spacing: -0.02em;
}

.close-btn {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  border: none;
  background: rgba(0, 0, 0, 0.04);
  color: #86868B;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
  flex-shrink: 0;
}

.close-btn:hover {
  background: rgba(0, 0, 0, 0.08);
  color: #1D1D1F;
}

form {
  padding: 24px;
  overflow-y: auto;
  max-height: calc(90vh - 80px);
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 13px;
  font-weight: 500;
  color: #86868B;
  letter-spacing: -0.01em;
  text-transform: uppercase;
}

.form-group input[type="text"],
.form-group input[type="password"],
.form-group input[type="email"],
.form-group select {
  width: 100%;
  padding: 12px 14px;
  border: 1px solid rgba(0, 0, 0, 0.1);
  border-radius: 10px;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 15px;
  color: #1D1D1F;
  background: #FFFFFF;
  transition: all 0.2s ease;
  letter-spacing: -0.01em;
}

.form-group input[type="text"]:focus,
.form-group input[type="password"]:focus,
.form-group select:focus {
  outline: none;
  border-color: #007AFF;
  box-shadow: 0 0 0 3px rgba(0, 122, 255, 0.1);
}

.form-group input[type="text"]:disabled {
  background: #F5F5F7;
  color: #86868B;
  cursor: not-allowed;
  border-color: rgba(0, 0, 0, 0.06);
}

.form-group input::placeholder {
  color: #C7C7CC;
}

.form-group select {
  cursor: pointer;
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg width='12' height='8' viewBox='0 0 12 8' fill='none' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M1 1.5L6 6.5L11 1.5' stroke='%2386868B' stroke-width='1.5' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 14px center;
  padding-right: 40px;
}

.checkbox-group {
  margin-top: 24px;
  padding-top: 20px;
  border-top: 1px solid rgba(0, 0, 0, 0.06);
}

.checkbox-label {
  display: flex;
  align-items: center;
  cursor: pointer;
  text-transform: none;
  font-size: 15px;
  color: #1D1D1F;
  font-weight: 400;
}

.checkbox-label input[type="checkbox"] {
  width: 20px;
  height: 20px;
  margin: 0;
  margin-right: 10px;
  cursor: pointer;
  accent-color: #007AFF;
}

.checkbox-text {
  user-select: none;
}

.error-message {
  display: flex;
  align-items: center;
  gap: 8px;
  background: rgba(255, 59, 48, 0.08);
  color: #FF3B30;
  padding: 12px 14px;
  border-radius: 10px;
  margin-bottom: 20px;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 14px;
  letter-spacing: -0.01em;
}

.modal-actions {
  display: flex;
  gap: 10px;
  margin-top: 28px;
  padding-top: 20px;
  border-top: 1px solid rgba(0, 0, 0, 0.06);
}

.btn-primary, .btn-secondary {
  flex: 1;
  padding: 12px 20px;
  border-radius: 10px;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 15px;
  font-weight: 500;
  cursor: pointer;
  border: none;
  transition: all 0.2s ease;
  letter-spacing: -0.01em;
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 44px;
}

.btn-primary {
  background: #007AFF;
  color: #FFFFFF;
}

.btn-primary:hover:not(:disabled) {
  background: #0051D5;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 122, 255, 0.3);
}

.btn-primary:active:not(:disabled) {
  transform: translateY(0);
}

.btn-primary:disabled {
  background: #C7C7CC;
  cursor: not-allowed;
  opacity: 0.6;
}

.btn-secondary {
  background: rgba(0, 0, 0, 0.04);
  color: #1D1D1F;
}

.btn-secondary:hover:not(:disabled) {
  background: rgba(0, 0, 0, 0.08);
}

.btn-secondary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.loading-spinner {
  width: 18px;
  height: 18px;
  border: 2px dashed rgba(255, 255, 255, 0.8);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}
</style>
