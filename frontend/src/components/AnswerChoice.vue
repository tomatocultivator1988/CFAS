<template>
  <div 
    class="answer-choice"
    :class="{ selected: selected }"
    @click="handleClick"
  >
    <div class="radio-wrapper">
      <input
        type="radio"
        :id="`choice-${choice.id}`"
        :name="choice.question_id"
        :value="choice.id"
        :checked="selected"
        @change="handleClick"
      />
      <label :for="`choice-${choice.id}`" class="radio-label">
        <span class="choice-letter">{{ choiceLetter }}</span>
        <span class="choice-text">{{ choice.choice_text }}</span>
      </label>
    </div>
  </div>
</template>

<script setup>
import { computed, defineProps, defineEmits } from 'vue'

const props = defineProps({
  choice: {
    type: Object,
    required: true
  },
  selected: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['select'])

const choiceLetter = computed(() => {
  // This will be set by the parent based on the order
  return props.choice.letter || String.fromCharCode(65 + (props.choice.order || 0))
})

const handleClick = () => {
  emit('select', props.choice.id)
}
</script>

<style scoped>
.answer-choice {
  background: #f9fafb;
  border: 2px solid #e5e7eb;
  border-radius: 8px;
  padding: 16px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.answer-choice:hover {
  background: #f3f4f6;
  border-color: #3b82f6;
}

.answer-choice.selected {
  background: #eff6ff;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.radio-wrapper {
  display: flex;
  align-items: flex-start;
}

.radio-wrapper input[type="radio"] {
  margin-top: 4px;
  margin-right: 12px;
  width: 18px;
  height: 18px;
  cursor: pointer;
  accent-color: #3b82f6;
}

.radio-label {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  cursor: pointer;
  flex: 1;
}

.choice-letter {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  background: #3b82f6;
  color: white;
  border-radius: 50%;
  font-weight: 600;
  font-size: 14px;
  flex-shrink: 0;
}

.selected .choice-letter {
  background: #1e40af;
}

.choice-text {
  flex: 1;
  line-height: 1.6;
  color: #374151;
  font-size: 16px;
  padding-top: 2px;
}
</style>
