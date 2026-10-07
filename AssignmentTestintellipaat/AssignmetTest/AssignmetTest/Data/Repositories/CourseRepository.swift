import Foundation

protocol CourseRepositoryProtocol: Sendable {
    func loadCourses() async throws -> CourseLoadResult
    func markLessonCompleted(courseID: Int, lessonID: Int) async throws -> Course
    func course(id: Int) throws -> Course?
}

struct CourseLoadResult: Equatable {
    let courses: [Course]
    let isFromCache: Bool
}

final class CourseRepository: CourseRepositoryProtocol, @unchecked Sendable {
    private let remote: CourseRemoteDataSource
    private let local: CourseLocalStoreProtocol
    private let lock = NSLock()
    private var inMemoryCache: [Course] = []

    init(
        remote: CourseRemoteDataSource = MockCourseService(),
        local: CourseLocalStoreProtocol = CourseLocalStore()
    ) {
        self.remote = remote
        self.local = local
    }

    func loadCourses() async throws -> CourseLoadResult {
        do {
            let remoteCourses = try await remote.fetchCourses()
            try local.save(remoteCourses)
            setMemory(remoteCourses)
            return CourseLoadResult(courses: remoteCourses, isFromCache: false)
        } catch {
            if let cached = try local.load(), !cached.isEmpty {
                setMemory(cached)
                return CourseLoadResult(courses: cached, isFromCache: true)
            }
            throw error
        }
    }

    func markLessonCompleted(courseID: Int, lessonID: Int) async throws -> Course {
        var courses = memorySnapshot()
        if courses.isEmpty, let disk = try local.load() {
            courses = disk
        }

        guard let index = courses.firstIndex(where: { $0.id == courseID }) else {
            throw AppError.unknown("Course not found.")
        }

        let updatedCourse = ProgressCalculator.markLessonCompleted(
            course: courses[index],
            lessonID: lessonID
        )
        courses[index] = updatedCourse
        setMemory(courses)
        try local.save(courses)
        return updatedCourse
    }

    func course(id: Int) throws -> Course? {
        if let found = memorySnapshot().first(where: { $0.id == id }) {
            return found
        }
        return try local.load()?.first(where: { $0.id == id })
    }

    private func setMemory(_ courses: [Course]) {
        lock.lock()
        inMemoryCache = courses
        lock.unlock()
    }

    private func memorySnapshot() -> [Course] {
        lock.lock()
        defer { lock.unlock() }
        return inMemoryCache
    }
}
