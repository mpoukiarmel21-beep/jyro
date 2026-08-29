import Combine

@MainActor
final class TranslatorSheetModel: ObservableObject {
    @Published var sourceText = ""
    @Published var targetCode = "fr"
    @Published var result = ""
    @Published var detectedCode: String?
    @Published var isBusy = false
    @Published var errorText = ""
    @Published var reply = ""
    @Published var replyResult = ""
    @Published var replyEngaged = false
    @Published var quickMode = QuickMode.isOn

    private let translator = Translator.shared

    init() {
        if let saved = UserDefaults.standard.string(forKey: "jyro.target"),
           !saved.isEmpty {
            targetCode = saved
        }
        quickMode = QuickMode.isOn
    }

    func setTarget(_ code: String) {
        targetCode = code
        UserDefaults.standard.set(code, forKey: "jyro.target")
        translate()
    }

    func translate() {
        let source = sourceText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !source.isEmpty else { return }
        isBusy = true
        errorText = ""
        Task {
            do {
                let translated = try await translator.translate(source, to: targetCode)
                result = translated.text
                detectedCode = translated.detectedLanguage
            } catch {
                result = ""
                detectedCode = nil
                errorText = (error as? LocalizedError)?.errorDescription ?? "Erreur réseau."
            }
            isBusy = false
        }
    }

    func translateReply() {
        let source = reply.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !source.isEmpty else { return }
        isBusy = true
        Task {
            do {
                let translated = try await translator.translate(source, to: targetCode)
                replyResult = translated.text
            } catch {
                replyResult = (error as? LocalizedError)?.errorDescription ?? "Erreur réseau."
            }
            isBusy = false
        }
    }
}