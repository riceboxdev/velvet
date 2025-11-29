import SwiftUI

/// Main waitlist signup view component
public struct WaitlistView: View {
    @StateObject private var viewModel: WaitlistViewModel
    @State private var email: String = ""
    @State private var showSuccess: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var hasLoadedInitialStatus: Bool = false
    @State private var isAccepted: Bool = false
    
    private let config: WaitlistConfig
    private let title: String
    private let subtitle: String
    private let buttonText: String
    private let successMessage: String
    private let onAccepted: (() -> Void)?
    
    /// Initialize a new WaitlistView
    /// - Parameters:
    ///   - config: The waitlist configuration
    ///   - title: Optional custom title (defaults to "Join the Waitlist")
    ///   - subtitle: Optional custom subtitle
    ///   - buttonText: Optional custom button text (defaults to "Join Waitlist")
    ///   - successMessage: Optional custom success message
    ///   - onAccepted: Optional callback invoked when the SDK detects that this user has been accepted
    public init(
        config: WaitlistConfig,
        title: String = "Join the Waitlist",
        subtitle: String = "",
        buttonText: String = "Join Waitlist",
        successMessage: String = "You're on the list! We'll notify you when we launch.",
        onAccepted: (() -> Void)? = nil
    ) {
        self.config = config
        self.title = title
        self.subtitle = subtitle
        self.buttonText = buttonText
        self.successMessage = successMessage
        self.onAccepted = onAccepted
        _viewModel = StateObject(wrappedValue: WaitlistViewModel(config: config))
    }
    
    public var body: some View {
        Group {
            if isAccepted {
                // User has been accepted.
                // If the host app provided an onAccepted callback, we assume it will
                // navigate away and we render nothing here. Otherwise, show a simple
                // accepted message instead of a blank screen.
                if onAccepted != nil {
                    EmptyView()
                } else {
                    VStack(spacing: 20) {
                        Text("You're in!")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("You've been accepted and no longer need the waitlist.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            } else {
                VStack(spacing: 20) {
                    Text(title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if showSuccess {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 50))
                            Text(successMessage)
                                .font(.headline)
                                .multilineTextAlignment(.center)
                            if let position = viewModel.position {
                                Text("Your position: #\(position)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                    } else {
                        VStack(spacing: 16) {
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                            
                            Button(action: handleSignup) {
                                HStack {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text(buttonText)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .disabled(viewModel.isLoading || email.isEmpty)
                        }
                    }
                    
                    if showError {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
        .padding()
        .onAppear {
            if !hasLoadedInitialStatus {
                hasLoadedInitialStatus = true
                Task {
                    await loadInitialStatus()
                }
            }
        }
    }
    
    private func handleSignup() {
        guard !email.isEmpty else { return }
        
        Task {
            do {
                let response = try await viewModel.signup(email: email)
                await MainActor.run {
                    showSuccess = true
                    showError = false
                }
            } catch {
                await MainActor.run {
                    showError = true
                    if let waitlistError = error as? WaitlistError {
                        errorMessage = waitlistError.localizedDescription
                    } else {
                        errorMessage = "Failed to join waitlist. Please try again."
                    }
                }
            }
        }
    }
    
    private func loadInitialStatus() async {
        // First, ask the backend whether this stored user has been accepted.
        do {
            if let status = try await viewModel.checkStoredStatus() {
                await MainActor.run {
                    if status.accepted {
                        isAccepted = true
                        onAccepted?()
                    } else {
                        showSuccess = true
                        showError = false
                    }
                }
                return
            }
        } catch {
            // If this check fails, fall back to local knowledge.
        }
        
        // Fall back: if we know locally that this device has joined, show confirmation.
        if viewModel.hasJoinedPreviously() {
            await MainActor.run {
                showSuccess = true
                showError = false
            }
        }
    }
}

/// View model for WaitlistView
@MainActor
private class WaitlistViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var position: Int?
    
    private let client: WaitlistClient
    
    init(config: WaitlistConfig) {
        self.client = WaitlistClient(config: config)
    }
    
    func signup(email: String) async throws -> WaitlistSignupResponse {
        isLoading = true
        defer { isLoading = false }
        
        let response = try await client.signup(email: email)
        position = response.position
        return response
    }

    func checkStoredStatus() async throws -> WaitlistPosition? {
        let status = try await client.checkStoredStatus()
        if let status = status {
            position = status.position
        }
        return status
    }

    func hasJoinedPreviously() -> Bool {
        client.hasJoined()
    }
}
