import SwiftUI

/// Act 2 — Screen 2: Statistics Comic Panels.
///
/// 5 comic-style panels arranged in a grid showing the real cost of screen time.
/// Calculations based on `appState.dailyHours`.
///
/// Layout:
/// ┌──────────┬─────────┐
/// │  Week    │  Month  │
/// │  (blue)  │ (yellow)│
/// ├──────────┴─────────┤
/// │    Container       │
/// │    (green + Pose3) │
/// ├──────────┬─────────┤
/// │  Year    │Lifetime │
/// │  (red)   │ (blue)  │
/// └──────────┴─────────┘
struct StatisticsView: View {
    @EnvironmentObject private var appState: AppState

    @State private var panelsRevealed: Int = 0
    @State private var showContinue: Bool = false
    @State private var titlePulse: Bool = false

    // MARK: - Computed Statistics

    private var dailyHours: Double { appState.dailyHours }

    /// Hours per week
    private var weeklyHours: Int {
        Int(dailyHours * 7)
    }

    /// Days lost per month (hours / 24)
    private var monthlyDays: Double {
        (dailyHours * 30) / 24
    }

    /// Weeks lost per year
    private var yearlyWeeks: Double {
        (dailyHours * 365) / (24 * 7)
    }

    /// Years lost in a lifetime (~60 years of scrolling)
    private var lifetimeYears: Double {
        (dailyHours * 365 * 60) / (24 * 365)
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let pad: CGFloat = w * 0.03
            let panelW = (w - pad * 3) / 2

            ZStack {
                // Dark background behind the panels
                Color.black
                    .ignoresSafeArea()

                VStack(spacing: pad) {
                    // MARK: Top row: Week | Month
                    HStack(spacing: pad) {
                        // WEEK panel (blue, left, taller)
                        weekPanel(width: panelW, height: h * 0.30, screenWidth: w)
                            .opacity(panelsRevealed >= 1 ? 1 : 0)
                            .scaleEffect(panelsRevealed >= 1 ? 1 : 0.9)

                        // MONTH panel (yellow, right, shorter)
                        monthPanel(width: panelW, height: h * 0.30, screenWidth: w)
                            .opacity(panelsRevealed >= 2 ? 1 : 0)
                            .scaleEffect(panelsRevealed >= 2 ? 1 : 0.9)
                    }

                    // MARK: Middle: Container (green, full width)
                    containerPanel(width: w - pad * 2, height: h * 0.26, screenWidth: w)
                        .opacity(panelsRevealed >= 3 ? 1 : 0)
                        .scaleEffect(panelsRevealed >= 3 ? 1 : 0.9)

                    // MARK: Bottom row: Year | Lifetime
                    HStack(spacing: pad) {
                        // YEAR panel (red, left)
                        yearPanel(width: panelW, height: h * 0.28, screenWidth: w)
                            .opacity(panelsRevealed >= 4 ? 1 : 0)
                            .scaleEffect(panelsRevealed >= 4 ? 1 : 0.9)

                        // LIFETIME panel (blue, right)
                        lifetimePanel(width: panelW, height: h * 0.28, screenWidth: w)
                            .opacity(panelsRevealed >= 5 ? 1 : 0)
                            .scaleEffect(panelsRevealed >= 5 ? 1 : 0.9)
                    }
                }
                .padding(.horizontal, pad)
                .padding(.top, h * 0.02)

                // MARK: - "Tap to Continue" (after all panels shown)
                if showContinue {
                    VStack {
                        Spacer()
                        Text("Tap to Continue")
                            .font(.custom("ComicNeue-Bold", size: titleFontSize(width: w)))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.8), radius: 4, x: 2, y: 2)
                            .opacity(titlePulse ? 0.6 : 1.0)
                            .padding(.bottom, h * 0.03)
                    }
                }
            }
            .onTapGesture {
                handleTap()
            }
        }
        .ignoresSafeArea()
        .statusBarHidden(true)
        .onAppear {
            revealPanelsSequentially()
        }
    }

    // MARK: - Panel Builders

    @ViewBuilder
    private func weekPanel(width: CGFloat, height: CGFloat, screenWidth: CGFloat) -> some View {
        panelBase(imageName: "Stats Panel Blue", width: width, height: height) {
            VStack(spacing: 4) {
                Text("Every week, you feed me")
                    .font(.custom("ComicNeue-Regular", size: panelBodyFont(width: screenWidth)))
                    .foregroundColor(.white)
                Text("\(weeklyHours)")
                    .font(.custom("ComicNeue-Bold", size: panelBigFont(width: screenWidth)))
                    .foregroundColor(.white)
                Text("hours")
                    .font(.custom("ComicNeue-Regular", size: panelBodyFont(width: screenWidth)))
                    .foregroundColor(.white)
            }
            .multilineTextAlignment(.center)
            .shadow(color: .black.opacity(0.5), radius: 3, x: 1, y: 1)
        }
    }

    @ViewBuilder
    private func monthPanel(width: CGFloat, height: CGFloat, screenWidth: CGFloat) -> some View {
        panelBase(imageName: "Stats Panel Yellow", width: width, height: height) {
            VStack(spacing: 4) {
                Text("Each month, that becomes")
                    .font(.custom("ComicNeue-Regular", size: panelBodyFont(width: screenWidth)))
                    .foregroundColor(.white)
                Text(String(format: "%.1f", monthlyDays))
                    .font(.custom("ComicNeue-Bold", size: panelBigFont(width: screenWidth)))
                    .foregroundColor(.white)
                Text("days erased")
                    .font(.custom("ComicNeue-Regular", size: panelBodyFont(width: screenWidth)))
                    .foregroundColor(.white)
            }
            .multilineTextAlignment(.center)
            .shadow(color: .black.opacity(0.5), radius: 3, x: 1, y: 1)
        }
    }

    @ViewBuilder
    private func containerPanel(width: CGFloat, height: CGFloat, screenWidth: CGFloat) -> some View {
        panelBase(imageName: "Stats Panel Green", width: width, height: height) {
            HStack(spacing: 0) {
                // Pose 3 (left)
                Image("Dr Doomscroll Pose 3")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width * 0.40, height: height * 0.85)

                // Text (right)
                VStack(spacing: 8) {
                    Text("No rewind.")
                        .font(.custom("ComicNeue-Bold", size: panelBigFont(width: screenWidth)))
                    Text("No refund.")
                        .font(.custom("ComicNeue-Bold", size: panelBigFont(width: screenWidth)))
                    Text("Just gone.")
                        .font(.custom("ComicNeue-Bold", size: panelBigFont(width: screenWidth)))
                }
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 3, x: 1, y: 1)
                .frame(maxWidth: .infinity)
            }
        }
    }

    @ViewBuilder
    private func yearPanel(width: CGFloat, height: CGFloat, screenWidth: CGFloat) -> some View {
        panelBase(imageName: "Stats Panel Red", width: width, height: height) {
            VStack(spacing: 4) {
                Text("Per year...")
                    .font(.custom("ComicNeue-Regular", size: panelBodyFont(width: screenWidth)))
                    .foregroundColor(.white)
                Text(String(format: "%.1f", yearlyWeeks))
                    .font(.custom("ComicNeue-Bold", size: panelBigFont(width: screenWidth)))
                    .foregroundColor(.white)
                Text("weeks")
                    .font(.custom("ComicNeue-Regular", size: panelBodyFont(width: screenWidth)))
                    .foregroundColor(.white)
                Text("vanish into the void")
                    .font(.custom("ComicNeue-Regular", size: panelBodyFont(width: screenWidth)))
                    .foregroundColor(.white)
            }
            .multilineTextAlignment(.center)
            .shadow(color: .black.opacity(0.5), radius: 3, x: 1, y: 1)
        }
    }

    @ViewBuilder
    private func lifetimePanel(width: CGFloat, height: CGFloat, screenWidth: CGFloat) -> some View {
        panelBase(imageName: "Stats Panel Blue", width: width, height: height) {
            VStack(spacing: 4) {
                Text("Across a lifetime, that's")
                    .font(.custom("ComicNeue-Regular", size: panelBodyFont(width: screenWidth)))
                    .foregroundColor(.white)
                Text(String(format: "%.1f", lifetimeYears))
                    .font(.custom("ComicNeue-Bold", size: panelBigFont(width: screenWidth)))
                    .foregroundColor(.white)
                Text("years")
                    .font(.custom("ComicNeue-Regular", size: panelBodyFont(width: screenWidth)))
                    .foregroundColor(.white)
                Text("you won't get back")
                    .font(.custom("ComicNeue-Regular", size: panelBodyFont(width: screenWidth)))
                    .foregroundColor(.white)
            }
            .multilineTextAlignment(.center)
            .shadow(color: .black.opacity(0.5), radius: 3, x: 1, y: 1)
        }
    }

    /// Reusable panel template: background image + rounded corners + content overlay
    @ViewBuilder
    private func panelBase<Content: View>(
        imageName: String,
        width: CGFloat,
        height: CGFloat,
        @ViewBuilder content: () -> Content
    ) -> some View {
        ZStack {
            Image(imageName)
                .resizable()
                .frame(width: width, height: height)

            content()
                .padding(12)
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black, lineWidth: 3)
        )
    }

    // MARK: - Animation: Sequential Reveal

    private func revealPanelsSequentially() {
        let delayPerPanel: Double = 0.5

        for i in 1...5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * delayPerPanel) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    panelsRevealed = i
                }

                // After the last panel, show "Tap to Continue"
                if i == 5 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        withAnimation(.easeIn(duration: 0.4)) {
                            showContinue = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                                titlePulse = true
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Tap Handler

    private func handleTap() {
        guard showContinue else { return }
        withAnimation(.easeInOut(duration: 0.5)) {
            appState.phase = .defeat
        }
    }

    // MARK: - Font Sizing

    private func titleFontSize(width: CGFloat) -> CGFloat {
        let s = width / 834
        return max(24, 36 * s)
    }

    private func panelBodyFont(width: CGFloat) -> CGFloat {
        let s = width / 834
        return max(12, 18 * s)
    }

    private func panelBigFont(width: CGFloat) -> CGFloat {
        let s = width / 834
        return max(28, 48 * s)
    }
}
