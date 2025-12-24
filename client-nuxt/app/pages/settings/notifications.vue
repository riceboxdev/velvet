<script setup lang="ts">
import { useWaitlistStore } from '~/stores/waitlist'
import { useAuthStore } from '~/stores/auth'

const store = useWaitlistStore()
const authStore = useAuthStore()
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

const sendingTest = ref(false)

async function sendTestEmail() {
  if (sendingTest.value) return
  sendingTest.value = true
  try {
    const result = await store.sendTestEmail()
    toast.add({ 
        title: 'Email Sent', 
        description: result?.message || 'Test email successfully sent.',
        icon: 'i-lucide-check'
    })
  } catch (e: any) {
    toast.add({ 
        title: 'Failed to send', 
        description: e.message, 
        color: 'error' 
    })
  } finally {
    sendingTest.value = false
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
          :disabled="!authStore.subscription?.features.includes('custom_offboarding_email')"
        />
        <p v-if="!authStore.subscription?.features.includes('custom_offboarding_email')" class="text-xs text-primary mt-1 pl-7">Upgrade to Pro to send offboarding emails</p>
      
        <div class="pt-4 border-t border-gray-100 dark:border-gray-800 mt-4">
            <UButton
                label="Send Test Email"
                size="xs"
                variant="soft"
                icon="i-lucide-send"
                :loading="sendingTest"
                @click="sendTestEmail"
            />
            <p class="text-xs text-dimmed mt-2">Sends a test welcome email to your account email address ({{ authStore.user?.email }}) to verify configuration.</p>
        </div>
      </div>
    </UPageCard>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <UPageCard variant="subtle">
        <div class="flex items-center gap-2 mb-4">
          <UIcon name="i-lucide-server" class="size-5" />
          <h3 class="font-semibold text-sm">SMTP Configuration</h3>
        </div>
        <p class="text-sm text-dimmed mb-4">Configure your email server to send automated emails.</p>

        <div class="relative">
          <div :class="{'opacity-50 pointer-events-none': !authStore.subscription?.features.includes('custom_domain_emails')}">
             <div class="grid grid-cols-2 gap-4">
              <UFormField label="SMTP Host">
                <UInput v-model="email.smtpHost" placeholder="smtp.example.com" />
              </UFormField>
  
              <UFormField label="SMTP Port">
                <UInput v-model="email.smtpPort" placeholder="587" />
              </UFormField>
            </div>
  
            <div class="grid grid-cols-2 gap-4 mt-4">
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
              class="mt-4"
            />
          </div>
           <div v-if="!authStore.subscription?.features.includes('custom_domain_emails')" class="absolute inset-0 flex items-center justify-center bg-white/50 backdrop-blur-sm rounded-lg">
               <div class="text-center">
                   <p class="font-semibold text-gray-900 mb-2">Custom SMTP</p>
                   <p class="text-sm text-gray-500 mb-3">Send emails from your own domain</p>
                   <UBadge color="primary" variant="subtle">Pro Feature</UBadge>
               </div>
           </div>
        </div>
      </UPageCard>

      <UPageCard variant="subtle">
        <div class="flex items-center gap-2 mb-4">
          <UIcon name="i-lucide-mail" class="size-5" />
          <h3 class="font-semibold text-sm">Email Templates</h3>
        </div>

        <div class="space-y-4" :class="{'opacity-50 pointer-events-none': !authStore.subscription?.features.includes('custom_email_templates')}">
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
        <p v-if="!authStore.subscription?.features.includes('custom_email_templates')" class="text-xs text-primary mt-4 text-center">Upgrade to Pro to customize email templates</p>

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
