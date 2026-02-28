import SwiftUI

struct ResultView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let questionText: String
    let ocrText: String
    let aiRaw: String

    var body: some View {
        let colors = themeManager.colors
        let analysis = AiResponseParser.parseOrNull(aiRaw)

        VStack(spacing: 0) {
            // ── 内容 ──
            ScrollView {
                VStack(spacing: 12) {
                    if let analysis = analysis {
                        // 题目与答案
                        SectionCard(
                            icon: "📋", title: "题目与答案",
                            accentColor: colors.primary, colors: colors
                        ) {
                            let qText = analysis.question.isEmpty ? questionText : analysis.question
                            Text(qText)
                                .font(.system(size: 14))
                                .foregroundColor(colors.textPrimary)
                                .lineSpacing(4)

                            HStack {
                                Text("✅ 正确答案")
                                    .font(.caption.bold())
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(colors.success.opacity(0.15).cornerRadius(6))
                                    .foregroundColor(colors.success)
                            }
                            .padding(.top, 8)

                            Text(analysis.answer)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(colors.success)
                                .lineSpacing(4)

                            // 选项分析
                            if !analysis.optionAnalysis.isEmpty {
                                Text("📊 各选项分析")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(colors.warning)
                                    .padding(.top, 10)

                                ForEach(analysis.optionAnalysis.sorted(by: { $0.key < $1.key }), id: \.key) { letter, explanation in
                                    let isCorrect = letter.uppercased() == analysis.answer.trimmingCharacters(in: .whitespaces).prefix(1).uppercased()
                                    let optColor = isCorrect ? colors.success : colors.error

                                    HStack(alignment: .top, spacing: 10) {
                                        Text(letter.uppercased())
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(optColor)
                                            .frame(width: 28, height: 28)
                                            .background(optColor.opacity(0.2).cornerRadius(6))

                                        Text(explanation)
                                            .font(.system(size: 13))
                                            .foregroundColor(colors.textPrimary)
                                            .lineSpacing(3)
                                    }
                                    .padding(10)
                                    .background(optColor.opacity(isCorrect ? 0.08 : 0.04).cornerRadius(8))
                                }
                            }

                            // 关键点
                            if !analysis.keyPoints.isEmpty {
                                Text("🔑 关键点")
                                    .font(.caption.bold())
                                    .foregroundColor(colors.primary.opacity(0.8))
                                    .padding(.top, 8)
                                Text(analysis.keyPoints)
                                    .font(.system(size: 13))
                                    .foregroundColor(colors.textPrimary)
                                    .lineSpacing(3)
                            }
                        }

                        // 一句话要点
                        if !analysis.oneLiner.isEmpty {
                            SectionCard(
                                icon: "💡", title: "一句话要点",
                                accentColor: colors.secondary, colors: colors
                            ) {
                                Text(analysis.oneLiner)
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(colors.secondary)
                                    .lineSpacing(6)
                            }
                        }

                        // 机制解析
                        if !analysis.steps.isEmpty {
                            SectionCard(
                                icon: "🔬", title: "机制解析",
                                accentColor: colors.primary.opacity(0.7), colors: colors
                            ) {
                                Text(analysis.steps)
                                    .font(.system(size: 14))
                                    .foregroundColor(colors.textPrimary)
                                    .lineSpacing(4)
                            }
                        }

                        // 知识点
                        if !analysis.knowledge.isEmpty {
                            SectionCard(
                                icon: "📚", title: "知识点",
                                accentColor: colors.primary, colors: colors
                            ) {
                                ForEach(analysis.knowledge.split(separator: "\n").map(String.init), id: \.self) { item in
                                    let clean = item.trimmingCharacters(in: .whitespacesAndNewlines)
                                    if !clean.isEmpty {
                                        HStack {
                                            Text("🔍")
                                                .font(.system(size: 13))
                                            Text(clean)
                                                .font(.system(size: 13))
                                                .foregroundColor(colors.primary)
                                        }
                                        .padding(10)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(colors.primary.opacity(0.06).cornerRadius(8))
                                    }
                                }
                            }
                        }

                        // 错因分析
                        if !analysis.userCorrect && !analysis.mistakes.isEmpty {
                            SectionCard(
                                icon: "⚠️", title: "错因分析",
                                accentColor: colors.error, colors: colors
                            ) {
                                Text(analysis.mistakes)
                                    .font(.system(size: 14))
                                    .foregroundColor(colors.textPrimary)
                                    .lineSpacing(4)
                            }
                        }

                        // 类题练习
                        if !analysis.similar.isEmpty {
                            SectionCard(
                                icon: "🎯", title: "类题练习",
                                accentColor: colors.primary.opacity(0.6), colors: colors
                            ) {
                                Text(analysis.similar)
                                    .font(.system(size: 14))
                                    .foregroundColor(colors.textPrimary)
                                    .lineSpacing(4)
                            }
                        }
                    } else {
                        // 原始文本兜底
                        SectionCard(
                            icon: "⚡", title: "AI 解析结果",
                            accentColor: colors.warning, colors: colors
                        ) {
                            Text("⚠️ AI 返回的不是严格 JSON，已用原始文本兜底显示。")
                                .font(.caption)
                                .foregroundColor(colors.warning)
                                .padding(10)
                                .background(colors.warning.opacity(0.08).cornerRadius(8))
                            Text(aiRaw)
                                .font(.system(size: 14))
                                .foregroundColor(colors.textPrimary)
                                .lineSpacing(4)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
            }

            // ── 底栏 ──
            HStack(spacing: 10) {
                Button {
                    saveToWrongBook(analysis: analysis)
                } label: {
                    Text("💾 保存到错题本")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(colors.primary.opacity(0.15))
                        .foregroundColor(colors.primary)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(colors.primary.opacity(0.4), lineWidth: 1)
                        )
                }

                Button {
                    dismiss()
                } label: {
                    Text("关闭")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(colors.surface)
                        .foregroundColor(colors.textSecondary)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(colors.border, lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(colors.surface)
        }
        .background(colors.background.ignoresSafeArea())
        .navigationTitle("⚡ MedMindAI 解析")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func saveToWrongBook(analysis: AiAnalysis?) {
        let title = analysis?.oneLiner.prefix(40).description.isEmpty == false
            ? String(analysis!.oneLiner.prefix(40))
            : (analysis?.answer.prefix(30).description ?? String(questionText.prefix(20)))

        let entry = WrongBookEntry(
            title: title,
            questionText: questionText,
            ocrText: ocrText,
            aiRaw: aiRaw
        )
        modelContext.insert(entry)
    }
}

// MARK: - Section Card
struct SectionCard<Content: View>: View {
    let icon: String
    let title: String
    let accentColor: Color
    let colors: ThemeColors
    @ViewBuilder let content: Content

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // 左侧色条
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [accentColor, accentColor.opacity(0.2)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 8) {
                Text("\(icon) \(title)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(accentColor)

                content
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colors.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(accentColor.opacity(0.15), lineWidth: 1)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
