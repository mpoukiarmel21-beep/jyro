import SwiftUI

/// Page « Bouton flottant » : où l'utilisateur active et paramètre la carte
/// flottante de traduction (style PLAYit via Picture-in-Picture iOS).
struct FloatSettingsView: View {
    @EnvironmentObject var model: AppModel
    @State private var showFloat = false
    @State private var testDone = false

    private var floating = FloatingTranslate.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                hero

                toggleCard(
                    title: "Bouton flottant de traduction",
                    subtitle: "La carte de traduction flotte au-dessus de toutes les apps (WhatsApp, YouTube…) comme une vidéo en réduit. Elle reste active jusqu'à ce que tu la fermes.",
                    systemImage: "pip.fill",
                    isOn: Binding(
                        get: { model.floatOn },
                        set: { model.setFloatOn($0) }
                    )
                )

                toggleCard(
                    title: "Détection automatique du copié",
                    subtitle: "Dès que tu ouvres Jyro après avoir copié un texte, il est rempli et traduit tout seul — sans aucun clic.",
                    systemImage: "doc.on.clipboard.fill",
                    isOn: Binding(
                        get: { model.autoTranslate },
                        set: { model.setAutoTranslate($0) }
                    )
                )

                floatCard

                ideasCard
            }
            .padding(16)
        }
        .background(JyroTheme.appBackground.ignoresSafeArea())
        .navigationTitle("Bouton flottant")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showFloat) {
            NavigationView {
                FloatPlayerView(floating: floating)
                    .ignoresSafeArea()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Fermer") {
                                floating.stop()
                                showFloat = false
                            }
                        }
                    }
            }
            .preferredColorScheme(.dark)
        }
        .onAppear {
            if floating.player == nil && floating.errorText == nil {
                testDone = false
            }
        }
    }

    private var hero: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(JyroTheme.gradient)
                    .frame(width: 72, height: 72)
                Circle()
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    .frame(width: 84, height: 84)
                Image(systemName: "pip.fill")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
            }
            Text("Carte flottante")
                .font(.title3.bold())
            Text("Comme PLAYit : la carte reste à l'écran\nau-dessus de n'importe quelle app.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
        .frame(maxWidth: .infinity)
    }

    private func toggleCard(title: String, subtitle: String, systemImage: String, isOn: Binding<Bool>) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(JyroTheme.accent)
                .frame(width: 30)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(subtitle).font(.footnote).foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            Toggle("", isOn: isOn)
                .labelsHidden()
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 18).fill(JyroTheme.card))
    }

    private var floatCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Faire flotter")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            if let currentResult = model.resultNonEmpty {
                Text("Dernière traduction :")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text("\"\(currentResult)\"")
                    .font(.footnote.weight(.medium))
                    .lineLimit(2)
                    .textSelection(.enabled)
                Button {
                    floatCurrent()
                } label: {
                    Label("Faire flotter cette traduction", systemImage: "pip.enter")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(JyroTheme.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .disabled(!model.floatOn || floating.isPreparing)
            } else {
                Text("Aucune traduction pour l'instant. Teste avec un exemple :")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Button {
                    testFloat()
                } label: {
                    Label(testDone ? "Relancer l'exemple" : "Essayer avec un exemple",
                          systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(JyroTheme.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .disabled(!model.floatOn || floating.isPreparing)
            }

            if floating.isPreparing {
                HStack(spacing: 8) {
                    ProgressView().tint(JyroTheme.accent)
                    Text("Préparation de la carte…").font(.footnote).foregroundStyle(.secondary)
                }
            }
            if let error = floating.errorText {
                Text(error).font(.footnote).foregroundStyle(.orange)
            }

            Text("Touche le bouton ⧉ (Picture-in-Picture) dans la vidéo pour faire flotter la carte au-dessus de toutes les apps.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 18).fill(JyroTheme.card))
    }

    private var ideasCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Idées de paramétrage", systemImage: "sparkles")
                .font(.caption.weight(.bold))
            ForEach([
                "Carte froide : stylet ou mascotte animé pendant la traduction.",
                "Bouton flottant : écouté à voix haute (TTS) + copie en 1 clic en PiP.",
                "Répondre en flottant : tape la réponse, elle se traduit et l'autre côté est prêt à coller.",
                "Mini-carte sur la vidéo : suit la lecture YouTube comme un badge.",
            ], id: \.self) { idea in
                Label(idea, systemImage: "lightbulb")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 18).fill(JyroTheme.card.opacity(0.55)))
    }

    private func floatCurrent() {
        guard let result = model.resultNonEmpty, let detected = model.detectedCode else { return }
        let card = TranslationCard.render(
            source: model.source, result: result,
            targetName: LanguageKit.name(for: model.target), detected: LanguageKit.name(for: detected)
        )
        floating.start(card: card)
        showFloat = true
    }

    private func testFloat() {
        testDone = true
        let card = TranslationCard.render(
            source: "Hello, how are you?",
            result: "Bonjour, comment vas-tu ?",
            targetName: "Français",
            detected: "English"
        )
        floating.start(card: card)
        showFloat = true
    }
}