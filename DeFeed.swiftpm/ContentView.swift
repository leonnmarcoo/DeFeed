import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack {
            switch appState.phase {
            case .onboarding:
                OnboardingView()
                    .transition(.opacity)

            case .feed:
                // TODO: FeedView — Act 1
                Color.red.opacity(0.3)
                    .overlay(Text("Feed — Coming Soon"))
                    .transition(.opacity)

            case .input:
                // TODO: InputView — Act 2 Screen 1
                Color.blue.opacity(0.3)
                    .overlay(Text("Input — Coming Soon"))
                    .transition(.opacity)

            case .statistics:
                // TODO: StatisticsView — Act 2 Screen 2
                Color.purple.opacity(0.3)
                    .overlay(Text("Statistics — Coming Soon"))
                    .transition(.opacity)

            case .defeat:
                // TODO: DefeatView — Act 2 Screen 3
                Color.green.opacity(0.3)
                    .overlay(Text("Defeat — Coming Soon"))
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: appState.phase)
    }
}
