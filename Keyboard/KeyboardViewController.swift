import UIKit

final class KeyboardViewController: UIInputViewController {

    private let translator = Translator.shared
    private let defaults = UserDefaults.standard

    private var myCode = "fr"
    private var targetCode = "en"
    private var followsCopy = true
    private var autoInsert = false
    private var modeNumbers = false
    private var shiftOn = true

    private var box: UITextView!
    private var targetChip: UIButton!
    private var autoSwitch: UIButton!
    private var statusLabel: UILabel!
    private var modeButton: UIButton!
    private var shiftButton: UIButton!
    private var keysStack: UIStackView!
    private var busy = false

    private let lettersRows: [[String]] = [
        ["A", "Z", "E", "R", "T", "Y", "U", "I", "O", "P"],
        ["Q", "S", "D", "F", "G", "H", "J", "K", "L", "M"],
        ["W", "X", "C", "V", "B", "N"]
    ]
    private let numbersRows: [[String]] = [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
        ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""],
        [".", ",", "?", "!", "'"]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        loadPreferences()
        buildUI()
        if let copied = UIPasteboard.general.string, followsCopy {
            useCopied(copied, announce: false)
        } else {
            refreshChip()
        }
    }

    // MARK: - Preferences

    private func loadPreferences() {
        if let saved = defaults.string(forKey: "jyro.keyboard.target"), !saved.isEmpty {
            targetCode = saved
            followsCopy = false
        }
        autoInsert = defaults.bool(forKey: "jyro.keyboard.autoInsert")
    }

    private func savePreferences() {
        defaults.set(targetCode, forKey: "jyro.keyboard.target")
        defaults.set(autoInsert, forKey: "jyro.keyboard.autoInsert")
    }

    // MARK: - Build UI

    private func buildUI() {
        view.backgroundColor = UIColor(red: 0.09, green: 0.09, blue: 0.12, alpha: 1)

        let bar = UIStackView()
        bar.axis = .vertical
        bar.spacing = 8
        bar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bar)
        NSLayoutConstraint.activate([
            bar.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        ])

        bar.addArrangedSubview(makeTopRow())
        bar.addArrangedSubview(makeBoxRow())
        bar.addArrangedSubview(makeActionRow())

        keysStack = UIStackView()
        keysStack.axis = .vertical
        keysStack.spacing = 6
        keysStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(keysStack)
        NSLayoutConstraint.activate([
            keysStack.topAnchor.constraint(equalTo: bar.bottomAnchor, constant: 8),
            keysStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            keysStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            keysStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -6)
        ])

        rebuildRows()
        refreshChip()
        updateAutoSwitch()
    }

    private func makeTopRow() -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 8
        row.distribution = .fill

        let brand = UIButton(type: .system)
        brand.setTitle("Jyro", for: .normal)
        brand.titleLabel?.font = .boldSystemFont(ofSize: 13)
        brand.tintColor = UIColor(red: 0.55, green: 0.45, blue: 1, alpha: 1)
        brand.setContentHuggingPriority(.required, for: .horizontal)

        targetChip = UIButton(type: .system)
        targetChip.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        targetChip.layer.cornerRadius = 14
        targetChip.clipsToBounds = true
        targetChip.addTarget(self, action: #selector(targetTapped(_:)), for: .touchUpInside)

        autoSwitch = UIButton(type: .system)
        autoSwitch.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        autoSwitch.layer.cornerRadius = 14
        autoSwitch.clipsToBounds = true
        autoSwitch.addTarget(self, action: #selector(autoTapped(_:)), for: .touchUpInside)
        autoSwitch.setContentHuggingPriority(.required, for: .horizontal)

        statusLabel = UILabel()
        statusLabel.font = .systemFont(ofSize: 11)
        statusLabel.textColor = .secondaryLabel
        statusLabel.numberOfLines = 1
        statusLabel.lineBreakMode = .byTruncatingTail
        statusLabel.text = "Copie un message puis appuie sur 📋"

        row.addArrangedSubview(brand)
        row.addArrangedSubview(targetChip)
        row.addArrangedSubview(autoSwitch)
        row.addArrangedSubview(statusLabel)
        return row
    }

    private func makeBoxRow() -> UIView {
        let container = UIView()
        container.layer.cornerRadius = 12
        container.backgroundColor = UIColor(red: 0.14, green: 0.14, blue: 0.19, alpha: 1)
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([container.heightAnchor.constraint(equalToConstant: 64)])

        box = UITextView()
        box.backgroundColor = .clear
        box.font = .systemFont(ofSize: 15)
        box.textColor = .label
        box.isScrollEnabled = true
        box.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(box)
        NSLayoutConstraint.activate([
            box.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            box.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),
            box.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            box.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10)
        ])
        return container
    }

    private func makeActionRow() -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 8
        row.distribution = .fillEqually

        let paste = actionButton(title: "📋 Copié", color: UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1)) {
            guard let copied = UIPasteboard.general.string else {
                self.status("Active « Accès complet » (Réglages → Claviers → Jyro)")
                return
            }
            self.useCopied(copied, announce: true)
        }

        let listen = actionButton(title: "🔊 Lire", color: UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1)) {
            self.readCopy()
        }

        let reply = actionButton(title: "▶ Répondre", color: UIColor(red: 0.45, green: 0.35, blue: 0.95, alpha: 1)) {
            self.replyWrite()
        }

        row.addArrangedSubview(paste)
        row.addArrangedSubview(listen)
        row.addArrangedSubview(reply)
        return row
    }

    private func actionButton(title: String, color: UIColor, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = color
        button.layer.cornerRadius = 14
        button.clipsToBounds = true
        button.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            action()
        }, for: .touchUpInside)
        return button
    }

    // MARK: - Keys

    private func rebuildRows() {
        for arranged in keysStack.arrangedSubviews {
            keysStack.removeArrangedSubview(arranged)
            arranged.removeFromSuperview()
        }

        let rows = modeNumbers ? numbersRows : lettersRows
        for (index, keys) in rows.enumerated() {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 6
            row.distribution = index == 2 ? .fillProportionally : .fillEqually

            if !modeNumbers && index == 2 {
                shiftButton = specialKey("⇧", target: #selector(shiftTapped(_:)), width: 52)
                row.addArrangedSubview(shiftButton)
            }
            for key in keys {
                row.addArrangedSubview(letterKey(key))
            }
            if !modeNumbers && index == 2 {
                row.addArrangedSubview(specialKey("⌫", target: #selector(backTapped(_:)), width: 52))
            }
            if modeNumbers && index == 2 {
                row.addArrangedSubview(specialKey("⌫", target: #selector(backTapped(_:)), width: 52))
            }
            keysStack.addArrangedSubview(row)
        }

        let bottom = UIStackView()
        bottom.axis = .horizontal
        bottom.spacing = 6
        bottom.distribution = .fill

        modeButton = specialKey("123", target: #selector(modeTapped(_:)))
        modeButton.translatesAutoresizingMaskIntoConstraints = false
        let space = specialKey("espace", target: #selector(spaceTapped(_:)))
        space.translatesAutoresizingMaskIntoConstraints = false
        let ret = specialKey("⏎", target: #selector(returnTapped(_:)))
        ret.translatesAutoresizingMaskIntoConstraints = false

        bottom.addArrangedSubview(modeButton)
        bottom.addArrangedSubview(space)
        bottom.addArrangedSubview(ret)
        keysStack.addArrangedSubview(bottom)

        NSLayoutConstraint.activate([
            modeButton.widthAnchor.constraint(equalToConstant: 52),
            ret.widthAnchor.constraint(equalToConstant: 72)
        ])
        modeButton.setTitle(modeNumbers ? "ABC" : "123", for: .normal)
        updateShiftLook()
    }

    private func letterKey(_ title: String) -> UIButton {
        let button = keyButton(title)
        button.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.insert(self.shiftOn ? title : title.lowercased())
            if self.shiftOn { self.shiftOn = false; self.updateShiftLook() }
        }, for: .touchUpInside)
        return button
    }

    private func specialKey(_ title: String, target: Selector, width: CGFloat? = nil) -> UIButton {
        let button = keyButton(title)
        button.addTarget(self, action: target, for: .touchUpInside)
        if let width {
            button.translatesAutoresizingMaskIntoConstraints = false
            button.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        return button
    }

    private func keyButton(_ title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.16, green: 0.16, blue: 0.22, alpha: 1)
        button.layer.cornerRadius = 7
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return button
    }

    // MARK: - Key actions

    @objc private func insert(_ char: String) {
        if modeNumbers { modeTapped(modeButton) }
        textDocumentProxy.insertText(char)
    }

    @objc private func spaceTapped(_ sender: Any) { textDocumentProxy.insertText(" ") }
    @objc private func backTapped(_ sender: Any) { textDocumentProxy.deleteBackward() }
    @objc private func returnTapped(_ sender: Any) { textDocumentProxy.insertText("\n") }

    @objc private func shiftTapped(_ sender: Any) {
        shiftOn.toggle()
        updateShiftLook()
    }

    @objc private func modeTapped(_ sender: Any) {
        modeNumbers.toggle()
        rebuildRows()
    } 

    private func updateShiftLook() {
        shiftButton?.backgroundColor = shiftOn
            ? UIColor(red: 0.35, green: 0.3, blue: 0.8, alpha: 1)
            : UIColor(red: 0.16, green: 0.16, blue: 0.22, alpha: 1)
    }

    // MARK: - Chip & auto

    @objc private func targetTapped(_ sender: UIButton) {
        let options: [String] = ["auto", "fr", "en", "es", "de", "it", "pt", "ar", "ja", "ru"]
        let menu = UIMenu(children: options.map { code in
            let name = code == "auto" ? "Auto (suivre la copie)" : LanguageKit.name(for: code)
            return UIAction(title: name, state: (!followsCopy && targetCode == code) || (followsCopy && code == "auto") ? .on : .off) { _ in
                if code == "auto" {
                    self.followsCopy = true
                    if let copied = UIPasteboard.general.string { self.useCopied(copied, announce: false) }
                } else {
                    self.followsCopy = false
                    self.targetCode = code
                    self.savePreferences()
                }
                self.refreshChip()
            }
        })
        sender.menu = menu
        sender.showsMenuAsPrimaryAction = true
    }

    @objc private func autoTapped(_ sender: Any) {
        autoInsert.toggle()
        updateAutoSwitch()
        savePreferences()
        status(autoInsert ? "Auto-écriture ON : la réponse s'écrit direct dans le champ" : "Auto OFF : la réponse sera copiée")
    }

    private func updateAutoSwitch() {
        autoSwitch.setTitle(autoInsert ? "✍️ Auto ON" : "✍️ Auto OFF", for: .normal)
        autoSwitch.backgroundColor = autoInsert
            ? UIColor(red: 0.35, green: 0.3, blue: 0.8, alpha: 1)
            : UIColor(red: 0.16, green: 0.16, blue: 0.22, alpha: 1)
    }

    private func refreshChip() {
        let name = followsCopy ? "Auto · \(LanguageKit.name(for: targetCode))" : LanguageKit.name(for: targetCode)
        targetChip.setTitle("🌐 \(name)", for: .normal)
        targetChip.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1)
    }

    // MARK: - Translation actions

    private func useCopied(_ text: String, announce: Bool) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        box.text = trimmed
        if followsCopy {
            let detected = LanguageKit.guess(trimmed)
            targetCode = detected
            refreshChip()
        }
        if announce {
            let lang = LanguageKit.name(for: LanguageKit.guess(trimmed))
            status("Copie détectée : \(lang). Écris ta réponse puis ▶ Répondre")
        }
    }

    private func readCopy() {
        let raw = box.text ?? ""
        let q = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { status("La zone est vide. Tape 📋 ou écris du texte."); return }
        setBusy(true)
        Task {
            do {
                let out = try await translator.translate(q, to: myCode)
                UIPasteboard.general.string = out.text
                box.text = out.text
                self.status("Lu dans ta langue (\(LanguageKit.name(for: self.myCode))) · copié ✔")
            } catch {
                self.status(self.reason(error))
            }
            self.setBusy(false)
        }
    }

    private func replyWrite() {
        let raw = box.text ?? ""
        let q = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { status("Écris ta réponse ci-dessus, puis ▶ Répondre"); return }
        setBusy(true)
        Task {
            do {
                let out = try await translator.translate(q, to: targetCode)
                if autoInsert {
                    textDocumentProxy.insertText(out.text)
                    box.text = ""
                    status("Écrit dans le champ en \(LanguageKit.name(for: targetCode)) ✔")
                } else {
                    UIPasteboard.general.string = out.text
                    status("Copié ✔ — colle-le dans la conversation")
                }
            } catch {
                self.status(self.reason(error))
            }
            self.setBusy(false)
        }
    }

    private func reason(_ error: Error) -> String {
        if let localized = error as? LocalizedError, let message = localized.errorDescription {
            return message
        }
        return "Erreur réseau. Clavier : active « Accès complet » (Réglages → Claviers → Jyro)"
    }

    private func status(_ text: String) {
        statusLabel.text = text
    }

    private func setBusy(_ value: Bool) {
        busy = value
        statusLabel.alpha = value ? 0.5 : 1
    }
}