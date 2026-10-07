import Foundation

struct Course: Identifiable, Codable, Equatable, Hashable {
    let id: Int
    var title: String
    var instructor: String
    var progress: Int
    var lessons: Int
    var lessonItems: [Lesson]

    enum CodingKeys: String, CodingKey {
        case id, title, instructor, progress, lessons, lessonItems
    }

    init(
        id: Int,
        title: String,
        instructor: String,
        progress: Int,
        lessons: Int,
        lessonItems: [Lesson] = []
    ) {
        self.id = id
        self.title = title
        self.instructor = instructor
        self.progress = progress
        self.lessons = lessons
        self.lessonItems = lessonItems
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        instructor = try container.decode(String.self, forKey: .instructor)
        progress = try container.decode(Int.self, forKey: .progress)
        lessons = try container.decode(Int.self, forKey: .lessons)
        lessonItems = try container.decodeIfPresent([Lesson].self, forKey: .lessonItems) ?? []
    }
}

struct Lesson: Identifiable, Codable, Equatable, Hashable {
    let id: Int
    var title: String
    var isCompleted: Bool
}
