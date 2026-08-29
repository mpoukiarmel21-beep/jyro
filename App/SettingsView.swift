import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var model: AppModel
    @State private var showTargetPicker = false

    var body: some View {
        Form {
            Section {
                Toggle(isOn: Binding(
                    get: { model.quickMode },
                    set: { model.setQuickMode($0) }
                )) {
                    Label("Mode rapide", systemImage: "control")
                }
                Text("Ajoute un interrupteur Jyro au Centre de contrôle (zone torche / économiseur) pour armer ou désarmer la traduction rapide.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                Button {
                    showTargetPicker = true
                } label: {
                    HStack {
                        Label("Langue de sortie", systemImage: "globe")
                        Spacer()
                        Text(LanguageKit.name(for: model.target))
                            .foregroundStyle(JyroTheme.accent)
                    }
                }
            }

            Section("Comment ça marche") {
                Label("Sélectionne un texte n'importe où → Partage → Jyro → traduction instantanée.", systemImage: "cursorarrow.click.2")
                Label("Rédige une réponse dans ta langue, elle est traduite et copiée.", systemImage: "arrow.up.message.fill")
                Label("Moteurs : réseaux neuronaux Google + secours MyMemory. Gratuit, sans clé.", systemImage: "bolt.fill")
            }

            Section("À propos") {
                LabeledContent("Version") {
                    Text("1.0.0")
                }
                LabeledContent("Installation") {
                    Text("Sideloadly")
                        .foregroundStyle(.secondary)
                }
                Label("Jyro — traduis et réponds partout.", systemImage: "character.bubble.fill")
            }
        }
        .scrollContentBackground(.hidden)
        .background(JyroTheme.appBackground.ignoresSafeArea())
        .navigationTitle("Réglages")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showTargetPicker) {
            LanguagePickerView(current: model.target) { code in
                model.setTarget(code)
            }
        }
    }
}