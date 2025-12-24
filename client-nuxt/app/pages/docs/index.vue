<script setup lang="ts">
definePageMeta({
  layout: 'docs'
})

const { data: page } = await useAsyncData('docs-index', () => 
  queryCollection('docs').path('/docs').first()
)

if (!page.value) {
  throw createError({ statusCode: 404, statusMessage: 'Page not found', fatal: true })
}

const title = page.value.seo?.title || page.value.title
const description = page.value.seo?.description || page.value.description

useSeoMeta({
  title: `${title} - Velvet`,
  ogTitle: title,
  description,
  ogDescription: description
})
</script>

<template>
  <ContentRenderer v-if="page" :value="page" :prose="false" />
</template>
