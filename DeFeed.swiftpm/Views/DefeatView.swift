import SwiftUI

/// Act 2 — Screen 3: Defeat.
///
/// The player holds a button to "take back control."
/// As they hold, the villain's HP drains from 100 → 0.
/// When HP hits 0 the villain collapses and the closing message appears.
struct DefeatView: View {
    @EnvironmentObject private var appState: AppState

    @State private var hp: Double = 100
    @State private var isHolding: Bool = false
    @State private var defeated: Bool = false
    @State private var showEndText: Bool = false
    @State private var holdTimer: Timer? = nil
    @State private var buttonScale: Double = 1.0
    @State private var villainOpacity: Double = 1.0
    @State private var villainOffset: CGFloat = 0
    @State private var endTextOpacity: Double = 0

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // MARK: - Background
                Image("Stats Panel Blue")
                    .resizable()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: h * 0.04)

                    // MARK: - HP Bar (draining)
                    HPBarView(hp: hp)
                        .frame(width: w * 0.80, height: 44)
                        .animation(.easeOut(duration: 0.15), value: hp)

                    Spacer()
                        .frame(height: h * 0.02)

                    // MARK: - Villain dialogue
                    if !defeated {
                        Text(villainDialogue)
                            .font(.custom("ComicNeue-Bold", size: dialogueFontSize(width: w)))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .shadow(color: .black.opacity(0.6), radius: 4, x: 2, y: 2)
                            .padding(.horizontal, w * 0.10)
                            .transition(.opacity)
                    }

                    Spacer()

                    // MARK: - Dr. Doomscroll (collapses on defeat)
                    Image("Dr Doomscroll Pose 3")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: w * 0.70, height: h * 0.40)
                        .opacity(villainOpacity)
                        .offset(y: villainOffset)
                        .scaleEffect(defeated ? 0.6 : 1.0)
                        .rotationEffect(defeated ? .degrees(15) : .zero)
                        .animation(.easeIn(duration: 0.8), value: defeated)

                    Spacer()

                    // MARK: - Hold Button or End Text
                    if !defeated {
                        holdButton(w: w, h: h)
                            .padding(.bottom, h * 0.06)
                    } else if showEndText {
                        endingMessage(w: w)
                            .opacity(endTextOpacity)
                            .padding(.bottom, h * 0.06)
                    }
                }

                // MARK: - Ending overlay (after defeat)
                if showEndText {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                        .opacity(endTextOpacity)

                    VStack(spacing: 16) {
                        Text("Your attention is yours again.")
                            .font(.custom("ComicNeue-Bold", size: endTitleFont(width: w)))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .shadow(color: .black.opacity(0.8), radius: 6, x: 2, y: 2)

                        Text("DeFeed.")
                            .font(.custom("ComicNeue-Bold", size: endLogoFont(width: w)))
                            .foregroundColor(.yellow)
                            .shadow(color: .black.opacity(0.8), radius: 6, x: 2, y: 2)
                    }
                    .opacity(endTextOpacity)
                    .padding(.horizontal, 32)
                }
            }
        }
        .ignoresSafeArea()
        .statusBarHidden(true)
    }

    // MARK: - Villain Dialogue (changes as HP drops)

    private var villainDialogue: String {
        if hp > 75 { return "You can't do this. I OWN your time!" }
        if hp > 50 { return "Stop! You NEED me!" }
        if hp > 25 { return "No… no… I'm losing control…" }
        return "Please… just one more scroll…"
    }

    // MARK: - Hold Button

    @ViewBuilder
    private func holdButton(w: CGFloat, h: CGFloat) -> some View {
        Text("Hold to Take Back Control")
            .font(.custom("ComicNeue-Bold", size: buttonFontSize(width: w)))
            .foregroundColor(.black)
            .padding(.horizontal, 32)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.4), radius: 6, x: 2, y: 3)
            )
            .scaleEffect(buttonScale)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isHolding {
                            startHolding()
                        }
                    }
                    .onEnded { _ in
                        stopHolding()
                    }
            )
    }

    // MARK: - Ending Message

    @ViewBuilder
    private func endingMessage(w: CGFloat) -> some View {
        EmptyView() // Text is now shown as overlay
    }

    // MARK: - Hold Logic

    private func startHolding() {
        isHolding = true
        withAnimation(.easeInOut(duration: 0.2)) {
            buttonScale = 0.92
        }

        // Drain HP over time (100 → 0 in ~3 seconds)
        holdTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [self] _ in
            Task { @MainActor [self] in
                if hp > 0 {
                    hp = max(0, hp - 1.7)
                } else {
                    holdTimer?.invalidate()
                    triggerDefeat()
                }
            }
        }
    }

    private func stopHolding() {
        isHolding = false
        holdTimer?.invalidate()
        holdTimer = nil

        withAnimation(.easeOut(duration: 0.2)) {
            buttonScale = 1.0
        }
    }

    private func triggerDefeat() {
        holdTimer?.invalidate()
        holdTimer = nil
        isHolding = false

        // Villain collapse
        withAnimation(.easeIn(duration: 0.8)) {
            defeated = true
            villainOpacity = 0.3
            villainOffset = 80
        }

        // Show ending text after collapse animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            showEndText = true
            withAnimation(.easeIn(duration: 1.5)) {
                endTextOpacity = 1.0
            }
        }
    }

    // MARK: - Font Sizing

    private func dialogueFontSize(width: CGFloat) -> CGFloat {
        let s = width / 834
        return max(18, 26 * s)
    }

    private func buttonFontSize(width: CGFloat) -> CGFloat {
        let s = width / 834
        return max(16, 22 * s)
    }

    private func endTitleFont(width: CGFloat) -> CGFloat {
        let s = width / 834
        return max(28, 40 * s)
    }

    private func endLogoFont(width: CGFloat) -> CGFloat {
        let s = width / 834
        return max(36, 56 * s)
    }
}
