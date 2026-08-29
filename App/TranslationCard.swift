import SwiftUI
import UIKit

/// Dessine la carte de traduction qui sera flottée au-dessus des apps.
enum TranslationCard {
    static func render(source: String, result: String, targetName: String, detected: String?) -> UIImage {
        let width: CGFloat = 560
        let height: CGFloat = 320
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: bounds.size, format: format)
        return renderer.image { _ in
            let card = UIBezierPath(roundedRect: bounds, cornerRadius: 44)
            UIColor(red: 0.055, green: 0.055, blue: 0.10, alpha: 1).setFill()
            card.fill()
            UIColor(red: 0.55, green: 0.45, blue: 1.0, alpha: 1).setStroke()
            card.lineWidth = 4
            card.stroke()

            let accent = UIColor(red: 0.62, green: 0.52, blue: 1.0, alpha: 1)
            ("Jyro" as NSString).draw(at: CGPoint(x: 34, y: 30), withAttributes: [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: accent
            ])

            let header = detected != nil ? "\(detected!) → \(targetName)" : "→ \(targetName)"
            (header as NSString).draw(at: CGPoint(x: 150, y: 36), withAttributes: [
                .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
                .foregroundColor: UIColor.white.withAlphaComponent(0.55)
            ])

            let resultParagraph = NSMutableParagraphStyle()
            resultParagraph.lineSpacing = 4
            (result as NSString).draw(
                in: CGRect(x: 34, y: 76, width: width - 68, height: 148),
                withAttributes: [
                    .font: UIFont.systemFont(ofSize: 33, weight: .bold),
                    .foregroundColor: UIColor.white,
                    .paragraphStyle: resultParagraph
                ]
            )

            let sourceParagraph = NSMutableParagraphStyle()
            sourceParagraph.lineBreakMode = .byTruncatingTail
            ("« " + source + " »" as NSString).draw(
                in: CGRect(x: 34, y: 234, width: width - 68, height: 56),
                withAttributes: [
                    .font: UIFont.systemFont(ofSize: 15),
                    .foregroundColor: UIColor.white.withAlphaComponent(0.5),
                    .paragraphStyle: sourceParagraph
                ]
            )
        }
    }
}