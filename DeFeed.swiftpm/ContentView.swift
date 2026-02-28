import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    private let audioManager = AudioManager.shared

    @State private var displayedPhase: AppPhase = .onboarding
    @State private var wipeProgress: CGFloat = 0
    @State private var isWiping: Bool = false

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                phaseView(for: displayedPhase)

                inkWipeOverlay(w: w, h: h)
            }
            .frame(width: w, height: h)
        }
        .ignoresSafeArea()
        .onChange(of: appState.phase) { newPhase in
            performInkWipe(to: newPhase)
        }
        .onAppear {
            displayedPhase = appState.phase
            audioManager.playMusic(for: appState.phase)
        }
    }

    // MARK: - Phase View

    @ViewBuilder
    private func phaseView(for phase: AppPhase) -> some View {
        switch phase {
        case .onboarding: OnboardingView()
        case .feed:       FeedView()
        case .input:      InputView()
        case .statistics:  StatisticsView()
        }
    }

    // MARK: - Ink Wipe Overlay

    @ViewBuilder
    private func inkWipeOverlay(w: CGFloat, h: CGFloat) -> some View {
        let xOffset: CGFloat = {
            if wipeProgress <= 0.5 {
                return -w + (wipeProgress / 0.5) * w
            } else {
                return ((wipeProgress - 0.5) / 0.5) * w
            }
        }()

        Rectangle()
            .fill(Color.black)
            .frame(width: w + 40, height: h + 40)
            .offset(x: xOffset)
            .opacity(isWiping ? 1 : 0)
            .allowsHitTesting(false)
    }

    // MARK: - Ink Wipe Transition

    private func performInkWipe(to newPhase: AppPhase) {
        guard !isWiping else { return }
        isWiping = true

        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()

        wipeProgress = 0
        withAnimation(.easeIn(duration: 0.28)) {
            wipeProgress = 0.5
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            displayedPhase = newPhase
            audioManager.playMusic(for: newPhase)

            withAnimation(.easeOut(duration: 0.28)) {
                wipeProgress = 1.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
                isWiping = false
                wipeProgress = 0
            }
        }
    }
}
