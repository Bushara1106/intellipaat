import Foundation

protocol CourseRemoteDataSource: Sendable {
    func fetchCourses() async throws -> [Course]
}

/// Loads course JSON from the app bundle and simulates a remote API.
/// When the device is offline, it throws so the repository can serve cached data.
struct MockCourseService: CourseRemoteDataSource {
    var delayNanoseconds: UInt64 = 700_000_000
    /// Toggle in debug to simulate API failure even while online.
    var forceFailure: Bool = false
    private let bundle: Bundle
    private let reachability: NetworkReachability

    init(
        bundle: Bundle = .main,
        forceFailure: Bool = false,
        reachability: NetworkReachability = .shared
    ) {
        self.bundle = bundle
        self.forceFailure = forceFailure
        self.reachability = reachability
    }

    func fetchCourses() async throws -> [Course] {
        try await Task.sleep(nanoseconds: delayNanoseconds)

        if forceFailure || !reachability.isConnected {
            throw AppError.networkUnavailable
        }

        guard let url = bundle.url(forResource: "courses", withExtension: "json") else {
            throw AppError.unknown("courses.json missing from bundle.")
        }

        do {
            let data = try Data(contentsOf: url)
            let courses = try JSONDecoder().decode([Course].self, from: data)
            return courses.map { course in
                var copy = course
                if !copy.lessonItems.isEmpty {
                    copy.lessons = copy.lessonItems.count
                    let completed = copy.lessonItems.filter(\.isCompleted).count
                    copy.progress = ProgressCalculator.progressPercentage(
                        completedLessons: completed,
                        totalLessons: copy.lessonItems.count
                    )
                }
                return copy
            }
        } catch is DecodingError {
            throw AppError.decodingFailed
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.unknown(error.localizedDescription)
        }
    }
}
