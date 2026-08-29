import SwiftUI

struct TranslatorSheetView: View {
    @ObservedObject var model: TranslatorSheetModel
    let onDone: () -> Void
    let onOpen: () -> Void

    @State private var showAllLangs = false

    var body: some View {
        VStack(spacing: 12) {
            header
            sourceCard
            targetRow
            if model.isBusy {
                ProgressView()
                    .tint(JyroTheme.accent)
                    .padding(.top, 6)
            }
            if !model.result.isEmpty && !model.isBusy {
                resultCard
            }
            if !model.errorText.isEmpty && !model.isBusy {
                errorCard
            }
            if model.replyEngaged {
                replyCard
            }
            Spacer(minLength: 0)
            footer
        }
        .padding(14)
        .background(JyroTheme.appBackground.ignoresSafeArea())
        .sheet(isPresented: $showAllLangs) {
            allLangsSheet
        }
    }

    private var header: some View {
        HStack {
            Image(systemName: "character.bubble.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(JyroTheme.gradient)
            Text("Jyro")
                .font(.headline)
            if model.quickMode {
                Text("Rapide")
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(JyroTheme.accent.opacity(0.25)))
                    .foregroundStyle(JyroTheme.accent)
            }
            Spacer()
            Button(action: onDone) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(JyroTheme.cardSoft))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
    }

    private var sourceCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Texte sélectionné")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            ScrollView {
                Text(model.sourceText.isEmpty ? "Aucun texte reçu." : model.sourceText)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 88)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 16).fill(JyroTheme.card))
    }

    private var targetRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(LanguageKit.quickChips, id: \.code) { item in
                    chip(label: item.name, code: item.code)
                }
                Button {
                    showAllLangs = true
                } label: {
                    Text("Toutes")
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Capsule().stroke(JyroTheme.cardSoft, lineWidth: 1.5))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 2)
        }
    }

    private func chip(label: String, code: String) -> some View {
        let active = model.targetCode.lowercased() == code
        return Button {
            model.setTarget(code)
        } label: {
            Text(label)
                .font(.footnote.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Capsule().fill(active ? AnyShapeStyle(JyroTheme.gradient) : AnyShapeStyle(JyroTheme.card)))
                .foregroundStyle(active ? Color.white : Color.primary)
        }
        .buttonStyle(.plain)
    }

    private var resultCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let detected = model.detectedCode, !detected.isEmpty {
                    Text("Détecté : \(LanguageKit.name(for: detected))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Traduction")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            Text(model.result)
                .font(.body.weight(.medium))
                .textSelection(.enabled)
            HStack(spacing: 8) {
                miniButton(title: "Copier", systemImage: "doc.on.doc.fill") {
                    UIPasteboard.general.string = model.result
                }
                miniButton(title: "Écouter", systemImage: "speaker.wave.2.fill") {
                    TranslatorSpeaker.speak(model.result, language: model.targetCode)
                }
                miniButton(title: "Répondre", systemImage: "arrow.up.message.fill") {
                    withAnimation(.snappy) { model.replyEngaged = true }
                }
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 16).fill(JyroTheme.card))
    }

    private var errorCard: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "wifi.exclamationmark")
                .foregroundStyle(.orange)
            Text(model.errorText)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14).fill(JyroTheme.card))
    }

    private var replyCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Réponds en \(LanguageKit.name(for: model.targetCode))")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(JyroTheme.accent)
                Spacer()
                if !model.replyResult.isEmpty {
                    Text("Copiée ✓")
                        .font(.caption2)
                        .foregroundStyle(.green)
                }
            }
            TextField("Écris ta réponse…", text: $model.reply, axis: .vertical)
                .lineLimit(1...3)
                .textFieldStyle(.plain)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 12).fill(JyroTheme.cardSoft))
            HStack(spacing: 8) {
                Button {
                    model.translateReply()
                } label: {
                    HStack(spacing: 6) {
                        if model.isBusy {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "arrow.up.message.fill")
                            Text("Traduire la réponse")
                        }
                    }
                    .font(.footnote.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(JyroTheme.gradient))
                    .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .disabled(model.reply.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || model.isBusy)
                if !model.replyResult.isEmpty {
                    miniButton(title: "Réécrire", systemImage: "autostartstop") {
                        model.reply = ""
                        model.replyResult = ""
                    }
                }
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 16).fill(JyroTheme.card))
    }

    private var footer: some View {
        HStack(spacing: 10) {
            Button(action: onOpen) {
                Label("Ouvrir dans Jyro", systemImage: "arrow.up.forward.app")
                    .font(.footnote.weight(.semibold))
            }
            .buttonStyle(.bordered)
            .tint(JyroTheme.accent)
            Spacer()
            Button("Terminé", action: onDone)
                .font(.footnote.weight(.bold))
                .buttonStyle(.borderedProminent)
                .tint(JyroTheme.accent)
        }
    }

    private func miniButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.caption2.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(JyroTheme.cardSoft))
                .foregroundStyle(JyroTheme.accent)
        }
        .buttonStyle(.plain)
    }

    private var allLangsSheet: some View {
        NavigationStack {
            List(LanguageKit.all, id: \.code) { item in
                Button {
                    model.setTarget(item.code)
                    showAllLangs = false
                } label: {
                    HStack {
                        Text(item.name)
                            .foregroundStyle(.primary)
                        Spacer()
                        if item.code == model.targetCode {
                            Image(systemName: "checkmark")
                                .foregroundStyle(JyroTheme.accent)
                        }
                    }
                }
            }
            .navigationTitle("Langue cible")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.dark)
    }
}

enum TranslatorSpeaker {
    static func speak(_ text: String, language: String) {
        Task { @MainActor in
            Speaker.shared.speak(text, language: language)
        }
    }
}