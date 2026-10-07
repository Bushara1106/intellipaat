import Foundation

@MainActor
final class CourseDetailsViewModel {
    private(set) var course: Course
    private(set) var errorMessage: String?

    var onUpdate: (() -> Void)?

    private let courseRepository: CourseRepositoryProtocol

    init(
        course: Course,
        courseRepository: CourseRepositoryProtocol = AppDependencies.shared.courseRepository
    ) {
        self.course = course
        self.courseRepository = courseRepository
    }

    func markCompleted(lessonID: Int) {
        Task { await completeLesson(lessonID: lessonID) }
    }

    func completeLesson(lessonID: Int) async {
        do {
            course = try await courseRepository.markLessonCompleted(
                courseID: course.id,
                lessonID: lessonID
            )
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        onUpdate?()
    }
}
