import Foundation

protocol CourseLocalStoreProtocol: Sendable {
    func save(_ courses: [Course]) throws
    func load() throws -> [Course]?
    func clear() throws
}

/// Simple offline cache using a JSON file in Application Support.
final class CourseLocalStore: CourseLocalStoreProtocol, @unchecked Sendable {
    private let fileManager: FileManager
    private let fileName: String
    private let queue = DispatchQueue(label: "com.assignmettest.coursestore", qos: .utility)

    init(fileManager: FileManager = .default, fileName: String = "cached_courses.json") {
        self.fileManager = fileManager
        self.fileName = fileName
    }

    private var fileURL: URL {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        let folder = base.appendingPathComponent("AssignmetTest", isDirectory: true)
        if !fileManager.fileExists(atPath: folder.path) {
            try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder.appendingPathComponent(fileName)
    }

    func save(_ courses: [Course]) throws {
        try queue.sync {
            let data = try JSONEncoder().encode(courses)
            try data.write(to: fileURL, options: [.atomic])
        }
    }

    func load() throws -> [Course]? {
        try queue.sync {
            guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([Course].self, from: data)
        }
    }

    func clear() throws {
        try queue.sync {
            guard fileManager.fileExists(atPath: fileURL.path) else { return }
            try fileManager.removeItem(at: fileURL)
        }
    }
}
