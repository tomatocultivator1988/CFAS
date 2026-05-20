<template>
  <div class="question-analysis-card">
    <div class="section-header">
      <div>
        <h2 class="section-title">Question Analysis</h2>
        <p class="section-subtitle">Track difficult and easy questions per exam</p>
      </div>
      <div class="control-row">
        <div class="select-wrap">
          <select v-model="selectedExamId">
            <option value="">Select exam</option>
            <option v-for="exam in exams" :key="exam.id" :value="String(exam.id)">
              {{ exam.name }}
            </option>
          </select>
        </div>
        <div class="select-wrap">
          <select v-model="difficultyFilter" :disabled="!selectedExam">
            <option value="all">All</option>
            <option value="difficult">Difficult (≥75%)</option>
            <option value="easy">Easy (≤30%)</option>
          </select>
        </div>
      </div>
    </div>

    <div class="stats-grid">
      <div class="stat-tile">
        <span class="stat-label">Total Questions</span>
        <strong class="stat-value">{{ stats.total }}</strong>
      </div>
      <div class="stat-tile">
        <span class="stat-label">Avg Pass Rate</span>
        <strong class="stat-value">{{ formatPercent(stats.avgPassRate) }}</strong>
      </div>
      <div class="stat-tile">
        <span class="stat-label">Difficult</span>
        <strong class="stat-value">{{ stats.difficult }}</strong>
      </div>
      <div class="stat-tile">
        <span class="stat-label">Easy</span>
        <strong class="stat-value">{{ stats.easy }}</strong>
      </div>
    </div>

    <div class="chip-row">
      <button class="chip all" :class="{ active: difficultyFilter === 'all' }" @click="difficultyFilter = 'all'" :disabled="!selectedExam">
        All <span>{{ stats.total }}</span>
      </button>
      <button class="chip difficult" :class="{ active: difficultyFilter === 'difficult' }" @click="difficultyFilter = 'difficult'" :disabled="!selectedExam">
        Difficult <span>{{ stats.difficult }}</span>
      </button>
      <button class="chip easy" :class="{ active: difficultyFilter === 'easy' }" @click="difficultyFilter = 'easy'" :disabled="!selectedExam">
        Easy <span>{{ stats.easy }}</span>
      </button>
    </div>

    <div v-if="!selectedExam" class="empty-state">
      <div class="empty-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <rect x="3" y="4" width="18" height="16" rx="3" />
          <path d="M8 9h8M8 13h6" />
        </svg>
      </div>
      <h3>Select an exam first</h3>
      <p>Choose an exam to view question-level performance and fail rates.</p>
    </div>

    <div v-else-if="filteredQuestions.length === 0" class="empty-state">
      <div class="empty-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <circle cx="11" cy="11" r="7" />
          <line x1="16.65" y1="16.65" x2="21" y2="21" />
        </svg>
      </div>
      <h3>No questions found</h3>
      <p>Try switching the difficulty filter.</p>
    </div>

    <div v-else class="question-list">
      <div v-for="question in filteredQuestions" :key="`${selectedExamId}-${question.n}`" class="question-item">
        <div class="question-head">
          <div class="head-left">
            <span class="q-number">Q{{ question.n }}</span>
            <span class="topic-tag">{{ question.topic || 'General' }}</span>
          </div>
          <span class="difficulty-badge" :class="difficultyClass(question)">{{ difficultyText(question) }}</span>
        </div>

        <p class="question-text">{{ question.text }}</p>

        <div class="progress-row">
          <div class="progress-track">
            <div class="progress-fill" :class="difficultyClass(question)" :style="{ width: `${clampPercent(question.pct)}%` }"></div>
          </div>
          <span class="pct-text">{{ formatPercent(question.pct) }} fail</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'

const props = defineProps({
  exams: {
    type: Array,
    default: () => []
  }
})

const selectedExamId = ref('')
const difficultyFilter = ref('all')

const selectedExam = computed(() => {
  const id = selectedExamId.value
  if (!id) return null
  return (props.exams || []).find((exam) => String(exam.id) === String(id)) || null
})

const examQuestions = computed(() =>
  (selectedExam.value?.questions || []).map((question) => ({
    n: question.n,
    text: question.text || '',
    topic: question.topic || '',
    pct: Number(question.pct || 0)
  }))
)

const stats = computed(() => {
  const questions = examQuestions.value
  const total = questions.length
  const difficult = questions.filter((question) => question.pct >= 75).length
  const easy = questions.filter((question) => question.pct <= 30).length
  const avgFail = total > 0 ? questions.reduce((sum, question) => sum + question.pct, 0) / total : 0
  return {
    total,
    difficult,
    easy,
    avgPassRate: Math.max(0, 100 - avgFail)
  }
})

const filteredQuestions = computed(() => {
  if (!selectedExam.value) return []
  if (difficultyFilter.value === 'difficult') {
    return examQuestions.value.filter((question) => question.pct >= 75)
  }
  if (difficultyFilter.value === 'easy') {
    return examQuestions.value.filter((question) => question.pct <= 30)
  }
  return examQuestions.value
})

watch(selectedExamId, () => {
  difficultyFilter.value = 'all'
})

const difficultyText = (question) => {
  if (question.pct >= 75) return 'Difficult'
  if (question.pct <= 30) return 'Easy'
  return 'Moderate'
}

const difficultyClass = (question) => {
  if (question.pct >= 75) return 'difficult'
  if (question.pct <= 30) return 'easy'
  return 'moderate'
}

const clampPercent = (value) => {
  const num = Number(value || 0)
  return Math.max(0, Math.min(100, num))
}

const formatPercent = (value) => `${Number(value || 0).toFixed(2)}%`
</script>

<style scoped>
.question-analysis-card {
  font-family: -apple-system, BlinkMacSystemFont, 'Helvetica Neue', sans-serif;
  background: rgba(255, 255, 255, 0.75);
  border-radius: 22px;
  border: 0.5px solid rgba(255, 255, 255, 0.9);
  padding: 16px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
}

.section-title {
  margin: 0;
  font-size: 17px;
  font-weight: 600;
  color: #1D1D1F;
}

.section-subtitle {
  margin: 4px 0 0;
  font-size: 12px;
  color: rgba(60, 60, 67, 0.58);
}

.control-row {
  display: inline-flex;
  gap: 8px;
}

.select-wrap {
  position: relative;
}

.select-wrap select {
  appearance: none;
  -webkit-appearance: none;
  border-radius: 10px;
  border: 0.5px solid rgba(60, 60, 67, 0.15);
  background: rgba(118, 118, 128, 0.08);
  padding: 8px 34px 8px 12px;
  min-width: 160px;
  font-size: 13px;
  color: #1D1D1F;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='%238E8E93' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 10px center;
}

.select-wrap select:focus {
  outline: none;
  border-color: rgba(10, 132, 255, 0.55);
}

.select-wrap select:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}

.stats-grid {
  margin-top: 14px;
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 8px;
}

.stat-tile {
  background: rgba(118, 118, 128, 0.07);
  border-radius: 12px;
  padding: 10px;
}

.stat-label {
  display: block;
  font-size: 10px;
  letter-spacing: 0.07em;
  text-transform: uppercase;
  color: rgba(60, 60, 67, 0.45);
}

.stat-value {
  margin-top: 4px;
  display: block;
  font-size: 22px;
  font-weight: 600;
  color: #1D1D1F;
}

.chip-row {
  margin-top: 12px;
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.chip {
  border: 0.5px solid transparent;
  border-radius: 20px;
  padding: 7px 12px;
  font-size: 13px;
  font-weight: 500;
  color: rgba(60, 60, 67, 0.58);
  background: rgba(118, 118, 128, 0.1);
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 6px;
}

.chip:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}

.chip span {
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.75);
  padding: 2px 7px;
}

.chip.all.active {
  color: #007AFF;
  border-color: rgba(10, 132, 255, 0.35);
  background: rgba(10, 132, 255, 0.12);
}

.chip.difficult.active {
  color: #FF3B30;
  border-color: rgba(255, 59, 48, 0.3);
  background: rgba(255, 59, 48, 0.09);
}

.chip.easy.active {
  color: #34C759;
  border-color: rgba(52, 199, 89, 0.3);
  background: rgba(52, 199, 89, 0.09);
}

.question-list {
  margin-top: 12px;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.question-item {
  background: rgba(255, 255, 255, 0.8);
  border-radius: 14px;
  border: 0.5px solid rgba(60, 60, 67, 0.1);
  padding: 12px;
}

.question-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 8px;
}

.head-left {
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.q-number {
  font-size: 12px;
  font-weight: 600;
  color: rgba(60, 60, 67, 0.65);
}

.topic-tag {
  font-size: 11px;
  border-radius: 999px;
  padding: 3px 8px;
  background: rgba(10, 132, 255, 0.1);
  color: #0055B3;
}

.difficulty-badge {
  font-size: 11px;
  border-radius: 999px;
  padding: 4px 9px;
  border: 0.5px solid transparent;
  font-weight: 600;
}

.difficulty-badge.difficult {
  color: #C0392B;
  border-color: rgba(255, 59, 48, 0.3);
  background: rgba(255, 59, 48, 0.11);
}

.difficulty-badge.moderate {
  color: #B95000;
  border-color: rgba(255, 149, 0, 0.3);
  background: rgba(255, 149, 0, 0.11);
}

.difficulty-badge.easy {
  color: #1A7F37;
  border-color: rgba(52, 199, 89, 0.3);
  background: rgba(52, 199, 89, 0.11);
}

.question-text {
  margin: 10px 0 0;
  font-size: 14px;
  line-height: 1.45;
  color: #1D1D1F;
}

.progress-row {
  margin-top: 10px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.progress-track {
  flex: 1;
  height: 5px;
  border-radius: 10px;
  overflow: hidden;
  background: rgba(60, 60, 67, 0.14);
}

.progress-fill {
  height: 100%;
  border-radius: 10px;
  transition: width 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

.progress-fill.difficult {
  background: #FF3B30;
}

.progress-fill.moderate {
  background: #FF9500;
}

.progress-fill.easy {
  background: #34C759;
}

.pct-text {
  font-size: 12px;
  color: rgba(60, 60, 67, 0.7);
  min-width: 72px;
  text-align: right;
}

.empty-state {
  margin-top: 12px;
  text-align: center;
  padding: 22px 10px;
}

.empty-icon {
  width: 48px;
  height: 48px;
  margin: 0 auto 10px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(118, 118, 128, 0.12);
  color: rgba(60, 60, 67, 0.6);
}

.empty-icon svg {
  width: 22px;
  height: 22px;
  stroke-width: 2;
}

.empty-state h3 {
  margin: 0;
  color: rgba(60, 60, 67, 0.86);
  font-size: 15px;
}

.empty-state p {
  margin: 6px 0 0;
  color: rgba(60, 60, 67, 0.56);
  font-size: 13px;
}

@media (prefers-color-scheme: dark) {
  .question-analysis-card {
    background: rgba(28, 28, 30, 0.85);
    border-color: rgba(255, 255, 255, 0.1);
  }

  .section-title {
    color: #F2F2F7;
  }

  .section-subtitle {
    color: rgba(235, 235, 245, 0.6);
  }

  .select-wrap select {
    background-color: rgba(44, 44, 50, 0.8);
    color: #F2F2F7;
    border-color: rgba(255, 255, 255, 0.15);
  }

  .stat-tile {
    background: rgba(44, 44, 50, 0.75);
  }

  .stat-label {
    color: rgba(235, 235, 245, 0.35);
  }

  .stat-value {
    color: #F2F2F7;
  }

  .chip {
    background: rgba(118, 118, 128, 0.2);
    color: rgba(235, 235, 245, 0.7);
  }

  .chip span {
    background: rgba(255, 255, 255, 0.12);
    color: #F2F2F7;
  }

  .chip.all.active {
    color: #4DA3FF;
    border-color: rgba(77, 163, 255, 0.4);
    background: rgba(77, 163, 255, 0.16);
  }

  .chip.difficult.active {
    color: #FF6B6B;
    border-color: rgba(255, 107, 107, 0.4);
    background: rgba(255, 107, 107, 0.16);
  }

  .chip.easy.active {
    color: #4CD964;
    border-color: rgba(76, 217, 100, 0.4);
    background: rgba(76, 217, 100, 0.16);
  }

  .question-item {
    background: rgba(44, 44, 50, 0.6);
    border-color: rgba(255, 255, 255, 0.12);
  }

  .q-number,
  .pct-text {
    color: rgba(235, 235, 245, 0.72);
  }

  .question-text {
    color: #F2F2F7;
  }

  .topic-tag {
    color: #82B6FF;
    background: rgba(77, 163, 255, 0.16);
  }

  .empty-icon {
    background: rgba(118, 118, 128, 0.2);
    color: rgba(235, 235, 245, 0.7);
  }

  .empty-state h3 {
    color: #F2F2F7;
  }

  .empty-state p {
    color: rgba(235, 235, 245, 0.58);
  }
}

@media (max-width: 920px) {
  .section-header {
    flex-direction: column;
  }

  .control-row {
    width: 100%;
  }

  .select-wrap {
    flex: 1;
  }

  .select-wrap select {
    width: 100%;
    min-width: 0;
  }

  .stats-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}
</style>
