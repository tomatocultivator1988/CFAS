<template>
  <div class="modal-overlay">
    <div class="modal-content">
      <div class="modal-header">
        <h2>{{ question ? 'Edit Question' : 'Create Question' }}</h2>
        <button @click="$emit('close')" class="close-btn">
          <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
            <path d="M15 5L5 15M5 5L15 15" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
          </svg>
        </button>
      </div>
      
      <form @submit.prevent="handleSubmit" class="modal-body">
        <div class="form-group">
          <label>Question Text</label>
          <textarea 
            v-model="formData.question_text" 
            rows="4" 
            required
            placeholder="Enter your question here..."
          ></textarea>
        </div>

        <div class="form-group">
          <label>Topic (Optional)</label>
          <input 
            v-model="formData.topic" 
            type="text" 
            placeholder="e.g., Mathematics, Science, History"
          />
        </div>

        <!-- Exam Selector (only show if not editing and no examId prop) -->
        <div v-if="!question && !examId && exams.length > 0" class="form-group">
          <label>Attach to Exam (Optional)</label>
          <select v-model="formData.exam_id">
            <option :value="null">-- No Exam (Create as unassigned) --</option>
            <option v-for="exam in exams" :key="exam.id" :value="exam.id">
              {{ exam.title }}
            </option>
          </select>
          <p class="hint">You can attach this question to an exam now, or leave it unassigned and attach it later</p>
        </div>

        <div class="form-group">
          <label>Answer Choices</label>
          <div class="choices-container">
            <div 
              v-for="(choice, index) in formData.answer_choices" 
              :key="index" 
              class="choice-item"
            >
              <input 
                type="radio" 
                :name="'correct'" 
                :checked="choice.is_correct"
                @change="setCorrectAnswer(index)"
                class="choice-radio"
                :id="`choice-${index}`"
              />
              
              <input 
                v-model="choice.choice_text" 
                type="text" 
                :placeholder="`Choice ${String.fromCharCode(65 + index)}`"
                required
                class="choice-input"
              />
              
              <button 
                v-if="formData.answer_choices.length > 2"
                type="button" 
                @click="removeChoice(index)" 
                class="btn-remove"
              >
                <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                  <path d="M12 4L4 12M4 4L12 12" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
                </svg>
              </button>
            </div>
          </div>
          
          <button 
            v-if="formData.answer_choices.length < 6"
            type="button" 
            @click="addChoice" 
            class="btn-add-choice"
          >
            <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
              <path d="M8 3V13M3 8H13" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
            </svg>
            Add Choice
          </button>
          
          <p class="hint">Select the radio button to mark the correct answer</p>
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
          <button 
            type="submit" 
            class="btn-primary" 
            :disabled="submitting"
          >
            <span v-if="!submitting">{{ question ? 'Update' : 'Create' }}</span>
            <div v-else class="loading-spinner"></div>
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, defineProps, defineEmits } from 'vue'
import { useAdminStore } from '@/stores/admin'

const props = defineProps({
  question: {
    type: Object,
    default: null
  },
  examId: {
    type: [String, Number],
    default: null
  },
  exams: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['close', 'save'])
const adminStore = useAdminStore()

const formData = reactive({
  question_text: props.question?.question_text || '',
  topic: props.question?.topic || '',
  exam_id: props.examId || null,
  answer_choices: props.question?.answer_choices?.length > 0 
    ? props.question.answer_choices.map(c => ({ ...c }))
    : [
        { choice_text: '', is_correct: true },
        { choice_text: '', is_correct: false },
        { choice_text: '', is_correct: false },
        { choice_text: '', is_correct: false },
        { choice_text: '', is_correct: false }
      ]
})

const submitting = ref(false)
const error = ref(null)

const addChoice = () => {
  if (formData.answer_choices.length < 6) {
    formData.answer_choices.push({ choice_text: '', is_correct: false })
  }
}

const removeChoice = (index) => {
  if (formData.answer_choices.length > 2) {
    const wasCorrect = formData.answer_choices[index].is_correct
    formData.answer_choices.splice(index, 1)
    
    if (wasCorrect && formData.answer_choices.length > 0) {
      formData.answer_choices[0].is_correct = true
    }
  }
}

const setCorrectAnswer = (index) => {
  formData.answer_choices.forEach((choice, i) => {
    choice.is_correct = i === index
  })
}

const handleSubmit = async () => {
  if (formData.answer_choices.length < 2 || formData.answer_choices.length > 6) {
    error.value = 'You must have between 2 and 6 answer choices'
    return
  }

  const hasCorrect = formData.answer_choices.some(c => c.is_correct)
  if (!hasCorrect) {
    error.value = 'You must select one correct answer'
    return
  }

  const allFilled = formData.answer_choices.every(c => c.choice_text.trim() !== '')
  if (!allFilled) {
    error.value = 'All answer choices must have text'
    return
  }

  submitting.value = true
  error.value = null

  // Prepare data
  const questionData = { ...formData }
  
  // If examId prop is provided (from Exam Detail page), use it
  if (!props.question && props.examId) {
    questionData.exam_id = props.examId
  }
  // Otherwise, use the selected exam_id from the form (could be null)

  const result = props.question
    ? await adminStore.updateQuestion(props.question.id, questionData)
    : await adminStore.createQuestion(questionData)

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
  padding: 16px;
  animation: fadeIn 0.2s ease-out;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

.modal-content {
  background: #FFFFFF;
  border-radius: 16px;
  max-width: 700px;
  width: 100%;
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

.modal-body {
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

.form-group textarea,
.form-group input[type="text"] {
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

.form-group textarea {
  resize: vertical;
  min-height: 100px;
}

.form-group textarea:focus,
.form-group input[type="text"]:focus {
  outline: none;
  border-color: #007AFF;
  box-shadow: 0 0 0 3px rgba(0, 122, 255, 0.1);
}

.form-group textarea::placeholder,
.form-group input[type="text"]::placeholder {
  color: #C7C7CC;
}

.choices-container {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-bottom: 12px;
}

.choice-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 14px;
  background: #F5F5F7;
  border-radius: 10px;
  transition: all 0.2s ease;
}

.choice-item:hover {
  background: #EBEBED;
}

.choice-radio {
  width: 20px;
  height: 20px;
  cursor: pointer;
  accent-color: #007AFF;
  flex-shrink: 0;
}

.choice-input {
  flex: 1;
  padding: 8px 12px !important;
  background: #FFFFFF !important;
  border: 1px solid rgba(0, 0, 0, 0.1) !important;
  border-radius: 8px !important;
}

.choice-input:focus {
  border-color: #007AFF !important;
  box-shadow: 0 0 0 2px rgba(0, 122, 255, 0.1) !important;
}

.btn-remove {
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s ease;
  background: rgba(0, 0, 0, 0.04);
  color: #FF3B30;
  flex-shrink: 0;
}

.btn-remove:hover {
  background: rgba(255, 59, 48, 0.1);
}

.btn-add-choice {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  width: 100%;
  padding: 12px 14px;
  background: rgba(0, 122, 255, 0.1);
  border: none;
  border-radius: 10px;
  color: #007AFF;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  letter-spacing: -0.01em;
}

.btn-add-choice:hover {
  background: rgba(0, 122, 255, 0.15);
}

.hint {
  margin-top: 8px;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 13px;
  color: #86868B;
  letter-spacing: -0.01em;
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
  display: flex;
  align-items: center;
  justify-content: center;
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

.btn-secondary:hover {
  background: rgba(0, 0, 0, 0.08);
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

@media (max-width: 768px) {
  .modal-content {
    max-height: 95vh;
  }
  
  .modal-header,
  .modal-body {
    padding: 20px;
  }
  
  .modal-actions {
    flex-direction: column;
  }
}
</style>
