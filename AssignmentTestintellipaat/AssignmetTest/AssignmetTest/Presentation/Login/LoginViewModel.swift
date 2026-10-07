import Foundation

@MainActor
final class LoginViewModel {
    enum ViewState: Equatable {
        case idle
        case loading
        case error(String)
    }

    var email: String = ""
    var password: String = ""
    private(set) var state: ViewState = .idle

    var onStateChange: ((ViewState) -> Void)?
    var onLoginSuccess: (() -> Void)?

    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol = AppDependencies.shared.authRepository) {
        self.authRepository = authRepository
    }

    var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }

    func login() {
        guard !isLoading else { return }
        updateState(.loading)
        Task { await performLogin() }
    }

    func performLogin() async {
        do {
            try await authRepository.login(email: email, password: password)
            updateState(.idle)
            onLoginSuccess?()
        } catch let error as AppError {
            updateState(.error(error.localizedDescription))
        } catch {
            updateState(.error(error.localizedDescription))
        }
    }

    private func updateState(_ newState: ViewState) {
        state = newState
        onStateChange?(newState)
    }
}
