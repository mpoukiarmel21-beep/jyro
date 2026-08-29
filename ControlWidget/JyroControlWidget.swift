import AppIntents
import ControlCenter
import SwiftUI

@main
struct JyroControlWidget: ControlWidget {
    var body: some ControlWidgetConfiguration {
        ToggleControlIntentWidget(kind: "com.jyro.app.quickmode-control") {
            Label("Jyro", systemImage: "character.bubble.fill")
        } intent: {
            JyroQuickModeIntent()
        }
    }
}

struct JyroQuickModeIntent: SetValueIntent {
    static let title = LocalizedStringResource("Mode traduction rapide")

    @Parameter(title: "Activé")
    var value: Bool

    func perform() async throws -> some IntentResult {
        QuickMode.set(value)
        return .result()
    }
}