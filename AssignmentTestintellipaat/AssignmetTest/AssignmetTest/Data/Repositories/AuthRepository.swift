import Foundation

protocol AuthRepositoryProtocol: Sendable {
    func login(email: String, password: String) async throws
}

struct AuthRepository: AuthRepositoryProtocol {
    private let service: AuthServiceProtocol

    init(service: AuthServiceProtocol = MockAuthService()) {
        self.service = service
    }

    func login(email: String, password: String) async throws {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty, !trimmedPassword.isEmpty else {
            throw AppError.emptyFields
        }
        guard trimmedEmail.contains("@"), trimmedEmail.contains(".") else {
            throw AppError.invalidEmail
        }
        guard trimmedPassword.count >= 6 else {
            throw AppError.shortPassword
        }

        try await service.login(email: trimmedEmail, password: trimmedPassword)
    }
}
