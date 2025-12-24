<script setup lang="ts">
import { useWaitlistStore } from '~/stores/waitlist'

const store = useWaitlistStore()
const saving = ref(false)
const toast = useToast()

const form = ref({
  // Contact type
  contactType: 'email' as 'email' | 'phone',
  requireName: false,
  termsUrl: '',
  // Redirection
  redirectOnSubmit: false,
  redirectUrl: ''
})

onMounted(async () => {
  if (store.hasApiKey) {
    await store.fetchWaitlist()
    if (store.currentWaitlist) {
      populateForm()
    }
  }
})

function populateForm() {
  const settings = (store.currentWaitlist as any)?.settings || {}
  form.value.contactType = settings.contactType || 'email'
  form.value.requireName = settings.requireName ?? false
  form.value.termsUrl = settings.termsUrl || ''
  form.value.redirectOnSubmit = settings.redirectOnSubmit ?? false
  form.value.redirectUrl = settings.redirectUrl || ''
}

async function saveSettings() {
  saving.value = true
  try {
    await store.updateWaitlistSettings({
      settings: {
        contactType: form.value.contactType,
        requireName: form.value.requireName,
        termsUrl: form.value.termsUrl || null,
        redirectOnSubmit: form.value.redirectOnSubmit,
        redirectUrl: form.value.redirectUrl || null
      }
    })
    await store.fetchWaitlist()
    toast.add({ title: 'Settings saved', icon: 'i-lucide-check' })
  } catch (e: any) {
    toast.add({ title: 'Failed to save', description: e.message, color: 'error' })
  } finally {
    saving.value = false
  }
}

const contactOptions = [
  { label: 'Email', value: 'email' },
  { label: 'Phone Number', value: 'phone' }
]
</script>

<template>
  <div>
    <UPageCard
      title="Signup Form"
      description="Configure what information to collect from users."
      variant="naked"
      orientation="horizontal"
      class="mb-4"
    >
      <UButton
        label="Save changes"
        :loading="saving"
        icon="i-lucide-save"
        class="w-fit lg:ms-auto"
        @click="saveSettings"
      />
    </UPageCard>

    <!-- Collect Info -->
    <UPageCard title="Collect Information" description="Configure what data to collect on signup" class="mb-6">
      <div class="space-y-6">
        <UFormField label="Required Contact" description="What contact method to collect from users">
          <USelect v-model="form.contactType" :items="contactOptions" class="w-48" />
        </UFormField>

        <UCheckbox
          v-model="form.requireName"
          label="Require Name"
          description="Require first and last name from users when signing up"
        />

        <UFormField label="Terms and Conditions URL" description="If provided, users must agree to your terms before signing up">
          <UInput
            v-model="form.termsUrl"
            type="url"
            placeholder="https://example.com/terms"
          />
        </UFormField>
      </div>
    </UPageCard>

    <!-- Redirection -->
    <UPageCard title="Redirection" description="Redirect users after signup" class="mb-6">
      <div class="space-y-6">
        <UCheckbox
          v-model="form.redirectOnSubmit"
          label="Redirect on Submit"
          description="Automatically redirect users to a URL after they sign up"
        />

        <UFormField
          v-if="form.redirectOnSubmit"
          label="Redirect URL"
          description="Where to redirect users after signup"
        >
          <UInput
            v-model="form.redirectUrl"
            type="url"
            placeholder="https://example.com/thank-you"
          />
        </UFormField>
      </div>
    </UPageCard>
  </div>
</template>
