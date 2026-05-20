# Performance Optimization Guide

This document outlines the performance optimizations implemented in the Review Center Examination System.

## Backend Optimizations

### 1. Database Query Optimization

#### Eager Loading
Always use eager loading to prevent N+1 query problems:

```php
// Bad - N+1 queries
$exams = Exam::all();
foreach ($exams as $exam) {
    echo $exam->questions->count(); // Separate query for each exam
}

// Good - Single query with eager loading
$exams = Exam::with('questions')->get();
foreach ($exams as $exam) {
    echo $exam->questions->count(); // No additional queries
}
```

#### Database Indexes
The following indexes are already created in migrations:
- `users`: index on `username`, `email`, `role`
- `exams`: index on `created_by`, `deleted_at`
- `questions`: index on `topic`, `deleted_at`
- `exam_attempts`: index on `user_id`, `exam_id`, `status`
- `auth_tokens`: index on `token`, `expires_at`

### 2. Caching Strategy

#### Cache Configuration
Cache settings are in `config/cache.php`:
- Exams: 1 hour TTL
- Questions: 1 hour TTL
- Users: 30 minutes TTL
- Analytics: 10 minutes TTL

#### Using CacheService
```php
use App\Services\CacheService;

$cacheService = new CacheService();

// Cache exam data
$cacheService->cacheExam($examId, $examData);

// Retrieve cached exam
$exam = $cacheService->getCachedExam($examId);

// Clear cache when data changes
$cacheService->clearExamCache($examId);
```

#### Cache Invalidation
Clear cache when:
- Exam is created/updated/deleted
- Questions are modified
- User data changes

### 3. API Response Optimization

#### Pagination
Always paginate large datasets:
```php
$exams = Exam::paginate(20); // 20 items per page
```

#### Selective Field Loading
Only load needed fields:
```php
$users = User::select('id', 'username', 'email')->get();
```

#### Response Compression
Enable gzip compression in `.htaccess` or nginx config.

## Frontend Optimizations

### 1. Code Splitting

#### Route-Based Splitting
Already implemented with lazy loading:
```javascript
{
  path: '/admin',
  component: () => import('@/views/AdminDashboardView.vue')
}
```

#### Component-Based Splitting
For large components:
```javascript
import { defineAsyncComponent } from 'vue'

const HeavyComponent = defineAsyncComponent(() =>
  import('./components/HeavyComponent.vue')
)
```

### 2. Vite Build Optimization

#### Production Build
```bash
npm run build
```

Vite automatically:
- Minifies JavaScript and CSS
- Tree-shakes unused code
- Optimizes assets
- Generates source maps

#### Build Configuration
In `vite.config.js`:
```javascript
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'vendor': ['vue', 'vue-router', 'pinia'],
          'ui': ['chart.js'] // If using charts
        }
      }
    },
    chunkSizeWarningLimit: 1000
  }
})
```

### 3. Component Optimization

#### Use v-show vs v-if
- `v-if`: Conditional rendering (removes from DOM)
- `v-show`: Toggle visibility (keeps in DOM)

Use `v-show` for frequently toggled elements:
```vue
<div v-show="isVisible">Content</div>
```

#### Computed Properties
Use computed properties for derived data:
```javascript
const filteredItems = computed(() => {
  return items.value.filter(item => item.active)
})
```

#### Virtual Scrolling
For long lists, consider virtual scrolling libraries.

### 4. Asset Optimization

#### Image Optimization
- Use appropriate formats (WebP, AVIF)
- Compress images before upload
- Use lazy loading for images

#### Font Optimization
- Use system fonts when possible
- Subset custom fonts
- Preload critical fonts

## Network Optimization

### 1. HTTP/2
Enable HTTP/2 on your web server for:
- Multiplexing
- Header compression
- Server push

### 2. CDN Usage
Consider using a CDN for:
- Static assets
- Frontend build files
- Public images

### 3. API Request Optimization

#### Debouncing
Debounce search inputs:
```javascript
import { debounce } from 'lodash-es'

const search = debounce((query) => {
  // API call
}, 300)
```

#### Request Batching
Batch multiple API calls:
```javascript
const [exams, users, analytics] = await Promise.all([
  api.get('/admin/exams'),
  api.get('/admin/users'),
  api.get('/admin/analytics')
])
```

## Database Optimization

### 1. Connection Pooling
Configure in `config/database.php`:
```php
'mysql' => [
    'pool' => [
        'min' => 2,
        'max' => 10
    ]
]
```

### 2. Query Optimization

#### Use Indexes
```sql
-- Check if indexes are being used
EXPLAIN SELECT * FROM exams WHERE created_by = 1;
```

#### Avoid SELECT *
```php
// Bad
$users = DB::table('users')->select('*')->get();

// Good
$users = DB::table('users')->select('id', 'username')->get();
```

### 3. Database Maintenance

#### Regular Tasks
- Optimize tables: `OPTIMIZE TABLE table_name`
- Analyze tables: `ANALYZE TABLE table_name`
- Check for slow queries in logs

## Monitoring and Profiling

### 1. Laravel Debugbar (Development)
Install for development:
```bash
composer require barryvdh/laravel-debugbar --dev
```

### 2. Query Logging
Enable query logging in development:
```php
DB::enableQueryLog();
// ... your code
dd(DB::getQueryLog());
```

### 3. Performance Metrics

#### Backend Metrics
- Response time
- Database query count
- Memory usage
- Cache hit rate

#### Frontend Metrics
- First Contentful Paint (FCP)
- Time to Interactive (TTI)
- Largest Contentful Paint (LCP)
- Cumulative Layout Shift (CLS)

Use Chrome DevTools Lighthouse for auditing.

## Production Checklist

### Backend
- [ ] Enable OPcache
- [ ] Configure proper cache driver (Redis recommended)
- [ ] Set `APP_DEBUG=false`
- [ ] Set `APP_ENV=production`
- [ ] Enable query caching
- [ ] Configure queue workers
- [ ] Set up proper logging

### Frontend
- [ ] Run production build
- [ ] Enable gzip/brotli compression
- [ ] Set up CDN
- [ ] Configure caching headers
- [ ] Minify assets
- [ ] Remove console.log statements

### Database
- [ ] Create all indexes
- [ ] Configure connection pooling
- [ ] Set up read replicas (if needed)
- [ ] Regular backups
- [ ] Monitor slow queries

### Server
- [ ] Enable HTTP/2
- [ ] Configure proper PHP-FPM settings
- [ ] Set up reverse proxy (nginx)
- [ ] Enable SSL/TLS
- [ ] Configure firewall

## Performance Testing

### Load Testing
Use tools like:
- Apache Bench (ab)
- JMeter
- k6

Example with Apache Bench:
```bash
ab -n 1000 -c 10 http://localhost:8000/api/exams
```

### Stress Testing
Test system limits:
```bash
ab -n 10000 -c 100 http://localhost:8000/api/exams
```

## Common Performance Issues

### 1. N+1 Query Problem
**Solution**: Use eager loading

### 2. Large Payload Sizes
**Solution**: Implement pagination and field selection

### 3. Slow Database Queries
**Solution**: Add indexes, optimize queries

### 4. Memory Leaks
**Solution**: Profile and fix memory issues

### 5. Unoptimized Images
**Solution**: Compress and lazy load images

## Recommended Tools

### Backend
- Laravel Telescope (monitoring)
- Laravel Debugbar (debugging)
- Blackfire (profiling)

### Frontend
- Chrome DevTools
- Lighthouse
- Vue DevTools
- Webpack Bundle Analyzer

### Database
- MySQL Workbench
- phpMyAdmin
- Adminer

## Additional Resources

- [Laravel Performance](https://laravel.com/docs/performance)
- [Vue.js Performance](https://vuejs.org/guide/best-practices/performance.html)
- [Vite Performance](https://vitejs.dev/guide/performance.html)
- [MySQL Optimization](https://dev.mysql.com/doc/refman/8.0/en/optimization.html)
