import Foundation

enum ProgressCalculator {
    /// Calculates course progress percentage from completed lesson count.
    /// Clamped to 0...100. Returns 0 when total is 0 to avoid divide-by-zero.
    static func progressPercentage(completedLessons: Int, totalLessons: Int) -> Int {
        guard totalLessons > 0 else { return 0 }
        let safeCompleted = max(0, min(completedLessons, totalLessons))
        let value = (Double(safeCompleted) / Double(totalLessons)) * 100.0
        return Int(value.rounded())
    }

    /// Marks a lesson completed and returns an updated course with recalculated progress.
    static func markLessonCompleted(course: Course, lessonID: Int) -> Course {
        var updated = course
        guard let index = updated.lessonItems.firstIndex(where: { $0.id == lessonID }) else {
            return course
        }

        updated.lessonItems[index].isCompleted = true
        let completedCount = updated.lessonItems.filter(\.isCompleted).count
        updated.progress = progressPercentage(
            completedLessons: completedCount,
            totalLessons: updated.lessonItems.count
        )
        updated.lessons = updated.lessonItems.count
        return updated
    }
}
