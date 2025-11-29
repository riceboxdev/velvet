# Usage Examples

## iOS SDK Examples

### Basic Integration with Pre-built UI

```swift
import SwiftUI
import Waitlist

struct ContentView: View {
    let config = WaitlistConfig(
        apiKey: "your-api-key-here",
        waitlistId: "your-waitlist-id-here",
        baseURL: "https://your-api-url.onrender.com"
    )
    
    var body: some View {
        VStack {
            Text("Welcome to My App")
                .font(.largeTitle)
            
            // Use the pre-built waitlist view
            WaitlistView(
                config: config,
                title: "Join the Waitlist",
                subtitle: "Be the first to know when we launch!",
                buttonText: "Join Now"
            )
        }
        .padding()
    }
}
```

### Using WaitlistButton Component

```swift
import SwiftUI
import Waitlist

struct HomeView: View {
    let config = WaitlistConfig(
        apiKey: "your-api-key",
        waitlistId: "your-waitlist-id"
    )
    
    var body: some View {
        VStack(spacing: 20) {
            Text("My Awesome App")
                .font(.title)
            
            // Button that opens a signup sheet
            WaitlistButton(
                config: config,
                label: "Join Waitlist",
                style: .primary
            )
        }
        .padding()
    }
}
```

### Using WaitlistBanner Component

```swift
import SwiftUI
import Waitlist

struct BannerExample: View {
    let config = WaitlistConfig(
        apiKey: "your-api-key",
        waitlistId: "your-waitlist-id"
    )
    
    var body: some View {
        ScrollView {
            VStack {
                // Your app content here
                Text("App Content")
                
                // Banner at the bottom
                WaitlistBanner(
                    config: config,
                    title: "Join the Waitlist",
                    subtitle: "Get notified when we launch"
                )
            }
        }
    }
}
```

### Custom UI with API Client

```swift
import SwiftUI
import Waitlist

struct CustomWaitlistView: View {
    @State private var email: String = ""
    @State private var isLoading: Bool = false
    @State private var message: String = ""
    @State private var position: Int?
    
    private let client: WaitlistClient
    
    init() {
        let config = WaitlistConfig(
            apiKey: "your-api-key",
            waitlistId: "your-waitlist-id"
        )
        self.client = WaitlistClient(config: config)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
            
            Button("Sign Up") {
                Task {
                    await signup()
                }
            }
            .disabled(isLoading || email.isEmpty)
            
            if isLoading {
                ProgressView()
            }
            
            if !message.isEmpty {
                Text(message)
                    .foregroundColor(position != nil ? .green : .red)
            }
            
            if let position = position {
                Text("Your position: #\(position)")
                    .font(.headline)
            }
        }
        .padding()
    }
    
    private func signup() async {
        isLoading = true
        message = ""
        
        do {
            let response = try await client.signup(email: email)
            await MainActor.run {
                self.position = response.position
                self.message = "Successfully joined the waitlist!"
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.message = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
```

### Getting Waitlist Statistics

```swift
import Waitlist

let config = WaitlistConfig(
    apiKey: "your-api-key",
    waitlistId: "your-waitlist-id"
)
let client = WaitlistClient(config: config)

// Get stats
Task {
    do {
        let stats = try await client.getStats()
        print("Total signups: \(stats.totalSignups)")
        print("Waitlist name: \(stats.waitlistName)")
    } catch {
        print("Error: \(error.localizedDescription)")
    }
}
```

## API Examples

### Register a Developer Account

```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "developer@example.com",
    "password": "securepassword123"
  }'
```

### Login

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "developer@example.com",
    "password": "securepassword123"
  }'
```

### Create a Waitlist

```bash
curl -X POST http://localhost:3000/api/waitlists \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "name": "My App Waitlist",
    "description": "Join to be notified when we launch"
  }'
```

### Add User to Waitlist (Public API)

```bash
curl -X POST http://localhost:3000/api/public/waitlists/WAITLIST_ID/signup \
  -H "Content-Type: application/json" \
  -H "X-API-Key: YOUR_API_KEY" \
  -d '{
    "email": "user@example.com",
    "metadata": {
      "source": "ios_app",
      "version": "1.0.0"
    }
  }'
```

### Get Waitlist Stats (Public API)

```bash
curl http://localhost:3000/api/public/waitlists/WAITLIST_ID/stats \
  -H "X-API-Key: YOUR_API_KEY"
```

