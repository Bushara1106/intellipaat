import XCTest
@testable import AssignmetTest

final class ProgressCalculatorTests: XCTestCase {

    func testProgressPercentage_calculatesRoundedValue() {
        XCTAssertEqual(
            ProgressCalculator.progressPercentage(completedLessons: 1, totalLessons: 4),
            25
        )
        XCTAssertEqual(
            ProgressCalculator.progressPercentage(completedLessons: 2, totalLessons: 3),
            67
        )
    }

    func testProgressPercentage_handlesEdgeCases() {
        XCTAssertEqual(
            ProgressCalculator.progressPercentage(completedLessons: 0, totalLessons: 0),
            0
        )
        XCTAssertEqual(
            ProgressCalculator.progressPercentage(completedLessons: 5, totalLessons: 4),
            100
        )
        XCTAssertEqual(
            ProgressCalculator.progressPercentage(completedLessons: -1, totalLessons: 4),
            0
        )
    }

    func testMarkLessonCompleted_updatesStatusAndProgress() {
        let course = Course(
            id: 1,
            title: "Python Programming",
            instructor: "John Smith",
            progress: 50,
            lessons: 4,
            lessonItems: [
                Lesson(id: 1, title: "Introduction", isCompleted: true),
                Lesson(id: 2, title: "Variables & Data Types", isCompleted: true),
                Lesson(id: 3, title: "Functions", isCompleted: false),
                Lesson(id: 4, title: "OOP", isCompleted: false)
            ]
        )

        let updated = ProgressCalculator.markLessonCompleted(course: course, lessonID: 3)

        XCTAssertTrue(updated.lessonItems[2].isCompleted)
        XCTAssertEqual(updated.progress, 75)
        XCTAssertFalse(course.lessonItems[2].isCompleted) // original unchanged
    }
}
