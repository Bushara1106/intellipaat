import Foundation

@MainActor
final class CourseDashboardViewModel {
    enum LoadState: Equatable {
        case idle
        case loading
        case success
        case empty
        case failure(String)
    }

    private(set) var courses: [Course] = []
    private(set) var loadState: LoadState = .idle
    private(set) var isOfflineBannerVisible = false

    var onStateChange: (() -> Void)?

    private let courseRepository: CourseRepositoryProtocol

    init(courseRepository: CourseRepositoryProtocol = AppDependencies.shared.courseRepository) {
        self.courseRepository = courseRepository
    }

    func load() {
        Task { await refresh() }
    }

    func refresh() async {
        loadState = .loading
        isOfflineBannerVisible = false
        onStateChange?()

        do {
            let result = try await courseRepository.loadCourses()
            courses = result.courses
            isOfflineBannerVisible = result.isFromCache
            loadState = result.courses.isEmpty ? .empty : .success
        } catch {
            courses = []
            loadState = .failure(error.localizedDescription)
        }
        onStateChange?()
    }

    func course(at index: Int) -> Course? {
        guard courses.indices.contains(index) else { return nil }
        return courses[index]
    }
}
