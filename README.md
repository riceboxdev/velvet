# Velvet iOS SDK

The Velvet iOS SDK is a Swift Package that makes it easy to add waitlist functionality to your iOS app. Velvet is a hosted SaaS platform, so you don't need to manage any backend infrastructure. With just a few lines of code, you can integrate a complete waitlist signup flow with pre-built UI components, or use the API client directly for fully custom implementations.

## Features

- 🎨 **Pre-built SwiftUI Components**: Drop-in views for waitlist signups
- 🔧 **Flexible API Client**: Build your own custom UI while leveraging the SDK
- 📱 **Smart State Management**: Automatically remembers when users have joined
- ✅ **Acceptance Tracking**: Built-in support for tracking when users are accepted off the waitlist
- 🎯 **Easy Integration**: Add to your project in minutes

## Requirements

- **iOS 15.0+**
- **Swift 5.9+**
- **Xcode 14.0+**

## Installation

### Swift Package Manager

1. In Xcode, open your project
2. Go to **File → Add Package Dependencies...**
3. Enter your package repository URL:
   ```
   https://github.com/riceboxdev/Velvet
   ```
   Or if using a local path during development:
   ```
   /path/to/velvet/Sources/Waitlist
   ```
4. Select the version or branch you want to use
5. Add the `Waitlist` package to your app target
6. Click **Add Package**

### Import the Module

In any Swift file where you want to use the SDK:

```swift
import Waitlist
```

## Getting Started

### Step 1: Get Your API Credentials

Before you can use the SDK, you need to:

1. **Sign up for Velvet** at [velvet.app](https://velvet.app) (or your dashboard URL)
2. **Create a waitlist** in the dashboard
3. **Copy your credentials** from the waitlist detail page:
   - **API Key**: Your waitlist's unique API key
   - **Waitlist ID**: The unique identifier for your waitlist

That's all you need! Velvet is a fully hosted SaaS platform, so there's no backend to deploy or manage.

### Step 2: Configure the SDK

Create a `WaitlistConfig` with your credentials:

```swift
import Waitlist

let config = WaitlistConfig(
    apiKey: "your-api-key-here",
    waitlistId: "your-waitlist-id-here"
)
```

That's it! The SDK automatically connects to the hosted Velvet SaaS API. No backend setup required.

**Note**: You only need to provide a `baseURL` parameter if you're using a custom deployment or local development server:

```swift
// For local development
let config = WaitlistConfig(
    apiKey: "your-api-key",
    waitlistId: "your-waitlist-id",
    baseURL: "http://localhost:3000"
)
```

### Step 3: Add Waitlist UI to Your App

Choose one of the following approaches based on your needs:

#### Option A: Full-Screen Waitlist View

Use `WaitlistView` for a complete signup experience:

```swift
import SwiftUI
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

**Customize the messaging**:

```swift
WaitlistView(
    config: config,
    title: "Get Early Access",
    subtitle: "Join the waitlist and be among the first to try our app.",
    buttonText: "Request Invite",
    successMessage: "You're in! We'll email you when it's your turn."
)
```

**Handle accepted users**:

```swift
WaitlistView(
    config: config,
    onAccepted: {
        // User has been accepted off the waitlist
        // Navigate to your main app flow
        navigateToMainApp()
    }
)
```

#### Option B: Waitlist Button

Use `WaitlistButton` to present the waitlist in a sheet:

```swift
struct ContentView: View {
    let config = WaitlistConfig(
        apiKey: "your-api-key",
        waitlistId: "your-waitlist-id"
    )
    
    var body: some View {
        VStack {
            Text("Welcome to My App")
            WaitlistButton(config: config, label: "Join Waitlist")
        }
    }
}
```

**Customize the button style**:

```swift
// Primary style (default)
WaitlistButton(config: config, label: "Join Waitlist", style: .primary)

// Secondary style
WaitlistButton(config: config, label: "Join Waitlist", style: .secondary)

// Custom colors
WaitlistButton(
    config: config,
    label: "Join Waitlist",
    style: .custom(foreground: .white, background: .purple)
)
```

#### Option C: Waitlist Banner

Use `WaitlistBanner` for an inline signup form:

```swift
struct ContentView: View {
    let config = WaitlistConfig(
        apiKey: "your-api-key",
        waitlistId: "your-waitlist-id"
    )
    
    var body: some View {
        ScrollView {
            VStack {
                Text("My App Content")
                
                WaitlistBanner(
                    config: config,
                    title: "Join the Waitlist",
                    subtitle: "Be the first to know when we launch"
                )
            }
        }
    }
}
```

## Advanced Usage

### Using the API Client Directly

If you want complete control over the UI, use `WaitlistClient` directly:

```swift
let client = WaitlistClient(config: config)

Task {
    do {
        let response = try await client.signup(email: "user@example.com")
        print("Position: \(response.position)")
        print("Message: \(response.message)")
    } catch {
        print("Error: \(error)")
    }
}
```

### Check if User Has Already Joined

The SDK automatically tracks when a device has joined a waitlist:

```swift
let client = WaitlistClient(config: config)

if client.hasJoined() {
    // This device has already joined
    // Show a confirmation screen instead of the signup form
    showConfirmationScreen()
} else {
    // Show the waitlist signup form
    showWaitlistForm()
}
```

### Check Waitlist Status

Check the current status of a user on the waitlist, including whether they've been accepted:

```swift
let client = WaitlistClient(config: config)

Task {
    do {
        // Check status using stored email from this device
        if let status = try await client.checkStoredStatus() {
            if status.accepted {
                // User has been accepted - show main app
                navigateToMainApp()
            } else {
                // User is still waiting
                print("Position: \(status.position) of \(status.totalSignups)")
                showWaitingScreen()
            }
        } else {
            // No stored status - show waitlist form
            showWaitlistForm()
        }
    } catch {
        print("Error checking status: \(error)")
    }
}
```

### Get Waitlist Statistics

Fetch statistics about your waitlist:

```swift
let client = WaitlistClient(config: config)

Task {
    do {
        let stats = try await client.getStats()
        print("Total signups: \(stats.totalSignups)")
        print("Waitlist name: \(stats.waitlistName)")
    } catch {
        print("Error: \(error)")
    }
}
```

### Get User Position

Check a specific user's position on the waitlist:

```swift
let client = WaitlistClient(config: config)

Task {
    do {
        let position = try await client.getPosition(email: "user@example.com")
        print("Position: \(position.position)")
        print("Total signups: \(position.totalSignups)")
        print("Accepted: \(position.accepted)")
        
        if let referralCode = position.referralCode {
            print("Referral code: \(referralCode)")
            print("Referrals: \(position.referralCount ?? 0)")
        }
    } catch {
        print("Error: \(error)")
    }
}
```

### Add Metadata to Signups

Include custom metadata when users sign up:

```swift
let client = WaitlistClient(config: config)

Task {
    do {
        let metadata = [
            "source": "ios_app",
            "version": "1.0.0",
            "user_id": "12345"
        ]
        
        let response = try await client.signup(
            email: "user@example.com",
            metadata: metadata
        )
        print("Signed up: \(response.position)")
    } catch {
        print("Error: \(error)")
    }
}
```

## Error Handling

The SDK throws `WaitlistError` for various error conditions:

```swift
do {
    let response = try await client.signup(email: "user@example.com")
} catch let error as WaitlistError {
    switch error {
    case .invalidConfiguration:
        print("Invalid configuration - check your API key and waitlist ID")
    case .invalidEmail:
        print("Invalid email address")
    case .alreadySignedUp:
        print("This email is already on the waitlist")
    case .networkError(let underlyingError):
        print("Network error: \(underlyingError)")
    case .serverError(let message):
        print("Server error: \(message)")
    case .unknown:
        print("Unknown error occurred")
    }
} catch {
    print("Unexpected error: \(error)")
}
```

### Error Types

- `invalidConfiguration`: The configuration is missing or invalid
- `invalidEmail`: The email address failed validation
- `alreadySignedUp`: The email is already on the waitlist
- `networkError(Error)`: An underlying network error occurred
- `serverError(String)`: The backend returned an error with a message
- `unknown`: An unexpected error occurred

## How It Works

### Automatic State Management

The SDK automatically tracks when a device has joined a waitlist:

1. When a user successfully signs up, the SDK stores this information locally
2. The next time `WaitlistView` appears, it automatically shows a confirmation screen instead of the signup form
3. This prevents users from seeing the waitlist form again on the same device

### Acceptance Tracking

The SDK supports tracking when users are accepted off the waitlist:

1. Call `checkStoredStatus()` to check if a stored user has been accepted
2. If `accepted` is `true`, you can navigate users directly to your main app
3. Use the `onAccepted` callback in `WaitlistView` to handle acceptance automatically

### Local Storage

The SDK uses `UserDefaults` to store:
- Whether this device has joined the waitlist
- The last email that successfully joined

This data is stored per `waitlistId`, so you can use multiple waitlists in the same app.

## Complete Example

Here's a complete example showing how to integrate the SDK in your app:

```swift
import SwiftUI
import Waitlist

@main
struct MyApp: App {
    // Configure once, use everywhere
    static let waitlistConfig = WaitlistConfig(
        apiKey: "your-api-key",
        waitlistId: "your-waitlist-id"
    )
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var showWaitlist = true
    @State private var isAccepted = false
    
    var body: some View {
        Group {
            if isAccepted {
                MainAppView()
            } else if showWaitlist {
                WaitlistView(
                    config: MyApp.waitlistConfig,
                    onAccepted: {
                        isAccepted = true
                        showWaitlist = false
                    }
                )
            } else {
                MainAppView()
            }
        }
        .onAppear {
            checkWaitlistStatus()
        }
    }
    
    private func checkWaitlistStatus() {
        let client = WaitlistClient(config: MyApp.waitlistConfig)
        
        Task {
            do {
                if let status = try await client.checkStoredStatus() {
                    if status.accepted {
                        await MainActor.run {
                            isAccepted = true
                            showWaitlist = false
                        }
                    } else {
                        await MainActor.run {
                            showWaitlist = true
                        }
                    }
                } else if client.hasJoined() {
                    await MainActor.run {
                        showWaitlist = true
                    }
                }
            } catch {
                print("Error checking status: \(error)")
            }
        }
    }
}
```

## Best Practices

1. **Store Configuration Securely**: Consider storing your API key and waitlist ID in a secure configuration file or environment variables, especially for production builds.

2. **Check Status on App Launch**: Call `checkStoredStatus()` when your app launches to automatically handle accepted users.

3. **Handle Errors Gracefully**: Always wrap SDK calls in do-catch blocks and provide user-friendly error messages.

4. **Use Metadata Wisely**: Include useful metadata (app version, source, etc.) to help analyze signup patterns in your dashboard.

5. **Test Acceptance Flow**: Make sure to test the acceptance flow by accepting users in your dashboard and verifying the SDK handles it correctly.

## Troubleshooting

### "Invalid Configuration" Error

- Verify your API key and waitlist ID are correct
- Ensure your base URL is correct and includes the protocol (`https://`)
- Check that your backend is deployed and accessible

### Network Errors

- Verify your device has internet connectivity
- Check that your backend URL is correct and accessible
- Ensure your backend CORS settings allow requests from your app

### Users Not Seeing Confirmation

- The SDK stores state locally per device
- If testing on a simulator, reset the simulator to clear stored state
- Verify that signups are actually succeeding by checking your dashboard

## Support

For issues, questions, or feature requests, please:
- Open an issue in the [repository](https://github.com/riceboxdev/Velvet)
- Check the [web dashboard repository](https://github.com/riceboxdev/velvet-dashboard) for backend setup instructions
- Review the API documentation in the dashboard

## License

ISC
