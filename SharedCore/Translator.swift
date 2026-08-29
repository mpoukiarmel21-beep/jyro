import Foundation

enum TranslateError: Error, LocalizedError {
    case empty
    case bad(String)

    var errorDescription: String? {
        switch self {
        case .empty: return "Rien à traduire."
        case .bad(let message): return message
        }
    }
}

struct TranslationResult: Sendable {
    let text: String
    let detectedLanguage: String?
    let engine: String
}

enum LanguageKit {
    static let all: [(code: String, name: String)] = [
        ("fr", "Français"), ("en", "English"), ("es", "Español"),
        ("de", "Deutsch"), ("it", "Italiano"), ("pt", "Português"),
        ("nl", "Nederlands"), ("pl", "Polski"), ("tr", "Türkçe"),
        ("ru", "Русский"), ("ar", "العربية"), ("he", "עברית"),
        ("hi", "हिन्दी"), ("zh-CN", "简体中文"), ("zh-TW", "繁體中文"),
        ("ja", "日本語"), ("ko", "한국어"), ("th", "ไทย"),
        ("vi", "Tiếng Việt"), ("id", "Bahasa Indonesia"), ("sv", "Svenska"),
        ("da", "Dansk"), ("fi", "Suomi"), ("no", "Norsk"),
        ("cs", "Čeština"), ("el", "Ελληνικά"), ("uk", "Українська"),
        ("ro", "Română"), ("hu", "Magyar"), ("bg", "Български"),
        ("ms", "Bahasa Melayu"), ("ta", "தமிழ்"), ("sw", "Kiswahili")
    ]

    static let quickChips: [(code: String, name: String)] = [
        ("fr", "Français"), ("en", "English"), ("es", "Español"),
        ("de", "Deutsch"), ("it", "Italiano"), ("pt", "Português"),
        ("ar", "العربية"), ("ja", "日本語")
    ]

    static func name(for code: String) -> String {
        if code.isEmpty || code == "auto" { return "Auto" }
        let lower = code.lowercased()
        return all.first { $0.code.lowercased() == lower }?.name ?? code.uppercased()
    }

    static func guess(_ text: String) -> String {
        var arabic = 0, hebrew = 0, thai = 0, cyrillic = 0, cjk = 0, hangul = 0, kana = 0, latin = 0
        for scalar in text.unicodeScalars {
            switch scalar.value {
            case 0x0600...0x06FF: arabic += 1
            case 0x0590...0x05FF: hebrew += 1
            case 0x0E00...0x0E7F: thai += 1
            case 0x0400...0x04FF: cyrillic += 1
            case 0x4E00...0x9FFF, 0x3400...0x4DBF: cjk += 1
            case 0xAC00...0xD7AF: hangul += 1
            case 0x3040...0x30FF: kana += 1
            case 0x0041...0x007A: latin += 1
            default: break
            }
        }
        if arabic > 0 { return "ar" }
        if hebrew > 0 { return "he" }
        if thai > 0 { return "th" }
        if cyrillic > latin && cyrillic > 0 { return "ru" }
        if hangul > 0 { return "ko" }
        if kana > 0 { return "ja" }
        if cjk > 0 { return "zh-CN" }
        let lower = text.lowercased()
        let markers = ["le ", "la ", "les ", "des ", "que ", "qui ", "dans ", "pour ", "vous ", "une ", "est ", "mon ", "ma ", "nous "]
        for marker in markers where lower.contains(marker) {
            return "fr"
        }
        return "en"
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

final class Translator: @unchecked Sendable {
    static let shared = Translator()

    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 20
        session = URLSession(configuration: config)
    }

    func translate(_ text: String, to target: String) async throws -> TranslationResult {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw TranslateError.empty }
        do {
            return try await google(trimmed, to: target)
        } catch {
            let from = LanguageKit.guess(trimmed)
            return try await myMemory(trimmed, from: from, to: target)
        }
    }

    private func google(_ text: String, to target: String) async throws -> TranslationResult {
        var components = URLComponents(string: "https://translate.googleapis.com/translate_a/single")!
        components.queryItems = [
            URLQueryItem(name: "client", value: "gtx"),
            URLQueryItem(name: "sl", value: "auto"),
            URLQueryItem(name: "tl", value: target),
            URLQueryItem(name: "dt", value: "t"),
            URLQueryItem(name: "dj", value: "1"),
            URLQueryItem(name: "q", value: text)
        ]
        guard let url = components.url else { throw TranslateError.bad("URL invalide.") }
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await session.data(for: request)
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            throw TranslateError.bad("Google \(http.statusCode)")
        }
        if let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let sentences = dict["sentences"] as? [[String: Any]] {
            let parts = sentences.compactMap { row -> String? in
                guard let segment = row["trans"] as? String, !segment.isEmpty else { return nil }
                return segment
            }
            let translated = parts.joined()
            guard !translated.isEmpty else { throw TranslateError.bad("Traduction vide.") }
            return TranslationResult(text: translated, detectedLanguage: dict["src"] as? String, engine: "Google")
        }
        if let array = try? JSONSerialization.jsonObject(with: data) as? [[Any]],
           let rows = array.first as? [[Any]] {
            let parts = rows.compactMap { row -> String? in
                guard let segment = row.first as? String, !segment.isEmpty else { return nil }
                return segment
            }
            let translated = parts.joined()
            guard !translated.isEmpty else { throw TranslateError.bad("Traduction vide.") }
            return TranslationResult(text: translated, detectedLanguage: array[safe: 2] as? String, engine: "Google")
        }
        throw TranslateError.bad("Réponse illisible de Google.")
    }

    private func myMemory(_ text: String, from: String, to: String) async throws -> TranslationResult {
        var components = URLComponents(string: "https://api.mymemory.translated.net/get")!
        components.queryItems = [
            URLQueryItem(name: "q", value: text),
            URLQueryItem(name: "langpair", value: "\(from)|\(to)")
        ]
        guard let url = components.url else { throw TranslateError.bad("URL invalide.") }
        let (data, _) = try await session.data(from: url)
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw TranslateError.bad("Réponse illisible de MyMemory.")
        }
        if let responseData = json["responseData"] as? [String: Any],
           let translated = responseData["translatedText"] as? String,
           !translated.isEmpty {
            return TranslationResult(text: translated, detectedLanguage: nil, engine: "MyMemory")
        }
        throw TranslateError.bad("MyMemory indisponible, réessaie.")
    }
}