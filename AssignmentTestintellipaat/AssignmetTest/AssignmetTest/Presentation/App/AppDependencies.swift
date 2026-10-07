import Foundation

/// Shared composition root for storyboard-instantiated view controllers.
final class AppDependencies: @unchecked Sendable {
    nonisolated(unsafe) static let shared = AppDependencies()

    let authRepository: AuthRepositoryProtocol
    let courseRepository: CourseRepositoryProtocol

    init(
        authRepository: AuthRepositoryProtocol = AuthRepository(),
        courseRepository: CourseRepositoryProtocol = CourseRepository()
    ) {
        self.authRepository = authRepository
        self.courseRepository = courseRepository
    }
}
