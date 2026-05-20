import { defineConfig, loadEnv } from 'vite'
import vue from '@vitejs/plugin-vue'
import { fileURLToPath, URL } from 'node:url'

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => {
  // Load env file based on `mode` in the current working directory.
  const env = loadEnv(mode, process.cwd(), '')
  
  // Determine base path based on environment
  // For local/LAN: use '/'
  // For production: use '/exam-frontend/' or custom path
  const basePath = mode === 'production' ? (env.VITE_BASE_PATH || '/exam-frontend/') : '/'
  
  // Determine if source maps should be generated
  const shouldGenerateSourceMap = mode === 'development'
  
  return {
    base: basePath,
    plugins: [vue()],
    resolve: {
      alias: {
        '@': fileURLToPath(new URL('./src', import.meta.url))
      }
    },
    server: {
      port: 5173,
      https: false,
      proxy: {
        '/api': {
          target: env.VITE_API_URL || 'http://127.0.0.1:8000',
          changeOrigin: true,
          secure: false
        }
      }
    },
    build: {
      outDir: 'dist',
      sourcemap: shouldGenerateSourceMap,
      minify: mode === 'production' ? 'terser' : false,
      rollupOptions: {
        output: {
          manualChunks: {
            'vue-vendor': ['vue', 'vue-router', 'pinia'],
            'chart-vendor': ['chart.js', 'vue-chartjs']
          }
        }
      },
      chunkSizeWarningLimit: 1000
    }
  }
})
