<script setup lang="ts">
import { useWaitlistStore } from '~/stores/waitlist'
import { useAuthStore } from '~/stores/auth'

const store = useWaitlistStore()
const authStore = useAuthStore()
const router = useRouter()
const toast = useToast()

const deleting = ref(false)
const confirmText = ref('')

const canDelete = computed(() => {
  return confirmText.value === store.currentWaitlist?.name
})

async function deleteWaitlist() {
  if (!canDelete.value) return

  deleting.value = true
  try {
    const token = await authStore.getIdToken()
    await $fetch(`/api/waitlists/${store.currentWaitlist?.id}`, {
      method: 'DELETE',
      headers: {
        'Authorization': `Bearer ${token}`
      }
    })

    toast.add({ title: 'Waitlist deleted', icon: 'i-lucide-check' })
    // Clear the current API key to reset state
    localStorage.removeItem('waitlist_api_key')
    router.push('/dashboard')
  } catch (e: any) {
    toast.add({ title: 'Failed to delete', description: e.message, color: 'error' })
  } finally {
    deleting.value = false
  }
}
</script>

<template>
  <div>
    <UPageCard
      title="Danger Zone"
      description="Irreversible and destructive actions."
      variant="naked"
      class="mb-4"
    />

    <UPageCard class="border-red-500/50 dark:border-red-500/30">
      <div class="space-y-6">
        <div>
          <h3 class="text-lg font-semibold text-red-600 dark:text-red-400">Delete Waitlist</h3>
          <p class="text-sm text-dimmed mt-1">
            Permanently remove this waitlist and all associated signups. This action cannot be undone.
          </p>
        </div>

        <UAlert
          icon="i-lucide-alert-triangle"
          color="error"
          title="Warning"
          description="All signups, referral data, and analytics will be permanently deleted."
        />

        <UFormField
          :label="`Type '${store.currentWaitlist?.name || 'waitlist name'}' to confirm`"
          description="This action is permanent and cannot be undone"
        >
          <UInput
            v-model="confirmText"
            :placeholder="store.currentWaitlist?.name"
            class="max-w-md"
          />
        </UFormField>

        <UButton
          color="error"
          icon="i-lucide-trash-2"
          :disabled="!canDelete"
          :loading="deleting"
          @click="deleteWaitlist"
        >
          Delete Waitlist Permanently
        </UButton>
      </div>
    </UPageCard>
  </div>
</template>
