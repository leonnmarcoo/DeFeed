import SwiftUI

/// Card 5 — The Mirror Card. Tap-through dialogue like onboarding.
///
/// 3 dialogue steps, each revealed on tap (bottom to top):
/// 1. Small bubble (bottom-right): "Now that my health is full..."
/// 2. Left bubble (middle): "Unrealistic standards..."
/// 3. Right bubble (top): "Now meet the numbers behind your story."
/// Final tap → transitions to Act 2.
struct MirrorCardView: View {
    let villainHP: Double
    var onContinue: () -> Void

    /// 0 = nothing shown yet (on appear → auto-advance to 1)
    /// 1 = bottom bubble visible
    /// 2 = bottom + left bubbles visible
    /// 3 = all three bubbles visible
    @State private var dialogueStep: Int = 0
    @State private var showContinue: Bool = false
    @State private var titlePulse: Bool = false
    @State private var mirrorDialogueId: Int = 0

    private let mirrorDialogues: [String] = [
        "Now that my health is full, you've met the real villain.",
        "Unrealistic standards. Manufactured anxiety. Engineered loneliness. An algorithm that owns your emotions.",
        "Now meet the numbers behind your story."
    ]

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack(alignment: .topLeading) {
                // MARK: - Red Background
                Image("Stats Panel Red")
                    .resizable()
                    .ignoresSafeArea()

                // MARK: - Full HP Bar (spanning full width at top)
                HPBarView(hp: villainHP)
                    .frame(width: w * 0.88, height: 44)
                    .position(x: w * 0.50, y: h * 0.06)

                // MARK: - Speech Bubble Right-Top (Step 3)
                if dialogueStep >= 3 {
                    ZStack {
                        Image("Mirror Bubble Right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: w * 0.37, height: h * 0.23)

                        Text(mirrorDialogues[2])
                            .font(.custom("ComicNeue-Regular", size: bubbleFontSize(width: w)))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .frame(width: w * 0.22, alignment: .center)
                    }
                    .position(x: w * 0.63, y: h * 0.27)
                    .transition(.opacity)
                }

                // MARK: - Speech Bubble Left: Crimes list (Step 2+)
                if dialogueStep >= 2 {
                    ZStack {
                        Image("Mirror Bubble Left")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: w * 0.37, height: h * 0.23)

                        Text(mirrorDialogues[1])
                            .font(.custom("ComicNeue-Regular", size: bubbleFontSize(width: w)))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .frame(width: w * 0.24, alignment: .center)
                            .offset(y: -h * 0.015)
                    }
                    .position(x: w * 0.30, y: h * 0.42)
                    .transition(.opacity)
                }

                // MARK: - Dialogue Box Bottom-Right (Step 1+)
                if dialogueStep >= 1 {
                    ZStack {
                        Image("Speech Bubble Small")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: w * 0.36, height: w * 0.36)

                        Text(mirrorDialogues[0])
                            .font(.custom("ComicNeue-Regular", size: bubbleFontSize(width: w)))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .frame(width: w * 0.22, alignment: .center)
                            .offset(y: -w * 0.02)
                    }
                    .position(x: w * 0.64, y: h * 0.53)
                    .transition(.opacity)
                }

                // MARK: - Dr. Doomscroll Pose 3 (large, triumphant)
                Image("Dr Doomscroll Pose 3")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: w * 0.80, height: h * 0.51)
                    .position(x: w * 0.50, y: h * 0.75)

                // MARK: - "Tap to Continue" (shown after each bubble appears)
                if showContinue {
                    Text("Tap to Continue")
                        .font(.custom("ComicNeue-Bold", size: titleFontSize(width: w)))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.6), radius: 4, x: 2, y: 2)
                        .opacity(titlePulse ? 0.6 : 1.0)
                        .position(x: w * 0.50, y: h * 0.93)
                        .transition(.opacity)
                }
            }
            .onTapGesture {
                handleTap()
            }
        }
        .ignoresSafeArea()
        .onAppear {
            // Auto-show first bubble after a short delay
            withAnimation(.easeIn(duration: 0.6).delay(0.3)) {
                dialogueStep = 1
            }
            // Show "Tap to Continue" after first bubble
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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

    // MARK: - Tap Handler

    private func handleTap() {
        guard showContinue else { return }

        if dialogueStep < 3 {
            // Reveal next bubble
            mirrorDialogueId += 1
            withAnimation(.easeIn(duration: 0.5)) {
                dialogueStep += 1
            }
        } else {
            // All 3 dialogues shown — continue to Act 2
            onContinue()
        }
    }

    // MARK: - Font Sizing

    private func bubbleFontSize(width: CGFloat) -> CGFloat {
        let s = width / 834
        return max(12, 18 * s)
    }

    private func titleFontSize(width: CGFloat) -> CGFloat {
        let s = width / 834
        return max(24, 40 * s)
    }
}
