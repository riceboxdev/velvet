<script setup lang="ts">
const user = useCurrentUser()

onMounted(() => {
  watchEffect(() => {
    if (user.value) {
      navigateTo('/dashboard')
    } else {
      navigateTo('/auth')
    }
  })
})
</script>

<template>
  <div class="flex items-center justify-center min-h-screen">
    <UIcon name="i-lucide-loader-2" class="size-8 animate-spin text-dimmed" />
  </div>
</template>
