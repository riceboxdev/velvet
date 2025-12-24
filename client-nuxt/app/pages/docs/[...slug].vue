<script setup lang="ts">
import type { ContentNavigationItem } from '@nuxt/content'

definePageMeta({
  layout: 'docs'
})

const route = useRoute()
const navigation = inject<Ref<ContentNavigationItem[]>>('docs-navigation')

const { data: page } = await useAsyncData(route.path, () => 
  queryCollection('docs').path(route.path).first()
)

if (!page.value) {
  throw createError({ statusCode: 404, statusMessage: 'Page not found', fatal: true })
}

const title = page.value.seo?.title || page.value.title
const description = page.value.seo?.description || page.value.description

useSeoMeta({
  title: `${title} - Velvet Docs`,
  ogTitle: title,
  description,
  ogDescription: description
})

// Find page headline from navigation
function findHeadline(items: ContentNavigationItem[] | undefined, path: string): string {
  if (!items) return ''
  for (const item of items) {
    if (item.children?.some(child => child.path === path)) {
      return item.title || ''
    }
    const found = findHeadline(item.children, path)
    if (found) return found
  }
  return ''
}

const headline = computed(() => findHeadline(navigation?.value, page.value?.path || ''))
</script>

<template>
  <article v-if="page" class="prose prose-zinc dark:prose-invert max-w-none">
    <!-- Page Header -->
    <header class="not-prose mb-8">
      <p v-if="headline" class="text-sm font-medium text-primary mb-2">{{ headline }}</p>
      <h1 class="text-3xl font-bold mb-4">{{ page.title }}</h1>
      <p v-if="page.description" class="text-lg text-muted">{{ page.description }}</p>
    </header>

    <!-- Page Content -->
    <ContentRenderer :value="page" />

    <!-- Navigation -->
    <footer class="not-prose mt-12 pt-8 border-t border-default">
      <div class="flex items-center justify-between">
        <NuxtLink to="/docs" class="flex items-center gap-2 text-sm text-muted hover:text-default transition-colors">
          <UIcon name="i-lucide-arrow-left" class="size-4" />
          Back to Docs
        </NuxtLink>
      </div>
    </footer>
  </article>
</template>
