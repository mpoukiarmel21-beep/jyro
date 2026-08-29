import UIKit
import SwiftUI
import UniformTypeIdentifiers

final class TranslateViewController: UIViewController {
    private let model = TranslatorSheetModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        let controller = UIHostingController(
            rootView: TranslatorSheetView(
                model: model,
                onDone: { [weak self] in self?.finish() },
                onOpen: { [weak self] in self?.openJyro() }
            )
        )
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.view.backgroundColor = .clear
        addChild(controller)
        view.addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: view.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        controller.didMove(toParent: self)

        preferredContentSize = CGSize(width: 420, height: 640)

        loadSourceText()
    }

    private func loadSourceText() {
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem else { return }
        guard let provider = item.attachments?.first else { return }

        let textType = UTType.plainText.identifier
        let urlType = UTType.url.identifier
        let selectedType: String
        if provider.hasItemConformingToTypeIdentifier(textType) {
            selectedType = textType
        } else if provider.hasItemConformingToTypeIdentifier(urlType) {
            selectedType = urlType
        } else {
            return
        }

        provider.loadItem(forTypeIdentifier: selectedType, options: nil) { [weak self] value, _ in
            Task { @MainActor in
                guard let self else { return }
                var text: String?
                if let string = value as? String {
                    text = string
                } else if let url = value as? URL {
                    text = url.absoluteString
                } else if let data = value as? Data {
                    text = String(data: data, encoding: .utf8)
                }
                self.model.sourceText = text ?? ""
                if let text, !text.isEmpty {
                    self.model.translate()
                }
            }
        }
    }

    private func finish() {
        extensionContext?.completeRequest(returningItems: nil) { _ in }
    }

    private func openJyro() {
        let allowed = CharacterSet.urlQueryAllowed
        let query = model.sourceText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .addingPercentEncoding(withAllowedCharacters: allowed) ?? ""
        guard let url = URL(string: "jyro://translate?q=\(query)") else { return }
        extensionContext?.open(url) { _ in }
    }
}