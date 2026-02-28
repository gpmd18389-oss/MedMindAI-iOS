import SwiftUI

struct SplashView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var outerRotation: Double = 0
    @State private var innerRotation: Double = 360
    @State private var pulseScale: CGFloat = 0.6
    @State private var textOpacity: Double = 0

    var body: some View {
        let colors = themeManager.colors

        ZStack {
            colors.background.ignoresSafeArea()

            // 动画圆环
            ZStack {
                // 外圈
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [colors.primary, colors.secondary, colors.primary.opacity(0.2)],
                            center: .center
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(outerRotation))

                // 内圈
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [colors.secondary, colors.tertiary, colors.secondary.opacity(0.2)],
                            center: .center
                        ),
                        lineWidth: 2.5
                    )
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(innerRotation))

                // 脉冲光环
                Circle()
                    .stroke(colors.primary.opacity(0.3), lineWidth: 2)
                    .frame(width: 200 * pulseScale, height: 200 * pulseScale)

                // 中心点
                Circle()
                    .fill(colors.primary)
                    .frame(width: 12, height: 12)
            }
            .offset(y: -60)

            // 文字
            VStack(spacing: 8) {
                Text("MedMind AI")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(colors.primary)
                    .tracking(4)

                Text("CLINICAL INTELLIGENCE SYSTEM")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(colors.secondary.opacity(0.7))
                    .tracking(3)

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, colors.primary.opacity(0.6), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 120, height: 2)
                    .padding(.top, 12)
            }
            .offset(y: 120)
            .opacity(textOpacity)
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                outerRotation = 360
            }
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                innerRotation = 0
            }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulseScale = 1.2
            }
            withAnimation(.easeIn(duration: 0.8).delay(0.6)) {
                textOpacity = 1
            }
        }
    }
}
