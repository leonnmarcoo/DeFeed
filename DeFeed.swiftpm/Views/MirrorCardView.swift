import SwiftUI

struct MirrorCardView: View {
    let villainHP: Double
    var onContinue: () -> Void

    @State private var dialogueStep: Int = 0
    @State private var showContinue: Bool = false
    @State private var titlePulse: Bool = false

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

                // MARK: - Dr. Doomscroll Pose 3 (large, triumphant — behind dialogue)
                Image("Dr Doomscroll Pose 3")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: w * 0.80, height: h * 0.51)
                    .position(x: w * 0.50, y: h * 0.75)

                // MARK: - Speech Bubble Right-Top (Step 3)
                if dialogueStep >= 3 {
                    SpeechBubbleView(tailDirection: .bottomLeft, cornerRadius: 12, borderWidth: 2) {
                        Text(mirrorDialogues[2])
                            .font(.custom("ComicNeue-Regular", size: bubbleFontSize(width: w)))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .frame(width: w * 0.24, alignment: .center)
                    }
                    .frame(width: w * 0.35)
                    .position(x: w * 0.63, y: h * 0.24)
                    .transition(.opacity)
                }

                // MARK: - Speech Bubble Left: Crimes list (Step 2+)
                if dialogueStep >= 2 {
                    SpeechBubbleView(tailDirection: .bottomRight, cornerRadius: 12, borderWidth: 2) {
                        Text(mirrorDialogues[1])
                            .font(.custom("ComicNeue-Regular", size: bubbleFontSize(width: w)))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .frame(width: w * 0.26, alignment: .center)
                    }
                    .frame(width: w * 0.38)
                    .position(x: w * 0.30, y: h * 0.38)
                    .transition(.opacity)
                }

                // MARK: - Dialogue Box Bottom-Right (Step 1+)
                if dialogueStep >= 1 {
                    SpeechBubbleView(tailDirection: .bottomLeft, cornerRadius: 12, borderWidth: 2) {
                        Text(mirrorDialogues[0])
                            .font(.custom("ComicNeue-Regular", size: bubbleFontSize(width: w)))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .frame(width: w * 0.24, alignment: .center)
                    }
                    .frame(width: w * 0.35)
                    .position(x: w * 0.64, y: h * 0.50)
                    .transition(.opacity)
                }

                // MARK: - "Tap to Continue" (shown after each bubble appears)
                if showContinue {
                    Text("TAP TO CONTINUE")
                        .font(.custom("ComicNeue-Bold", size: titleFontSize(width: w)))
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.yellow)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.black, lineWidth: 3)
                                )
                        )
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
            withAnimation(.easeIn(duration: 0.6).delay(0.3)) {
                dialogueStep = 1
            }
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
            withAnimation(.easeIn(duration: 0.5)) {
                dialogueStep += 1
            }
        } else {
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
        return max(20, 32 * s)
    }
}
