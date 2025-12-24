---
seo:
  title: Velvet - Waitlist Management for iOS Apps
  description: The complete waitlist management platform with iOS SDK, REST API, and admin dashboard.
---

::u-page-hero{class="dark:bg-gradient-to-b from-neutral-900 to-neutral-950"}
---
orientation: horizontal
---
#title
Waitlist Management [Made Simple]{.text-primary}.

#description
Add waitlist functionality to your iOS app in minutes. Velvet provides a complete hosted SaaS platform with pre-built SwiftUI components, a powerful REST API, and a web dashboard to manage your signups.

#links
  :::u-button
  ---
  to: /getting-started
  size: xl
  trailing-icon: i-lucide-arrow-right
  ---
  Get started
  :::

  :::u-button
  ---
  icon: i-simple-icons-github
  color: neutral
  variant: outline
  size: xl
  to: https://github.com/riceboxdev/Velvet
  target: _blank
  ---
  View on GitHub
  :::

#default
  :::prose-pre
  ---
  code: |
    import Waitlist

    struct ContentView: View {
        let config = WaitlistConfig(
            apiKey: "your-api-key",
            waitlistId: "your-waitlist-id"
        )
        
        var body: some View {
            WaitlistView(config: config)
        }
    }
  filename: ContentView.swift
  ---

  ```swift [ContentView.swift]
  import Waitlist

  struct ContentView: View {
      let config = WaitlistConfig(
          apiKey: "your-api-key",
          waitlistId: "your-waitlist-id"
      )
      
      var body: some View {
          WaitlistView(config: config)
      }
  }
  ```
  :::
::

::u-page-section{class="dark:bg-neutral-950"}
#title
Everything You Need

#features
  :::u-page-feature
  ---
  icon: i-lucide-smartphone
  ---
  #title
  iOS SDK

  #description
  Drop-in SwiftUI components for waitlist signups. WaitlistView, WaitlistButton, and WaitlistBanner - ready to use in minutes.
  :::

  :::u-page-feature
  ---
  icon: i-lucide-server
  ---
  #title
  REST API

  #description
  Full-featured REST API for custom integrations. Public endpoints for signups, admin endpoints for management.
  :::

  :::u-page-feature
  ---
  icon: i-lucide-layout-dashboard
  ---
  #title
  Web Dashboard

  #description
  Manage waitlists, view signups, accept users, and configure settings through an intuitive admin interface.
  :::

  :::u-page-feature
  ---
  icon: i-lucide-users
  ---
  #title
  Referral System

  #description
  Built-in referral tracking. Users get unique codes to share, and referrers move up in the queue automatically.
  :::

  :::u-page-feature
  ---
  icon: i-lucide-cloud
  ---
  #title
  Fully Hosted

  #description
  No backend to deploy or manage. Velvet is a complete SaaS platform - just configure your API key and go.
  :::

  :::u-page-feature
  ---
  icon: i-lucide-moon
  ---
  #title
  Dark Mode Ready

  #description
  All SDK components support light and dark mode out of the box. Matches your app's appearance automatically.
  :::
::

::u-page-section{class="dark:bg-gradient-to-b from-neutral-950 to-neutral-900"}
  :::u-page-c-t-a
  ---
  links:
    - label: Get Started
      to: '/getting-started'
      trailingIcon: i-lucide-arrow-right
    - label: iOS SDK
      to: '/ios-sdk'
      variant: subtle
      icon: i-simple-icons-swift
    - label: API Reference
      to: '/api'
      variant: subtle
      icon: i-lucide-book-open
  title: Ready to add a waitlist to your app?
  description: Get up and running in under 5 minutes with our iOS SDK and hosted platform.
  class: dark:bg-neutral-950
  ---
  :::
::
