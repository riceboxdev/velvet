import SwiftUI

/// A banner-style waitlist component
public struct WaitlistBanner: View {
    @StateObject private var viewModel: WaitlistBannerViewModel
    @State private var email: String = ""
    @State private var showSuccess: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    private let config: WaitlistConfig
    private let title: String
    private let subtitle: String
    
    /// Initialize a new WaitlistBanner
    /// - Parameters:
    ///   - config: The waitlist configuration
    ///   - title: Optional custom title
    ///   - subtitle: Optional custom subtitle
    public init(
        config: WaitlistConfig,
        title: String = "Join the Waitlist",
        subtitle: String = "Be the first to know when we launch"
    ) {
        self.config = config
        self.title = title
        self.subtitle = subtitle
        _viewModel = StateObject(wrappedValue: WaitlistBannerViewModel(config: config))
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if showSuccess {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("You're on the list!")
                        .font(.headline)
                    Spacer()
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 8) {
                        TextField("Your email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        Button(action: handleSignup) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Join")
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                        .disabled(viewModel.isLoading || email.isEmpty)
                    }
                    
                    if showError {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func handleSignup() {
        guard !email.isEmpty else { return }
        
        Task {
            do {
                _ = try await viewModel.signup(email: email)
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
}

/// View model for WaitlistBanner
@MainActor
private class WaitlistBannerViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    
    private let client: WaitlistClient
    
    init(config: WaitlistConfig) {
        self.client = WaitlistClient(config: config)
    }
    
    func signup(email: String) async throws -> WaitlistSignupResponse {
        isLoading = true
        defer { isLoading = false }
        
        return try await client.signup(email: email)
    }
}
