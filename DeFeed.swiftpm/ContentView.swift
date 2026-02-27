import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    private let audioManager = AudioManager.shared

    var body: some View {
        ZStack {
            switch appState.phase {
            case .onboarding:
                OnboardingView()
                    .transition(.opacity)

            case .feed:
                FeedView()
                    .transition(.opacity)

            case .input:
                InputView()
                    .transition(.opacity)

            case .statistics:
                StatisticsView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: appState.phase)
        .onChange(of: appState.phase) { newPhase in
            audioManager.playMusic(for: newPhase)
        }
        .onAppear {
            audioManager.playMusic(for: appState.phase)
        }
    }
}
