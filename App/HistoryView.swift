import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var model: AppModel

    var body: some View {
        Group {
            if model.histories.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 44, weight: .medium))
                        .foregroundStyle(.tertiary)
                    Text("Aucune traduction enregistrée.")
                        .foregroundStyle(.secondary)
                    Text("Tes traductions apparaîtront ici.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(model.histories) { entry in
                        historyRow(entry)
                            .swipeActions {
                                Button(role: .destructive) {
                                    model.removeHistory(entry)
                                } label: {
                                    Label("Supprimer", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .background(JyroTheme.appBackground.ignoresSafeArea())
        .navigationTitle("Historique")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !model.histories.isEmpty {
                Button {
                    model.clearHistory()
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
    }

    private func historyRow(_ entry: HistoryEntry) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.source)
                .font(.subheadline)
                .lineLimit(2)
            Text(entry.result)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(JyroTheme.accent)
                .lineLimit(2)
            HStack(spacing: 8) {
                Text("\(LanguageKit.name(for: entry.sourceCode)) → \(LanguageKit.name(for: entry.targetCode))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(entry.date, format: .dateTime.day().month().hour().minute())
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Button {
                    UIPasteboard.general.string = entry.result
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundStyle(JyroTheme.accent)
            }
        }
        .padding(.vertical, 4)
    }
}