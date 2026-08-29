import AVFoundation

@MainActor
final class Speaker {
    static let shared = Speaker()
    private let synth = AVSpeechSynthesizer()

    private init() {}

    func speak(_ text: String, language: String?) {
        synth.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        if let language, !language.isEmpty {
            utterance.voice = AVSpeechSynthesisVoice(language: language)
        }
        synth.speak(utterance)
    }
}