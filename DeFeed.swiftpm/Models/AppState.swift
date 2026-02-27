import SwiftUI

enum AppPhase {
    case onboarding
    case feed
    case input
    case statistics
}

@MainActor
final class AppState: ObservableObject {
    @Published var phase: AppPhase = .onboarding
    @Published var villainHP: Double = 0
    @Published var dailyHours: Double = 3
}
