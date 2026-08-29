import SwiftUI

struct TranslateView: View {
    @EnvironmentObject var model: AppModel
    @State private var showTargetPicker = false
    @State private var showFloat = false

    private var floating = FloatingTranslate.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                hero
                sourceCard
                languageBar
                translateButton
                if !model.result.isEmpty {
                    resultCard
                }
                if !model.errorText.isEmpty && !model.isBusy {
                    errorCard
                }
                howToCard
            }
            .padding(16)
        }
        .background(JyroTheme.appBackground.ignoresSafeArea())
        .navigationTitle("Jyro")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showTargetPicker) {
            LanguagePickerView(current: model.target) { code in
                model.setTarget(code)
            }
        }
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
    }

    private var hero: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(JyroTheme.gradient)
                    .frame(width: 74, height: 74)
                Circle()
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    .frame(width: 86, height: 86)
                Image(systemName: "character.bubble.fill")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)
            }
            Text("Jyro")
                .font(.largeTitle.bold())
            Text("Traduis et réponds, n'importe où")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
        .frame(maxWidth: .infinity)
    }

    private var sourceCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Texte à traduire")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    model.pasteFromClipboard()
                } label: {
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(JyroTheme.cardSoft))
                }
                .buttonStyle(.plain)
                if !model.source.isEmpty {
                    Button {
                        model.source = ""
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .bold))
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(JyroTheme.cardSoft))
                    }
                    .buttonStyle(.plain)
                }
            }
            ZStack(alignment: .topLeading) {
                TextEditor(text: $model.source)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 110)
                    .padding(6)
                if model.source.isEmpty {
                    Text("Colle ou écris le message à traduire…")
                        .foregroundStyle(.tertiary)
                        .padding(.top, 10)
                        .padding(.leading, 12)
                        .allowsHitTesting(false)
                }
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 20).fill(JyroTheme.card))
    }

    private var languageBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "sparkle.magnifyingglass")
                    .font(.footnote)
                Text("Auto")
                    .font(.footnote.weight(.semibold))
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule().fill(JyroTheme.card))

            Button {
                showTargetPicker = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "globe")
                        .font(.footnote)
                    Text(LanguageKit.name(for: model.target))
                        .font(.footnote.weight(.semibold))
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Capsule().fill(JyroTheme.gradient))
            }
            .buttonStyle(.plain)

            Spacer()

            if let detected = model.detectedCode, !detected.isEmpty {
                Text("Détecté : \(LanguageKit.name(for: detected))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var translateButton: some View {
        Button {
            model.translateNow()
        } label: {
            ZStack {
                if model.isBusy {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Traduire")
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
        .disabled(model.source.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || model.isBusy)
        .opacity(model.isBusy ? 0.9 : 1)
    }

    private var resultCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Traduction")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
            }
            Text(model.result)
                .font(.body.weight(.medium))
                .textSelection(.enabled)
            HStack(spacing: 10) {
                actionButton("Copier", "doc.on.doc.fill") {
                    model.copyResult()
                }
                actionButton("Écouter", "speaker.wave.2.fill") {
                    Speaker.shared.speak(model.result, language: model.target)
                }
                if model.floatOn {
                    actionButton("Flotter", "pip.fill") {
                        let card = TranslationCard.render(
                            source: model.source,
                            result: model.result,
                            targetName: LanguageKit.name(for: model.target),
                            detected: model.detectedCode.map { LanguageKit.name(for: $0) }
                        )
                        floating.start(card: card)
                        showFloat = true
                    }
                }
                actionButton("Effacer", "xmark.circle.fill") {
                    model.clearResult()
                }
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 20).fill(JyroTheme.card))
    }

    private var errorCard: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "wifi.exclamationmark")
                .foregroundStyle(.orange)
            Text(model.errorText)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(JyroTheme.card))
    }

    private var howToCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Traduire partout", systemImage: "hand.tap.fill")
                .font(.footnote.weight(.bold))
            Text("Sélectionne une phrase dans Messages, WhatsApp, Telegram, Safari… puis touche **Partager → Jyro**. La traduction s'affiche, et tu peux répondre directement.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(JyroTheme.card.opacity(0.55)))
    }

    private func actionButton(_ title: String, _ systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Capsule().fill(JyroTheme.cardSoft))
                .foregroundStyle(JyroTheme.accent)
        }
        .buttonStyle(.plain)
    }
}