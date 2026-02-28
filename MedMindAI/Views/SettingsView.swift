import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var apiKey: String = ""
    @State private var baseURL: String = ""
    @State private var showSaved = false

    var body: some View {
        let colors = themeManager.colors

        NavigationStack {
            Form {
                // ── 主题选择 ──
                Section("主题设置") {
                    ForEach(AppThemeType.allCases, id: \.self) { theme in
                        HStack {
                            let themeColors: ThemeColors = theme == .pink ? .pink : .blue
                            Circle()
                                .fill(themeColors.primary)
                                .frame(width: 24, height: 24)
                            Text(theme.rawValue)
                                .foregroundColor(colors.textPrimary)
                            Spacer()
                            if themeManager.selectedTheme == theme {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(colors.primary)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                themeManager.selectedTheme = theme
                            }
                        }
                    }
                }

                // ── API 配置 ──
                Section("Claude API 配置") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("API Key")
                            .font(.caption.bold())
                            .foregroundColor(colors.textSecondary)
                        SecureField("sk-...", text: $apiKey)
                            .textContentType(.password)
                            .font(.system(size: 14, design: .monospaced))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("API Base URL")
                            .font(.caption.bold())
                            .foregroundColor(colors.textSecondary)
                        TextField("https://api.anthropic.com/v1", text: $baseURL)
                            .font(.system(size: 14, design: .monospaced))
                            .autocapitalization(.none)
                            .keyboardType(.URL)
                    }

                    Button {
                        ClaudeAPIService.shared.apiKey = apiKey
                        if !baseURL.isEmpty {
                            ClaudeAPIService.shared.baseURL = baseURL
                        }
                        showSaved = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showSaved = false
                        }
                    } label: {
                        HStack {
                            Image(systemName: showSaved ? "checkmark.circle.fill" : "square.and.arrow.down")
                            Text(showSaved ? "已保存" : "保存配置")
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .background(colors.primary.cornerRadius(10))
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                }

                // ── 模型信息 ──
                Section("模型信息") {
                    HStack {
                        Text("当前模型")
                            .foregroundColor(colors.textSecondary)
                        Spacer()
                        Text("Claude Opus 4.6")
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundColor(colors.primary)
                    }
                    HStack {
                        Text("模型 ID")
                            .foregroundColor(colors.textSecondary)
                        Spacer()
                        Text("claude-opus-4-6")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(colors.textSecondary)
                    }
                }

                // ── 关于 ──
                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(colors.textSecondary)
                    }
                    HStack {
                        Text("平台")
                        Spacer()
                        Text("iOS (SwiftUI)")
                            .foregroundColor(colors.textSecondary)
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                apiKey = ClaudeAPIService.shared.apiKey
                baseURL = ClaudeAPIService.shared.baseURL
            }
        }
    }
}
