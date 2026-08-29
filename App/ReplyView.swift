import SwiftUI

struct ReplyView: View {
    @EnvironmentObject var model: AppModel
    @State private var reply = ""
    @State private var output = ""
    @State private var busy = false
    @State private var showTargetPicker = false

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                VStack(spacing: 6) {
                    Image(systemName: "arrow.up.message.fill")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(JyroTheme.gradient)
                    Text("Tu écris, Jyro traduit pour l'autre.")
                        .font(.headline)
                    Text("Le message traduit est copié automatiquement.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 10)

                ZStack(alignment: .topLeading) {
                    TextEditor(text: $reply)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 140)
                        .padding(6)
                    if reply.isEmpty {
                        Text("Ex : « Oui je suis partant ! »")
                            .foregroundStyle(.tertiary)
                            .padding(.top, 10)
                            .padding(.leading, 12)
                            .allowsHitTesting(false)
                    }
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 20).fill(JyroTheme.card))

                HStack {
                    Text("Réponse en")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button {
                        showTargetPicker = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "globe")
                            Text(LanguageKit.name(for: model.target))
                                .font(.footnote.weight(.semibold))
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(JyroTheme.gradient))
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    go()
                } label: {
                    ZStack {
                        if busy {
                            ProgressView().tint(.white)
                        } else {
                            Label("Traduire la réponse", systemImage: "arrow.up.message.fill")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(JyroTheme.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .disabled(reply.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || busy)

                if !output.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Traduction copiée")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.green)
                            Spacer()
                        }
                        Text(output)
                            .font(.body.weight(.medium))
                            .textSelection(.enabled)
                        HStack(spacing: 10) {
                            Button {
                                UIPasteboard.general.string = output
                            } label: {
                                Label("Recopier", systemImage: "doc.on.doc.fill")
                                    .font(.caption.weight(.semibold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(Capsule().fill(JyroTheme.cardSoft))
                                    .foregroundStyle(JyroTheme.accent)
                            }
                            .buttonStyle(.plain)
                            Button {
                                Speaker.shared.speak(output, language: model.target)
                            } label: {
                                Label("Écouter", systemImage: "speaker.wave.2.fill")
                                    .font(.caption.weight(.semibold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(Capsule().fill(JyroTheme.cardSoft))
                                    .foregroundStyle(JyroTheme.accent)
                            }
                            .buttonStyle(.plain)
                        }
                        Button("Nouvelle réponse") {
                            reply = ""
                            output = ""
                        }
                        .font(.caption)
                        .foregroundStyle(JyroTheme.accent)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 20).fill(JyroTheme.card))
                }
            }
            .padding(16)
        }
        .background(JyroTheme.appBackground.ignoresSafeArea())
        .navigationTitle("Répondre")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showTargetPicker) {
            LanguagePickerView(current: model.target) { code in
                model.setTarget(code)
            }
        }
    }

    private func go() {
        let trimmed = reply.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        busy = true
        Task {
            do {
                let translated = try await Translator.shared.translate(trimmed, to: model.target)
                output = translated.text
                UIPasteboard.general.string = translated.text
            } catch {
                output = (error as? LocalizedError)?.errorDescription ?? "Erreur réseau."
            }
            busy = false
        }
    }
}