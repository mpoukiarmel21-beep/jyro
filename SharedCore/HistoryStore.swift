import Foundation

struct HistoryEntry: Codable, Identifiable, Sendable {
    let id: UUID
    let source: String
    let result: String
    let sourceCode: String
    let targetCode: String
    let date: Date

    init(source: String, result: String, sourceCode: String, targetCode: String) {
        self.id = UUID()
        self.source = source
        self.result = result
        self.sourceCode = sourceCode
        self.targetCode = targetCode
        self.date = Date()
    }
}

final class HistoryStore: @unchecked Sendable {
    private let key = "jyro.history.v1"
    private let lock = NSLock()

    init() {}

    func all() -> [HistoryEntry] {
        lock.lock()
        defer { lock.unlock() }
        return decode()
    }

    func add(_ entry: HistoryEntry) {
        lock.lock()
        defer { lock.unlock() }
        var list = decode()
        list.insert(entry, at: 0)
        if list.count > 100 {
            list = Array(list.prefix(100))
        }
        if let data = try? JSONEncoder().encode(list) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func remove(id: UUID) {
        lock.lock()
        defer { lock.unlock() }
        var list = decode()
        list.removeAll { $0.id == id }
        if let data = try? JSONEncoder().encode(list) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func clear() {
        lock.lock()
        defer { lock.unlock() }
        UserDefaults.standard.removeObject(forKey: key)
    }

    private func decode() -> [HistoryEntry] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let list = try? JSONDecoder().decode([HistoryEntry].self, from: data) else {
            return []
        }
        return list
    }
}