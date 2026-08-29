import SwiftUI

@main
struct JyroApp: App {
    @StateObject private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(model)
                .onOpenURL { url in
                    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                          let query = components.queryItems?.first(where: { $0.name == "q" })?.value else {
                        return
                    }
                    model.openShareLink(query)
                }
                .task { model.loadHistories() }
        }
    }
}