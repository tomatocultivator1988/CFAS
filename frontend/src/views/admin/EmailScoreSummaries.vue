<template>
  <div class="email-summaries">
    <div class="email-header">
      <div>
        <h2 class="page-title">Email Score Summaries</h2>
        <p class="page-subtitle">Send professional Gmail summaries with downloadable XLSX attachments.</p>
      </div>
      <button @click="refreshData" class="btn-refresh" :disabled="loading">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
        </svg>
        <span>Refresh</span>
      </button>
    </div>

    <transition name="notice-slide">
      <div v-if="notice.show" class="notice" :class="notice.type">
        <div>
          <div class="notice-title">{{ notice.title }}</div>
          <div class="notice-message">{{ notice.message }}</div>
        </div>
        <button @click="notice.show = false" class="notice-close" aria-label="Close notification">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M6 18L18 6M6 6l12 12" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
          </svg>
        </button>
      </div>
    </transition>

    <div class="stats-grid">
      <div class="stat-card">
        <span class="stat-label">Reviewees</span>
        <strong>{{ studentData.length }}</strong>
      </div>
      <div class="stat-card ready">
        <span class="stat-label">Ready to Email</span>
        <strong>{{ readyCount }}</strong>
      </div>
      <div class="stat-card warning">
        <span class="stat-label">No Email</span>
        <strong>{{ missingEmailCount }}</strong>
      </div>
      <div class="stat-card muted">
        <span class="stat-label">No Scores</span>
        <strong>{{ noScoresCount }}</strong>
      </div>
    </div>

    <div class="email-toolbar">
      <div class="filter-group">
        <label>Search Reviewee</label>
        <input
          v-model="searchStudent"
          type="text"
          placeholder="Search name, username, or email"
          class="filter-input"
        />
      </div>
      <div class="filter-group compact">
        <label>Status</label>
        <select v-model="statusFilter" class="filter-select">
          <option value="all">All reviewees</option>
          <option value="ready">Ready to email</option>
          <option value="missing-email">No email</option>
          <option value="no-scores">No scores</option>
        </select>
      </div>
      <button
        @click="openBulkSendConfirm"
        class="btn-send-filtered"
        :disabled="sendingBulk || sendableFilteredStudents.length === 0"
      >
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path d="M4 4h16v16H4z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
          <path d="M4 7l8 6 8-6" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
        </svg>
        <span>{{ sendingBulk ? 'Sending...' : `Send Filtered + XLSX (${sendableFilteredStudents.length})` }}</span>
      </button>
    </div>

    <div v-if="loading" class="loading-container">
      <div class="spinner-ring"></div>
      <p>Loading reviewees...</p>
    </div>

    <div v-else-if="filteredStudentData.length > 0" class="table-wrap">
      <table class="email-table">
        <thead>
          <tr>
            <th>Reviewee</th>
            <th>Email</th>
            <th>Exams</th>
            <th>Pass Rate</th>
            <th>Status</th>
            <th class="action-col">Action</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="student in filteredStudentData" :key="student.student_id">
            <td>
              <div class="student-name">{{ student.name }}</div>
              <div class="student-username">@{{ student.username }}</div>
            </td>
            <td>
              <span v-if="student.email" class="email-value">{{ student.email }}</span>
              <span v-else class="missing-value">No email set</span>
            </td>
            <td>{{ student.total_exams }}</td>
            <td>{{ student.pass_rate }}%</td>
            <td>
              <span class="status-pill" :class="getSendStatus(student).type">
                {{ getSendStatus(student).label }}
              </span>
            </td>
            <td class="action-col">
              <button
                @click="sendSingleSummary(student)"
                class="btn-send-one"
                :disabled="sendingStudentId === student.student_id || !canSend(student)"
                :title="getSendStatus(student).hint"
              >
                {{ sendingStudentId === student.student_id ? 'Sending...' : 'Send Gmail + XLSX' }}
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-else class="empty-state">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
        <path d="M4 4h16v16H4z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
        <path d="M4 7l8 6 8-6" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
      </svg>
      <h3>No Reviewees Found</h3>
      <p>No reviewees match the current filters.</p>
    </div>

    <transition name="modal-fade">
      <div v-if="showBulkConfirm" class="modal-overlay">
        <transition name="modal-scale">
          <div v-if="showBulkConfirm" class="confirm-modal">
            <div class="confirm-header">
              <div>
                <h3>Send Gmail Score Summaries?</h3>
                <p>This will send to {{ sendableFilteredStudents.length }} ready reviewee{{ sendableFilteredStudents.length === 1 ? '' : 's' }} from the current filter.</p>
              </div>
              <button @click="showBulkConfirm = false" class="modal-close" :disabled="sendingBulk">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <path d="M6 18L18 6M6 6l12 12" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                </svg>
              </button>
            </div>
            <div class="confirm-actions">
              <button @click="showBulkConfirm = false" class="btn-cancel" :disabled="sendingBulk">Cancel</button>
              <button @click="confirmBulkSend" class="btn-confirm" :disabled="sendingBulk">
                {{ sendingBulk ? 'Sending...' : 'Send Emails' }}
              </button>
            </div>
          </div>
        </transition>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import api from '@/services/api'

const loading = ref(true)
const studentData = ref([])
const searchStudent = ref('')
const statusFilter = ref('all')
const sendingStudentId = ref(null)
const sendingBulk = ref(false)
const showBulkConfirm = ref(false)
const notice = ref({
  show: false,
  type: 'success',
  title: '',
  message: ''
})

const filteredStudentData = computed(() => {
  const search = searchStudent.value.trim().toLowerCase()

  return studentData.value
    .filter((student) => {
      if (!search) return true

      return student.name.toLowerCase().includes(search) ||
        student.username.toLowerCase().includes(search) ||
        (student.email || '').toLowerCase().includes(search)
    })
    .filter((student) => {
      if (statusFilter.value === 'ready') return canSend(student)
      if (statusFilter.value === 'missing-email') return !student.email
      if (statusFilter.value === 'no-scores') return student.total_exams === 0
      return true
    })
    .sort((a, b) => a.name.localeCompare(b.name))
})

const sendableFilteredStudents = computed(() => filteredStudentData.value.filter(canSend))
const readyCount = computed(() => studentData.value.filter(canSend).length)
const missingEmailCount = computed(() => studentData.value.filter((student) => !student.email).length)
const noScoresCount = computed(() => studentData.value.filter((student) => student.total_exams === 0).length)

const canSend = (student) => Boolean(student.email) && student.total_exams > 0

const getSendStatus = (student) => {
  if (!student.email) {
    return {
      label: 'No Email',
      type: 'blocked',
      hint: 'Add an email address before sending.'
    }
  }

  if (student.total_exams === 0) {
    return {
      label: 'No Scores',
      type: 'muted',
      hint: 'The reviewee has no completed score records.'
    }
  }

  return {
    label: 'Ready',
    type: 'ready',
    hint: 'Send score summary by Gmail.'
  }
}

const showNotice = (type, title, message) => {
  notice.value = { show: true, type, title, message }
  window.setTimeout(() => {
    notice.value.show = false
  }, 6000)
}

const loadData = async () => {
  loading.value = true

  try {
    const response = await api.get('/admin/export/category-exam-data')
    const categories = response.data?.success ? response.data.data : []
    const studentsMap = new Map()

    categories.forEach((categoryItem) => {
      categoryItem.exams.forEach((exam) => {
        exam.students.forEach((student) => {
          if (!studentsMap.has(student.student_id)) {
            studentsMap.set(student.student_id, {
              student_id: student.student_id,
              username: student.username,
              name: student.name,
              email: student.email || null,
              total_exams: 0,
              passed_exams: 0
            })
          }

          const studentEntry = studentsMap.get(student.student_id)

          if (student.status !== 'Not Taken') {
            studentEntry.total_exams++

            if (student.status.includes('Passed')) {
              studentEntry.passed_exams++
            }
          }
        })
      })
    })

    studentData.value = Array.from(studentsMap.values()).map((student) => ({
      ...student,
      pass_rate: student.total_exams > 0
        ? Math.round((student.passed_exams / student.total_exams) * 100)
        : 0
    }))
  } catch (error) {
    console.error('Failed to load email score summary data:', error)
    showNotice('error', 'Load Failed', 'Could not load reviewees for Gmail sending.')
  } finally {
    loading.value = false
  }
}

const refreshData = () => {
  showBulkConfirm.value = false
  loadData()
}

const sendSingleSummary = async (student) => {
  if (!canSend(student)) {
    const status = getSendStatus(student)
    showNotice('error', status.label, status.hint)
    return
  }

  sendingStudentId.value = student.student_id

  try {
    const response = await api.post(`/admin/users/${student.student_id}/send-score-summary`)
    showNotice('success', 'Gmail Sent', response.data?.message || `Sent to ${student.email} with XLSX attachment.`)
  } catch (error) {
    showNotice('error', 'Send Failed', error.response?.data?.message || 'Failed to send Gmail score summary.')
  } finally {
    sendingStudentId.value = null
  }
}

const openBulkSendConfirm = () => {
  if (sendableFilteredStudents.value.length === 0) return
  showBulkConfirm.value = true
}

const confirmBulkSend = async () => {
  sendingBulk.value = true

  try {
    const userIds = sendableFilteredStudents.value.map((student) => student.student_id)
    const response = await api.post('/admin/users/send-score-summary-bulk', {
      user_ids: userIds,
      search: searchStudent.value || null
    })
    const result = response.data?.data || {}
    const message = [
      `${result.sent || 0} sent`,
      `${result.skipped_no_email || 0} no email`,
      `${result.skipped_no_scores || 0} no scores`,
      `${result.failed || 0} failed`
    ].join(' | ')

    showBulkConfirm.value = false
    showNotice((result.failed || 0) > 0 ? 'error' : 'success', 'Bulk Gmail Complete', `${message} | XLSX attached`)
  } catch (error) {
    showNotice('error', 'Bulk Send Failed', error.response?.data?.message || 'Failed to send Gmail score summaries.')
  } finally {
    sendingBulk.value = false
  }
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.email-summaries {
  padding: 40px 48px;
  max-width: 1600px;
  margin: 0 auto;
  background: #F5F5F7;
  min-height: calc(100vh - 120px);
}

.email-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 20px;
  margin-bottom: 28px;
}

.page-title {
  font-size: 34px;
  font-weight: 700;
  color: #1D1D1F;
  margin: 0 0 8px;
  letter-spacing: -0.8px;
}

.page-subtitle {
  font-size: 17px;
  color: #6B7280;
  margin: 0;
  font-weight: 500;
}

.btn-refresh,
.btn-send-filtered,
.btn-send-one,
.btn-confirm,
.btn-cancel {
  border: none;
  border-radius: 10px;
  font-size: 14px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  white-space: nowrap;
}

.btn-refresh {
  height: 44px;
  padding: 0 18px;
  background: #FFFFFF;
  color: #1D1D1F;
  border: 1px solid rgba(0, 0, 0, 0.08);
}

.btn-send-filtered,
.btn-confirm,
.btn-send-one {
  background: #111827;
  color: #FFFFFF;
}

.btn-send-filtered {
  height: 46px;
  padding: 0 18px;
  align-self: end;
}

.btn-send-one {
  min-height: 36px;
  padding: 0 14px;
}

.btn-cancel {
  background: #F3F4F6;
  color: #1F2937;
  min-height: 40px;
  padding: 0 18px;
}

.btn-confirm {
  min-height: 40px;
  padding: 0 18px;
}

.btn-refresh svg,
.btn-send-filtered svg {
  width: 18px;
  height: 18px;
}

button:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 6px 16px rgba(17, 24, 39, 0.14);
}

button:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 14px;
  margin-bottom: 20px;
}

.stat-card {
  background: #FFFFFF;
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 12px;
  padding: 18px;
}

.stat-card strong {
  display: block;
  margin-top: 6px;
  font-size: 28px;
  line-height: 1;
  color: #111827;
}

.stat-card.ready {
  border-left: 4px solid #16A34A;
}

.stat-card.warning {
  border-left: 4px solid #D97706;
}

.stat-card.muted {
  border-left: 4px solid #6B7280;
}

.stat-label {
  display: block;
  font-size: 13px;
  color: #6B7280;
  font-weight: 700;
  text-transform: uppercase;
}

.email-toolbar {
  display: grid;
  grid-template-columns: minmax(260px, 1fr) minmax(180px, 240px) auto;
  gap: 16px;
  align-items: end;
  margin-bottom: 22px;
  padding: 20px;
  background: #FFFFFF;
  border-radius: 12px;
  border: 1px solid rgba(0, 0, 0, 0.06);
}

.filter-group label {
  display: block;
  font-size: 13px;
  font-weight: 700;
  color: #6B7280;
  margin-bottom: 8px;
}

.filter-input,
.filter-select {
  width: 100%;
  height: 44px;
  padding: 0 14px;
  background: #F9FAFB;
  border: 1px solid rgba(0, 0, 0, 0.08);
  border-radius: 10px;
  font-size: 15px;
  color: #111827;
}

.filter-input:focus,
.filter-select:focus {
  outline: none;
  border-color: #111827;
  background: #FFFFFF;
}

.loading-container,
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 320px;
  gap: 14px;
  color: #6B7280;
}

.spinner-ring {
  width: 44px;
  height: 44px;
  border: 4px solid rgba(0, 0, 0, 0.1);
  border-top-color: #111827;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.empty-state svg {
  width: 62px;
  height: 62px;
  color: #9CA3AF;
}

.empty-state h3 {
  color: #111827;
  margin: 0;
}

.empty-state p {
  margin: 0;
}

.table-wrap {
  overflow-x: auto;
  background: #FFFFFF;
  border-radius: 12px;
  border: 1px solid rgba(0, 0, 0, 0.06);
}

.email-table {
  width: 100%;
  border-collapse: collapse;
  min-width: 900px;
}

.email-table th,
.email-table td {
  padding: 15px 18px;
  border-bottom: 1px solid #F3F4F6;
  text-align: left;
  vertical-align: middle;
}

.email-table th {
  font-size: 12px;
  color: #6B7280;
  text-transform: uppercase;
  letter-spacing: 0;
  background: #F9FAFB;
}

.email-table tr:last-child td {
  border-bottom: none;
}

.student-name {
  font-size: 15px;
  color: #111827;
  font-weight: 700;
}

.student-username,
.missing-value {
  font-size: 13px;
  color: #6B7280;
  margin-top: 3px;
}

.email-value {
  color: #111827;
  overflow-wrap: anywhere;
}

.status-pill {
  display: inline-flex;
  align-items: center;
  min-height: 28px;
  padding: 0 10px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 800;
}

.status-pill.ready {
  background: #DCFCE7;
  color: #166534;
}

.status-pill.blocked {
  background: #FEF3C7;
  color: #92400E;
}

.status-pill.muted {
  background: #E5E7EB;
  color: #374151;
}

.action-col {
  text-align: right;
}

.notice {
  position: fixed;
  right: 24px;
  bottom: 24px;
  z-index: 2000;
  width: min(420px, calc(100vw - 48px));
  background: #FFFFFF;
  border: 1px solid rgba(0, 0, 0, 0.08);
  border-left: 4px solid #16A34A;
  border-radius: 12px;
  box-shadow: 0 16px 40px rgba(0, 0, 0, 0.14);
  padding: 16px 44px 16px 16px;
}

.notice.error {
  border-left-color: #DC2626;
}

.notice-title {
  color: #111827;
  font-size: 14px;
  font-weight: 800;
  margin-bottom: 4px;
}

.notice-message {
  color: #4B5563;
  font-size: 13px;
  line-height: 1.4;
}

.notice-close,
.modal-close {
  border: none;
  background: transparent;
  cursor: pointer;
  color: #6B7280;
}

.notice-close {
  position: absolute;
  top: 12px;
  right: 12px;
}

.notice-close svg,
.modal-close svg {
  width: 18px;
  height: 18px;
}

.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(17, 24, 39, 0.55);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
  z-index: 1900;
}

.confirm-modal {
  width: min(520px, 100%);
  background: #FFFFFF;
  border-radius: 12px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.22);
  padding: 22px;
}

.confirm-header {
  display: flex;
  justify-content: space-between;
  gap: 18px;
}

.confirm-header h3 {
  margin: 0 0 6px;
  font-size: 20px;
  color: #111827;
}

.confirm-header p {
  margin: 0;
  color: #6B7280;
  line-height: 1.45;
}

.confirm-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 22px;
}

.notice-slide-enter-active,
.notice-slide-leave-active,
.modal-fade-enter-active,
.modal-fade-leave-active,
.modal-scale-enter-active,
.modal-scale-leave-active {
  transition: all 0.2s ease;
}

.notice-slide-enter-from,
.notice-slide-leave-to {
  opacity: 0;
  transform: translateY(12px);
}

.modal-fade-enter-from,
.modal-fade-leave-to,
.modal-scale-enter-from,
.modal-scale-leave-to {
  opacity: 0;
}

.modal-scale-enter-from,
.modal-scale-leave-to {
  transform: scale(0.96);
}

@media (max-width: 1024px) {
  .email-summaries {
    padding: 32px 24px;
  }

  .stats-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .email-toolbar {
    grid-template-columns: 1fr;
  }

  .btn-send-filtered {
    width: 100%;
  }
}

@media (max-width: 640px) {
  .email-summaries {
    padding: 24px 16px;
  }

  .email-header {
    flex-direction: column;
  }

  .btn-refresh {
    width: 100%;
  }

  .stats-grid {
    grid-template-columns: 1fr;
  }

  .page-title {
    font-size: 28px;
  }

  .confirm-actions {
    flex-direction: column-reverse;
  }

  .btn-confirm,
  .btn-cancel {
    width: 100%;
  }
}
</style>
