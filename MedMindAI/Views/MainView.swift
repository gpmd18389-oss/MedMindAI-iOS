import SwiftUI

struct MainView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var apiService = ClaudeAPIService.shared

    var body: some View {
        let colors = themeManager.colors

        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // ── App Logo ──
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [colors.primary, colors.secondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 72, height: 72)
                        .overlay(Text("⚡").font(.system(size: 32)))

                    Text("MedMindAI")
                        .font(.title2.bold())
                        .foregroundColor(colors.textPrimary)

                    Text("临床医学智能辅助 · AI 驱动")
                        .font(.caption)
                        .foregroundColor(colors.textSecondary)

                    // ── 主题切换 ──
                    HStack(spacing: 12) {
                        ForEach(AppThemeType.allCases, id: \.self) { theme in
                            Button {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    themeManager.selectedTheme = theme
                                }
                            } label: {
                                Text(theme.rawValue)
                                    .font(.system(size: 13, weight: .medium))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(themeManager.selectedTheme == theme
                                                  ? colors.primary.opacity(0.2)
                                                  : colors.surface)
                                    )
                                    .foregroundColor(themeManager.selectedTheme == theme
                                                     ? colors.primary : colors.textSecondary)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(themeManager.selectedTheme == theme
                                                    ? colors.primary.opacity(0.5) : colors.border,
                                                    lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.bottom, 4)

                    // ── 系统状态 ──
                    StatusCard(colors: colors, apiConfigured: apiService.isConfigured)

                    // ── 操作卡片 ──
                    NavigationLink {
                        CaptureView()
                    } label: {
                        ActionCardView(
                            emoji: "📷",
                            title: "拍照识题",
                            subtitle: "相机拍照 → OCR → AI 分析",
                            tintColor: colors.primary
                        )
                    }

                    NavigationLink {
                        WrongBookView()
                    } label: {
                        ActionCardView(
                            emoji: "📖",
                            title: "打开错题本",
                            subtitle: "查看已保存的错题记录",
                            tintColor: colors.secondary
                        )
                    }

                    NavigationLink {
                        SettingsView()
                    } label: {
                        ActionCardView(
                            emoji: "⚙️",
                            title: "设置",
                            subtitle: "配置 API Key、主题切换",
                            tintColor: colors.textSecondary
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(colors.background.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Status Card
struct StatusCard: View {
    let colors: ThemeColors
    let apiConfigured: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("系统状态")
                .font(.caption.bold())
                .foregroundColor(colors.textSecondary)

            StatusRow(granted: true, label: "相机权限", colors: colors)
            StatusRow(granted: apiConfigured, label: "API 已配置", colors: colors)
            StatusRow(granted: true, label: "OCR 引擎", colors: colors)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colors.surface)
        )
    }
}

struct StatusRow: View {
    let granted: Bool
    let label: String
    let colors: ThemeColors

    var body: some View {
        HStack {
            Circle()
                .fill(granted ? colors.success : colors.error)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.subheadline)
                .foregroundColor(colors.textPrimary)
            Spacer()
            Text(granted ? "就绪" : "未配置")
                .font(.caption2.bold())
                .foregroundColor(granted ? colors.success : colors.error)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(granted ? colors.success.opacity(0.1) : colors.error.opacity(0.1))
        )
    }
}

// MARK: - Action Card
struct ActionCardView: View {
    let emoji: String
    let title: String
    let subtitle: String
    let tintColor: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(tintColor.opacity(0.12))
                    .frame(width: 44, height: 44)
                Text(emoji)
                    .font(.system(size: 20))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("›")
                .font(.title3)
                .foregroundColor(.secondary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
        )
    }
}
