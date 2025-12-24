<script setup lang="ts">
import type { ContentNavigationItem } from '@nuxt/content'

defineProps<{
  navigation: ContentNavigationItem[] | null
}>()
</script>

<template>
  <div class="space-y-1" v-if="navigation">
    <template v-for="item in navigation" :key="item.path">
      <!-- Section with children -->
      <div v-if="item.children?.length" class="mb-4">
        <h3 class="text-xs font-semibold text-muted uppercase tracking-wider mb-2 px-3">
          {{ item.title }}
        </h3>
        <ul class="space-y-1">
          <li v-for="child in item.children" :key="child.path">
            <NuxtLink
              :to="child.path"
              class="block px-3 py-2 text-sm rounded-lg transition-colors"
              :class="$route.path === child.path 
                ? 'bg-primary/10 text-primary font-medium' 
                : 'text-muted hover:text-default hover:bg-elevated'"
            >
              {{ child.title }}
            </NuxtLink>
          </li>
        </ul>
      </div>
      <!-- Single item without children -->
      <NuxtLink
        v-else
        :to="item.path"
        class="block px-3 py-2 text-sm rounded-lg transition-colors"
        :class="$route.path === item.path 
          ? 'bg-primary/10 text-primary font-medium' 
          : 'text-muted hover:text-default hover:bg-elevated'"
      >
        {{ item.title }}
      </NuxtLink>
    </template>
  </div>
</template>
