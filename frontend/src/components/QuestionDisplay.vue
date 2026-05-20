<template>
  <div class="question-display">
    <div class="question-header">
      <span class="question-number">Question {{ questionNumber }} of {{ totalQuestions }}</span>
      <span v-if="question.topic" class="question-topic">{{ question.topic }}</span>
    </div>
    
    <div class="question-text">
      {{ question.question_text }}
    </div>
    
    <div class="answer-choices">
      <AnswerChoice
        v-for="choice in question.choices"
        :key="choice.id"
        :choice="choice"
        :selected="selectedChoiceId === choice.id"
        @select="handleSelect"
      />
    </div>
  </div>
</template>

<script setup>
import { defineProps, defineEmits } from 'vue'
import AnswerChoice from './AnswerChoice.vue'

const props = defineProps({
  question: {
    type: Object,
    required: true
  },
  questionNumber: {
    type: Number,
    required: true
  },
  totalQuestions: {
    type: Number,
    required: true
  },
  selectedChoiceId: {
    type: Number,
    default: null
  }
})

const emit = defineEmits(['answer-selected'])

const handleSelect = (choiceId) => {
  emit('answer-selected', choiceId)
}
</script>

<style scoped>
.question-display {
  background: white;
  border-radius: 8px;
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.question-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 12px;
  border-bottom: 2px solid #e5e7eb;
}

.question-number {
  font-weight: 600;
  color: #3b82f6;
  font-size: 14px;
}

.question-topic {
  background: #dbeafe;
  color: #1e40af;
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
}

.question-text {
  font-size: 18px;
  line-height: 1.6;
  color: #1f2937;
  margin-bottom: 24px;
  font-weight: 500;
}

.answer-choices {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
</style>
