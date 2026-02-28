import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingSplash = true

    var body: some View {
        ZStack {
            if showingSplash {
                SplashView()
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showingSplash = false
                            }
                        }
                    }
            } else {
                TabView {
                    MainView()
                        .tabItem {
                            Label("首页", systemImage: "house.fill")
                        }
                    CaptureView()
                        .tabItem {
                            Label("拍照识题", systemImage: "camera.fill")
                        }
                    WrongBookView()
                        .tabItem {
                            Label("错题本", systemImage: "book.fill")
                        }
                    SettingsView()
                        .tabItem {
                            Label("设置", systemImage: "gearshape.fill")
                        }
                }
                .tint(themeManager.colors.primary)
            }
        }
    }
}
