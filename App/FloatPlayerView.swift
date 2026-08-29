import SwiftUI
import AVKit

/// Lecteur plein écran qui propose le bouton Picture-in-Picture :
/// une fois « ⧉ » touché, la carte flotte au-dessus de toutes les apps.
struct FloatPlayerView: UIViewControllerRepresentable {
    @ObservedObject var floating: FloatingTranslate

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.allowsPictureInPicturePlayback = true
        controller.canStartPictureInPictureAutomaticallyFromInline = true
        controller.player = floating.player
        return controller
    }

    func updateUIViewController(_ controller: AVPlayerViewController, context: Context) {
        controller.player = floating.player
    }
}