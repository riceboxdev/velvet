<script setup lang="ts">
import { useWaitlistStore } from '~/stores/waitlist'
import { useAuthStore } from '~/stores/auth'

const store = useWaitlistStore()
const authStore = useAuthStore()
const saving = ref(false)
const toast = useToast()

// Form with all general settings matching GetWaitlist.com
const form = ref({
  name: '',
  description: '',
  // Referral & Ranking
  spotsSkippedOnReferral: 3,
  rankByReferrals: false,
  // Visibility
  hideSignupCount: false,
  hideTotalCount: false,
  hidePosition: false,
  hideReferralLink: false,
  // Controls
  closed: false,
  enableCaptcha: false,
  allowSignupDataUpdate: false,
  // Leaderboard
  showLeaderboard: true,
  leaderboardSize: 5
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
  const wl = store.currentWaitlist
  const settings = (wl as any)?.settings || {}

  form.value.name = wl?.name || ''
  form.value.description = wl?.description || ''
  // Apply settings with defaults
  form.value.spotsSkippedOnReferral = settings.spotsSkippedOnReferral ?? 3
  form.value.rankByReferrals = settings.rankByReferrals ?? false
  form.value.hideSignupCount = settings.hideSignupCount ?? false
  form.value.hideTotalCount = settings.hideTotalCount ?? false
  form.value.hidePosition = settings.hidePosition ?? false
  form.value.hideReferralLink = settings.hideReferralLink ?? false
  form.value.closed = settings.closed ?? false
  form.value.enableCaptcha = settings.enableCaptcha ?? false
  form.value.allowSignupDataUpdate = settings.allowSignupDataUpdate ?? false
  form.value.showLeaderboard = settings.showLeaderboard ?? true
  form.value.leaderboardSize = settings.leaderboardSize ?? 5
}

async function saveSettings() {
  saving.value = true
  try {
    await store.updateWaitlistSettings({
      name: form.value.name,
      description: form.value.description,
      settings: {
        spotsSkippedOnReferral: form.value.spotsSkippedOnReferral,
        rankByReferrals: form.value.rankByReferrals,
        hideSignupCount: form.value.hideSignupCount,
        hideTotalCount: form.value.hideTotalCount,
        hidePosition: form.value.hidePosition,
        hideReferralLink: form.value.hideReferralLink,
        closed: form.value.closed,
        enableCaptcha: form.value.enableCaptcha,
        allowSignupDataUpdate: form.value.allowSignupDataUpdate,
        showLeaderboard: form.value.showLeaderboard,
        leaderboardSize: form.value.leaderboardSize
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
      title="General"
      description="Configure your waitlist basic settings and behavior."
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

    <!-- Basic Info -->
    <UPageCard title="Basic Information" class="mb-6">
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div class="space-y-4">
          <UFormField label="Waitlist Name" required>
            <UInput v-model="form.name" placeholder="My Awesome Product" />
          </UFormField>

          <UFormField label="Description">
            <UTextarea
              v-model="form.description"
              :rows="3"
              placeholder="Brief description shown to users..."
            />
          </UFormField>
        </div>

        <UCard>
          <template #header>
            <h3 class="font-semibold text-sm">Quick Stats</h3>
          </template>

          <div class="space-y-3">
            <div class="flex items-center gap-4 p-3 rounded-lg bg-elevated">
              <UIcon name="i-lucide-users" class="size-5 text-dimmed" />
              <div>
                <div class="text-xl font-bold">{{ store.stats?.total_signups || 0 }}</div>
                <div class="text-xs text-dimmed">Total Signups</div>
              </div>
            </div>
            <div class="flex items-center gap-4 p-3 rounded-lg bg-elevated">
              <UIcon name="i-lucide-user-check" class="size-5 text-dimmed" />
              <div>
                <div class="text-xl font-bold">{{ store.stats?.admitted || 0 }}</div>
                <div class="text-xs text-dimmed">Admitted</div>
              </div>
            </div>
            <div class="flex items-center gap-4 p-3 rounded-lg bg-elevated">
              <UIcon name="i-lucide-share-2" class="size-5 text-dimmed" />
              <div>
                <div class="text-xl font-bold">{{ (store.stats as any)?.total_referrals || 0 }}</div>
                <div class="text-xs text-dimmed">Referrals</div>
              </div>
            </div>
          </div>
        </UCard>
      </div>
    </UPageCard>

    <!-- Referral Settings -->
    <UPageCard title="Referral & Ranking" description="Configure how referrals affect waitlist position" class="mb-6">
      <div class="space-y-6">
        <UFormField label="Spots Skipped on Referral" description="When someone refers another, how many spots should the referrer skip ahead?">
          <UInput
            v-model.number="form.spotsSkippedOnReferral"
            type="number"
            :min="1"
            :max="100"
            class="w-32"
          />
        </UFormField>

        <UCheckbox
          v-model="form.rankByReferrals"
          label="Rank by Referrals"
          description="Rank signups purely by number of referrals instead of signup time"
        />
      </div>
    </UPageCard>

    <!-- Visibility Settings -->
    <UPageCard title="Visibility" description="Control what users can see" class="mb-6">
      <div class="space-y-4">
        <div class="space-y-4">
          <div class="flex items-start justify-between gap-4">
            <UCheckbox
              v-model="form.hideSignupCount"
              label="Hide Signup Count"
              description="Don't show the total number of signups on the widget"
              :disabled="!authStore.subscription?.features.includes('hide_position_count')"
            />
            <UBadge v-if="!authStore.subscription?.features.includes('hide_position_count')" color="primary" variant="subtle" size="xs">Pro</UBadge>
          </div>

          <div class="flex items-start justify-between gap-4">
            <UCheckbox
              v-model="form.hideTotalCount"
              label="Hide Total Count"
              description="Hide total waiters but still show user's position"
              :disabled="!authStore.subscription?.features.includes('hide_position_count')"
            />
            <UBadge v-if="!authStore.subscription?.features.includes('hide_position_count')" color="primary" variant="subtle" size="xs">Pro</UBadge>
          </div>

          <div class="flex items-start justify-between gap-4">
            <UCheckbox
              v-model="form.hidePosition"
              label="Hide Position"
              description="Don't show the user's position (rank)"
              :disabled="!authStore.subscription?.features.includes('hide_position_count')"
            />
            <UBadge v-if="!authStore.subscription?.features.includes('hide_position_count')" color="primary" variant="subtle" size="xs">Pro</UBadge>
          </div>

          <UCheckbox
            v-model="form.hideReferralLink"
            label="Hide Referral Link"
            description="Don't show the referral link to users after signup"
          />
        </div>
      </div>
    </UPageCard>

    <!-- Leaderboard Settings -->
    <UPageCard title="Leaderboard" description="Configure the public leaderboard display" class="mb-6">
      <div class="space-y-6">
        <UCheckbox
          v-model="form.showLeaderboard"
          label="Show Leaderboard"
          description="Display top referrers on the widget"
        />

        <UFormField v-if="form.showLeaderboard" label="Leaderboard Size" description="Number of top referrers to show">
          <UInput
            v-model.number="form.leaderboardSize"
            type="number"
            :min="3"
            :max="20"
            class="w-32"
          />
        </UFormField>
      </div>
    </UPageCard>

    <!-- Controls -->
    <UPageCard title="Controls" description="Waitlist behavior settings" class="mb-6">
      <div class="space-y-4">
        <UCheckbox
          v-model="form.closed"
          label="Close Waitlist"
          description="No new signups will be accepted while closed"
        />

        <UCheckbox
          v-model="form.enableCaptcha"
          label="Enable CAPTCHA"
          description="Require users to pass a CAPTCHA before signing up (coming soon)"
          disabled
        />

        <UCheckbox
          v-model="form.allowSignupDataUpdate"
          label="Allow Signup Data Update"
          description="Allow users to update their email or other data after signing up"
        />
      </div>
    </UPageCard>
  </div>
</template>
