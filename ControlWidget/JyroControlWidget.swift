import AppIntents
import SwiftUI
import WidgetKit

@main
struct JyroControlWidget: ControlWidget {
    static let kind = "com.jyro.app.quickmode-control"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: Self.kind,
            provider: QuickModeProvider()
        ) { isOn in
            ControlWidgetToggle(
                "Traduction rapide",
                isOn: isOn,
                action: JyroQuickModeIntent()
            ) { isOn in
                Label(
                    isOn ? "Mode rapide actif" : "Mode rapide",
                    systemImage: isOn ? "character.bubble.fill" : "character.bubble"
                )
            }
            .tint(.purple)
        }
        .displayName("Jyro · Traduction rapide")
        .description("Active ou désactive le mode traduction rapide.")
    }
}

struct QuickModeProvider: ControlValueProvider {
    var previewValue: Bool {
        QuickMode.isOn
    }

    func currentValue() async throws -> Bool {
        QuickMode.isOn
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