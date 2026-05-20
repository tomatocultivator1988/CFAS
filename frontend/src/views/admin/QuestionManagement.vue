<template>
  <div class="question-management">
    <div class="page-header">
      <div class="header-content">
        <h1 class="page-title text-gradient glow-text">
          <span class="title-icon">📝</span>
          Question Bank
        </h1>
        <p class="page-subtitle">Manage your examination questions with ease</p>
      </div>
      <button @click="showCreateModal = true" class="btn btn-primary btn-create">
        <svg class="icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
        </svg>
        Create Question
      </button>
    </div>

    <div class="filters-section glass-card">
      <div class="filter-group">
        <div class="search-wrapper">
          <input 
            v-model="searchQuery" 
            type="text" 
            placeholder="Search questions..." 
            class="search-input neon-input"
          />
        </div>
        <select v-model="filterTopic" class="filter-select neon-input">
          <option value="">All Topics</option>
          <option v-for="topic in uniqueTopics" :key="topic" :value="topic">
            {{ topic }}
          </option>
        </select>
      </div>
      <div class="stats-mini">
        <div class="stat-mini">
          <span class="stat-value">{{ filteredQuestions.length }}</span>
          <span class="stat-label">Questions</span>
        </div>
        <div class="stat-mini">
          <span class="stat-value">{{ uniqueTopics.length }}</span>
          <span class="stat-label">Topics</span>
        </div>
      </div>
    </div>

    <div v-if="loading" class="loading">
      <div class="loading-spinner"></div>
      <p class="loading-text">Loading questions...</p>
    </div>
    
    <div v-else-if="filteredQuestions.length === 0" class="empty-state glass-card scale-in">
      <div class="empty-icon">📝</div>
      <h3 class="empty-title">No Questions Found</h3>
      <p class="empty-text">
        {{ searchQuery || filterTopic ? 'Try adjusting your filters' : 'Create your first question to get started' }}
      </p>
      <button v-if="!searchQuery && !filterTopic" @click="showCreateModal = true" class="btn btn-neon">
        <svg class="icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
        </svg>
        Create First Question
      </button>
    </div>

    <TransitionGroup v-else name="list" tag="div" class="question-grid">
      <div 
        v-for="(question, index) in filteredQuestions" 
        :key="question.id" 
        class="question-card glass-card neon-border stagger-item"
        :style="{ animationDelay: `${index * 0.05}s` }"
      >
        <div class="question-header">
          <div class="question-number">#{{ index + 1 }}</div>
          <div v-if="question.topic" class="topic-badge badge badge-neon">
            📚 {{ question.topic }}
          </div>
        </div>
        
        <div class="question-content">
          <p class="question-text">{{ question.question_text }}</p>
        </div>
        
        <div class="question-footer">
          <div class="question-meta">
            <span class="meta-item">
              <svg class="meta-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
              </svg>
              {{ question.answer_choices?.length || 0 }} choices
            </span>
          </div>
          
          <div class="question-actions">
            <button @click="editQuestion(question)" class="btn-icon btn-icon-edit" title="Edit">
              <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
              </svg>
            </button>
            <button @click="deleteQuestionConfirm(question)" class="btn-icon btn-icon-delete" title="Delete">
              <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
              </svg>
            </button>
          </div>
        </div>
      </div>
    </TransitionGroup>

    <!-- Create/Edit Modal -->
    <Transition name="modal">
      <QuestionForm
        v-if="showCreateModal || showEditModal"
        :question="selectedQuestion"
        :exams="adminStore.exams"
        @close="closeModals"
        @save="handleSave"
      />
    </Transition>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAdminStore } from '@/stores/admin'
import QuestionForm from '@/components/admin/QuestionForm.vue'

const adminStore = useAdminStore()
const loading = ref(false)
const showCreateModal = ref(false)
const showEditModal = ref(false)
const selectedQuestion = ref(null)
const searchQuery = ref('')
const filterTopic = ref('')

onMounted(async () => {
  loading.value = true
  await Promise.all([
    adminStore.loadQuestions(),
    adminStore.loadExams()
  ])
  loading.value = false
})

const uniqueTopics = computed(() => {
  const topics = adminStore.questions
    .map(q => q.topic)
    .filter(t => t && t.trim() !== '')
  return [...new Set(topics)].sort()
})

const filteredQuestions = computed(() => {
  let questions = adminStore.questions

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    questions = questions.filter(q => 
      q.question_text?.toLowerCase().includes(query) ||
      q.topic?.toLowerCase().includes(query)
    )
  }

  if (filterTopic.value) {
    questions = questions.filter(q => q.topic === filterTopic.value)
  }

  return questions
})

const editQuestion = (question) => {
  selectedQuestion.value = { ...question }
  showEditModal.value = true
}

const deleteQuestionConfirm = async (question) => {
  if (confirm(`Are you sure you want to delete this question?`)) {
    const result = await adminStore.deleteQuestion(question.id)
    if (!result.success) {
      alert(result.error)
    }
  }
}

const closeModals = () => {
  showCreateModal.value = false
  showEditModal.value = false
  selectedQuestion.value = null
}

const handleSave = async () => {
  closeModals()
  await adminStore.loadQuestions()
}
</script>

<style scoped>
.question-management {
  padding: 2rem;
  max-width: 1600px;
  margin: 0 auto;
  position: relative;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
  flex-wrap: wrap;
  gap: 1.5rem;
}

.header-content {
  flex: 1;
}

.page-title {
  font-size: 2.5rem;
  font-weight: 800;
  margin: 0 0 0.5rem 0;
  display: flex;
  align-items: center;
  gap: 1rem;
}

.title-icon {
  font-size: 2.5rem;
  animation: float 3s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-10px); }
}

.page-subtitle {
  color: var(--text-secondary);
  font-size: 1rem;
  margin: 0;
}

.btn-create {
  padding: 1rem 2rem;
  font-size: 1rem;
}

.icon {
  width: 20px;
  height: 20px;
}

.filters-section {
  padding: 1.5rem;
  margin-bottom: 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 2rem;
  flex-wrap: wrap;
}

.filter-group {
  display: flex;
  gap: 1rem;
  flex: 1;
  min-width: 300px;
}

.search-wrapper {
  flex: 1;
}

.neon-input {
  width: 100%;
  padding: 0.875rem 1.25rem;
  background: var(--bg-tertiary);
  border: 2px solid var(--border-color);
  border-radius: var(--radius-full);
  color: var(--text-primary);
  font-size: 0.875rem;
  transition: all 0.3s ease;
}

.neon-input:focus {
  outline: none;
  border-color: var(--neon-blue);
  box-shadow: 0 0 0 3px rgba(0, 212, 255, 0.1), 0 0 20px rgba(0, 212, 255, 0.3);
}

.search-input {
  padding-left: 3rem;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%2300d4ff'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z'%3E%3C/path%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: 1rem center;
  background-size: 1.25rem;
}

.filter-select {
  min-width: 200px;
  cursor: pointer;
}

.stats-mini {
  display: flex;
  gap: 2rem;
}

.stat-mini {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.25rem;
}

.stat-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--neon-blue);
  text-shadow: 0 0 10px rgba(0, 212, 255, 0.5);
}

.stat-label {
  font-size: 0.75rem;
  color: var(--text-secondary);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.loading {
  text-align: center;
  padding: 4rem 2rem;
}

.loading-text {
  color: var(--text-secondary);
  margin-top: 1rem;
  font-size: 1.125rem;
}

.empty-state {
  text-align: center;
  padding: 4rem 2rem;
}

.empty-icon {
  font-size: 5rem;
  margin-bottom: 1.5rem;
  animation: bounce 2s ease-in-out infinite;
  filter: drop-shadow(0 0 20px rgba(0, 212, 255, 0.3));
}

.empty-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--text-primary);
  margin: 0 0 0.5rem 0;
}

.empty-text {
  color: var(--text-secondary);
  margin: 0 0 2rem 0;
  font-size: 1rem;
}

.question-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 1.5rem;
}

.question-card {
  padding: 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 1rem;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.question-card:hover {
  transform: translateY(-8px) scale(1.02);
}

.question-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.question-number {
  font-size: 0.875rem;
  font-weight: 700;
  color: var(--neon-purple);
  background: rgba(168, 85, 247, 0.1);
  padding: 0.375rem 0.875rem;
  border-radius: var(--radius-full);
  border: 1px solid rgba(168, 85, 247, 0.3);
}

.topic-badge {
  font-size: 0.75rem;
}

.question-content {
  flex: 1;
}

.question-text {
  color: var(--text-primary);
  font-size: 1rem;
  line-height: 1.6;
  margin: 0;
}

.question-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 1rem;
  border-top: 1px solid var(--border-color);
}

.question-meta {
  display: flex;
  gap: 1rem;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: var(--text-secondary);
  font-size: 0.875rem;
}

.meta-icon {
  width: 16px;
  height: 16px;
  stroke: var(--neon-blue);
}

.question-actions {
  display: flex;
  gap: 0.5rem;
}

.btn-icon {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: none;
  border-radius: var(--radius);
  cursor: pointer;
  transition: all 0.3s ease;
  background: var(--bg-tertiary);
  border: 1px solid var(--border-color);
}

.btn-icon svg {
  width: 18px;
  height: 18px;
}

.btn-icon-edit {
  color: var(--neon-blue);
}

.btn-icon-edit:hover {
  background: rgba(0, 212, 255, 0.1);
  border-color: var(--neon-blue);
  box-shadow: 0 0 15px rgba(0, 212, 255, 0.3);
  transform: scale(1.1);
}

.btn-icon-delete {
  color: var(--neon-red);
}

.btn-icon-delete:hover {
  background: rgba(239, 68, 68, 0.1);
  border-color: var(--neon-red);
  box-shadow: 0 0 15px rgba(239, 68, 68, 0.3);
  transform: scale(1.1);
}

@media (max-width: 768px) {
  .question-grid {
    grid-template-columns: 1fr;
  }
  
  .page-title {
    font-size: 2rem;
  }
  
  .filters-section {
    flex-direction: column;
    align-items: stretch;
  }
  
  .filter-group {
    flex-direction: column;
  }
  
  .stats-mini {
    justify-content: center;
  }
}
</style>
