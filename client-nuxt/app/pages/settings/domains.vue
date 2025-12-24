<script setup lang="ts">
import { useWaitlistStore } from '~/stores/waitlist'

const store = useWaitlistStore()
const saving = ref(false)
const toast = useToast()

const form = ref({
  // Email Verification
  verifySignupsByEmail: false,
  requireVerificationForReferrals: false,
  customVerificationRedirect: '',
  // Domain Restrictions
  permittedDomains: [] as string[],
  blockFreeEmails: false,
  verificationBypassDomains: [] as string[]
})

// For domain input
const newPermittedDomain = ref('')
const newBypassDomain = ref('')

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
  form.value.verifySignupsByEmail = settings.verifySignupsByEmail ?? false
  form.value.requireVerificationForReferrals = settings.requireVerificationForReferrals ?? false
  form.value.customVerificationRedirect = settings.customVerificationRedirect || ''
  form.value.permittedDomains = settings.permittedDomains || []
  form.value.blockFreeEmails = settings.blockFreeEmails ?? false
  form.value.verificationBypassDomains = settings.verificationBypassDomains || []
}

async function saveSettings() {
  saving.value = true
  try {
    await store.updateWaitlistSettings({
      settings: {
        verifySignupsByEmail: form.value.verifySignupsByEmail,
        requireVerificationForReferrals: form.value.requireVerificationForReferrals,
        customVerificationRedirect: form.value.customVerificationRedirect || null,
        permittedDomains: form.value.permittedDomains,
        blockFreeEmails: form.value.blockFreeEmails,
        verificationBypassDomains: form.value.verificationBypassDomains
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

function addPermittedDomain() {
  const domain = newPermittedDomain.value.trim().toLowerCase()
  if (domain && !form.value.permittedDomains.includes(domain)) {
    form.value.permittedDomains.push(domain)
    newPermittedDomain.value = ''
  }
}

function removePermittedDomain(domain: string) {
  form.value.permittedDomains = form.value.permittedDomains.filter(d => d !== domain)
}

function addBypassDomain() {
  const domain = newBypassDomain.value.trim().toLowerCase()
  if (domain && !form.value.verificationBypassDomains.includes(domain)) {
    form.value.verificationBypassDomains.push(domain)
    newBypassDomain.value = ''
  }
}

function removeBypassDomain(domain: string) {
  form.value.verificationBypassDomains = form.value.verificationBypassDomains.filter(d => d !== domain)
}
</script>

<template>
  <div>
    <UPageCard
      title="Domains & Verification"
      description="Configure email verification and domain restrictions."
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

    <!-- Domain Restrictions -->
    <UPageCard title="Domain Restrictions" description="Control which email domains can sign up" class="mb-6">
      <div class="space-y-6">
        <UFormField
          label="Permitted Domains"
          description="Only allow emails from these domains (e.g., columbia.edu). Leave empty to allow all domains."
        >
          <div class="flex gap-2 mb-2">
            <UInput
              v-model="newPermittedDomain"
              placeholder="company.com"
              class="flex-1"
              @keyup.enter="addPermittedDomain"
            />
            <UButton icon="i-lucide-plus" @click="addPermittedDomain" />
          </div>
          <div v-if="form.permittedDomains.length > 0" class="flex flex-wrap gap-2">
            <UBadge
              v-for="domain in form.permittedDomains"
              :key="domain"
              variant="subtle"
              class="gap-1"
            >
              {{ domain }}
              <UButton
                icon="i-lucide-x"
                variant="link"
                size="xs"
                class="p-0 h-auto"
                @click="removePermittedDomain(domain)"
              />
            </UBadge>
          </div>
          <p v-else class="text-sm text-dimmed">All email domains are currently allowed</p>
        </UFormField>

        <UCheckbox
          v-model="form.blockFreeEmails"
          label="Block Free/Personal Emails"
          description="Block signups from gmail.com, yahoo.com, outlook.com, and other free email providers"
        />
      </div>
    </UPageCard>

    <!-- Email Verification -->
    <UPageCard title="Email Verification" description="Verify signups with email confirmation" class="mb-6">
      <div class="space-y-6">
        <UCheckbox
          v-model="form.verifySignupsByEmail"
          label="Verify Signups by Email"
          description="Send a verification email to new signups (coming soon)"
          disabled
        />

        <UCheckbox
          v-model="form.requireVerificationForReferrals"
          label="Require Verification for Referrals"
          description="Only count referrals after the referred person verifies their email"
          :disabled="!form.verifySignupsByEmail"
        />

        <UFormField
          label="Verification Bypass Domains"
          description="Skip email verification for users with these domains"
        >
          <div class="flex gap-2 mb-2">
            <UInput
              v-model="newBypassDomain"
              placeholder="trusted-company.com"
              class="flex-1"
              @keyup.enter="addBypassDomain"
            />
            <UButton icon="i-lucide-plus" @click="addBypassDomain" />
          </div>
          <div v-if="form.verificationBypassDomains.length > 0" class="flex flex-wrap gap-2">
            <UBadge
              v-for="domain in form.verificationBypassDomains"
              :key="domain"
              variant="subtle"
              class="gap-1"
            >
              {{ domain }}
              <UButton
                icon="i-lucide-x"
                variant="link"
                size="xs"
                class="p-0 h-auto"
                @click="removeBypassDomain(domain)"
              />
            </UBadge>
          </div>
          <p v-else class="text-sm text-dimmed">No bypass domains configured</p>
        </UFormField>

        <UFormField
          v-if="form.verifySignupsByEmail"
          label="Custom Verification Redirect"
          description="Redirect users to this URL after they verify their email"
        >
          <UInput
            v-model="form.customVerificationRedirect"
            type="url"
            placeholder="https://example.com/verified"
          />
        </UFormField>
      </div>
    </UPageCard>
  </div>
</template>
