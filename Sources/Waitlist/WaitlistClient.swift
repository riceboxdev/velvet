import Foundation

/// Main client for interacting with the Waitlist API
public final class WaitlistClient: @unchecked Sendable {
    private let config: WaitlistConfig
    private let session: URLSession
    
    /// Initialize a new Waitlist client
    /// - Parameter config: The waitlist configuration
    public init(config: WaitlistConfig) {
        self.config = config
        self.session = URLSession.shared
    }
    
    /// Sign up a user to the waitlist
    /// - Parameters:
    ///   - email: The user's email address
    ///   - metadata: Optional metadata to attach to the signup
    /// - Returns: A WaitlistSignupResponse containing the signup details
    /// - Throws: WaitlistError if the signup fails
    public func signup(email: String, metadata: [String: String]? = nil) async throws -> WaitlistSignupResponse {
        guard config.isValid else {
            throw WaitlistError.invalidConfiguration
        }
        
        guard isValidEmail(email) else {
            throw WaitlistError.invalidEmail
        }
        
        let url = URL(string: "\(config.baseURL)/api/public/waitlists/\(config.waitlistId)/signup")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(config.apiKey, forHTTPHeaderField: "X-API-Key")
        
        let body: [String: Any] = [
            "email": email,
            "metadata": metadata ?? [:]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WaitlistError.unknown
            }
            
            if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                let decoder = JSONDecoder()
                let result = try decoder.decode(WaitlistSignupResponse.self, from: data)
                // Persist local status so the SDK knows this device has already joined
                WaitlistStatusStore.markJoined(waitlistId: config.waitlistId, email: email)
                return result
            } else if httpResponse.statusCode == 400 {
                // Check if it's an "already signed up" case
                if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = errorData["message"] as? String,
                   message.lowercased().contains("already") {
                    throw WaitlistError.alreadySignedUp
                }
                let errorMessage = try? JSONDecoder().decode([String: String].self, from: data)
                throw WaitlistError.serverError(errorMessage?["message"] ?? "Bad request")
            } else {
                let errorMessage = try? JSONDecoder().decode([String: String].self, from: data)
                throw WaitlistError.serverError(errorMessage?["message"] ?? "Server error")
            }
        } catch let error as WaitlistError {
            throw error
        } catch {
            throw WaitlistError.networkError(error)
        }
    }

    /// Returns whether this device has already joined the waitlist for this configuration.
    /// This is stored locally and can be used to decide whether to show the waitlist form or a confirmation screen.
    public func hasJoined() -> Bool {
        guard config.isValid else { return false }
        return WaitlistStatusStore.hasJoined(waitlistId: config.waitlistId)
    }
    
    /// Get statistics for the waitlist
    /// - Returns: WaitlistStats containing the total signups and waitlist name
    /// - Throws: WaitlistError if the request fails
    public func getStats() async throws -> WaitlistStats {
        guard config.isValid else {
            throw WaitlistError.invalidConfiguration
        }
        
        let url = URL(string: "\(config.baseURL)/api/public/waitlists/\(config.waitlistId)/stats")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(config.apiKey, forHTTPHeaderField: "X-API-Key")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WaitlistError.unknown
            }
            
            if httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                return try decoder.decode(WaitlistStats.self, from: data)
            } else {
                let errorMessage = try? JSONDecoder().decode([String: String].self, from: data)
                throw WaitlistError.serverError(errorMessage?["message"] ?? "Server error")
            }
        } catch let error as WaitlistError {
            throw error
        } catch {
            throw WaitlistError.networkError(error)
        }
    }

    /// Get the current position and acceptance status for a user on this waitlist
    /// - Parameter email: The user's email address
    /// - Returns: WaitlistPosition containing position, total signups, and whether the user has been accepted
    /// - Throws: WaitlistError if the request fails
    public func getPosition(email: String) async throws -> WaitlistPosition {
        guard config.isValid else {
            throw WaitlistError.invalidConfiguration
        }

        guard isValidEmail(email) else {
            throw WaitlistError.invalidEmail
        }

        var components = URLComponents(string: "\(config.baseURL)/api/public/waitlists/\(config.waitlistId)/position")!
        components.queryItems = [
            URLQueryItem(name: "email", value: email)
        ]

        guard let url = components.url else {
            throw WaitlistError.invalidConfiguration
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(config.apiKey, forHTTPHeaderField: "X-API-Key")

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw WaitlistError.unknown
            }

            if httpResponse.statusCode == 200 {
                let decoder = JSONDecoder()
                return try decoder.decode(WaitlistPosition.self, from: data)
            } else if httpResponse.statusCode == 404 {
                // Not on the waitlist yet
                throw WaitlistError.serverError("Signup not found")
            } else {
                let errorMessage = try? JSONDecoder().decode([String: String].self, from: data)
                throw WaitlistError.serverError(errorMessage?["message"] ?? "Server error")
            }
        } catch let error as WaitlistError {
            throw error
        } catch {
            throw WaitlistError.networkError(error)
        }
    }

    /// Check the stored waitlist status for this device, if any.
    /// Uses the last email that successfully joined this waitlist on this device.
    /// - Returns: WaitlistPosition if a stored email exists and the signup is found, otherwise nil.
    /// - Throws: WaitlistError if the request fails for other reasons.
    public func checkStoredStatus() async throws -> WaitlistPosition? {
        guard config.isValid else {
            throw WaitlistError.invalidConfiguration
        }

        guard let email = WaitlistStatusStore.lastEmail(waitlistId: config.waitlistId) else {
            return nil
        }

        do {
            return try await getPosition(email: email)
        } catch let error as WaitlistError {
            // If the backend says "Signup not found", treat it as no stored status
            switch error {
            case .serverError(let message) where message.contains("Signup not found"):
                return nil
            default:
                throw error
            }
        }
    }
    
    /// Validates an email address
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
