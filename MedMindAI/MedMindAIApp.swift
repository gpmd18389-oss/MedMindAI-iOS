import SwiftUI
import SwiftData

@main
struct MedMindAIApp: App {
    @StateObject private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
        }
        .modelContainer(for: WrongBookEntry.self)
    }
}
