import SwiftUI

@MainActor
final class AppModel: ObservableObject {
    @Published var source = ""
    @Published var target = "fr"
    @Published var result = ""
    @Published var detectedCode: String?
    @Published var isBusy = false
    @Published var errorText = ""
    @Published var histories: [HistoryEntry] = []
    @Published var quickMode = QuickMode.isOn
    @Published var autoTranslate = UserDefaults.standard.object(forKey: "jyro.autoTranslate") as? Bool ?? true

    private let translator = Translator.shared
    private let store = HistoryStore()

    init() {
        if let saved = UserDefaults.standard.string(forKey: "jyro.target"),
           !saved.isEmpty {
            target = saved
        }
        quickMode = QuickMode.isOn
    }

    func loadHistories() {
        histories = store.all()
    }

    func setTarget(_ code: String) {
        target = code
        UserDefaults.standard.set(code, forKey: "jyro.target")
    }

    func setQuickMode(_ on: Bool) {
        QuickMode.set(on)
        quickMode = QuickMode.isOn
    }

    func setAutoTranslate(_ on: Bool) {
        autoTranslate = on
        UserDefaults.standard.set(on, forKey: "jyro.autoTranslate")
    }

    func autoDetectClipboard() {
        guard autoTranslate,
              let clipboard = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines),
              !clipboard.isEmpty else { return }
        let last = UserDefaults.standard.string(forKey: "jyro.lastClipboard") ?? ""
        guard clipboard != last else { return }
        UserDefaults.standard.set(clipboard, forKey: "jyro.lastClipboard")
        source = clipboard
        result = ""
        errorText = ""
        translateNow()
    }

    func pasteFromClipboard() {
        guard let string = UIPasteboard.general.string else { return }
        source = string
    }

    func copyResult() {
        guard !result.isEmpty else { return }
        UIPasteboard.general.string = result
    }

    func translateNow() {
        let trimmed = source.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        isBusy = true
        errorText = ""
        Task {
            do {
                let translated = try await translator.translate(trimmed, to: target)
                result = translated.text
                detectedCode = translated.detectedLanguage
                store.add(HistoryEntry(
                    source: trimmed,
                    result: translated.text,
                    sourceCode: translated.detectedLanguage ?? "",
                    targetCode: target
                ))
                loadHistories()
            } catch {
                result = ""
                detectedCode = nil
                errorText = (error as? LocalizedError)?.errorDescription ?? "Erreur réseau."
            }
            isBusy = false
        }
    }

    func clearResult() {
        result = ""
        detectedCode = nil
        errorText = ""
    }

    func openShareLink(_ text: String) {
        source = text
        result = ""
        errorText = ""
        translateNow()
    }

    func removeHistory(_ entry: HistoryEntry) {
        histories.removeAll { $0.id == entry.id }
        store.remove(id: entry.id)
    }

    func clearHistory() {
        histories = []
        store.clear()
    }
}