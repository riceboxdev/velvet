import Foundation

/// Represents a waitlist signup response
public struct WaitlistSignupResponse: Codable {
    public let message: String
    public let position: Int
    public let signup: Signup
    
    enum CodingKeys: String, CodingKey {
        case message
        case position
        case signup
    }
}

/// Represents a signup entry
public struct Signup: Codable {
    public let _id: String
    public let email: String
    public let waitlistId: String
    public let position: Int
    public let metadata: [String: String]?
    public let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case _id
        case email
        case waitlistId
        case position
        case metadata
        case createdAt
    }
}

/// Represents waitlist statistics
public struct WaitlistStats: Codable {
    public let totalSignups: Int
    public let waitlistName: String
    
    enum CodingKeys: String, CodingKey {
        case totalSignups
        case waitlistName
    }
}

/// Represents a signup's position and acceptance status on the waitlist
public struct WaitlistPosition: Codable {
    public let email: String
    public let position: Int
    public let totalSignups: Int
    public let accepted: Bool
    public let referralCode: String?
    public let referralCount: Int?

    enum CodingKeys: String, CodingKey {
        case email
        case position
        case totalSignups
        case accepted
        case referralCode
        case referralCount
    }
}

