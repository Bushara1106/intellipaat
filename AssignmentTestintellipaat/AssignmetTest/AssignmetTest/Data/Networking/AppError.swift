import Foundation

enum AppError: LocalizedError, Equatable {
    case invalidCredentials
    case invalidEmail
    case shortPassword
    case emptyFields
    case networkUnavailable
    case decodingFailed
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password."
        case .invalidEmail:
            return "Enter a valid email address."
        case .shortPassword:
            return "Password must be at least 6 characters."
        case .emptyFields:
            return "Email and password are required."
        case .networkUnavailable:
            return "Unable to reach the server. Showing offline data if available."
        case .decodingFailed:
            return "Failed to parse course data."
        case .unknown(let message):
            return message
        }
    }
}
