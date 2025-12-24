<script setup lang="ts">
import { z } from 'zod'
import { useWaitlistStore } from '~/stores/waitlist'

const waitlistStore = useWaitlistStore()
const toast = useToast()

const state = reactive({
  connectors: {
    zapier: { enabled: false },
    webhook: { url: '' },
    slack: { enabled: false },
    hubspot: { enabled: false }
  }
})

// Initialize state from store
watchEffect(() => {
  if (waitlistStore.currentWaitlist?.settings?.connectors) {
    // Deep merge or assign to avoid overwriting with defaults if partial
    Object.assign(state.connectors, waitlistStore.currentWaitlist.settings.connectors)
  }
})

const loading = ref(false)

async function saveSettings() {
  loading.value = true
  try {
    const settings = {
      ...waitlistStore.currentWaitlist?.settings,
      connectors: state.connectors
    }
    
    await waitlistStore.updateWaitlist(waitlistStore.currentWaitlist!.id, { settings })
    toast.add({ title: 'Settings saved', color: 'success' })
  } catch (error) {
    toast.add({ title: 'Failed to save settings', color: 'error' })
  } finally {
    loading.value = false
  }
}

function copyZapierKey() {
  if (!waitlistStore.currentWaitlist?.api_key) return
  navigator.clipboard.writeText(waitlistStore.currentWaitlist.api_key)
  toast.add({ title: 'Copied to clipboard', color: 'success' })
}

// Mock connection functions
const connectingSlack = ref(false)
const connectingHubspot = ref(false)

async function connectSlack() {
  connectingSlack.value = true
  // Mock delay
  await new Promise(resolve => setTimeout(resolve, 1500))
  connectingSlack.value = false
  state.connectors.slack.enabled = true
  saveSettings()
  toast.add({ title: 'Connected to Slack', color: 'success' })
}

async function connectHubspot() {
  connectingHubspot.value = true
  await new Promise(resolve => setTimeout(resolve, 1500))
  connectingHubspot.value = false
  state.connectors.hubspot.enabled = true
  saveSettings()
  toast.add({ title: 'Connected to Hubspot', color: 'success' })
}
</script>

<template>
  <UCard>
    <template #header>
      <h3 class="text-lg font-semibold">Connectors</h3>
      <p class="text-sm text-dimmed">Manage third-party integrations and automations.</p>
    </template>

    <div class="space-y-8">
      
      <!-- Zapier -->
      <section>
        <div class="flex items-start justify-between mb-4">
          <div>
            <h4 class="font-medium text-lg">Zapier</h4>
            <p class="text-sm text-dimmed">Trigger Zapier hooks on User Signup and Offboarding.</p>
          </div>
          <p class="text-xs text-primary bg-primary/10 px-2 py-1 rounded">PRO</p>
        </div>

        <div class="space-y-4 border rounded-lg p-4 bg-gray-50 dark:bg-gray-900/50">
          <UFormGroup label="Enable Zapier">
            <UToggle v-model="state.connectors.zapier.enabled" @change="saveSettings" />
          </UFormGroup>

          <Transition
            enter-active-class="transition duration-200 ease-out"
            enter-from-class="translate-y-1 opacity-0"
            enter-to-class="translate-y-0 opacity-100"
            leave-active-class="transition duration-150 ease-in"
            leave-from-class="translate-y-0 opacity-100"
            leave-to-class="translate-y-1 opacity-0"
          >
            <div v-if="state.connectors.zapier.enabled" class="pt-2">
              <UFormGroup label="Zapier Key" help="Please use this key to connect with Zapier.">
                <div class="flex gap-2">
                  <UInput
                    :model-value="waitlistStore.currentWaitlist?.api_key"
                    readonly
                    class="flex-1"
                    type="password"
                  />
                  <UButton
                    icon="i-lucide-copy"
                    color="gray"
                    variant="soft"
                    @click="copyZapierKey"
                  />
                </div>
              </UFormGroup>
            </div>
          </Transition>
        </div>
      </section>

      <UDivider />

      <!-- Webhooks -->
      <section>
         <div class="mb-4">
            <h4 class="font-medium text-lg">Webhooks</h4>
            <p class="text-sm text-dimmed">Trigger webhook callbacks on User Signup and Offboarding.</p>
         </div>
         
         <UFormGroup label="Webhook URL">
           <UInput 
             v-model="state.connectors.webhook.url" 
             placeholder="https://example.com/webhook"
             @blur="saveSettings"
           />
         </UFormGroup>
      </section>

      <UDivider />

      <!-- Custom Integrations -->
      <section class="space-y-6">
        <h4 class="font-medium text-lg">Custom</h4>

        <!-- Slack -->
        <div class="flex items-center justify-between">
          <div class="flex items-start gap-3">
             <UIcon name="i-logos-slack-icon" class="w-8 h-8 shrink-0" />
             <div>
               <div class="font-medium">Slack</div>
               <p class="text-sm text-dimmed">Get a notification in Slack every time a user signs up</p>
             </div>
          </div>
          <UButton 
            v-if="!state.connectors.slack.enabled"
            color="primary" 
            :loading="connectingSlack"
            @click="connectSlack"
          >
            Connect with Slack
          </UButton>
          <UButton v-else color="gray" variant="soft" disabled>Connected</UButton>
        </div>

        <!-- Hubspot -->
        <div class="flex items-center justify-between">
            <div class="flex items-start gap-3">
               <UIcon name="i-logos-hubspot" class="w-8 h-8 shrink-0" />
               <div>
                 <div class="font-medium">Hubspot</div>
                 <p class="text-sm text-dimmed">Add/Update contact in hubspot every time a user signs up</p>
               </div>
            </div>
            <UButton 
              v-if="!state.connectors.hubspot.enabled"
              color="primary" 
              :loading="connectingHubspot"
              @click="connectHubspot"
            >
              Connect with Hubspot
            </UButton>
             <UButton v-else color="gray" variant="soft" disabled>Connected</UButton>
        </div>
      </section>

    </div>
  </UCard>
</template>
