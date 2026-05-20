<template>
  <div id="app">
    <router-view />
    <AutoRefreshNotification />
  </div>
</template>

<script setup>
import AutoRefreshNotification from '@/components/AutoRefreshNotification.vue'
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
}

/* Custom Scrollbar Styling - Always Visible & Beautiful */
* {
  scrollbar-width: thin;
  scrollbar-color: #3b82f6 #e5e7eb;
}

/* Webkit browsers (Chrome, Safari, Edge) */
*::-webkit-scrollbar {
  width: 12px;
  height: 12px;
}

*::-webkit-scrollbar-track {
  background: #f1f5f9;
  border-radius: 10px;
  margin: 2px;
}

*::-webkit-scrollbar-thumb {
  background: linear-gradient(180deg, #3b82f6 0%, #2563eb 100%);
  border-radius: 10px;
  border: 2px solid #f1f5f9;
  transition: all 0.3s ease;
}

*::-webkit-scrollbar-thumb:hover {
  background: linear-gradient(180deg, #2563eb 0%, #1d4ed8 100%);
  border-color: #e2e8f0;
}

*::-webkit-scrollbar-thumb:active {
  background: linear-gradient(180deg, #1d4ed8 0%, #1e40af 100%);
}

/* Scrollbar corner */
*::-webkit-scrollbar-corner {
  background: #f1f5f9;
}

/* Dark mode scrollbar (for dark backgrounds) */
.dark *::-webkit-scrollbar-track,
[class*="bg-gray-"]::-webkit-scrollbar-track,
[class*="bg-slate-"]::-webkit-scrollbar-track {
  background: #1e293b;
}

.dark *::-webkit-scrollbar-thumb,
[class*="bg-gray-"]::-webkit-scrollbar-thumb,
[class*="bg-slate-"]::-webkit-scrollbar-thumb {
  background: linear-gradient(180deg, #60a5fa 0%, #3b82f6 100%);
  border-color: #1e293b;
}

.dark *::-webkit-scrollbar-thumb:hover,
[class*="bg-gray-"]::-webkit-scrollbar-thumb:hover,
[class*="bg-slate-"]::-webkit-scrollbar-thumb:hover {
  background: linear-gradient(180deg, #3b82f6 0%, #2563eb 100%);
}
</style>
