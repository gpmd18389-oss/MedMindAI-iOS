import SwiftUI

// MARK: - Theme Colors Protocol
struct ThemeColors {
    let background: Color
    let surface: Color
    let card: Color
    let border: Color
    let primary: Color
    let primaryDim: Color
    let secondary: Color
    let accent: Color
    let tertiary: Color
    let textPrimary: Color
    let textSecondary: Color
    let success: Color
    let warning: Color
    let error: Color
}

// MARK: - Pink Theme
extension ThemeColors {
    static let pink = ThemeColors(
        background:    Color(hex: 0xFFF5F7),
        surface:       Color(hex: 0xFFF0F3),
        card:          Color(hex: 0xFFF8FA),
        border:        Color(hex: 0xFFD6E0),
        primary:       Color(hex: 0xFF8FAB),
        primaryDim:    Color(hex: 0xE8879C),
        secondary:     Color(hex: 0xFF69B4),
        accent:        Color(hex: 0xFF1493),
        tertiary:      Color(hex: 0x4CAF50),
        textPrimary:   Color(hex: 0x4A3043),
        textSecondary: Color(hex: 0x9B8A94),
        success:       Color(hex: 0x4CAF50),
        warning:       Color(hex: 0xFFA726),
        error:         Color(hex: 0xE53935)
    )
}

// MARK: - Blue Theme
extension ThemeColors {
    static let blue = ThemeColors(
        background:    Color(hex: 0xF0F4FF),
        surface:       Color(hex: 0xECF0FF),
        card:          Color(hex: 0xF5F8FF),
        border:        Color(hex: 0xBFCFFF),
        primary:       Color(hex: 0x4A90D9),
        primaryDim:    Color(hex: 0x3A7AC4),
        secondary:     Color(hex: 0x2196F3),
        accent:        Color(hex: 0x1565C0),
        tertiary:      Color(hex: 0x4CAF50),
        textPrimary:   Color(hex: 0x1A2744),
        textSecondary: Color(hex: 0x7B8BA8),
        success:       Color(hex: 0x4CAF50),
        warning:       Color(hex: 0xFFA726),
        error:         Color(hex: 0xE53935)
    )
}

// MARK: - Theme Manager
enum AppThemeType: String, CaseIterable {
    case pink = "淡粉主题"
    case blue = "蓝色主题"
}

class ThemeManager: ObservableObject {
    @Published var selectedTheme: AppThemeType {
        didSet {
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: "app_theme")
        }
    }

    var colors: ThemeColors {
        switch selectedTheme {
        case .pink: return .pink
        case .blue: return .blue
        }
    }

    init() {
        let saved = UserDefaults.standard.string(forKey: "app_theme") ?? ""
        self.selectedTheme = AppThemeType(rawValue: saved) ?? .pink
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}
