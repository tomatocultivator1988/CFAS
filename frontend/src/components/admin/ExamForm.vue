<template>
  <!-- Main Form Modal -->
  <div v-if="!showConfirmation" class="modal-overlay">
    <div class="modal-content">
      <div class="modal-header">
        <h2>{{ exam ? 'Edit Exam' : 'Create Exam' }}</h2>
        <button type="button" @click="$emit('close')" class="close-btn">
          <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
            <path d="M15 5L5 15M5 5L15 15" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
          </svg>
        </button>
      </div>
      
      <form @submit.prevent="showConfirmationModal">
        <div class="form-group">
          <label>Exam Title</label>
          <input v-model="formData.title" type="text" required placeholder="Enter exam title" />
        </div>

        <div class="form-group">
          <label>Category</label>
          <select v-model="formData.category" required>
            <option value="">Select Category</option>
            <option value="Aquaculture">Aquaculture</option>
            <option value="Capture Fisheries">Capture Fisheries</option>
            <option value="Aquatic Resources and Ecology">Aquatic Resources and Ecology</option>
            <option value="Post Harvest Fisheries">Post Harvest Fisheries</option>
          </select>
        </div>

        <div class="form-group">
          <label>Description</label>
          <textarea v-model="formData.description" rows="3" placeholder="Enter exam description (optional)"></textarea>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label>Time Limit (minutes)</label>
            <input v-model.number="formData.time_limit_minutes" type="number" min="1" required placeholder="60" />
          </div>

          <div class="form-group">
            <label>Max Attempts</label>
            <input v-model.number="formData.max_attempts" type="number" min="1" required placeholder="3" />
          </div>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label>Passing Score (%)</label>
            <input v-model.number="formData.passing_score" type="number" min="0" max="100" placeholder="75" />
          </div>

          <div class="form-group checkbox-group">
            <label class="toggle-label" @click.prevent="formData.randomize_questions = !formData.randomize_questions">
              <span class="toggle-text">Randomize Questions</span>
              <div class="toggle-switch">
                <div class="toggle-slider" :class="{ active: formData.randomize_questions }">
                  <div class="toggle-knob"></div>
                </div>
              </div>
            </label>
          </div>
        </div>

        <div v-if="error" class="error-message">
          <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
            <circle cx="8" cy="8" r="7" stroke="currentColor" stroke-width="1.5"/>
            <path d="M8 4V8M8 11V11.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
          </svg>
          {{ error }}
        </div>

        <div class="modal-actions">
          <button type="button" @click="$emit('close')" class="btn-secondary">
            Cancel
          </button>
          <button type="submit" class="btn-primary">
            {{ exam ? 'Update' : 'Create' }}
          </button>
        </div>
      </form>
    </div>
  </div>

  <!-- Confirmation Modal -->
  <div v-if="showConfirmation" class="modal-overlay">
    <div class="confirmation-modal">
      <div class="confirmation-icon">
        <svg width="48" height="48" viewBox="0 0 48 48" fill="none">
          <circle cx="24" cy="24" r="20" stroke="#007AFF" stroke-width="2"/>
          <path d="M24 16V26M24 30V31" stroke="#007AFF" stroke-width="2" stroke-linecap="round"/>
        </svg>
      </div>
      
      <h3>{{ exam ? 'Update Exam?' : 'Create Exam?' }}</h3>
      <p>{{ exam ? 'Are you sure you want to update this exam?' : 'Are you sure you want to create this exam?' }}</p>
      
      <div class="confirmation-actions">
        <button @click="cancelConfirmation" class="btn-cancel" :disabled="submitting">
          Cancel
        </button>
        <button @click="handleSubmit" class="btn-confirm" :disabled="submitting">
          <span v-if="!submitting">{{ exam ? 'Update' : 'Create' }}</span>
          <div v-else class="loading-spinner"></div>
        </button>
      </div>
    </div>
  </div>

  <!-- Success Notification -->
  <div v-if="showNotification" class="notification">
    <div class="notification-icon">
      <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
        <path d="M16 6L8 14L4 10" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
      </svg>
    </div>
    <span>{{ exam ? 'Exam updated successfully!' : 'Exam created successfully!' }}</span>
  </div>
</template>

<script setup>
import { ref, reactive, defineProps, defineEmits } from 'vue'
import { useAdminStore } from '@/stores/admin'

const props = defineProps({
  exam: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['close', 'save'])
const adminStore = useAdminStore()

const formData = reactive({
  title: props.exam?.title || '',
  category: props.exam?.category || '',
  description: props.exam?.description || '',
  time_limit_minutes: props.exam?.time_limit_minutes || 60,
  max_attempts: props.exam?.max_attempts || 3,
  passing_score: props.exam?.passing_score || 75,
  randomize_questions: props.exam?.randomize_questions || false
})

const submitting = ref(false)
const error = ref(null)
const showConfirmation = ref(false)
const showNotification = ref(false)

const showConfirmationModal = () => {
  error.value = null
  showConfirmation.value = true
}

const cancelConfirmation = () => {
  if (!submitting.value) {
    showConfirmation.value = false
  }
}

const handleSubmit = async () => {
  submitting.value = true
  error.value = null

  const result = props.exam
    ? await adminStore.updateExam(props.exam.id, formData)
    : await adminStore.createExam(formData)

  submitting.value = false

  if (result.success) {
    showConfirmation.value = false
    showNotification.value = true
    
    setTimeout(() => {
      showNotification.value = false
      emit('save')
    }, 2000)
  } else {
    error.value = result.error
    showConfirmation.value = false
  }
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
  from { opacity: 0; }
  to { opacity: 1; }
}

.modal-content {
  background: #FFFFFF;
  border-radius: 16px;
  padding: 0;
  max-width: 560px;
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
.form-group input[type="number"],
.form-group textarea,
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

.form-group input:focus,
.form-group textarea:focus,
.form-group select:focus {
  outline: none;
  border-color: #007AFF;
  box-shadow: 0 0 0 3px rgba(0, 122, 255, 0.1);
}

.form-group input::placeholder,
.form-group textarea::placeholder {
  color: #C7C7CC;
}

.form-group textarea {
  resize: vertical;
  min-height: 80px;
}

.form-group select {
  cursor: pointer;
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg width='12' height='8' viewBox='0 0 12 8' fill='none' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M1 1.5L6 6.5L11 1.5' stroke='%2386868B' stroke-width='1.5' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 14px center;
  padding-right: 40px;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.checkbox-group {
  display: flex;
  align-items: center;
  margin-top: 8px;
}

.toggle-label {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  cursor: pointer;
  text-transform: none;
  font-size: 15px;
  color: #1D1D1F;
  font-weight: 400;
  padding: 12px 14px;
  background: rgba(0, 0, 0, 0.02);
  border-radius: 10px;
  transition: background 0.2s ease;
}

.toggle-label:hover {
  background: rgba(0, 0, 0, 0.04);
}

.toggle-text {
  user-select: none;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  letter-spacing: -0.01em;
}

.toggle-switch {
  position: relative;
  flex-shrink: 0;
}

.toggle-slider {
  width: 51px;
  height: 31px;
  background: rgba(0, 0, 0, 0.1);
  border-radius: 31px;
  position: relative;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  cursor: pointer;
}

.toggle-slider.active {
  background: #34C759;
}

.toggle-knob {
  width: 27px;
  height: 27px;
  background: #FFFFFF;
  border-radius: 50%;
  position: absolute;
  top: 2px;
  left: 2px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1), 0 1px 2px rgba(0, 0, 0, 0.06);
}

.toggle-slider.active .toggle-knob {
  transform: translateX(20px);
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
  min-height: 44px;
}

.btn-primary {
  background: #007AFF;
  color: #FFFFFF;
}

.btn-primary:hover {
  background: #0051D5;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 122, 255, 0.3);
}

.btn-primary:active {
  transform: translateY(0);
}

.btn-secondary {
  background: rgba(0, 0, 0, 0.04);
  color: #1D1D1F;
}

.btn-secondary:hover {
  background: rgba(0, 0, 0, 0.08);
}

/* Confirmation Modal */
.confirmation-modal {
  background: #FFFFFF;
  border-radius: 16px;
  padding: 32px;
  max-width: 400px;
  width: 90%;
  text-align: center;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
  animation: slideUp 0.3s ease-out;
}

.confirmation-icon {
  width: 64px;
  height: 64px;
  margin: 0 auto 20px;
  background: rgba(0, 122, 255, 0.1);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.confirmation-modal h3 {
  margin: 0 0 12px 0;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', sans-serif;
  font-size: 20px;
  font-weight: 600;
  color: #1D1D1F;
  letter-spacing: -0.02em;
}

.confirmation-modal p {
  margin: 0 0 28px 0;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 15px;
  color: #86868B;
  line-height: 1.5;
  letter-spacing: -0.01em;
}

.confirmation-actions {
  display: flex;
  gap: 10px;
}

.btn-cancel, .btn-confirm {
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
  min-height: 44px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-cancel {
  background: rgba(0, 0, 0, 0.04);
  color: #1D1D1F;
}

.btn-cancel:hover:not(:disabled) {
  background: rgba(0, 0, 0, 0.08);
}

.btn-cancel:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-confirm {
  background: #007AFF;
  color: #FFFFFF;
}

.btn-confirm:hover:not(:disabled) {
  background: #0051D5;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 122, 255, 0.3);
}

.btn-confirm:active:not(:disabled) {
  transform: translateY(0);
}

.btn-confirm:disabled {
  background: #C7C7CC;
  cursor: not-allowed;
  opacity: 0.6;
}

.loading-spinner {
  width: 18px;
  height: 18px;
  border: 2px dashed rgba(255, 255, 255, 0.8);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

/* Success Notification */
.notification {
  position: fixed;
  top: 24px;
  right: 24px;
  background: #34C759;
  color: white;
  padding: 16px 20px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  gap: 12px;
  box-shadow: 0 8px 24px rgba(52, 199, 89, 0.3);
  z-index: 2000;
  animation: slideInRight 0.3s ease-out;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 15px;
  font-weight: 500;
  letter-spacing: -0.01em;
}

@keyframes slideInRight {
  from {
    opacity: 0;
    transform: translateX(100px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

.notification-icon {
  width: 24px;
  height: 24px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
</style>
