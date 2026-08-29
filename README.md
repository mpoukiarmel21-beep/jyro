# Jyro

**Jyro** est une app iOS de traduction universelle : traduis n'importe quel texte sélectionné, où qu'il soit (Messages, WhatsApp, Telegram, Safari, OnlyFans…), et réponds directement dans l'interface — dans la langue de ton interlocuteur.

> IPA non signée distribuée via **GitHub Releases** et installée avec **Sideloadly** (Apple ID, 7 jours en compte gratuit).

## Fonctionnalités

- **Partage → Jyro** : sélectionne un texte, touche *Partager*, choisis Jyro. Le petit volet traduit instantanément (détection auto de la langue) avec bouton **Réessayer**.
- **Réponse rapide** : écris ta réponse en français, Jyro la traduit dans la langue cible et la copie automatiquement — prête à coller.
- **Clavier Jyro** : un vrai clavier qui **répond directement dans la conversation** (WhatsApp, Telegram, OnlyFans, SMS…) : [📋 Copié] charge le message et détecte sa langue, tu écris ta réponse, [▶ Répondre] l'insère dans le champ déjà traduite. Toggle « ✍️ Auto » pour écrire automatiquement.
- **App principale** : traduction (coller/écrire), onglet `Répondre`, historique (100 dernières), réglages.
- **Interrupteur Centre de contrôle** (iOS 18+) : « Mode rapide Jyro » dans la zone torche/économiseur.
- **Lecture vocale** (TTS système, gratuit).
- **Moteur gratuit** : réseaux neuronaux Google (endpoints gtx + dict-chrome-ex, sans clé) + secours MyMemory. Aucun compte, aucune clé API.

## Pourquoi pas un popup flottant au-dessus des apps ?

iOS (sans jailbreak) interdit à toute app d'afficher une fenêtre flottante au-dessus des autres applications, ou d'intercepter automatiquement la sélection de texte. Les seuls chemins fournis par Apple : l'action **Partager** (que Jyro exploite partout) et le **clavier** (qui peut écrire dans n'importe quel champ lorsqu'il est actif).

## Installer

1. Démarrer un runner **GitHub Actions** (`workflow_dispatch`) pour produire l'IPA et la Release.
2. Télécharger `Jyro.ipa` depuis la Release.
3. Ouvrir **Sideloadly**, connecter l'iPhone, glisser l'IPA, entrer ton Apple ID, *Start*.
4. Réglages → Général → Gestion VPN & appareils → approuver le profil.
5. **(A)** Sélectionner un texte → **Partager → Jyro**.
6. **(B) Clavier Jyro** : Réglages → Général → Clavier → Claviers → *Ajouter un clavier* → **Jyro**. Puis Réglages → Général → Clavier → Claviers → toucher **Jyro** → activer **« Autoriser l'accès complet »** (requis pour la lecture du texte copié et la traduction réseau depuis le clavier).
7. Dans une conversation : copie le message reçu → ouvre Jyro en clavier → [📋 Copié] → écris ta réponse → [▶ Répondre].

## Développement

- Structure multi-cibles générée par **XcodeGen** (`project.yml`), build macOS uniquement.
- `SharedCore` : moteur de traduction, historique, mode rapide, thème.
- `App` : l'application principale (SwiftUI).
- `ShareExt` : extension de partage (le point d'entrée universel).
- `Keyboard` : clavier Jyro (écriture universelle de la réponse traduite).
- `ControlWidget` : interrupteur du Centre de contrôle (iOS 18+).
- `scripts/make_icon.py` : génération du logo (labo PIL).

## Build local (macOS)

```sh
brew install xcodegen
xcodegen generate
xcodebuild -project Jyro.xcodeproj -scheme Jyro -configuration Release \
  -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build
```

Puis `Payload/Jyro.app` → `Jyro.ipa` → Sideloadly.

## Feuille de route

- Traduction vocale entrée/sortie (ElevenLabs / Apple Speech)
- Widget écran d'accueil de traduction rapide
- OCR caméra → traduction d'écran
- Étiquette de langue détectée sur la sélection
- Moteur DeepL en option si une clé gratuite est fournie