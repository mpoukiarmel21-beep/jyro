import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            NavigationStack {
                TranslateView()
            }
            .tabItem {
                Label("Traduire", systemImage: "bubble.left.and.text.bubble.right")
            }
            .tag(0)

            NavigationStack {
                ReplyView()
            }
            .tabItem {
                Label("Répondre", systemImage: "arrow.up.message.fill")
            }
            .tag(1)

            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label("Historique", systemImage: "clock.arrow.circlepath")
            }
            .tag(2)

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Réglages", systemImage: "gearshape.fill")
            }
            .tag(3)
        }
        .tint(JyroTheme.accent)
        .preferredColorScheme(.dark)
    }
}