import { defineConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'

// Separate from vite.config.ts: vitest bundles its own nested Vite version,
// whose plugin types conflict with this project's own Vite package if merged
// into the same config object that `vue-tsc -b` type-checks for production builds.
export default defineConfig({
  plugins: [vue()],
  test: {
    environment: 'jsdom',
    exclude: ['**/node_modules/**', '**/e2e/**'],
  },
})
