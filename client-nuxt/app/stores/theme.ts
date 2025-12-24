import { defineStore } from 'pinia'
import { useAuthStore } from '~/stores/auth'

interface ThemeSettings {
    primary: string
    neutral: string
    mode: 'light' | 'dark' | 'system'
}

export const useThemeStore = defineStore('theme', () => {
    const authStore = useAuthStore()
    const appConfig = useAppConfig()
    const colorMode = useColorMode()

    // Helper to get API base
    const getApiBase = () => {
        const config = useRuntimeConfig()
        return config.public.apiBase as string
    }

    // State
    const primary = ref(appConfig.ui.colors.primary)
    const neutral = ref(appConfig.ui.colors.neutral)
    const mode = ref<'light' | 'dark' | 'system'>(colorMode.preference as any)
    const loading = ref(false)
    const saving = ref(false)
    const error = ref<string | null>(null)

    // Apply theme to the app
    function applyTheme() {
        appConfig.ui.colors.primary = primary.value
        appConfig.ui.colors.neutral = neutral.value
        colorMode.preference = mode.value
    }

    // Fetch theme from server
    async function fetchTheme() {
        loading.value = true
        error.value = null

        try {
            const token = await authStore.getIdToken()
            if (!token) return

            const res = await fetch(`${getApiBase()}/settings/theme`, {
                headers: { Authorization: `Bearer ${token}` }
            })

            if (!res.ok) {
                throw new Error('Failed to fetch theme')
            }

            const data = await res.json()

            if (data.success && data.data.theme) {
                const theme = data.data.theme as ThemeSettings
                primary.value = theme.primary || primary.value
                neutral.value = theme.neutral || neutral.value
                mode.value = theme.mode || mode.value
                applyTheme()
            }
        } catch (e: any) {
            console.error('[Theme] Fetch error:', e)
            error.value = e.message
        } finally {
            loading.value = false
        }
    }

    // Save theme to server (admin only)
    async function saveTheme() {
        saving.value = true
        error.value = null

        try {
            const token = await authStore.getIdToken()
            if (!token) throw new Error('Not authenticated')

            const theme: ThemeSettings = {
                primary: primary.value,
                neutral: neutral.value,
                mode: mode.value
            }

            const res = await fetch(`${getApiBase()}/settings/theme`, {
                method: 'PUT',
                headers: {
                    Authorization: `Bearer ${token}`,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ theme })
            })

            if (!res.ok) {
                const data = await res.json()
                throw new Error(data.error || 'Failed to save theme')
            }

            // Apply theme locally after successful save
            applyTheme()
        } catch (e: any) {
            console.error('[Theme] Save error:', e)
            error.value = e.message
            throw e
        } finally {
            saving.value = false
        }
    }

    // Update a theme property and apply immediately
    function updatePrimary(color: string) {
        primary.value = color
        applyTheme()
    }

    function updateNeutral(color: string) {
        neutral.value = color
        applyTheme()
    }

    function updateMode(newMode: 'light' | 'dark' | 'system') {
        mode.value = newMode
        applyTheme()
    }

    return {
        // State
        primary,
        neutral,
        mode,
        loading,
        saving,
        error,

        // Actions
        fetchTheme,
        saveTheme,
        applyTheme,
        updatePrimary,
        updateNeutral,
        updateMode
    }
})
