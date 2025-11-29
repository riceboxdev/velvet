import Foundation

/// Simple local storage for tracking waitlist join status per waitlist
struct WaitlistStatusStore {
    private static func joinedKey(waitlistId: String) -> String {
        "waitlist.joined.\(waitlistId)"
    }

    private static func emailKey(waitlistId: String) -> String {
        "waitlist.email.\(waitlistId)"
    }

    static func markJoined(waitlistId: String, email: String) {
        UserDefaults.standard.set(true, forKey: joinedKey(waitlistId: waitlistId))
        UserDefaults.standard.set(email, forKey: emailKey(waitlistId: waitlistId))
    }

    static func hasJoined(waitlistId: String) -> Bool {
        UserDefaults.standard.bool(forKey: joinedKey(waitlistId: waitlistId))
    }

    static func lastEmail(waitlistId: String) -> String? {
        UserDefaults.standard.string(forKey: emailKey(waitlistId: waitlistId))
    }
}

