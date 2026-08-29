import SwiftUI

struct OnboardingView: View {
    @Binding var done: Bool
    @State private var wantsKeyboard = false

    var body: some View {
        ZStack {
            JyroTheme.appBackground.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Image(systemName: "character.bubble.fill")
                            .font(.system(size: 52))
                            .foregroundStyle(JyroTheme.accent)
                        Text("Jyro")
                            .font(.system(size: 34, weight: .bold))
                        Text("Traduis n'importe quel texte et réponds dans la langue de ton interlocuteur.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }
                    .padding(.top, 40)

                    VStack(spacing: 12) {
                        featureRow(icon: "cursorarrow.click.2", title: "Fonctionne partout, sans réglage",
                                   text: "Sélectionne un texte → Partager → Jyro : traduction instantanée. Aucune autorisation à donner.")
                        featureRow(icon: "arrow.up.message.fill", title: "Réponds direct",
                                   text: "Écris ta réponse, Jyro la traduit et la copie prête à coller — ou utilise le clavier Jyro pour l'écrire direct dans la conversation.")
                        featureRow(icon: "doc.on.clipboard.fill", title: "Coller → traduire",
                                   text: "Copie un message puis ouvre Jyro : il est rempli et traduit automatiquement.")
                        featureRow(icon: "bolt.fill", title: "Gratuit, sans clé",
                                   text: "Réseaux neuronaux Google + secours MyMemory. Aucun compte.")
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 20).fill(JyroTheme.card))
                    .padding(.horizontal, 16)

                    VStack(spacing: 12) {
                        Button {
                            finish()
                        } label: {
                            Text("Continuer")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(JyroTheme.accent)

                        DisclosureGroup(isExpanded: $wantsKeyboard) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Le clavier Jyro écrit la réponse traduite directement dans la conversation (WhatsApp, Telegram, juste pour la lire avant d'envoyer…). Il fait suite à un réglage Apple impossible à automatiser depuis une app — voici les 3 étapes (30 secondes) :")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                stepRow(1, "Réglages → Général → Clavier → Claviers")
                                stepRow(2, "Ajouter un clavier → Jyro")
                                stepRow(3, "Toucher Jyro → activer « Accès complet »")
                                Text("Sans cet accès, le clavier ne peut ni lire le texte copié ni se connecter pour traduire.")
                                    .font(.footnote.weight(.medium))
                                    .foregroundStyle(.orange)
                            }
                            .padding(.vertical, 6)
                        } label: {
                            HStack {
                                Image(systemName: "keyboard.fill")
                                Text("Activer aussi le clavier Jyro (optionnel)")
                            }
                            .font(.subheadline.weight(.semibold))
                        }
                        .tint(JyroTheme.accent)
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 20).fill(JyroTheme.card))
                    .padding(.horizontal, 16)

                    Spacer(minLength: 24)
                }
            }
        }
    }

    private func featureRow(icon: String, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(JyroTheme.accent)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(text).font(.footnote).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func stepRow(_ n: Int, _ label: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(n)")
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .background(Circle().fill(JyroTheme.accent))
            Text(label)
                .font(.footnote)
                .foregroundStyle(.primary)
        }
    }

    private func finish() {
        UserDefaults.standard.set(true, forKey: "jyro.onboarded")
        done = true
    }
}

#Preview {
    OnboardingView(done: .constant(false))
}