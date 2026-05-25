<template>
  <div class="exam-detail">
    <!-- Loading State -->
    <div v-if="loading" class="loading">
      <div class="loading-rings">
        <div class="ring"></div>
        <div class="ring"></div>
        <div class="ring"></div>
      </div>
      <p>Loading exam...</p>
    </div>

    <div v-else-if="exam" class="exam-container">
      <!-- Exam Header -->
      <div class="exam-header">
        <div class="header-top">
          <button @click="goBack" class="btn-back">
            <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
              <path d="M12 4L6 10L12 16" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            Back
          </button>
          <button @click="showEditModal = true" class="btn-edit">
            <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
              <path d="M8 3H3C2.44772 3 2 3.44772 2 4V15C2 15.5523 2.44772 16 3 16H14C14.5523 16 15 15.5523 15 15V10" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
              <path d="M16 2L9 9L7 10L8 8L15 1C15.5523 0.447715 16.4477 0.447715 17 1C17.5523 1.55228 17.5523 2.44772 17 3L16 2Z" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            Edit
          </button>
        </div>

        <div class="exam-info">
          <h1 class="exam-title">{{ exam.title }}</h1>
          <div class="exam-meta">
            <span class="category-badge">{{ exam.category }}</span>
            <span class="meta-item">
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                <circle cx="8" cy="8" r="6" stroke="currentColor" stroke-width="1.5"/>
                <path d="M8 4V8L11 11" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
              </svg>
              {{ exam.time_limit_minutes }} min
            </span>
            <span class="meta-item">
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                <path d="M8 2V8L11 11" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M14 8C14 11.3137 11.3137 14 8 14C4.68629 14 2 11.3137 2 8C2 4.68629 4.68629 2 8 2" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
              </svg>
              {{ exam.max_attempts }} attempts
            </span>
            <span class="meta-item">
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                <rect x="3" y="3" width="10" height="10" rx="2" stroke="currentColor" stroke-width="1.5"/>
                <path d="M6 7H10M6 10H8" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
              </svg>
              {{ questions.length }} questions
            </span>
          </div>
          <p v-if="exam.description" class="exam-description">{{ exam.description }}</p>
        </div>
      </div>

      <!-- Questions Section -->
      <div class="questions-section">
        <div class="section-header">
          <h2>Questions</h2>
          <div class="header-actions">
            <button 
              @click="showImportModal = true" 
              class="btn-import"
            >
              <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
                <path d="M9 13V5M9 5L6 8M9 5L12 8" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M3 13V14C3 15.1046 3.89543 16 5 16H13C14.1046 16 15 15.1046 15 14V13" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
              </svg>
              Import
            </button>
            <button 
              @click="showBulkAddModal = true" 
              class="btn-add"
            >
              <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
                <path d="M9 4V14M4 9H14" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
              </svg>
              Add Questions
            </button>
          </div>
        </div>

        <!-- Empty State -->
        <div v-if="questions.length === 0" class="empty-state">
          <div class="empty-icon">
            <svg width="80" height="80" viewBox="0 0 80 80" fill="none">
              <rect x="15" y="15" width="50" height="50" rx="8" stroke="#C7C7CC" stroke-width="2"/>
              <path d="M30 35H50M30 45H42" stroke="#C7C7CC" stroke-width="2" stroke-linecap="round"/>
            </svg>
          </div>
          <h3 class="empty-title">No Questions Yet</h3>
          <p class="empty-text">Start building your exam by adding questions</p>
          <button @click="showBulkAddModal = true" class="btn-cta">
            <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
              <path d="M9 4V14M4 9H14" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
            </svg>
            Add First Question
          </button>
        </div>

        <!-- Questions List -->
        <div v-else class="questions-list">
          <div 
            v-for="(question, index) in questions" 
            :key="question.id"
            class="question-card"
          >
            <!-- Editable Question Form (for new questions) -->
            <div v-if="question.isEditing" class="inline-question-form">
              <div class="form-header">
                <div class="question-number">{{ index + 1 }}</div>
                <div class="form-actions">
                  <button @click="cancelInlineQuestion(index)" class="btn-cancel-inline">
                    <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
                      <path d="M13 5L5 13M5 5L13 13" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                    </svg>
                  </button>
                </div>
              </div>

              <div class="form-body">
                <div class="form-group">
                  <label>Question</label>
                  <textarea 
                    v-model="question.question_text" 
                    rows="3" 
                    placeholder="Enter your question here..."
                  ></textarea>
                </div>

                <div class="form-group">
                  <label>Answer Choices</label>
                  <div class="choices-editor">
                    <div 
                      v-for="(choice, cIndex) in question.answer_choices" 
                      :key="cIndex"
                      class="choice-editor"
                      :class="{ 'is-correct': choice.is_correct }"
                      @click="updateChoice(question, cIndex, 'is_correct', true)"
                    >
                      <div class="choice-letter-badge">{{ String.fromCharCode(65 + cIndex) }}</div>
                      <input 
                        type="text" 
                        v-model="choice.choice_text"
                        :placeholder="`Choice ${String.fromCharCode(65 + cIndex)}`"
                        class="choice-input"
                        @click.stop
                      />
                      <div v-if="choice.is_correct" class="correct-indicator">
                        <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                          <path d="M13 4L6 11L3 8" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                        </svg>
                      </div>
                      <button 
                        v-if="question.answer_choices.length > 2"
                        @click.stop="removeChoice(question, cIndex)" 
                        class="btn-remove-choice"
                      >
                        <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                          <path d="M12 4L4 12M4 4L12 12" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
                        </svg>
                      </button>
                    </div>
                    <button 
                      v-if="question.answer_choices.length < 6"
                      @click="addChoice(question)" 
                      class="btn-add-choice"
                    >
                      <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
                        <path d="M8 3V13M3 8H13" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
                      </svg>
                      Add Choice
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <!-- Regular Question Display (for saved questions) -->
            <template v-else>
              <div class="question-header">
                <div class="question-number">{{ index + 1 }}</div>
                <div class="question-actions">
                  <button @click="editQuestion(question)" class="btn-icon btn-icon-edit">
                    <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
                      <path d="M8 3H3C2.44772 3 2 3.44772 2 4V15C2 15.5523 2.44772 16 3 16H14C14.5523 16 15 15.5523 15 15V10" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
                      <path d="M16 2L9 9L7 10L8 8L15 1C15.5523 0.447715 16.4477 0.447715 17 1C17.5523 1.55228 17.5523 2.44772 17 3L16 2Z" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                  </button>
                  <button @click="deleteQuestionConfirm(question)" class="btn-icon btn-icon-delete">
                    <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
                      <path d="M3 5H15M7 8V13M11 8V13M13 5V15C13 15.5523 12.5523 16 12 16H6C5.44772 16 5 15.5523 5 15V5M8 5V3C8 2.44772 8.44772 2 9 2H9C9.55228 2 10 2.44772 10 3V5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
                    </svg>
                  </button>
                </div>
              </div>
              <div class="question-content">
                <p class="question-text">{{ question.question_text }}</p>
                <div class="choices-list">
                  <div 
                    v-for="(choice, cIndex) in question.answer_choices" 
                    :key="cIndex"
                    class="choice-item"
                    :class="{ correct: choice.is_correct }"
                  >
                    <span class="choice-letter">{{ String.fromCharCode(65 + cIndex) }}</span>
                    <span class="choice-text">{{ choice.choice_text }}</span>
                    <span v-if="choice.is_correct" class="correct-badge">
                      <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
                        <path d="M11 4L5.5 9.5L3 7" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                      </svg>
                    </span>
                  </div>
                </div>
              </div>
            </template>
          </div>
        </div>

        <!-- Save All Button (only show if there are new questions) -->
        <div v-if="hasNewQuestions" class="save-all-container">
          <button @click="saveAllNewQuestions" class="btn-save-all" :disabled="savingAll">
            <div v-if="savingAll" class="loading-spinner-small"></div>
            <template v-else>
              <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                <path d="M16 6L8 14L4 10" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
              <span>Save All Questions ({{ newQuestionsCount }})</span>
            </template>
          </button>
        </div>
      </div>
    </div>

    <!-- Edit Exam Modal -->
    <ExamForm
      v-if="showEditModal"
      :exam="exam"
      @close="showEditModal = false"
      @save="handleExamUpdated"
    />

    <!-- Bulk Add Questions Modal -->
    <div v-if="showBulkAddModal" class="modal-overlay">
      <div class="bulk-modal">
        <div class="modal-header">
          <h2>Add Questions</h2>
          <button type="button" @click="showBulkAddModal = false" class="close-btn">
            <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
              <path d="M15 5L5 15M5 5L15 15" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
            </svg>
          </button>
        </div>

        <div class="bulk-content">
          <div class="form-group">
            <label>Question Type</label>
            <select v-model="bulkType">
              <option value="multiple_choice">Multiple Choice</option>
              <option value="identification">Identification</option>
            </select>
          </div>

          <div class="form-group">
            <label>Number of Questions</label>
            <input v-model.number="bulkQuantity" type="number" min="1" max="1000" placeholder="Enter quantity" />
            <p class="hint">You can add up to 1000 questions per exam</p>
          </div>

          <div class="modal-actions">
            <button @click="showBulkAddModal = false" class="btn-secondary">
              Cancel
            </button>
            <button @click="handleBulkAdd" class="btn-primary" :disabled="bulkQuantity < 1 || bulkQuantity > (100 - questions.length)">
              Add {{ bulkQuantity }} Question{{ bulkQuantity !== 1 ? 's' : '' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Import from Text Modal -->
    <div v-if="showImportModal" class="modal-overlay">
      <div class="import-modal">
        <div class="modal-header">
          <h2>Import Questions</h2>
          <button type="button" @click="showImportModal = false" class="close-btn">
            <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
              <path d="M15 5L5 15M5 5L15 15" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
            </svg>
          </button>
        </div>

        <div class="import-content">
          <!-- Import Method Tabs -->
          <div class="import-tabs">
            <button 
              @click="importMethod = 'text'" 
              class="import-tab"
              :class="{ active: importMethod === 'text' }"
            >
              <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
                <path d="M3 3H15M3 7H15M3 11H10M3 15H10" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
              </svg>
              Paste Text
            </button>
            <button 
              @click="importMethod = 'docx'" 
              class="import-tab"
              :class="{ active: importMethod === 'docx' }"
            >
              <svg width="18" height="18" viewBox="0 0 18 18" fill="none">
                <path d="M10 2H4C3.44772 2 3 2.44772 3 3V15C3 15.5523 3.44772 16 4 16H14C14.5523 16 15 15.5523 15 15V7L10 2Z" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M10 2V7H15" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
              Upload Word Doc
            </button>
          </div>

          <!-- Text Import Method -->
          <div v-if="importMethod === 'text'" class="import-method-content">
            <div class="import-instructions">
              <h3>Format Guide:</h3>
              <div class="format-example-grid">
                <div class="format-col">
                  <strong>Questions:</strong>
                  <pre class="format-example">1. Question text?
a. Choice one
b. Choice two
c. Choice three
d. Choice four

2. Another question?
a. Choice A
b. Choice B
c. Choice C
d. Choice D</pre>
                </div>
                <div class="format-col">
                  <strong>Answer Key:</strong>
                  <pre class="format-example">1. c
2. b
3. a
4. d
5. c
...</pre>
                </div>
              </div>
              <p class="hint">Paste questions on the left and answer key on the right</p>
            </div>

            <div class="import-dual-input">
              <div class="form-group">
                <label>Questions</label>
                <textarea 
                  v-model="importText" 
                  rows="15" 
                  placeholder="Paste questions here..."
                  class="import-textarea"
                ></textarea>
              </div>

              <div class="form-group">
                <label>Answer Key</label>
                <textarea 
                  v-model="answerKeyText" 
                  rows="15" 
                  placeholder="Paste answer key here (e.g., 1. c, 2. b, 3. a...)"
                  class="import-textarea"
                ></textarea>
              </div>
            </div>

            <div v-if="importError" class="error-message">
              {{ importError }}
            </div>

            <div v-if="showJsonPreview" class="json-preview">
              <h4>Parsed JSON Preview:</h4>
              <pre class="json-content">{{ parsedJson }}</pre>
            </div>

            <div class="modal-actions">
              <button @click="showImportModal = false" class="btn-secondary">
                Cancel
              </button>
              <button @click="previewJson" class="btn-secondary" :disabled="!importText.trim()">
                Preview JSON
              </button>
              <button @click="handleImport" class="btn-primary" :disabled="!importText.trim() || importing">
                <span v-if="!importing">Import Questions</span>
                <div v-else class="loading-spinner-small"></div>
              </button>
            </div>
          </div>

          <!-- Word Document Import Method -->
          <div v-if="importMethod === 'docx'" class="import-method-content">
            <div class="import-instructions">
              <h3>Upload Document (.docx or .pdf)</h3>
              <p class="hint">The system will automatically detect highlighted text as correct answers. You can also include an answer key table at the bottom of the document.</p>
              <p class="hint">For PDF files: The system will extract text and use the same AI parsing as DOCX files.</p>
            </div>

            <div class="file-upload-area">
              <input 
                type="file" 
                ref="fileInput"
                @change="handleFileSelect"
                accept=".docx,.pdf"
                class="file-input"
                id="docx-upload"
              />
              <label for="docx-upload" class="file-upload-label">
                <div class="upload-icon">
                  <svg width="48" height="48" viewBox="0 0 48 48" fill="none">
                    <path d="M24 32V16M24 16L18 22M24 16L30 22" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M12 32V36C12 38.2091 13.7909 40 16 40H32C34.2091 40 36 38.2091 36 36V32" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                  </svg>
                </div>
                <div class="upload-text">
                  <span v-if="!selectedFile" class="upload-prompt">Click to upload or drag and drop</span>
                  <span v-else class="upload-filename">{{ selectedFile.name }}</span>
                  <span class="upload-hint">Word Document (.docx) or PDF (.pdf)</span>
                </div>
              </label>
            </div>

            <div v-if="importError" class="error-message">
              {{ importError }}
            </div>

            <div v-if="uploadProgress > 0 && uploadProgress < 100" class="upload-progress">
              <div class="progress-info">
                <span class="progress-label">
                  <span v-if="uploadProgress <= 5">🤖 AI is analyzing your document...</span>
                  <span v-else>📝 Processing Questions...</span>
                </span>
                <span class="progress-count">{{ importedQuestionsCount }} / {{ estimatedTotalQuestions }}</span>
              </div>
              <div class="progress-bar">
                <div class="progress-fill" :style="{ width: uploadProgress + '%' }"></div>
              </div>
              <div class="progress-details">
                <span class="progress-text">{{ Math.round(uploadProgress) }}%</span>
                <span v-if="uploadProgress <= 5" class="progress-hint">
                  ⏱️ Large files may take 30-60 minutes. Please wait...
                </span>
                <span v-else class="progress-hint">✨ Detecting correct answers from bold/highlighted text</span>
              </div>
            </div>

            <div class="modal-actions">
              <button @click="showImportModal = false" class="btn-secondary" :disabled="importing">
                Cancel
              </button>
              <button @click="handleDocxImport" class="btn-primary" :disabled="!selectedFile || importing">
                <span v-if="!importing">Import from Document</span>
                <div v-else class="loading-spinner-small"></div>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Add/Edit Question Modal -->
    <QuestionForm
      v-if="showAddQuestionModal || showEditQuestionModal"
      :question="selectedQuestion"
      :examId="examId"
      @close="closeQuestionModals"
      @save="handleQuestionSaved"
    />

    <!-- Delete Confirmation Modal -->
    <div v-if="showDeleteConfirm" class="modal-overlay">
      <div class="confirmation-modal">
        <div class="confirmation-icon delete-icon">
          <svg width="48" height="48" viewBox="0 0 48 48" fill="none">
            <path d="M12 16H36M20 22V32M28 22V32M30 16V12C30 10.8954 29.1046 10 28 10H20C18.8954 10 18 10.8954 18 12V16M14 16L16 36C16 37.1046 16.8954 38 18 38H30C31.1046 38 32 37.1046 32 36L34 16" stroke="#FF3B30" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
        </div>
        
        <h3>Delete Question?</h3>
        <p>Are you sure you want to delete this question? This action cannot be undone.</p>
        
        <div class="confirmation-actions">
          <button @click="cancelDelete" class="btn-cancel" :disabled="deleting">
            Cancel
          </button>
          <button @click="confirmDelete" class="btn-confirm btn-delete" :disabled="deleting">
            <span v-if="!deleting">Delete</span>
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
      <span>{{ notificationMessage }}</span>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAdminStore } from '@/stores/admin'
import ExamForm from '@/components/admin/ExamForm.vue'
import QuestionForm from '@/components/admin/QuestionForm.vue'

const AUTH_TOKEN_KEY = 'auth_token'

const route = useRoute()
const router = useRouter()
const adminStore = useAdminStore()

const examId = ref(route.params.id)
const exam = ref(null)
const questions = ref([])
const loading = ref(false)
const showEditModal = ref(false)
const showAddQuestionModal = ref(false)
const showEditQuestionModal = ref(false)
const showBulkAddModal = ref(false)
const showImportModal = ref(false)
const showDeleteConfirm = ref(false)
const showNotification = ref(false)
const savingAll = ref(false)
const importing = ref(false)
const selectedQuestion = ref(null)
const questionToDelete = ref(null)
const notificationMessage = ref('')
const importText = ref('')
const answerKeyText = ref('')
const importError = ref('')
const showJsonPreview = ref(false)
const parsedJson = ref('')
const importMethod = ref('text')
const selectedFile = ref(null)
const fileInput = ref(null)
const uploadProgress = ref(0)
const importedQuestionsCount = ref(0)
const estimatedTotalQuestions = ref(100)

const hasNewQuestions = computed(() => {
  return questions.value.some(q => q.isNew === true)
})

const newQuestionsCount = computed(() => {
  return questions.value.filter(q => q.isNew === true).length
})

const deleting = ref(false)

// Bulk add state
const bulkType = ref('multiple_choice')
const bulkQuantity = ref(1)

onMounted(async () => {
  await loadExamData()
})

const loadExamData = async () => {
  loading.value = true
  const result = await adminStore.getExam(examId.value)
  if (result.success) {
    exam.value = result.data.exam || result.data
    questions.value = exam.value.questions || []
    console.log('Loaded exam data:', exam.value)
    console.log('Questions count:', questions.value.length)
  }
  loading.value = false
}

const goBack = () => {
  router.push({ name: 'admin-exams' })
}

const previewJson = () => {
  importError.value = ''
  showJsonPreview.value = false
  
  try {
    const parsedQuestions = parseImportText(importText.value, answerKeyText.value)
    
    if (parsedQuestions.length === 0) {
      importError.value = 'No valid questions found. Please check the format.'
      return
    }
    
    parsedJson.value = JSON.stringify(parsedQuestions, null, 2)
    showJsonPreview.value = true
  } catch (error) {
    importError.value = 'Failed to parse questions: ' + error.message
  }
}

const formatText = () => {
  importError.value = ''
  showJsonPreview.value = false
  
  try {
    const parsedQuestions = parseImportText(importText.value, answerKeyText.value)
    
    if (parsedQuestions.length === 0) {
      importError.value = 'No valid questions found. Please check the format.'
      return
    }
    
    // Format the questions into clean text
    let formattedText = ''
    parsedQuestions.forEach((q, index) => {
      formattedText += `${index + 1}. ${q.question_text}\n`
      q.answer_choices.forEach((choice, cIndex) => {
        const letter = String.fromCharCode(97 + cIndex) // a, b, c, d...
        const marker = choice.is_correct ? '*' : ''
        formattedText += `${letter}. ${choice.choice_text}${marker}\n`
      })
      formattedText += '\n'
    })
    
    // Update the textarea with formatted text
    importText.value = formattedText.trim()
    
    notificationMessage.value = `Formatted ${parsedQuestions.length} questions successfully!`
    showNotification.value = true
    setTimeout(() => {
      showNotification.value = false
    }, 3000)
  } catch (error) {
    importError.value = 'Failed to format questions: ' + error.message
  }
}

const handleImport = async () => {
  importError.value = ''
  
  if (!importText.value.trim()) {
    importError.value = 'Please paste some text to import'
    return
  }
  
  importing.value = true
  
  try {
    // Parse the text into questions
    const parsedQuestions = parseImportText(importText.value, answerKeyText.value)
    
    console.log('Parsed questions:', parsedQuestions)
    
    if (parsedQuestions.length === 0) {
      importError.value = 'No valid questions found. Please check the format.'
      importing.value = false
      return
    }
    
    // Save all parsed questions
    let successCount = 0
    let failCount = 0
    
    for (const question of parsedQuestions) {
      const data = {
        question_text: question.question_text,
        answer_choices: question.answer_choices,
        exam_id: examId.value
      }
      
      const result = await adminStore.createQuestion(data)
      
      if (result.success) {
        successCount++
      } else {
        failCount++
      }
    }
    
    if (successCount > 0) {
      notificationMessage.value = `${successCount} question(s) imported successfully!`
      showNotification.value = true
      
      setTimeout(() => {
        showNotification.value = false
      }, 3000)
      
      // Close modal and reload
      showImportModal.value = false
      importText.value = ''
      await loadExamData()
    }
    
    if (failCount > 0) {
      importError.value = `${failCount} question(s) failed to import`
    }
  } catch (error) {
    importError.value = 'Failed to parse questions. Please check the format.'
  } finally {
    importing.value = false
  }
}

const parseImportText = (text, answerKey) => {
  const questions = []
  
  // Parse answer key first (format: "1. c" or "1.c" or "1) c")
  const answerMap = {}
  if (answerKey) {
    const answerLines = answerKey.split('\n').filter(l => l.trim())
    for (const line of answerLines) {
      const match = line.match(/(\d+)[\.\)]\s*([a-z])/i)
      if (match) {
        answerMap[parseInt(match[1])] = match[2].toLowerCase()
      }
    }
  }
  
  // Split by question numbers to get each question block
  const questionBlocks = text.split(/(?=^\d+\.\s)/m).filter(b => b.trim())
  
  for (const block of questionBlocks) {
    const lines = block.split('\n').map(l => l.trim()).filter(l => l)
    if (lines.length === 0) continue
    
    // First line should be the question
    const firstLine = lines[0]
    const questionMatch = firstLine.match(/^(\d+)\.\s*(.+)/)
    if (!questionMatch) continue
    
    const questionNum = parseInt(questionMatch[1])
    let questionText = questionMatch[2]
    
    // Check if choices are inline on the same line as question
    // Look for pattern like "a. text" with lots of spaces before it
    const hasInlineChoices = /\s{2,}[a-z]\.\s+/i.test(questionText)
    
    const choices = []
    
    if (hasInlineChoices) {
      // For inline format with excessive spacing (Word document format)
      // Split by multiple spaces followed by letter and dot
      const parts = questionText.split(/\s{2,}([a-z])\.\s+/i)
      
      // First part is the question text
      questionText = parts[0].trim()
      
      // Process remaining parts as choices (letter, text, letter, text...)
      for (let i = 1; i < parts.length; i += 2) {
        if (i + 1 < parts.length) {
          const letter = parts[i].toLowerCase()
          let choiceText = parts[i + 1].trim()
          
          // Clean up the choice text - remove excessive spaces and trailing content
          choiceText = choiceText.replace(/\s{2,}/g, ' ').trim()
          
          const correctLetter = answerMap[questionNum]
          const isCorrect = (letter === correctLetter)
          
          if (choiceText) {
            choices.push({
              choice_text: choiceText,
              is_correct: isCorrect
            })
          }
        }
      }
    } else {
      // Choices are on separate lines
      // Process remaining lines as choices
      for (let i = 1; i < lines.length; i++) {
        const line = lines[i]
        const choiceMatch = line.match(/^([a-z])\.\s*(.+)/i)
        
        if (choiceMatch) {
          const letter = choiceMatch[1].toLowerCase()
          const choiceText = choiceMatch[2].trim()
          
          const correctLetter = answerMap[questionNum]
          const isCorrect = (letter === correctLetter)
          
          if (choiceText) {
            choices.push({
              choice_text: choiceText,
              is_correct: isCorrect
            })
          }
        } else {
          // Append to question text if not a choice
          questionText += ' ' + line
        }
      }
    }
    
    if (questionText && choices.length >= 2) {
      questions.push({
        question_text: questionText,
        answer_choices: choices
      })
    }
  }
  
  return questions
}

const editQuestion = (question) => {
  selectedQuestion.value = { ...question }
  showEditQuestionModal.value = true
}

const deleteQuestionConfirm = (question) => {
  questionToDelete.value = question
  showDeleteConfirm.value = true
}

const cancelDelete = () => {
  if (!deleting.value) {
    showDeleteConfirm.value = false
    questionToDelete.value = null
  }
}

const confirmDelete = async () => {
  deleting.value = true
  const result = await adminStore.deleteQuestion(questionToDelete.value.id)
  deleting.value = false
  
  if (result.success) {
    showDeleteConfirm.value = false
    questionToDelete.value = null
    notificationMessage.value = 'Question deleted successfully!'
    showNotification.value = true
    
    setTimeout(() => {
      showNotification.value = false
    }, 3000)
    
    await loadExamData()
  } else {
    alert(result.error)
  }
}

const handleBulkAdd = () => {
  // Close the bulk modal
  showBulkAddModal.value = false
  
  // Create empty question slots based on quantity
  const newQuestions = []
  for (let i = 0; i < bulkQuantity.value; i++) {
    newQuestions.push({
      id: `temp-${Date.now()}-${i}`,
      question_text: '',
      answer_choices: bulkType.value === 'multiple_choice' 
        ? [
            { choice_text: '', is_correct: true },
            { choice_text: '', is_correct: false },
            { choice_text: '', is_correct: false },
            { choice_text: '', is_correct: false },
            { choice_text: '', is_correct: false }
          ]
        : [{ choice_text: '', is_correct: true }],
      type: bulkType.value,
      isNew: true,
      isEditing: true
    })
  }
  
  // Add to questions array
  questions.value = [...questions.value, ...newQuestions]
  
  // Reset bulk values
  bulkQuantity.value = 1
  bulkType.value = 'multiple_choice'
  
  // Scroll to bottom to show new questions
  setTimeout(() => {
    window.scrollTo({ top: document.body.scrollHeight, behavior: 'smooth' })
  }, 100)
}

const closeQuestionModals = () => {
  showAddQuestionModal.value = false
  showEditQuestionModal.value = false
  selectedQuestion.value = null
}

const handleQuestionSaved = async () => {
  closeQuestionModals()
  notificationMessage.value = selectedQuestion.value ? 'Question updated successfully!' : 'Question added successfully!'
  showNotification.value = true
  
  setTimeout(() => {
    showNotification.value = false
  }, 3000)
  
  await loadExamData()
}

const handleExamUpdated = async () => {
  showEditModal.value = false
  notificationMessage.value = 'Exam updated successfully!'
  showNotification.value = true
  
  setTimeout(() => {
    showNotification.value = false
  }, 3000)
  
  await loadExamData()
}

const saveAllNewQuestions = async () => {
  // Get only NEW questions (not already saved)
  const newQuestions = questions.value.filter(q => q.isNew === true)
  
  if (newQuestions.length === 0) {
    return
  }
  
  // Validate all new questions
  for (let i = 0; i < newQuestions.length; i++) {
    const question = newQuestions[i]
    
    if (!question.question_text.trim()) {
      alert(`Question ${questions.value.indexOf(question) + 1}: Please enter a question`)
      return
    }
    
    const hasValidChoice = question.answer_choices.some(c => c.choice_text.trim())
    if (!hasValidChoice) {
      alert(`Question ${questions.value.indexOf(question) + 1}: Please add at least one answer choice`)
      return
    }
    
    if (question.type === 'multiple_choice') {
      const hasCorrect = question.answer_choices.some(c => c.is_correct)
      if (!hasCorrect) {
        alert(`Question ${questions.value.indexOf(question) + 1}: Please mark at least one answer as correct`)
        return
      }
    }
  }
  
  savingAll.value = true
  
  try {
    // Save all new questions
    let successCount = 0
    let failCount = 0
    
    for (const question of newQuestions) {
      const data = {
        question_text: question.question_text,
        answer_choices: question.answer_choices.filter(c => c.choice_text.trim()),
        exam_id: examId.value
      }
      
      const result = await adminStore.createQuestion(data)
      
      if (result.success) {
        successCount++
        // Mark as saved (remove isNew flag)
        question.isNew = false
        question.isEditing = false
      } else {
        failCount++
      }
    }
    
    if (successCount > 0) {
      notificationMessage.value = `${successCount} question(s) saved successfully!`
      showNotification.value = true
      
      setTimeout(() => {
        showNotification.value = false
      }, 3000)
      
      // Reload to get fresh data from backend
      await loadExamData()
    }
    
    if (failCount > 0) {
      alert(`${failCount} question(s) failed to save. Please try again.`)
    }
  } finally {
    savingAll.value = false
  }
}

const saveInlineQuestion = async (question, index) => {
  // Validate question
  if (!question.question_text.trim()) {
    alert('Please enter a question')
    return
  }
  
  const hasValidChoice = question.answer_choices.some(c => c.choice_text.trim())
  if (!hasValidChoice) {
    alert('Please add at least one answer choice')
    return
  }
  
  if (question.type === 'multiple_choice') {
    const hasCorrect = question.answer_choices.some(c => c.is_correct)
    if (!hasCorrect) {
      alert('Please mark at least one answer as correct')
      return
    }
  }
  
  // Save to backend
  const data = {
    question_text: question.question_text,
    answer_choices: question.answer_choices.filter(c => c.choice_text.trim()),
    exam_id: examId.value
  }
  
  const result = await adminStore.createQuestion(data)
  
  if (result.success) {
    notificationMessage.value = 'Question added successfully!'
    showNotification.value = true
    
    setTimeout(() => {
      showNotification.value = false
    }, 3000)
    
    await loadExamData()
  } else {
    alert(result.error || 'Failed to save question')
  }
}

const cancelInlineQuestion = (index) => {
  questions.value.splice(index, 1)
}

const updateChoice = (question, choiceIndex, field, value) => {
  if (field === 'is_correct' && value === true) {
    // For radio buttons: set all choices to false first, then set the selected one to true
    question.answer_choices.forEach((choice, index) => {
      choice.is_correct = (index === choiceIndex)
    })
  } else {
    question.answer_choices[choiceIndex][field] = value
  }
}

const addChoice = (question) => {
  if (question.answer_choices.length < 6) {
    question.answer_choices.push({ choice_text: '', is_correct: false })
  }
}

const removeChoice = (question, choiceIndex) => {
  if (question.answer_choices.length > 2) {
    question.answer_choices.splice(choiceIndex, 1)
  }
}

const handleFileSelect = (event) => {
  const file = event.target.files[0]
  if (file && (file.name.endsWith('.docx') || file.name.endsWith('.pdf'))) {
    selectedFile.value = file
    importError.value = ''
  } else {
    importError.value = 'Please select a valid .docx or .pdf file'
    selectedFile.value = null
  }
}

const handleDocxImport = async () => {
  if (!selectedFile.value) {
    importError.value = 'Please select a file first'
    return
  }

  importing.value = true
  importError.value = ''
  uploadProgress.value = 0
  importedQuestionsCount.value = 0
  estimatedTotalQuestions.value = 100 // Default estimate

  // Get initial question count
  const initialCount = questions.value.length
  let pollInterval = null

  try {
    // Create FormData to send the file
    const formData = new FormData()
    formData.append('file', selectedFile.value)
    formData.append('exam_id', examId.value)

    // Start progress at 1%
    uploadProgress.value = 1
    
    // Start polling for question count updates
    pollInterval = setInterval(async () => {
      try {
        const result = await adminStore.getExam(examId.value)
        if (result.success) {
          const currentCount = (result.data.exam || result.data).questions?.length || 0
          const newQuestions = currentCount - initialCount
          
          // Update imported count
          importedQuestionsCount.value = newQuestions
          
          // Calculate progress: (newQuestions / estimatedTotal) * 95%
          // Reserve 5% for completion
          const progressPercent = Math.min(95, (newQuestions / estimatedTotalQuestions.value) * 95)
          uploadProgress.value = Math.max(uploadProgress.value, progressPercent)
          
          // Update questions list in real-time
          questions.value = (result.data.exam || result.data).questions || []
          
          console.log(`Progress: ${Math.round(uploadProgress.value)}% - ${newQuestions} questions added (${importedQuestionsCount.value}/${estimatedTotalQuestions.value})`)
        }
      } catch (error) {
        console.error('Polling error:', error)
      }
    }, 2000) // Poll every 2 seconds (balanced: smooth progress without rate limiting)
    
    
    // Upload the file to backend for parsing and saving
    const apiBaseUrl = import.meta.env.VITE_API_URL || 'http://127.0.0.1:8000/api'
    const authToken = localStorage.getItem(AUTH_TOKEN_KEY)
    const headers = authToken ? { Authorization: `Bearer ${authToken}` } : {}

    const response = await fetch(`${apiBaseUrl}/admin/questions/import-docx`, {
      method: 'POST',
      credentials: 'include',
      headers,
      body: formData
    })

    // Stop polling
    clearInterval(pollInterval)

    const result = await response.json()

    if (result.success) {
      uploadProgress.value = 100
      
      // Final reload to ensure we have all questions
      await loadExamData()
      
      // Update final count
      importedQuestionsCount.value = result.count
      
      notificationMessage.value = `${result.count} questions imported successfully!`
      showNotification.value = true
      
      setTimeout(() => {
        showNotification.value = false
      }, 3000)
      
      // Close modal and reset after a short delay to show 100%
      setTimeout(() => {
        showImportModal.value = false
        selectedFile.value = null
        uploadProgress.value = 0
        importedQuestionsCount.value = 0
      }, 1000)
    } else {
      importError.value = result.message || 'Failed to import document'
    }
  } catch (error) {
    console.error('Import error:', error)
    importError.value = 'Failed to upload file: ' + error.message
  } finally {
    if (pollInterval) {
      clearInterval(pollInterval)
    }
    importing.value = false
  }
}
</script>

<style scoped>
.exam-detail {
  padding: 24px;
  max-width: 1200px;
  margin: 0 auto;
  background: #F5F5F7;
  min-height: 100vh;
  position: relative;
}

/* Loading State */
.loading {
  text-align: center;
  padding: 80px 24px;
}

.loading-rings {
  width: 60px;
  height: 60px;
  margin: 0 auto 24px;
  position: relative;
}

.ring {
  position: absolute;
  width: 100%;
  height: 100%;
  border: 3px solid transparent;
  border-radius: 50%;
  animation: rotate 1.5s cubic-bezier(0.5, 0, 0.5, 1) infinite;
}

.ring:nth-child(1) {
  border-top-color: #007AFF;
  animation-delay: -0.45s;
}

.ring:nth-child(2) {
  border-top-color: #34C759;
  animation-delay: -0.3s;
}

.ring:nth-child(3) {
  border-top-color: #FF9500;
  animation-delay: -0.15s;
}

@keyframes rotate {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.loading p {
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 15px;
  color: #86868B;
  letter-spacing: -0.01em;
}


/* Exam Header */
.exam-header {
  background: #FFFFFF;
  border-radius: 16px;
  padding: 24px;
  margin-bottom: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.header-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.btn-back {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 14px;
  background: rgba(0, 0, 0, 0.04);
  border: none;
  border-radius: 8px;
  color: #007AFF;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 15px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  letter-spacing: -0.01em;
}

.btn-back:hover {
  background: rgba(0, 0, 0, 0.08);
}

.btn-edit {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 14px;
  background: #007AFF;
  border: none;
  border-radius: 8px;
  color: #FFFFFF;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 15px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  letter-spacing: -0.01em;
}

.btn-edit:hover {
  background: #0051D5;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 122, 255, 0.3);
}

.exam-info {
  margin-top: 8px;
}

.exam-title {
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', sans-serif;
  font-size: 32px;
  font-weight: 700;
  color: #1D1D1F;
  margin: 0 0 16px 0;
  letter-spacing: -0.03em;
  line-height: 1.2;
}

.exam-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-bottom: 12px;
}

.category-badge {
  display: inline-flex;
  align-items: center;
  padding: 6px 12px;
  background: rgba(0, 122, 255, 0.1);
  color: #007AFF;
  border-radius: 8px;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 13px;
  font-weight: 600;
  letter-spacing: -0.01em;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 14px;
  color: #86868B;
  letter-spacing: -0.01em;
}

.meta-item svg {
  color: #C7C7CC;
}

.exam-description {
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 15px;
  color: #86868B;
  line-height: 1.5;
  margin: 0;
  letter-spacing: -0.01em;
}


/* Questions Section */
.questions-section {
  margin-top: 24px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.section-header h2 {
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', sans-serif;
  font-size: 24px;
  font-weight: 700;
  color: #1D1D1F;
  margin: 0;
  letter-spacing: -0.02em;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.btn-import {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 10px 18px;
  background: #FFFFFF;
  border: 1px solid rgba(0, 0, 0, 0.1);
  border-radius: 10px;
  color: #007AFF;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 15px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  letter-spacing: -0.01em;
}

.btn-import:hover {
  background: rgba(0, 122, 255, 0.05);
  border-color: #007AFF;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 122, 255, 0.15);
}

.btn-add {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 10px 18px;
  background: #007AFF;
  border: none;
  border-radius: 10px;
  color: #FFFFFF;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 15px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  letter-spacing: -0.01em;
}

.btn-add:hover:not(:disabled) {
  background: #0051D5;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 122, 255, 0.3);
}

.btn-add:disabled {
  background: #C7C7CC;
  cursor: not-allowed;
  opacity: 0.6;
}

/* Empty State */
.empty-state {
  background: #FFFFFF;
  border-radius: 16px;
  padding: 60px 24px;
  text-align: center;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.empty-icon {
  margin: 0 auto 24px;
  opacity: 0.5;
}

.empty-title {
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', sans-serif;
  font-size: 20px;
  font-weight: 600;
  color: #1D1D1F;
  margin: 0 0 8px 0;
  letter-spacing: -0.02em;
}

.empty-text {
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 15px;
  color: #86868B;
  margin: 0 0 28px 0;
  letter-spacing: -0.01em;
}

.btn-cta {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 12px 24px;
  background: #007AFF;
  border: none;
  border-radius: 10px;
  color: #FFFFFF;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 15px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  letter-spacing: -0.01em;
}

.btn-cta:hover {
  background: #0051D5;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 122, 255, 0.3);
}

/* Questions List */
.questions-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.question-card {
  background: #FFFFFF;
  border-radius: 16px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  transition: all 0.2s ease;
}

.question-card:hover {
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  transform: translateY(-2px);
}

.question-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.question-number {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0, 122, 255, 0.1);
  color: #007AFF;
  border-radius: 50%;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 15px;
  font-weight: 600;
  letter-spacing: -0.01em;
}

.question-actions {
  display: flex;
  gap: 8px;
}

.btn-icon {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
  background: rgba(0, 0, 0, 0.04);
}

.btn-icon-edit {
  color: #007AFF;
}

.btn-icon-edit:hover {
  background: rgba(0, 122, 255, 0.1);
}

.btn-icon-delete {
  color: #FF3B30;
}

.btn-icon-delete:hover {
  background: rgba(255, 59, 48, 0.1);
}

.question-content {
  margin-top: 12px;
}

.question-text {
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 16px;
  font-weight: 500;
  color: #1D1D1F;
  margin: 0 0 16px 0;
  line-height: 1.5;
  letter-spacing: -0.01em;
}

.choices-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
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

.choice-item.correct {
  background: rgba(52, 199, 89, 0.1);
}

.choice-letter {
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #FFFFFF;
  border-radius: 50%;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 13px;
  font-weight: 600;
  color: #86868B;
  flex-shrink: 0;
}

.choice-item.correct .choice-letter {
  background: #34C759;
  color: #FFFFFF;
}

.choice-text {
  flex: 1;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 15px;
  color: #1D1D1F;
  letter-spacing: -0.01em;
}

.correct-badge {
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #34C759;
  border-radius: 50%;
  color: #FFFFFF;
  flex-shrink: 0;
}

/* Bulk Add Modal */
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

.bulk-modal {
  background: #FFFFFF;
  border-radius: 16px;
  max-width: 480px;
  width: 90%;
  overflow: hidden;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
  animation: slideUp 0.3s ease-out;
}

.import-modal {
  background: #FFFFFF;
  border-radius: 16px;
  max-width: 700px;
  width: 90%;
  max-height: 90vh;
  overflow: hidden;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
  animation: slideUp 0.3s ease-out;
  display: flex;
  flex-direction: column;
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

.bulk-content {
  padding: 24px;
}

.import-content {
  padding: 24px;
  overflow-y: auto;
  flex: 1;
}

.import-instructions {
  background: #F5F5F7;
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 20px;
}

.import-instructions h3 {
  margin: 0 0 12px 0;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 14px;
  font-weight: 600;
  color: #1D1D1F;
  letter-spacing: -0.01em;
}

.format-example-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  margin-bottom: 10px;
}

.format-col strong {
  display: block;
  margin-bottom: 6px;
  font-size: 12px;
  color: #1D1D1F;
}

.format-example {
  background: #FFFFFF;
  border: 1px solid rgba(0, 0, 0, 0.1);
  border-radius: 8px;
  padding: 12px;
  margin: 0;
  font-family: 'SF Mono', 'Monaco', 'Consolas', monospace;
  font-size: 11px;
  color: #1D1D1F;
  line-height: 1.6;
  overflow-x: auto;
  white-space: pre;
}

.import-dual-input {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
  margin-bottom: 12px;
}

.import-textarea {
  width: 100%;
  max-width: 100%;
  padding: 12px 14px;
  border: 1px solid rgba(0, 0, 0, 0.15);
  border-radius: 8px;
  font-family: 'SF Mono', 'Monaco', 'Consolas', monospace;
  font-size: 13px;
  color: #1D1D1F;
  background: #FAFAFA;
  transition: all 0.2s ease;
  resize: vertical;
  min-height: 200px;
  box-sizing: border-box;
  line-height: 1.6;
}

.import-textarea:focus {
  outline: none;
  border-color: #007AFF;
  background: #FFFFFF;
  box-shadow: 0 0 0 3px rgba(0, 122, 255, 0.1);
}

.import-textarea::placeholder {
  color: #C7C7CC;
}

.error-message {
  background: rgba(255, 59, 48, 0.1);
  color: #FF3B30;
  padding: 12px 14px;
  border-radius: 8px;
  margin-top: 12px;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 14px;
  font-weight: 500;
  letter-spacing: -0.01em;
}

.json-preview {
  margin-top: 16px;
  padding: 16px;
  background: #F5F5F7;
  border-radius: 8px;
  max-height: 300px;
  overflow-y: auto;
}

.json-preview h4 {
  margin: 0 0 12px 0;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 14px;
  font-weight: 600;
  color: #1D1D1F;
}

.json-content {
  background: #FFFFFF;
  border: 1px solid rgba(0, 0, 0, 0.1);
  border-radius: 6px;
  padding: 12px;
  margin: 0;
  font-family: 'SF Mono', 'Monaco', 'Consolas', monospace;
  font-size: 12px;
  color: #1D1D1F;
  line-height: 1.5;
  overflow-x: auto;
  white-space: pre;
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

.form-group input,
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
.form-group select:focus {
  outline: none;
  border-color: #007AFF;
  box-shadow: 0 0 0 3px rgba(0, 122, 255, 0.1);
}

.form-group select {
  cursor: pointer;
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg width='12' height='8' viewBox='0 0 12 8' fill='none' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M1 1.5L6 6.5L11 1.5' stroke='%2386868B' stroke-width='1.5' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 14px center;
  padding-right: 40px;
}

.hint {
  margin-top: 6px;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 13px;
  color: #86868B;
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

.btn-primary:hover:not(:disabled) {
  background: #0051D5;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 122, 255, 0.3);
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
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.delete-icon {
  background: rgba(255, 59, 48, 0.1);
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

.btn-delete {
  background: #FF3B30;
  color: #FFFFFF;
}

.btn-delete:hover:not(:disabled) {
  background: #D32F2F;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(255, 59, 48, 0.3);
}

.btn-delete:disabled {
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

@media (max-width: 768px) {
  .exam-detail {
    padding: 16px;
  }

  .exam-title {
    font-size: 24px;
  }

  .section-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }

  .btn-add {
    width: 100%;
    justify-content: center;
  }
}

/* Inline Question Form */
.inline-question-form {
  width: 100%;
  max-width: 100%;
  background: #FFFFFF;
  border: 1px solid rgba(0, 0, 0, 0.1);
  border-radius: 12px;
  padding: 20px;
  box-sizing: border-box;
  overflow: hidden;
}

.form-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 16px;
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
}

.form-header .question-number {
  background: rgba(0, 122, 255, 0.1);
  color: #007AFF;
}

.form-actions {
  display: flex;
  gap: 8px;
}

.btn-save {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  background: #34C759;
  border: none;
  border-radius: 8px;
  color: #FFFFFF;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  letter-spacing: -0.01em;
}

.btn-save:hover {
  background: #2DB04A;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(52, 199, 89, 0.3);
}

.btn-cancel-inline {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
  background: rgba(0, 0, 0, 0.04);
  color: #FF3B30;
}

.btn-cancel-inline:hover {
  background: rgba(255, 59, 48, 0.1);
}

.form-body {
  margin-top: 0;
  width: 100%;
  max-width: 100%;
  box-sizing: border-box;
}

.form-body .form-group {
  margin-bottom: 20px;
  width: 100%;
  max-width: 100%;
  box-sizing: border-box;
}

.form-body .form-group:last-child {
  margin-bottom: 0;
}

.form-body .form-group label {
  display: block;
  margin-bottom: 8px;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 14px;
  font-weight: 600;
  color: #1D1D1F;
  letter-spacing: -0.01em;
}

.form-body textarea {
  width: 100%;
  max-width: 100%;
  padding: 12px 14px;
  border: 1px solid rgba(0, 0, 0, 0.15);
  border-radius: 8px;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 15px;
  color: #1D1D1F;
  background: #FAFAFA;
  transition: all 0.2s ease;
  letter-spacing: -0.01em;
  resize: vertical;
  min-height: 80px;
  box-sizing: border-box;
}

.form-body textarea:focus {
  outline: none;
  border-color: #007AFF;
  background: #FFFFFF;
  box-shadow: 0 0 0 3px rgba(0, 122, 255, 0.1);
}

.form-body textarea::placeholder {
  color: #C7C7CC;
}

.choices-editor {
  display: flex;
  flex-direction: column;
  gap: 10px;
  padding: 16px 0;
  width: 100%;
  max-width: 100%;
  box-sizing: border-box;
}

.choice-editor {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 14px;
  background: #F5F5F7;
  border-radius: 10px;
  transition: all 0.2s ease;
  width: 100%;
  max-width: 100%;
  height: auto;
  box-sizing: border-box;
  cursor: pointer;
  position: relative;
}

.choice-editor:hover {
  background: #EBEBED;
}

.choice-editor.is-correct {
  background: #E8F5E9;
  border: 2px solid #4CAF50;
}

.choice-editor.is-correct:hover {
  background: #E0F2E1;
}

.choice-letter-badge {
  width: 32px;
  height: 32px;
  background: #FFFFFF;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 14px;
  font-weight: 600;
  color: #1D1D1F;
  flex-shrink: 0;
  border: 2px solid rgba(0, 0, 0, 0.1);
}

.choice-editor.is-correct .choice-letter-badge {
  background: #4CAF50;
  color: white;
  border-color: #4CAF50;
}

.choice-selector {
  display: none;
}

.choice-radio {
  display: none;
}

.choice-editor .choice-letter {
  display: none;
}

.choice-input {
  flex: 1;
  width: auto;
  min-width: 0;
  height: auto;
  padding: 8px 12px !important;
  background: transparent !important;
  border: none !important;
  border-radius: 0 !important;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 15px;
  color: #1D1D1F;
  transition: all 0.2s ease;
  letter-spacing: -0.01em;
  box-sizing: border-box;
  cursor: text;
}

.choice-input:hover {
  background: transparent !important;
  border: none !important;
}

.choice-input:focus {
  outline: none;
  background: transparent !important;
  border: none !important;
  box-shadow: none !important;
  padding: 8px 12px !important;
}

.choice-input::placeholder {
  color: #C7C7CC;
}

.correct-indicator {
  width: 24px;
  height: 24px;
  background: #4CAF50;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  flex-shrink: 0;
}

.btn-remove-choice {
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

.btn-remove-choice:hover {
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
  margin-top: 2px;
}

.btn-add-choice:hover {
  background: rgba(0, 122, 255, 0.15);
}

/* Save All Container */
.save-all-container {
  padding: 24px;
  background: #FFFFFF;
  border-top: 1px solid rgba(0, 0, 0, 0.06);
  display: flex;
  justify-content: center;
}

.btn-save-all {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  padding: 14px 32px;
  background: #34C759;
  color: white;
  border: none;
  border-radius: 12px;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  letter-spacing: -0.01em;
  box-shadow: 0 4px 16px rgba(52, 199, 89, 0.3);
}

.btn-save-all:hover:not(:disabled) {
  background: #2DB04A;
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(52, 199, 89, 0.4);
}

.btn-save-all:active:not(:disabled) {
  transform: translateY(0) scale(0.98);
}

.btn-save-all:disabled {
  background: #C7C7CC;
  cursor: not-allowed;
  opacity: 0.6;
  box-shadow: none;
}

.btn-save-all svg {
  width: 20px;
  height: 20px;
  stroke-width: 2.5;
}

.loading-spinner-small {
  width: 20px;
  height: 20px;
  border: 2px dashed rgba(255, 255, 255, 0.8);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

/* Import Tabs */
.import-tabs {
  display: flex;
  gap: 8px;
  margin-bottom: 24px;
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
}

.import-tab {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 20px;
  background: transparent;
  border: none;
  border-bottom: 2px solid transparent;
  color: #86868B;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 15px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  letter-spacing: -0.01em;
}

.import-tab:hover {
  color: #1D1D1F;
}

.import-tab.active {
  color: #007AFF;
  border-bottom-color: #007AFF;
}

.import-tab svg {
  width: 18px;
  height: 18px;
}

.import-method-content {
  animation: fadeIn 0.3s ease-out;
}

/* File Upload Area */
.file-upload-area {
  margin: 24px 0;
}

.file-input {
  display: none;
}

.file-upload-label {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 48px 24px;
  border: 2px dashed rgba(0, 0, 0, 0.15);
  border-radius: 12px;
  background: #FAFAFA;
  cursor: pointer;
  transition: all 0.2s ease;
}

.file-upload-label:hover {
  border-color: #007AFF;
  background: rgba(0, 122, 255, 0.05);
}

.upload-icon {
  margin-bottom: 16px;
  color: #007AFF;
}

.upload-text {
  text-align: center;
}

.upload-prompt {
  display: block;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 16px;
  font-weight: 500;
  color: #1D1D1F;
  margin-bottom: 6px;
}

.upload-filename {
  display: block;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 16px;
  font-weight: 600;
  color: #007AFF;
  margin-bottom: 6px;
}

.upload-hint {
  display: block;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 13px;
  color: #86868B;
}

/* Upload Progress */
.upload-progress {
  margin-top: 16px;
  padding: 16px;
  background: #F5F5F7;
  border-radius: 8px;
}

.progress-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.progress-label {
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 14px;
  font-weight: 500;
  color: #1D1D1F;
}

.progress-count {
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', sans-serif;
  font-size: 15px;
  font-weight: 600;
  color: #007AFF;
  letter-spacing: -0.02em;
}

.progress-bar {
  width: 100%;
  height: 8px;
  background: rgba(0, 0, 0, 0.1);
  border-radius: 4px;
  overflow: hidden;
  margin-bottom: 8px;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #007AFF, #34C759);
  border-radius: 4px;
  transition: width 0.3s ease;
  animation: shimmer 2s infinite;
}

@keyframes shimmer {
  0% {
    background-position: -100% 0;
  }
  100% {
    background-position: 200% 0;
  }
}

.progress-text {
  display: block;
  text-align: center;
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 13px;
  font-weight: 600;
  color: #007AFF;
}

.progress-details {
  display: flex;
  flex-direction: column;
  gap: 4px;
  align-items: center;
}

.progress-hint {
  font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', sans-serif;
  font-size: 12px;
  font-weight: 500;
  color: #86868B;
  text-align: center;
  line-height: 1.4;
}



</style>
