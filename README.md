# Jyro

**Jyro** est une app iOS de traduction universelle : traduis n'importe quel texte sélectionné, où qu'il soit (Messages, WhatsApp, Telegram, Safari, OnlyFans…), et réponds directement dans l'interface — dans la langue de ton interlocuteur.

> IPA non signée distribuée via **GitHub Releases** et installée avec **Sideloadly** (Apple ID, 7 jours en compte gratuit).

## Fonctionnalités

- **Partage → Jyro** : sélectionne un texte, touche *Partager*, choisis Jyro. Le petit volet traduit instantanément (détection auto de la langue) avec bouton **Réessayer**.
- **Réponse rapide** : écris ta réponse en français, Jyro la traduit dans la langue cible et la copie automatiquement — prête à coller.
- **Clavier Jyro** : un vrai clavier qui **répond directement dans la conversation** (WhatsApp, Telegram, OnlyFans, SMS…) : [📋 Copié] charge le message et détecte sa langue, tu écris ta réponse, [▶ Répondre] l'insère dans le champ déjà traduite. Toggle « ✍️ Auto » pour écrire automatiquement.
- **Carte flottante (gamme PLAYit)** : Jyro fabrique une petite vidéo de ta traduction et la lance en **Picture-in-Picture** → la carte flotte **au-dessus de toutes les apps** (WhatsApp, YouTube…) tant que tu ne la fermes pas. Accessible via le bouton « Flotter » après une traduction ou dans l'onglet Bouton.
- **Détection auto du copié** : tu copies un message, tu ouvres Jyro → il est rempli et traduit automatiquement.
- **App principale** : traduction (coller/écrire), onglet `Bouton flottant`, historique (100 dernières), réglages.
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
5. À la **première ouverture de l'app**, un écran d'accueil explique tout : **aucune autorisation à donner**, Jyro fonctionne directement via le menu Partager.
6. **(A)** Sélectionner un texte → **Partager → Jyro**.
7. **(B) Clavier Jyro** *(optionnel)* : dans l'app, Réglages → Général → Clavier → Claviers → *Ajouter un clavier* → **Jyro**, puis activer **« Autoriser l'accès complet »** dans Jyro. Ces 3 étapes sont détaillées dans l'écran d'accueil de l'app (le clavier est le seul point qui exige un réglage Apple, impossible à automatiser — Jyro fonctionne à 100 % sans lui).

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