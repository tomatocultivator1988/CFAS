<template>
  <div class="student-risk-card">
    <div class="top-toolbar">
      <div class="segmented-toggle">
        <button :class="{ active: viewMode === 'table' }" @click="viewMode = 'table'">Table</button>
        <button :class="{ active: viewMode === 'cards' }" @click="viewMode = 'cards'">Cards</button>
      </div>

      <div class="search-wrap">
        <input v-model="searchQuery" type="text" placeholder="Search student" />
      </div>
    </div>

    <div class="divider"></div>

    <div class="chip-row">
      <button class="chip all" :class="{ active: riskFilter === 'all' }" @click="riskFilter = 'all'">
        All <span>{{ searchedStudents.length }}</span>
      </button>
      <button class="chip high" :class="{ active: riskFilter === 'High' }" @click="riskFilter = 'High'">
        High <span>{{ riskCounts.high }}</span>
      </button>
      <button class="chip medium" :class="{ active: riskFilter === 'Medium' }" @click="riskFilter = 'Medium'">
        Medium <span>{{ riskCounts.medium }}</span>
      </button>
      <button class="chip low" :class="{ active: riskFilter === 'Low' }" @click="riskFilter = 'Low'">
        Low <span>{{ riskCounts.low }}</span>
      </button>
    </div>

    <div class="divider"></div>

    <div v-if="sortedStudents.length === 0" class="empty-state">
      <h3>No matching students</h3>
      <p>Try a different keyword or risk filter.</p>
    </div>

    <div v-else-if="viewMode === 'table'" class="table-wrap">
      <table>
        <thead>
          <tr>
            <th :class="headerClass('name')" @click="setSort('name')">
              <span>Name</span>
              <span class="arrow">{{ sortArrow('name') }}</span>
            </th>
            <th :class="headerClass('attempts')" @click="setSort('attempts')">
              <span>Attempts</span>
              <span class="arrow">{{ sortArrow('attempts') }}</span>
            </th>
            <th :class="headerClass('latest')" @click="setSort('latest')">
              <span>Latest</span>
              <span class="arrow">{{ sortArrow('latest') }}</span>
            </th>
            <th :class="headerClass('avg')" @click="setSort('avg')">
              <span>Average</span>
              <span class="arrow">{{ sortArrow('avg') }}</span>
            </th>
            <th :class="headerClass('actual')" @click="setSort('actual')">
              <span>Actual</span>
              <span class="arrow">{{ sortArrow('actual') }}</span>
            </th>
            <th :class="headerClass('predPass')" @click="setSort('predPass')">
              <span>Pred Pass</span>
              <span class="arrow">{{ sortArrow('predPass') }}</span>
            </th>
            <th :class="headerClass('predFail')" @click="setSort('predFail')">
              <span>Pred Fail</span>
              <span class="arrow">{{ sortArrow('predFail') }}</span>
            </th>
            <th :class="headerClass('risk')" @click="setSort('risk')">
              <span>Risk</span>
              <span class="arrow">{{ sortArrow('risk') }}</span>
            </th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="student in sortedStudents" :key="student.name">
            <td>
              <div class="name-cell">
                <div class="avatar">{{ initials(student.name) }}</div>
                <span class="name-text">{{ student.name }}</span>
              </div>
            </td>
            <td>{{ student.attempts }}</td>
            <td :class="scoreClass(student.latest)">{{ formatPercent(student.latest) }}</td>
            <td :class="scoreClass(student.avg)">{{ formatPercent(student.avg) }}</td>
            <td :class="scoreClass(student.actual)">{{ formatPercent(student.actual) }}</td>
            <td :class="scoreClass(student.predPass)">{{ formatPercent(student.predPass) }}</td>
            <td :class="failClass(student.predFail)">{{ formatPercent(student.predFail) }}</td>
            <td>
              <span class="risk-badge" :class="riskClass(student.risk)">{{ student.risk }}</span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-else class="cards-grid">
      <div v-for="student in sortedStudents" :key="student.name" class="student-card">
        <div class="card-head">
          <div class="name-cell">
            <div class="avatar">{{ initials(student.name) }}</div>
            <span class="name-text">{{ student.name }}</span>
          </div>
          <span class="risk-badge" :class="riskClass(student.risk)">{{ student.risk }}</span>
        </div>
        <div class="tile-grid">
          <div class="tile">
            <span>Attempts</span>
            <strong>{{ student.attempts }}</strong>
          </div>
          <div class="tile">
            <span>Latest</span>
            <strong :class="scoreClass(student.latest)">{{ formatPercent(student.latest) }}</strong>
          </div>
          <div class="tile">
            <span>Average</span>
            <strong :class="scoreClass(student.avg)">{{ formatPercent(student.avg) }}</strong>
          </div>
          <div class="tile">
            <span>Pred Pass</span>
            <strong :class="scoreClass(student.predPass)">{{ formatPercent(student.predPass) }}</strong>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'

const props = defineProps({
  students: {
    type: Array,
    default: () => []
  }
})

const searchQuery = ref('')
const riskFilter = ref('all')
const viewMode = ref('table')
const sortKey = ref('predFail')
const sortDirection = ref('desc')

const normalizedStudents = computed(() =>
  (props.students || []).map((student) => ({
    name: student.name || '',
    attempts: Number(student.attempts || 0),
    latest: Number(student.latest || 0),
    avg: Number(student.avg || 0),
    actual: Number(student.actual || 0),
    predPass: Number(student.predPass || 0),
    predFail: Number(student.predFail || 0),
    risk: student.risk || 'Medium'
  }))
)

const searchedStudents = computed(() => {
  const query = searchQuery.value.trim().toLowerCase()
  if (!query) return normalizedStudents.value
  return normalizedStudents.value.filter((student) => student.name.toLowerCase().includes(query))
})

const riskCounts = computed(() => ({
  high: searchedStudents.value.filter((student) => student.risk === 'High').length,
  medium: searchedStudents.value.filter((student) => student.risk === 'Medium').length,
  low: searchedStudents.value.filter((student) => student.risk === 'Low').length
}))

const filteredStudents = computed(() => {
  if (riskFilter.value === 'all') return searchedStudents.value
  return searchedStudents.value.filter((student) => student.risk === riskFilter.value)
})

const sortedStudents = computed(() => {
  const riskRank = { High: 3, Medium: 2, Low: 1 }
  return [...filteredStudents.value].sort((a, b) => {
    let result = 0
    if (sortKey.value === 'name') {
      result = a.name.localeCompare(b.name)
    } else if (sortKey.value === 'risk') {
      result = (riskRank[a.risk] || 0) - (riskRank[b.risk] || 0)
    } else {
      result = Number(a[sortKey.value] || 0) - Number(b[sortKey.value] || 0)
    }
    return sortDirection.value === 'asc' ? result : -result
  })
})

const setSort = (key) => {
  if (sortKey.value === key) {
    sortDirection.value = sortDirection.value === 'asc' ? 'desc' : 'asc'
    return
  }
  sortKey.value = key
  sortDirection.value = key === 'name' ? 'asc' : 'desc'
}

const sortArrow = (key) => {
  if (sortKey.value !== key) return '↕'
  return sortDirection.value === 'asc' ? '↑' : '↓'
}

const headerClass = (key) => ({
  sortable: true,
  sorted: sortKey.value === key
})

const formatPercent = (value) => `${Number(value || 0).toFixed(2)}%`

const scoreClass = (value) => {
  const score = Number(value || 0)
  if (score >= 85) return 'score-good'
  if (score >= 70) return 'score-mid'
  return 'score-bad'
}

const failClass = (value) => {
  const score = Number(value || 0)
  if (score >= 85) return 'score-bad'
  if (score >= 70) return 'score-mid'
  return 'score-good'
}

const riskClass = (risk) => {
  if (risk === 'High') return 'risk-high'
  if (risk === 'Medium') return 'risk-medium'
  return 'risk-low'
}

const initials = (name) => {
  const parts = String(name || '').trim().split(/\s+/).filter(Boolean).slice(0, 2)
  if (parts.length === 0) return 'NA'
  return parts.map((part) => part.charAt(0).toUpperCase()).join('')
}
</script>

<style scoped>
.student-risk-card {
  font-family: -apple-system, BlinkMacSystemFont, 'Helvetica Neue', sans-serif;
  background: rgba(255, 255, 255, 0.75);
  border-radius: 22px;
  border: 0.5px solid rgba(255, 255, 255, 0.9);
  padding: 14px;
}

.top-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 10px;
}

.segmented-toggle {
  background: rgba(118, 118, 128, 0.12);
  border-radius: 11px;
  padding: 3px;
  display: inline-flex;
}

.segmented-toggle button {
  border: none;
  background: transparent;
  color: rgba(60, 60, 67, 0.72);
  border-radius: 9px;
  padding: 7px 13px;
  font-weight: 600;
  cursor: pointer;
}

.segmented-toggle button.active {
  background: #FFFFFF;
  color: #1D1D1F;
}

.search-wrap {
  position: relative;
  width: 250px;
  max-width: 100%;
}

.search-wrap::before {
  content: '';
  position: absolute;
  left: 10px;
  top: 50%;
  transform: translateY(-50%);
  width: 14px;
  height: 14px;
  pointer-events: none;
  background-repeat: no-repeat;
  background-size: 14px 14px;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='%238E8E93' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Ccircle cx='11' cy='11' r='7'/%3E%3Cline x1='21' y1='21' x2='16.65' y2='16.65'/%3E%3C/svg%3E");
}

.search-wrap input {
  width: 100%;
  box-sizing: border-box;
  border: 0.5px solid rgba(60, 60, 67, 0.15);
  border-radius: 10px;
  background: rgba(118, 118, 128, 0.1);
  color: #1D1D1F;
  font-size: 14px;
  padding: 9px 12px 9px 32px;
}

.divider {
  margin: 12px 0;
  height: 0.5px;
  background: rgba(60, 60, 67, 0.1);
}

.chip-row {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.chip {
  border: 0.5px solid transparent;
  border-radius: 20px;
  padding: 7px 13px;
  font-size: 13px;
  font-weight: 500;
  color: rgba(60, 60, 67, 0.55);
  background: rgba(118, 118, 128, 0.1);
  display: inline-flex;
  align-items: center;
  gap: 6px;
  cursor: pointer;
  transition: all 0.15s cubic-bezier(0.4, 0, 0.2, 1);
}

.chip:active {
  transform: scale(0.96);
}

.chip span {
  border-radius: 99px;
  background: rgba(255, 255, 255, 0.75);
  padding: 2px 7px;
}

.chip.all.active {
  color: #007AFF;
  background: rgba(10, 132, 255, 0.12);
  border-color: rgba(10, 132, 255, 0.35);
}

.chip.high.active {
  color: #FF3B30;
  background: rgba(255, 59, 48, 0.1);
  border-color: rgba(255, 59, 48, 0.3);
}

.chip.medium.active {
  color: #FF9500;
  background: rgba(255, 149, 0, 0.1);
  border-color: rgba(255, 149, 0, 0.3);
}

.chip.low.active {
  color: #34C759;
  background: rgba(52, 199, 89, 0.1);
  border-color: rgba(52, 199, 89, 0.3);
}

.table-wrap {
  overflow-x: auto;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th,
td {
  padding: 11px 10px;
  border-bottom: 0.5px solid rgba(60, 60, 67, 0.1);
  text-align: left;
  white-space: nowrap;
}

th {
  font-size: 10px;
  text-transform: uppercase;
  letter-spacing: 0.07em;
  color: rgba(60, 60, 67, 0.55);
  user-select: none;
}

th.sortable {
  cursor: pointer;
}

th.sortable span.arrow {
  margin-left: 5px;
  font-size: 10px;
}

th.sorted {
  color: #007AFF;
}

.name-cell {
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.avatar {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 11px;
  font-weight: 700;
  background: rgba(10, 132, 255, 0.1);
  color: #0055B3;
}

.name-text {
  font-weight: 600;
  color: #1D1D1F;
}

.risk-badge {
  border-radius: 999px;
  font-size: 11px;
  font-weight: 600;
  padding: 4px 10px;
  border: 0.5px solid transparent;
}

.risk-high {
  color: #C0392B;
  border-color: rgba(255, 59, 48, 0.35);
  background: rgba(255, 59, 48, 0.12);
}

.risk-medium {
  color: #B95000;
  border-color: rgba(255, 149, 0, 0.35);
  background: rgba(255, 149, 0, 0.12);
}

.risk-low {
  color: #1A7F37;
  border-color: rgba(52, 199, 89, 0.35);
  background: rgba(52, 199, 89, 0.12);
}

.cards-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 10px;
}

.student-card {
  border: 0.5px solid rgba(60, 60, 67, 0.12);
  border-radius: 16px;
  padding: 12px;
  background: rgba(255, 255, 255, 0.65);
}

.card-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 8px;
}

.tile-grid {
  margin-top: 10px;
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 8px;
}

.tile {
  border-radius: 11px;
  border: 0.5px solid rgba(60, 60, 67, 0.12);
  background: rgba(118, 118, 128, 0.08);
  padding: 8px;
}

.tile span {
  font-size: 11px;
  color: rgba(60, 60, 67, 0.6);
}

.tile strong {
  margin-top: 3px;
  display: block;
  font-size: 14px;
}

.score-good {
  color: #1A7F37;
}

.score-mid {
  color: #B95000;
}

.score-bad {
  color: #C0392B;
}

.empty-state {
  text-align: center;
  padding: 24px 12px;
}

.empty-state h3 {
  margin: 0;
  color: #1D1D1F;
  font-size: 16px;
}

.empty-state p {
  margin: 6px 0 0;
  font-size: 13px;
  color: rgba(60, 60, 67, 0.65);
}

@media (prefers-color-scheme: dark) {
  .student-risk-card {
    background: rgba(28, 28, 30, 0.85);
    border-color: rgba(255, 255, 255, 0.1);
  }

  .segmented-toggle {
    background: rgba(118, 118, 128, 0.2);
  }

  .segmented-toggle button {
    color: rgba(235, 235, 245, 0.75);
  }

  .segmented-toggle button.active {
    background: rgba(255, 255, 255, 0.12);
    color: #F2F2F7;
  }

  .search-wrap input {
    background: rgba(44, 44, 50, 0.8);
    color: #F2F2F7;
    border-color: rgba(255, 255, 255, 0.16);
  }

  .divider {
    background: rgba(60, 60, 67, 0.3);
  }

  .chip {
    background: rgba(118, 118, 128, 0.2);
    color: rgba(235, 235, 245, 0.65);
  }

  .chip span {
    background: rgba(255, 255, 255, 0.12);
    color: #F2F2F7;
  }

  .chip.all.active {
    color: #4DA3FF;
    background: rgba(77, 163, 255, 0.15);
    border-color: rgba(77, 163, 255, 0.4);
  }

  .chip.high.active {
    color: #FF6B6B;
    background: rgba(255, 107, 107, 0.16);
    border-color: rgba(255, 107, 107, 0.4);
  }

  .chip.medium.active {
    color: #FFAA33;
    background: rgba(255, 170, 51, 0.16);
    border-color: rgba(255, 170, 51, 0.4);
  }

  .chip.low.active {
    color: #4CD964;
    background: rgba(76, 217, 100, 0.16);
    border-color: rgba(76, 217, 100, 0.4);
  }

  th {
    color: rgba(235, 235, 245, 0.55);
  }

  td,
  .name-text {
    color: #F2F2F7;
  }

  th.sorted {
    color: #4DA3FF;
  }

  .student-card {
    background: rgba(44, 44, 50, 0.58);
    border-color: rgba(255, 255, 255, 0.12);
  }

  .tile {
    background: rgba(44, 44, 50, 0.8);
    border-color: rgba(255, 255, 255, 0.14);
  }

  .tile span {
    color: rgba(235, 235, 245, 0.62);
  }

  .risk-high {
    color: #FF6B6B;
    border-color: rgba(255, 107, 107, 0.45);
    background: rgba(255, 107, 107, 0.18);
  }

  .risk-medium {
    color: #FFAA33;
    border-color: rgba(255, 170, 51, 0.45);
    background: rgba(255, 170, 51, 0.18);
  }

  .risk-low {
    color: #4CD964;
    border-color: rgba(76, 217, 100, 0.45);
    background: rgba(76, 217, 100, 0.18);
  }

  .score-good {
    color: #34C759;
  }

  .score-mid {
    color: #FF9500;
  }

  .score-bad {
    color: #FF453A;
  }

  .empty-state h3 {
    color: #F2F2F7;
  }

  .empty-state p {
    color: rgba(235, 235, 245, 0.7);
  }
}

@media (max-width: 900px) {
  .top-toolbar {
    flex-direction: column;
    align-items: stretch;
  }

  .search-wrap {
    width: 100%;
  }

  .cards-grid {
    grid-template-columns: 1fr;
  }
}
</style>
