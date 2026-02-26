import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState

    /// The 4 dialogue lines Dr. Doomscroll delivers.
    private let dialogueLines: [String] = [
        "Welcome. Or should I say, welcome back! They call me Dr. Doomscroll I live in every feed, every notification, every just one more video.",
        "You didn't come here by accident. You never do.",
        "Just a few more minutes, right? That's what you said last time.",
        "Scroll. I'll handle the rest."
    ]

    /// The title text for each dialogue step (last one changes).
    private var titleText: String {
        currentIndex < dialogueLines.count - 1 ? "Tap to Continue" : "Scroll to Continue"
    }

    @State private var currentIndex: Int = 0
    @State private var isTyping: Bool = true
    @State private var titleVisible: Bool = false
    @State private var titlePulse: Bool = false
    @State private var dialogueId: Int = 0 // Forces TypewriterText to re-create

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack(alignment: .topLeading) {
                // MARK: - Background (full bleed)
                BundleImage("Onboarding Background")
                    .ignoresSafeArea()

                // MARK: - Top Shadow Gradient
                LinearGradient(
                    colors: [Color.black.opacity(0.5), Color.black.opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: h * 0.40)
                .ignoresSafeArea()

                // MARK: - Dr. Doomscroll Pose (bottom area)
                BundleImage("Dr Doomscroll")
                    .frame(width: w * 0.875, height: h * 0.333)
                    .position(x: w * 0.50, y: h * 0.83)

                // MARK: - Speech Bubble
                BundleImage("Speech Bubble", contentMode: .fit)
                    .frame(width: w * 0.60, height: w * 0.60)
                    .position(x: w * 0.64, y: h * 0.55)

                // MARK: - Dialogue Text (inside the speech bubble)
                TypewriterText(
                    dialogueLines[currentIndex],
                    font: .custom("ComicSansMS", size: dialogueFontSize(width: w)),
                    color: .black,
                    characterDelay: .milliseconds(35)
                ) {
                    // Typing complete — show the title
                    withAnimation(.easeIn(duration: 0.4)) {
                        isTyping = false
                        titleVisible = true
                    }
                    // Start gentle pulse after appearing
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                            titlePulse = true
                        }
                    }
                }
                .id(dialogueId)
                .frame(width: w * 0.40, alignment: .leading)
                .position(x: w * 0.64, y: h * 0.52)

                // MARK: - Title Text (top center)
                if titleVisible {
                    Text(titleText)
                        .font(.custom("ComicSansMS-Bold", size: titleFontSize(width: w)))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.6), radius: 4, x: 2, y: 2)
                        .opacity(titlePulse ? 0.6 : 1.0)
                        .position(x: w * 0.50, y: h * 0.09)
                        .transition(.opacity)
                }
            }
            .onTapGesture {
                handleTap()
            }
        }
        .ignoresSafeArea()
        .statusBarHidden(true)
    }

    // MARK: - Actions

    private func handleTap() {
        // If still typing, wait for completion.
        guard !isTyping else { return }

        if currentIndex < dialogueLines.count - 1 {
            // Advance to next dialogue line
            titleVisible = false
            titlePulse = false
            isTyping = true
            currentIndex += 1
            dialogueId += 1
        } else {
            // Last line done — transition to the feed
            withAnimation(.easeInOut(duration: 0.5)) {
                appState.phase = .feed
            }
        }
    }

    // MARK: - Font Sizing

    /// Scales dialogue font based on screen width (Figma: 24pt at 834w).
    private func dialogueFontSize(width: CGFloat) -> CGFloat {
        let scale = width / 834
        return max(16, 24 * scale)
    }

    /// Scales title font based on screen width (Figma: 40pt at 834w).
    private func titleFontSize(width: CGFloat) -> CGFloat {
        let scale = width / 834
        return max(24, 40 * scale)
    }

}
