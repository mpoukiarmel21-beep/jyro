# Jyro

**Jyro** est une app iOS de traduction universelle : traduis n'importe quel texte sélectionné, où qu'il soit (Messages, WhatsApp, Telegram, Safari, OnlyFans…), et réponds directement dans l'interface — dans la langue de ton interlocuteur.

> IPA non signée distribuée via **GitHub Releases** et installée avec **Sideloadly** (Apple ID, 7 jours en compte gratuit).

## Fonctionnalités v1

- **Partage → Jyro** : sélectionne un texte, touche *Partager*, choisis Jyro. Le petit volet traduit instantanément (détection auto de la langue).
- **Réponse rapide** : écris ta réponse en français, Jyro la traduit dans la langue cible et la copie automatiquement — prête à coller.
- **App principale** : traduction (coller/écrire), onglet `Répondre`, historique (100 dernières), réglages.
- **Interrupteur Centre de contrôle** (iOS 18+) : « Mode rapide Jyro » dans la zone torche/économiseur.
- **Lecture vocale** (TTS système, gratuit).
- **Moteur gratuit** : réseaux neuronaux Google (endpoint gtx, sans clé) + secours MyMemory. Aucun compte, aucune clé API.

## Pourquoi pas un popup flottant au-dessus des apps ?

iOS (sans jailbreak) interdit à toute app d'afficher une fenêtre flottante au-dessus des autres applications, ou d'intercepter automatiquement la sélection de texte. Le seul chemin fourni par Apple pour agir sur une sélection n'importe où est l'action **Partager** — c'est ce que Jyro exploite, avec le même geste partout.

## Installer

1. Démarrer un runner **GitHub Actions** (`workflow_dispatch`) pour produire l'IPA et la Release.
2. Télécharger `Jyro.ipa` depuis la Release.
3. Ouvrir **Sideloadly**, connecter l'iPhone, glisser l'IPA, entrer ton Apple ID, *Start*.
4. Réglages → Général → Gestion VPN & appareils → approuver le profil.
5. Sélectionner un texte → **Partager → Jyro**.

## Développement

- Structure multi-cibles générée par **XcodeGen** (`project.yml`), build macOS uniquement.
- `SharedCore` : moteur de traduction, historique, mode rapide, thème.
- `App` : l'application principale (SwiftUI).
- `ShareExt` : extension de partage (le point d'entrée universel).
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