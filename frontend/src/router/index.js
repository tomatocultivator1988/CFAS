import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      redirect: '/login'
    },
    {
      path: '/login',
      name: 'login',
      component: () => import('@/views/LoginView.vue'),
      meta: { requiresAuth: false }
    },
    {
      path: '/exams',
      component: () => import('@/views/RevieweeDashboardView.vue'),
      meta: { requiresAuth: true, role: 'reviewee' },
      children: [
        {
          path: '',
          name: 'exam-list',
          component: () => import('@/views/ExamListView.vue')
        },
        {
          path: ':id/results',
          name: 'exam-results',
          component: () => import('@/views/ExamResultsView.vue')
        }
      ]
    },
    {
      path: '/exams/:id/take',
      name: 'exam-taking',
      component: () => import('@/views/ExamTakingView.vue'),
      meta: { requiresAuth: true, role: 'reviewee', isExamMode: true }
    },
    {
      path: '/admin',
      component: () => import('@/views/AdminDashboardView.vue'),
      meta: { requiresAuth: true, role: 'admin' },
      children: [
        {
          path: '',
          name: 'admin-home',
          component: () => import('@/views/admin/DashboardHome.vue')
        },
        {
          path: 'exams',
          name: 'admin-exams',
          component: () => import('@/components/admin/ExamManagement.vue')
        },
        {
          path: 'exams/:id',
          name: 'admin-exam-detail',
          component: () => import('@/views/admin/ExamDetailView.vue')
        },
        {
          path: 'questions',
          name: 'admin-questions',
          component: () => import('@/views/admin/QuestionManagement.vue')
        },
        {
          path: 'users',
          name: 'admin-users',
          component: () => import('@/views/admin/UserManagement.vue')
        },
        {
          path: 'analytics',
          name: 'admin-analytics',
          component: () => import('@/views/admin/AnalyticsDashboard.vue')
        },
        {
          path: 'ml-predictive',
          name: 'admin-ml-predictive',
          component: () => import('@/views/admin/MlPredictiveView.vue')
        },
        {
          path: 'exports',
          name: 'admin-exports',
          component: () => import('@/views/admin/ExportReports.vue')
        },
        {
          path: 'scores',
          name: 'admin-scores',
          component: () => import('@/views/admin/ViewScores.vue')
        }
      ]
    }
  ]
})

// Navigation guard for authentication
router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore()
  
  // Prevent navigation away from exam taking page
  if (from.meta.isExamMode && to.name !== 'exam-results' && to.name !== 'exam-list') {
    // Only allow going to results or exam list (after submission)
    const confirmLeave = confirm('Are you sure you want to leave the exam? Your progress may be lost.')
    if (!confirmLeave) {
      next(false)
      return
    }
  }
  
  // Skip validation for login page
  if (to.path === '/login') {
    if (authStore.isAuthenticated) {
      // Redirect to appropriate dashboard if already logged in
      const redirectPath = authStore.user?.role === 'admin' ? '/admin' : '/exams'
      next(redirectPath)
    } else {
      next()
    }
    return
  }
  
  // Check if route requires authentication
  if (to.meta.requiresAuth) {
    // Check if user is authenticated (simple check, no validation call)
    if (!authStore.isAuthenticated) {
      next('/login')
      return
    }
    
    // Check role-based access
    if (to.meta.role && authStore.user?.role !== to.meta.role) {
      // Redirect to appropriate dashboard based on role
      const redirectPath = authStore.user?.role === 'admin' ? '/admin' : '/exams'
      next(redirectPath)
      return
    }
  }
  
  next()
})

export default router
