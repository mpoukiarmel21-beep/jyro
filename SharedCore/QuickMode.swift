import Foundation

enum QuickMode {
    static let suiteName = "group.com.jyro.app"

    static func store() -> UserDefaults {
        UserDefaults(suiteName: suiteName) ?? .standard
    }

    static var isOn: Bool {
        store().bool(forKey: "jyro.quickMode")
    }

    static func set(_ on: Bool) {
        store().set(on, forKey: "jyro.quickMode")
    }
}