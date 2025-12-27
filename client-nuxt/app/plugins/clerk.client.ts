import { clerkPlugin } from '@clerk/vue'

export default defineNuxtPlugin((nuxtApp) => {
    const config = useRuntimeConfig()
    const publishableKey = config.public.clerkPublishableKey as string

    if (!publishableKey) {
        console.error('Clerk Publishable Key is missing in runtime config!')
        console.log('Current Public Config:', config.public)
    }

    nuxtApp.vueApp.use(clerkPlugin, {
        publishableKey
    })
})
