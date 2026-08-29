import SwiftUI
import AVFoundation
import AVKit
import UIKit

/// Fenêtre flottante type « PLAYit » : Jyro fabrique une petite vidéo de la carte
/// de traduction et la lance en Picture-in-Picture — le système la dessine
/// par-dessus n'importe quelle app (WhatsApp, YouTube…) jusqu'à fermeture.
@MainActor
final class FloatingTranslate: ObservableObject {
    static let shared = FloatingTranslate()

    @Published var player: AVPlayer?
    @Published var isPreparing = false
    @Published var errorText: String?

    private var endObserver: NSObjectProtocol?

    func start(card: UIImage) {
        guard !isPreparing else { return }
        isPreparing = true
        errorText = nil
        Task {
            do {
                let url = try await Task.detached {
                    try Self.buildClip(card: card)
                }.value
                let player = AVPlayer(url: url)
                player.isMuted = true
                player.actionAtItemEnd = .none
                if let observer = endObserver {
                    NotificationCenter.default.removeObserver(observer)
                }
                endObserver = NotificationCenter.default.addObserver(
                    forName: AVPlayerItem.didPlayToEndTimeNotification,
                    object: player.currentItem,
                    queue: .main
                ) { [weak player] _ in
                    player?.seek(to: .zero)
                    player?.play()
                }
                self.player = player
                player.play()
            } catch {
                errorText = "Impossible de créer la carte flottante."
            }
            isPreparing = false
        }
    }

    func stop() {
        if let observer = endObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        endObserver = nil
        player?.pause()
        player = nil
    }

    /// Fabrique un .mov : la carte affichée en boucle (vidéo calme, sans son).
    /// La lecture en boucle garde la fenêtre PiP vivante tant que l'utilisateur
    /// ne la ferme pas.
    nonisolated static func buildClip(card: UIImage) throws -> URL {
        let width = Int(card.size.width)
        let height = Int(card.size.height)
        let fps: Int32 = 15
        let timescale: Int32 = 600
        let frameCount = 600
        let step = Int64(timescale) / Int64(fps)

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("jyro_float_\(UUID().uuidString).mov")
        let writer = try AVAssetWriter(outputURL: url, fileType: .mov)
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height
        ]
        let input = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        input.expectsMediaDataInRealTime = false
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: input,
            sourcePixelBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
                kCVPixelBufferWidthKey as String: width,
                kCVPixelBufferHeightKey as String: height
            ]
        )
        writer.add(input)
        writer.startWriting()
        writer.startSession(atSourceTime: .zero)

        let colorSpace = CGColorSpaceCreateDeviceRGB()

        for frame in 0..<frameCount {
            while !input.isReadyForMoreMediaData {
                Thread.sleep(forTimeInterval: 0.005)
            }
            var pixelBuffer: CVPixelBuffer?
            CVPixelBufferCreate(
                kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA,
                nil, &pixelBuffer
            )
            guard let buffer = pixelBuffer else { continue }
            CVPixelBufferLockBaseAddress(buffer, [])
            if let context = CGContext(
                data: CVPixelBufferGetBaseAddress(buffer),
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
                    | CGBitmapInfo.byteOrder32Little.rawValue
            ), let cgImage = card.cgImage {
                context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            }
            CVPixelBufferUnlockBaseAddress(buffer, [])
            adaptor.append(buffer, withPresentationTime: CMTime(value: Int64(frame) * step, timescale: timescale))
        }

        input.markAsFinished()
        let semaphore = DispatchSemaphore(value: 0)
        writer.finishWriting { semaphore.signal() }
        semaphore.wait()
        guard writer.status == .completed else {
            throw TranslateError.bad("Encodage de la carte raté.")
        }
        return url
    }
}