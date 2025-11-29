import Foundation

/// Errors that can occur when using the Waitlist SDK
public enum WaitlistError: Error, LocalizedError {
    case invalidConfiguration
    case invalidEmail
    case networkError(Error)
    case serverError(String)
    case alreadySignedUp
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .invalidConfiguration:
            return "Waitlist configuration is invalid. Please check your API key and base URL."
        case .invalidEmail:
            return "The provided email address is invalid."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .alreadySignedUp:
            return "This email is already on the waitlist."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
