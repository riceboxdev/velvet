import Foundation

/// Configuration for the Waitlist SDK
public struct WaitlistConfig {
    /// The API key for your waitlist
    public let apiKey: String
    
    /// The base URL of the API server
    public let baseURL: String
    
    /// The waitlist ID
    public let waitlistId: String
    
    /// Default base URL for the Velvet hosted API
    /// This points to the production Velvet SaaS API. Update this when migrating to a custom domain.
    public static let defaultBaseURL = "https://velvet-app-peach.vercel.app"
    
    /// Initialize a new Waitlist configuration
    /// - Parameters:
    ///   - apiKey: Your waitlist API key (found in the dashboard)
    ///   - waitlistId: Your waitlist ID
    ///   - baseURL: Optional custom base URL (defaults to the hosted Velvet API)
    public init(apiKey: String, waitlistId: String, baseURL: String = WaitlistConfig.defaultBaseURL) {
        self.apiKey = apiKey
        self.waitlistId = waitlistId
        self.baseURL = baseURL
    }
    
    /// Validates the configuration
    public var isValid: Bool {
        return !apiKey.isEmpty && !waitlistId.isEmpty && !baseURL.isEmpty
    }
}
