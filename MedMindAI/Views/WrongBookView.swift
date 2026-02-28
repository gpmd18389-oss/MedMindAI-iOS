import SwiftUI
import SwiftData

struct WrongBookView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WrongBookEntry.createdAt, order: .reverse) private var entries: [WrongBookEntry]

    var body: some View {
        let colors = themeManager.colors

        NavigationStack {
            Group {
                if entries.isEmpty {
                    VStack(spacing: 12) {
                        Text("📚")
                            .font(.system(size: 48))
                        Text("还没有错题记录")
                            .font(.subheadline)
                            .foregroundColor(colors.textSecondary)
                        Text("在解析结果页点"保存到错题本"即可添加")
                            .font(.caption)
                            .foregroundColor(colors.textSecondary.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(entries) { entry in
                            NavigationLink {
                                ResultView(
                                    questionText: entry.questionText,
                                    ocrText: entry.ocrText,
                                    aiRaw: entry.aiRaw
                                )
                            } label: {
                                WrongBookRowView(entry: entry, colors: colors)
                            }
                        }
                        .onDelete(perform: deleteEntries)
                    }
                    .listStyle(.plain)
                }
            }
            .background(colors.background.ignoresSafeArea())
            .navigationTitle("⚡ 错题本")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !entries.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Text("\(entries.count) 题")
                            .font(.caption.bold())
                            .foregroundColor(colors.primary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(colors.primary.opacity(0.1).cornerRadius(6))
                    }
                }
            }
        }
    }

    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(entries[index])
        }
    }
}

struct WrongBookRowView: View {
    let entry: WrongBookEntry
    let colors: ThemeColors
    @State private var expanded = false
    @State private var notesText: String = ""

    var body: some View {
        let analysis = AiResponseParser.parseOrNull(entry.aiRaw)
        let summary = analysis?.oneLiner.isEmpty == false ? analysis?.oneLiner : analysis?.answer.prefix(50).description

        VStack(alignment: .leading, spacing: 6) {
            Text(entry.title.isEmpty ? "（无标题）" : entry.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(entry.analyzing ? colors.textSecondary : colors.textPrimary)
                .lineLimit(2)

            if entry.analyzing {
                HStack(spacing: 6) {
                    ProgressView()
                        .scaleEffect(0.7)
                    Text("AI 后台分析中…")
                        .font(.system(size: 12))
                        .foregroundColor(colors.primary)
                }
            } else if let summary = summary, !summary.isEmpty {
                Text("🧠 \(summary)")
                    .font(.system(size: 12))
                    .foregroundColor(colors.primary.opacity(0.8))
                    .lineLimit(1)
            }

            Text(entry.createdAt, style: .date)
                .font(.system(size: 11))
                .foregroundColor(colors.textSecondary)

            if !entry.userNotes.isEmpty && !expanded {
                Text("📝 \(entry.userNotes)")
                    .font(.system(size: 12))
                    .foregroundColor(colors.warning.opacity(0.8))
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
        .onAppear { notesText = entry.userNotes }
    }
}
