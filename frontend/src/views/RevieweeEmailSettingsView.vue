<template>
  <div class="email-settings-page">
    <div class="settings-shell">
      <header class="page-hero">
        <div class="title-stack">
          <router-link to="/exams" class="back-link">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path d="M15 18l-6-6 6-6" stroke-linecap="round" stroke-linejoin="round" stroke-width="2.4"/>
            </svg>
            My Exams
          </router-link>
          <h1>Score Email</h1>
          <p>Choose where CFAS sends your score summaries and spreadsheet reports.</p>
        </div>

        <div class="status-capsule" :class="{ empty: !currentEmail }">
          <span class="status-dot"></span>
          {{ currentEmail ? 'Ready for reports' : 'Email needed' }}
        </div>
      </header>

      <main class="settings-grid">
        <section class="settings-column">
          <div class="section-label">Delivery</div>

          <section class="settings-group recipient-group">
            <div class="settings-row recipient-row">
              <div class="row-leading mail-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <path d="M4 4h16v16H4z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                  <path d="M4 7l8 6 8-6" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                </svg>
              </div>

              <div class="row-copy">
                <h2>Score report recipient</h2>
                <p>{{ currentEmail || 'No email address saved yet' }}</p>
              </div>

              <span class="row-state" :class="{ empty: !currentEmail }">
                {{ currentEmail ? 'Active' : 'Not set' }}
              </span>
            </div>

            <form class="email-form" @submit.prevent="saveEmail">
              <label for="score-report-email">Email address</label>
              <div class="input-action-row">
                <input
                  id="score-report-email"
                  v-model="emailForm"
                  type="email"
                  placeholder="your.email@gmail.com"
                  autocomplete="email"
                  :disabled="savingEmail"
                />

                <button type="submit" class="btn-primary" :disabled="savingEmail || !hasChanges">
                  <span v-if="savingEmail" class="button-spinner"></span>
                  {{ savingEmail ? 'Saving' : 'Save' }}
                </button>
              </div>

              <p v-if="notice.message" class="form-notice" :class="notice.type">
                {{ notice.message }}
              </p>
            </form>
          </section>

          <section v-if="currentEmail" class="settings-group compact-group">
            <button
              type="button"
              class="destructive-row"
              :disabled="savingEmail"
              @click="clearEmail"
            >
              <span>Remove score email</span>
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M9 18l6-6-6-6" stroke-linecap="round" stroke-linejoin="round" stroke-width="2.2"/>
              </svg>
            </button>
          </section>
        </section>

        <aside class="settings-column side-column">
          <div class="section-label">Reports</div>

          <section class="settings-group report-group">
            <div class="settings-row">
              <div class="row-leading success-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <path d="M9 12l2 2 4-4" stroke-linecap="round" stroke-linejoin="round" stroke-width="2.4"/>
                  <path d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                </svg>
              </div>
              <div class="row-copy">
                <h2>Report package</h2>
                <p>Gmail summary plus XLSX attachment</p>
              </div>
            </div>

            <div class="row-divider"></div>

            <div class="feature-row">
              <span class="feature-dot"></span>
              <span>Professional score summary</span>
            </div>
            <div class="feature-row">
              <span class="feature-dot"></span>
              <span>Downloadable spreadsheet data</span>
            </div>
            <div class="feature-row">
              <span class="feature-dot"></span>
              <span>Sent by admin from Export Results</span>
            </div>
          </section>
        </aside>
      </main>
    </div>

    <transition name="modal-fade">
      <div v-if="confirmation.show" class="confirm-overlay" @click.self="closeConfirmation">
        <transition name="modal-scale">
          <section
            v-if="confirmation.show"
            class="confirm-dialog"
            role="dialog"
            aria-modal="true"
            aria-labelledby="email-confirm-title"
          >
            <div class="confirm-icon" :class="{ danger: confirmation.action === 'remove' }">
              <svg v-if="confirmation.action === 'remove'" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M12 9v4" stroke-linecap="round" stroke-linejoin="round" stroke-width="2.4"/>
                <path d="M12 17h.01" stroke-linecap="round" stroke-linejoin="round" stroke-width="2.4"/>
                <path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
              </svg>
              <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M4 4h16v16H4z" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
                <path d="M4 7l8 6 8-6" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
              </svg>
            </div>

            <h2 id="email-confirm-title">{{ confirmationTitle }}</h2>
            <p>{{ confirmationMessage }}</p>

            <div class="confirm-actions">
              <button type="button" class="confirm-cancel" :disabled="savingEmail" @click="closeConfirmation">
                Cancel
              </button>
              <button
                type="button"
                class="confirm-primary"
                :class="{ danger: confirmation.action === 'remove' }"
                :disabled="savingEmail"
                @click="confirmEmailAction"
              >
                <span v-if="savingEmail" class="button-spinner"></span>
                {{ savingEmail ? 'Please wait' : confirmationButtonLabel }}
              </button>
            </div>
          </section>
        </transition>
      </div>
    </transition>
  </div>
</template>

<script setup>
import { computed, ref, watch } from 'vue'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()

const currentEmail = computed(() => authStore.user?.email || '')
const emailForm = ref(currentEmail.value)
const hasChanges = computed(() => emailForm.value.trim() !== currentEmail.value)
const savingEmail = ref(false)
const notice = ref({
  type: 'success',
  message: ''
})
const confirmation = ref({
  show: false,
  action: null,
  email: ''
})

const confirmationTitle = computed(() => (
  confirmation.value.action === 'remove'
    ? 'Remove score email?'
    : 'Save this score email?'
))

const confirmationMessage = computed(() => {
  if (confirmation.value.action === 'remove') {
    return 'Score summaries will no longer be sent to your email until you add a new address.'
  }

  return `Future score summaries will be sent to ${confirmation.value.email || 'this email address'}.`
})

const confirmationButtonLabel = computed(() => (
  confirmation.value.action === 'remove' ? 'Remove Email' : 'Save Email'
))

watch(currentEmail, (email) => {
  if (!savingEmail.value) {
    emailForm.value = email
  }
})

const persistEmail = async (email) => {
  savingEmail.value = true
  notice.value = { type: 'success', message: '' }

  try {
    const result = await authStore.updateEmail(email)

    if (result.success) {
      emailForm.value = currentEmail.value
    }

    notice.value = result.success
      ? { type: 'success', message: result.message }
      : { type: 'error', message: result.error }
  } finally {
    savingEmail.value = false
  }
}

const saveEmail = async () => {
  confirmation.value = {
    show: true,
    action: 'save',
    email: emailForm.value.trim()
  }
}

const clearEmail = async () => {
  confirmation.value = {
    show: true,
    action: 'remove',
    email: currentEmail.value
  }
}

const closeConfirmation = () => {
  if (savingEmail.value) {
    return
  }

  confirmation.value = {
    show: false,
    action: null,
    email: ''
  }
}

const confirmEmailAction = async () => {
  const action = confirmation.value.action
  const email = action === 'remove' ? '' : confirmation.value.email

  await persistEmail(email)
  closeConfirmation()
}
</script>

<style scoped>
.email-settings-page {
  min-height: 100vh;
  background:
    linear-gradient(180deg, #FFFFFF 0%, #F7F7FA 260px, #F5F5F7 100%);
  color: #1D1D1F;
  font-family: -apple-system, BlinkMacSystemFont, "SF Pro Display", "Segoe UI", sans-serif;
}

.settings-shell {
  width: min(1180px, calc(100% - 96px));
  margin: 0 auto;
  padding: 34px 0 56px;
}

.page-hero {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 32px;
  padding-bottom: 30px;
}

.title-stack {
  min-width: 0;
}

.back-link {
  width: fit-content;
  min-height: 30px;
  display: inline-flex;
  align-items: center;
  gap: 5px;
  color: #007AFF;
  text-decoration: none;
  font-size: 14px;
  font-weight: 650;
  letter-spacing: 0;
  margin-bottom: 10px;
  transition: color 0.2s;
}

.back-link:hover {
  color: #005EC8;
}

.back-link svg {
  width: 18px;
  height: 18px;
  stroke-width: 2.4;
}

.page-hero h1 {
  margin: 0 0 10px;
  font-size: 40px;
  font-weight: 760;
  color: #1D1D1F;
  letter-spacing: 0;
  line-height: 1.08;
}

.page-hero p {
  margin: 0;
  max-width: 560px;
  font-size: 16px;
  color: #6E6E73;
  line-height: 1.5;
  letter-spacing: 0;
}

.status-capsule {
  min-height: 34px;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 7px 14px;
  background: #E8F7ED;
  color: #0A7A35;
  border-radius: 999px;
  font-size: 13px;
  font-weight: 700;
  letter-spacing: 0;
  white-space: nowrap;
}

.status-capsule.empty {
  background: #FFF3D7;
  color: #9A5A00;
}

.status-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: currentColor;
}

.settings-grid {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 360px;
  gap: 24px;
  align-items: start;
}

.settings-column {
  display: grid;
  gap: 12px;
}

.section-label {
  padding: 0 4px;
  color: #6E6E73;
  font-size: 13px;
  font-weight: 700;
  letter-spacing: 0;
}

.settings-group {
  background: rgba(255, 255, 255, 0.88);
  border: 1px solid rgba(0, 0, 0, 0.06);
  border-radius: 18px;
  box-shadow: 0 18px 44px rgba(0, 0, 0, 0.07);
  overflow: hidden;
  backdrop-filter: blur(18px);
  -webkit-backdrop-filter: blur(18px);
}

.recipient-group {
  padding: 0;
}

.settings-row {
  min-height: 86px;
  padding: 22px 24px;
  display: flex;
  align-items: center;
  gap: 16px;
}

.row-leading {
  width: 44px;
  height: 44px;
  border-radius: 13px;
  display: grid;
  place-items: center;
  flex: 0 0 auto;
}

.mail-icon {
  color: #007AFF;
  background: #EAF4FF;
}

.success-icon {
  color: #0A7A35;
  background: #E8F7ED;
}

.row-leading svg {
  width: 24px;
  height: 24px;
  stroke-width: 2;
}

.row-copy {
  flex: 1;
  min-width: 0;
}

.row-copy h2 {
  margin: 0 0 4px;
  font-size: 18px;
  font-weight: 760;
  color: #1D1D1F;
  letter-spacing: 0;
  line-height: 1.25;
}

.row-copy p {
  margin: 0;
  font-size: 14px;
  line-height: 1.5;
  color: #6E6E73;
  letter-spacing: 0;
  overflow-wrap: anywhere;
}

.row-state {
  min-height: 30px;
  display: inline-flex;
  align-items: center;
  padding: 5px 10px;
  color: #0A7A35;
  background: #E8F7ED;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 760;
  letter-spacing: 0;
  white-space: nowrap;
}

.row-state.empty {
  color: #9A5A00;
  background: #FFF3D7;
}

.email-form {
  padding: 0 24px 24px 84px;
  display: flex;
  flex-direction: column;
  gap: 9px;
}

.email-form label {
  font-size: 13px;
  font-weight: 720;
  color: #424245;
  letter-spacing: 0;
}

.input-action-row {
  display: grid;
  grid-template-columns: minmax(0, 1fr) auto;
  gap: 10px;
  align-items: center;
}

.input-action-row input {
  width: 100%;
  height: 46px;
  padding: 0 14px;
  background: #F5F5F7;
  border: 1px solid transparent;
  border-radius: 12px;
  color: #1D1D1F;
  font-size: 15px;
  letter-spacing: 0;
  transition: background 0.2s, border-color 0.2s, box-shadow 0.2s;
}

.input-action-row input:focus {
  outline: none;
  background: #FFFFFF;
  border-color: rgba(0, 122, 255, 0.72);
  box-shadow: 0 0 0 4px rgba(0, 122, 255, 0.13);
}

.input-action-row input:disabled {
  opacity: 0.65;
  cursor: not-allowed;
}

.form-notice {
  margin: 3px 0 0;
  font-size: 13px;
  line-height: 1.4;
  letter-spacing: 0;
}

.form-notice.success {
  color: #0A7A35;
}

.form-notice.error {
  color: #D70015;
}

.btn-primary {
  min-width: 96px;
  height: 46px;
  padding: 0 18px;
  border: none;
  border-radius: 12px;
  background: #007AFF;
  color: #FFFFFF;
  box-shadow: 0 10px 20px rgba(0, 122, 255, 0.22);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  font-size: 14px;
  font-weight: 760;
  letter-spacing: 0;
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s, opacity 0.2s, background 0.2s;
}

.btn-primary:hover {
  background: #006EE6;
  transform: translateY(-1px);
  box-shadow: 0 12px 24px rgba(0, 122, 255, 0.26);
}

.btn-primary:disabled {
  opacity: 0.48;
  cursor: not-allowed;
  transform: none;
  box-shadow: 0 8px 16px rgba(0, 122, 255, 0.1);
}

.button-spinner {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255, 255, 255, 0.45);
  border-top-color: #FFFFFF;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

.compact-group {
  box-shadow: none;
}

.destructive-row {
  width: 100%;
  min-height: 54px;
  padding: 0 18px 0 24px;
  border: 0;
  background: #FFFFFF;
  color: #D70015;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 14px;
  cursor: pointer;
  font-size: 15px;
  font-weight: 700;
  letter-spacing: 0;
  text-align: left;
  transition: background 0.2s;
}

.destructive-row:hover {
  background: #FFF2F2;
}

.destructive-row:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}

.destructive-row svg {
  width: 18px;
  height: 18px;
  stroke-width: 2.2;
  flex-shrink: 0;
}

.side-column {
  position: sticky;
  top: 24px;
}

.report-group {
  padding-bottom: 10px;
}

.row-divider {
  height: 1px;
  margin-left: 84px;
  background: rgba(0, 0, 0, 0.07);
}

.feature-row {
  min-height: 44px;
  padding: 0 22px 0 84px;
  display: flex;
  align-items: center;
  gap: 11px;
  color: #1D1D1F;
  font-size: 14px;
  font-weight: 650;
  line-height: 1.4;
  letter-spacing: 0;
}

.feature-dot {
  width: 7px;
  height: 7px;
  border-radius: 50%;
  background: #007AFF;
  flex: 0 0 auto;
}

.confirm-overlay {
  position: fixed;
  inset: 0;
  z-index: 10000;
  padding: 24px;
  background: rgba(15, 23, 42, 0.34);
  backdrop-filter: blur(18px);
  -webkit-backdrop-filter: blur(18px);
  display: flex;
  align-items: center;
  justify-content: center;
}

.confirm-dialog {
  width: min(420px, 100%);
  background: rgba(255, 255, 255, 0.96);
  border: 1px solid rgba(255, 255, 255, 0.72);
  border-radius: 22px;
  box-shadow: 0 26px 80px rgba(0, 0, 0, 0.28);
  padding: 28px;
  text-align: center;
}

.confirm-icon {
  width: 58px;
  height: 58px;
  margin: 0 auto 18px;
  border-radius: 18px;
  display: grid;
  place-items: center;
  background: #EAF4FF;
  color: #007AFF;
}

.confirm-icon.danger {
  background: #FFF1F1;
  color: #D70015;
}

.confirm-icon svg {
  width: 29px;
  height: 29px;
  stroke-width: 2;
}

.confirm-dialog h2 {
  margin: 0 0 8px;
  color: #1D1D1F;
  font-size: 22px;
  font-weight: 760;
  line-height: 1.25;
  letter-spacing: 0;
}

.confirm-dialog p {
  margin: 0;
  color: #6E6E73;
  font-size: 15px;
  line-height: 1.5;
  letter-spacing: 0;
  overflow-wrap: anywhere;
}

.confirm-actions {
  margin-top: 24px;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}

.confirm-cancel,
.confirm-primary {
  min-height: 46px;
  border: 0;
  border-radius: 14px;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  font-size: 14px;
  font-weight: 760;
  letter-spacing: 0;
  transition: transform 0.2s, background 0.2s, opacity 0.2s, box-shadow 0.2s;
}

.confirm-cancel {
  background: #F5F5F7;
  color: #1D1D1F;
}

.confirm-primary {
  background: #007AFF;
  color: #FFFFFF;
  box-shadow: 0 10px 20px rgba(0, 122, 255, 0.22);
}

.confirm-primary.danger {
  background: #D70015;
  box-shadow: 0 10px 20px rgba(215, 0, 21, 0.22);
}

.confirm-cancel:hover,
.confirm-primary:hover {
  transform: translateY(-1px);
}

.confirm-cancel:hover {
  background: #EAEAED;
}

.confirm-primary:hover {
  background: #006EE6;
}

.confirm-primary.danger:hover {
  background: #C30013;
}

.confirm-cancel:disabled,
.confirm-primary:disabled {
  opacity: 0.62;
  cursor: not-allowed;
  transform: none;
}

.modal-fade-enter-active,
.modal-fade-leave-active {
  transition: opacity 0.22s ease;
}

.modal-fade-enter-from,
.modal-fade-leave-to {
  opacity: 0;
}

.modal-scale-enter-active {
  transition: transform 0.24s cubic-bezier(0.34, 1.56, 0.64, 1), opacity 0.2s ease;
}

.modal-scale-leave-active {
  transition: transform 0.16s ease, opacity 0.16s ease;
}

.modal-scale-enter-from,
.modal-scale-leave-to {
  opacity: 0;
  transform: scale(0.94) translateY(10px);
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

@media (max-width: 1024px) {
  .settings-shell {
    width: calc(100% - 64px);
    padding-top: 30px;
  }

  .settings-grid {
    grid-template-columns: 1fr;
  }

  .side-column {
    position: static;
  }
}

@media (max-width: 768px) {
  .settings-shell {
    width: calc(100% - 32px);
    padding: 18px 0 28px;
  }

  .page-hero {
    flex-direction: column;
    gap: 16px;
    padding-bottom: 22px;
  }

  .page-hero h1 {
    font-size: 32px;
  }

  .page-hero p {
    font-size: 15px;
  }

  .status-capsule {
    align-self: flex-start;
  }

  .settings-grid {
    gap: 18px;
  }

  .settings-row {
    padding: 18px;
    align-items: flex-start;
  }

  .row-state {
    margin-top: 4px;
  }

  .email-form {
    padding: 0 18px 18px;
  }

  .input-action-row {
    grid-template-columns: 1fr;
  }

  .btn-primary {
    width: 100%;
  }

  .row-divider {
    margin-left: 72px;
  }

  .feature-row {
    padding-left: 72px;
  }

  .confirm-overlay {
    align-items: flex-end;
    padding: 16px;
  }

  .confirm-dialog {
    padding: 24px 20px 20px;
    border-radius: 20px;
  }

  .confirm-actions {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 560px) {
  .settings-shell {
    width: calc(100% - 24px);
  }

  .back-link {
    min-height: 26px;
    margin-bottom: 8px;
    font-size: 13px;
  }

  .page-hero h1 {
    font-size: 28px;
  }

  .page-hero p {
    font-size: 14px;
  }

  .status-capsule {
    min-height: 30px;
    padding: 6px 11px;
    font-size: 12px;
  }

  .settings-group {
    border-radius: 16px;
  }

  .recipient-row {
    display: grid;
    grid-template-columns: 42px minmax(0, 1fr);
    gap: 13px;
  }

  .recipient-row .row-state {
    grid-column: 2;
    justify-self: start;
    margin-top: -4px;
  }

  .row-leading {
    width: 42px;
    height: 42px;
    border-radius: 12px;
  }

  .row-leading svg {
    width: 22px;
    height: 22px;
  }

  .row-copy h2 {
    font-size: 16px;
  }

  .row-copy p {
    font-size: 13px;
  }

  .input-action-row input,
  .btn-primary {
    height: 44px;
  }

  .destructive-row {
    min-height: 52px;
    padding: 0 16px;
    font-size: 14px;
  }

  .report-group .settings-row {
    display: grid;
    grid-template-columns: 42px minmax(0, 1fr);
    gap: 13px;
  }

  .row-divider {
    margin-left: 18px;
    margin-right: 18px;
  }

  .feature-row {
    min-height: auto;
    padding: 12px 18px;
    align-items: flex-start;
    font-size: 13px;
  }
}

@media (max-width: 380px) {
  .settings-shell {
    width: calc(100% - 20px);
  }

  .settings-row {
    padding: 16px;
  }

  .email-form {
    padding: 0 16px 16px;
  }

  .page-hero h1 {
    font-size: 26px;
  }

  .confirm-dialog {
    padding: 22px 18px 18px;
  }
}
</style>
