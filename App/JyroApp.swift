import SwiftUI

@main
struct JyroApp: App {
    @StateObject private var model = AppModel()
    @Environment(\.scenePhase) private var scenePhase
    @State private var onboarded = UserDefaults.standard.bool(forKey: "jyro.onboarded")

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(model)
                .fullScreenCover(isPresented: Binding(
                    get: { !onboarded },
                    set: { if !$0 { onboarded = true } }
                )) {
                    OnboardingView(done: $onboarded)
                }
                .onOpenURL { url in
                    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                          let query = components.queryItems?.first(where: { $0.name == "q" })?.value else {
                        return
                    }
                    model.openShareLink(query)
                }
                .task { model.loadHistories() }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active {
                        model.autoDetectClipboard()
                    }
                }
        }
    }
}