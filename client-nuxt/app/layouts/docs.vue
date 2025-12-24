<script setup lang="ts">
import type { ContentNavigationItem } from '@nuxt/content'

const { data: navigation } = await useAsyncData('docs-navigation', () => queryCollectionNavigation('docs'))

provide('docs-navigation', navigation)
</script>

<template>
  <div class="min-h-screen bg-default">
    <!-- Simple Header -->
    <header class="sticky top-0 z-50 bg-elevated/80 backdrop-blur border-b border-default">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div class="flex items-center gap-4">
            <NuxtLink to="/" class="flex items-center gap-2 text-muted hover:text-default transition-colors">
              <UIcon name="i-lucide-arrow-left" class="size-4" />
              <span class="text-sm">Back to Dashboard</span>
            </NuxtLink>
            <USeparator orientation="vertical" class="h-6" />
            <NuxtLink to="/docs" class="flex items-center gap-2">
              <img src="/velvet-logo.svg" alt="Velvet" class="h-6 w-6 dark:invert" />
              <span class="font-semibold">Docs</span>
            </NuxtLink>
          </div>
          <div class="flex items-center gap-2">
            <UColorModeButton />
          </div>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="flex gap-8">
        <!-- Sidebar Navigation -->
        <aside class="hidden lg:block w-64 shrink-0">
          <nav class="sticky top-24 space-y-1">
            <DocsNavigation :navigation="navigation" />
          </nav>
        </aside>

        <!-- Page Content -->
        <main class="flex-1 min-w-0">
          <slot />
        </main>
      </div>
    </div>

    <!-- Footer -->
    <footer class="border-t border-default mt-16">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <p class="text-sm text-muted">
          Velvet Documentation • © {{ new Date().getFullYear() }}
        </p>
      </div>
    </footer>
  </div>
</template>
