import SwiftUI

struct LanguagePickerView: View {
    let current: String
    let onPick: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(LanguageKit.all, id: \.code) { item in
                Button {
                    onPick(item.code)
                    dismiss()
                } label: {
                    HStack {
                        Text(item.name)
                            .foregroundStyle(.primary)
                        Spacer()
                        if item.code == current {
                            Image(systemName: "checkmark")
                                .foregroundStyle(JyroTheme.accent)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Langue de sortie")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.dark)
    }
}