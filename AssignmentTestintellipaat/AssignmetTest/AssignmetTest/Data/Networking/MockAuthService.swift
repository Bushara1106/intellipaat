import Foundation

protocol AuthServiceProtocol: Sendable {
    func login(email: String, password: String) async throws
}

struct MockAuthService: AuthServiceProtocol {
    var delayNanoseconds: UInt64 = 800_000_000
    var shouldFail: Bool = false

    func login(email: String, password: String) async throws {
        try await Task.sleep(nanoseconds: delayNanoseconds)
        if shouldFail { throw AppError.networkUnavailable }
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard trimmedEmail.contains("@"), trimmedEmail.contains(".") else {
            throw AppError.invalidCredentials
        }
        guard password.count >= 6 else {
            throw AppError.invalidCredentials
        }
    }
}
