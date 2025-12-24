<script setup lang="ts">
import { useAuthStore } from '~/stores/auth'

const authStore = useAuthStore()
const saving = ref(false)

const form = ref({
  name: '',
  bio: '',
  website: '',
  company: ''
})

onMounted(() => {
  if (authStore.user) {
    form.value.name = authStore.user.name || ''
    form.value.bio = authStore.user.bio || ''
    form.value.website = authStore.user.website || ''
    form.value.company = authStore.user.company || ''
  }
})

const toast = useToast()

async function saveProfile() {
  saving.value = true
  try {
    await authStore.updateProfile({
      name: form.value.name,
      bio: form.value.bio,
      website: form.value.website,
      company: form.value.company
    })
    toast.add({
      title: 'Profile saved',
      description: 'Your profile has been updated.',
      color: 'success',
      icon: 'i-lucide-check-circle'
    })
  } catch (e: any) {
    console.error('Failed to save:', e)
    toast.add({
      title: 'Error saving profile',
      description: e.message || 'Something went wrong. Please try again.',
      color: 'error',
      icon: 'i-lucide-alert-circle'
    })
  } finally {
    saving.value = false
  }
}

// File Upload
const fileInput = ref<HTMLInputElement | null>(null)
const uploading = ref(false)

function triggerFileInput() {
  fileInput.value?.click()
}

async function handleFileSelect(event: Event) {
  const input = event.target as HTMLInputElement
  if (!input.files?.length) return

  const file = input.files[0]
  if (!file) return
  
  // Validate file size (2MB)
  if (file.size > 2 * 1024 * 1024) {
    toast.add({
      title: 'File too large',
      description: 'Please select an ideal image under 2MB.',
      color: 'error',
      icon: 'i-lucide-alert-circle'
    })
    return
  }

  // Validate file type
  if (!['image/jpeg', 'image/png', 'image/gif'].includes(file.type)) {
    toast.add({
      title: 'Invalid file type',
      description: 'Please select a JPG, PNG, or GIF image.',
      color: 'error',
      icon: 'i-lucide-alert-circle'
    })
    return
  }

  uploading.value = true
  try {
    await authStore.uploadProfilePhoto(file)
    toast.add({
      title: 'Photo uploaded',
      description: 'Your profile photo has been updated.',
      color: 'success',
      icon: 'i-lucide-check-circle'
    })
  } catch (e: any) {
    toast.add({
      title: 'Upload failed',
      description: e.message || 'Failed to upload photo.',
      color: 'error',
      icon: 'i-lucide-alert-circle'
    })
  } finally {
    uploading.value = false
    // Clear input
    if (fileInput.value) fileInput.value.value = ''
  }
}
</script>

<template>
  <div>
    <UPageCard
      title="Profile"
      description="Your public profile information."
      variant="naked"
      orientation="horizontal"
      class="mb-4"
    >
      <UButton
        label="Save profile"
        :loading="saving"
        icon="i-lucide-save"
        class="w-fit lg:ms-auto"
        @click="saveProfile"
      />
    </UPageCard>

    <UPageCard variant="subtle">
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Avatar Section -->
        <div class="flex flex-col items-center gap-4">
          <UAvatar
            :src="authStore.user?.photo_url"
            :alt="form.name || 'User'"
            :text="(form.name?.[0] || 'U').toUpperCase()"
            size="3xl"
          />
          <input
            ref="fileInput"
            type="file"
            accept="image/jpeg,image/png,image/gif"
            class="hidden"
            @change="handleFileSelect"
          >
          <UButton
            color="neutral"
            variant="outline"
            icon="i-lucide-upload"
            size="sm"
            :loading="uploading"
            @click="triggerFileInput"
          >
            Upload Photo
          </UButton>
          <p class="text-xs text-center text-dimmed">
            JPG, PNG or GIF. Max 2MB.
          </p>
        </div>

        <!-- Form Fields -->
        <div class="lg:col-span-2 space-y-5">
          <UFormField label="Display Name">
            <UInput
              v-model="form.name"
              placeholder="Your name"
            />
          </UFormField>

          <UFormField label="Bio">
            <UTextarea
              v-model="form.bio"
              placeholder="Tell us a little about yourself..."
              :rows="3"
            />
          </UFormField>

          <UFormField label="Website">
            <UInput
              v-model="form.website"
              type="url"
              placeholder="https://yourwebsite.com"
              leading-icon="i-lucide-link"
            />
          </UFormField>

          <UFormField label="Company">
            <UInput
              v-model="form.company"
              placeholder="Your company name"
              leading-icon="i-lucide-building-2"
            />
          </UFormField>
        </div>
      </div>
    </UPageCard>
  </div>
</template>
