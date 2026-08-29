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
                Text("Ajoute l'interrupteur Jyro dans le Centre de contrôle (zone torche / économiseur). iPhone ne permet pas à une app d'afficher un bouton flottant par-dessus les autres apps — c'est pourquoi Jyro passe par le menu Partager, le clavier et la détection du copié.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Toggle(isOn: Binding(
                    get: { model.autoTranslate },
                    set: { model.setAutoTranslate($0) }
                )) {
                    Label("Détection auto du copié", systemImage: "doc.on.clipboard.fill")
                }
                Text("Quand tu ouvres Jyro après avoir copié un texte, il est rempli et traduit automatiquement.")
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