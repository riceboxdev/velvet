<script setup lang="ts">
import { useWaitlistStore } from '~/stores/waitlist'

const store = useWaitlistStore()
const saving = ref(false)
const toast = useToast()

// Notification toggles
const notifications = ref({
  emailNewSignups: true,
  emailOnReferral: false,
  sendOffboardingEmail: false
})

// SMTP configuration
const email = ref({
  smtpHost: '',
  smtpPort: '587',
  smtpUser: '',
  smtpPass: '',
  smtpSecure: false,
  fromEmail: '',
  fromName: '',
  welcomeSubject: 'Welcome to the waitlist!',
  offboardSubject: "You're in! 🎉"
})

onMounted(async () => {
  if (store.hasApiKey) {
    await store.fetchWaitlist()
    if (store.currentWaitlist) {
      const settings = (store.currentWaitlist as any)?.settings || {}
      // Populate notification toggles
      notifications.value.emailNewSignups = settings.emailNewSignups ?? true
      notifications.value.emailOnReferral = settings.emailOnReferral ?? false
      notifications.value.sendOffboardingEmail = settings.sendOffboardingEmail ?? false
      // Populate email config
      if (settings.email) {
        email.value = { ...email.value, ...settings.email }
      }
    }
  }
})

async function saveSettings() {
  saving.value = true
  try {
    await store.updateWaitlistSettings({
      settings: {
        emailNewSignups: notifications.value.emailNewSignups,
        emailOnReferral: notifications.value.emailOnReferral,
        sendOffboardingEmail: notifications.value.sendOffboardingEmail,
        email: {
          ...email.value,
          // Don't save actual password if unchanged
          smtpPass: email.value.smtpPass === '***SAVED***' ? undefined : email.value.smtpPass
        }
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
</script>

<template>
  <div>
    <UPageCard
      title="Notifications"
      description="Configure email settings for automated notifications."
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

    <!-- Notification Toggles -->
    <UPageCard title="Send Emails" description="Configure which automated emails to send" class="mb-6">
      <div class="space-y-4">
        <UCheckbox
          v-model="notifications.emailNewSignups"
          label="Email New Signups"
          description="Send a welcome email with referral link and position when someone signs up"
        />

        <UCheckbox
          v-model="notifications.emailOnReferral"
          label="Congratulate on Referral"
          description="Send an email when someone successfully refers another person"
        />

        <UCheckbox
          v-model="notifications.sendOffboardingEmail"
          label="Send Offboarding Email"
          description="Send an email when you admit a user from the waitlist"
        />
      </div>
    </UPageCard>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <UPageCard variant="subtle">
        <div class="flex items-center gap-2 mb-4">
          <UIcon name="i-lucide-server" class="size-5" />
          <h3 class="font-semibold text-sm">SMTP Configuration</h3>
        </div>
        <p class="text-sm text-dimmed mb-4">Configure your email server to send automated emails.</p>

        <div class="space-y-4">
          <div class="grid grid-cols-2 gap-4">
            <UFormField label="SMTP Host">
              <UInput v-model="email.smtpHost" placeholder="smtp.example.com" />
            </UFormField>

            <UFormField label="SMTP Port">
              <UInput v-model="email.smtpPort" placeholder="587" />
            </UFormField>
          </div>

          <div class="grid grid-cols-2 gap-4">
            <UFormField label="SMTP Username">
              <UInput v-model="email.smtpUser" placeholder="user@example.com" />
            </UFormField>

            <UFormField label="SMTP Password">
              <UInput v-model="email.smtpPass" type="password" placeholder="••••••••" />
            </UFormField>
          </div>

          <UCheckbox
            v-model="email.smtpSecure"
            label="Use SSL/TLS (port 465)"
            description="Enable for secure SMTP connections"
          />
        </div>
      </UPageCard>

      <UPageCard variant="subtle">
        <div class="flex items-center gap-2 mb-4">
          <UIcon name="i-lucide-mail" class="size-5" />
          <h3 class="font-semibold text-sm">Email Templates</h3>
        </div>

        <div class="space-y-4">
          <UFormField label="From Name">
            <UInput v-model="email.fromName" placeholder="Your Company" />
          </UFormField>

          <UFormField label="From Email">
            <UInput v-model="email.fromEmail" type="email" placeholder="noreply@example.com" />
          </UFormField>

          <USeparator />

          <UFormField label="Welcome Email Subject">
            <UInput v-model="email.welcomeSubject" placeholder="Welcome to the waitlist!" />
          </UFormField>

          <UFormField label="Admission Email Subject">
            <UInput v-model="email.offboardSubject" placeholder="You're in! 🎉" />
          </UFormField>
        </div>

        <UAlert
          class="mt-4"
          color="info"
          variant="subtle"
          icon="i-lucide-info"
          title="Email templates use default styling. Custom HTML templates coming soon."
        />
      </UPageCard>
    </div>
  </div>
</template>
