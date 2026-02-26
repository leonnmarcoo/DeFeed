import SwiftUI

/// Act 2 — Screen 1: Screen Time Slider.
///
/// Two states:
/// 1. Initial: Slider + "Continue" button.
///    Dialogue: "Drag the bar to confess your daily screen time… I'm watching."
/// 2. After submit: Button becomes "Reveal My Doomscroll Wrap".
///    Dialogue: "Interesting… very interesting. Let me calculate your devotion to the scroll…"
struct InputView: View {
    @EnvironmentObject private var appState: AppState

    @State private var sliderValue: Double = 3
    @State private var submitted: Bool = false
    @State private var dialogueId: Int = 0

    private var dialogueText: String {
        submitted
            ? "Interesting… very interesting. Let me calculate your devotion to the scroll…"
            : "Drag the bar to confess your daily screen time… I'm watching."
    }

    private var buttonText: String {
        submitted ? "Reveal My Doomscroll Wrap" : "Continue"
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // MARK: - Blue Comic Background
                BundleImage("Stats Background")
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: h * 0.07)

                    // MARK: - Title
                    Text("Screen Time Slider")
                        .font(.custom("ComicNeue-Bold", size: titleFontSize(width: w)))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 4, x: 2, y: 2)

                    Spacer()
                        .frame(height: h * 0.04)

                    // MARK: - Number Labels (1–10)
                    HStack(spacing: 0) {
                        ForEach(1...10, id: \.self) { num in
                            Text("\(num)")
                                .font(.custom("ComicNeue-Bold", size: numberFontSize(width: w)))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.4), radius: 2, x: 1, y: 1)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, w * 0.08)

                    Spacer()
                        .frame(height: h * 0.01)

                    // MARK: - Slider
                    Slider(value: $sliderValue, in: 1...10, step: 1)
                        .accentColor(.white)
                        .padding(.horizontal, w * 0.08)

                    Spacer()
                        .frame(height: h * 0.04)

                    // MARK: - Button
                    Button {
                        handleButtonTap()
                    } label: {
                        Text(buttonText)
                            .font(.custom("ComicNeue-Bold", size: buttonFontSize(width: w)))
                            .foregroundColor(.black)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 3, x: 1, y: 2)
                            )
                    }

                    Spacer()

                    // MARK: - Bottom section: Pose 2 + Dialogue Box
                    ZStack(alignment: .bottomLeading) {
                        // Dialogue Box (right side)
                        ZStack {
                            BundleImage("Stats Dialogue Box", contentMode: .fit)
                                .frame(width: w * 0.60, height: w * 0.60)

                            TypewriterText(
                                dialogueText,
                                font: .custom("ComicNeue-Regular", size: dialogueFontSize(width: w)),
                                color: .black,
                                characterDelay: .milliseconds(25)
                            )
                            .id(dialogueId)
                            .multilineTextAlignment(.center)
                            .frame(width: w * 0.40, alignment: .center)
                        }
                        .frame(width: w * 0.60, height: w * 0.60)
                        .offset(x: w * 0.38, y: -h * 0.08)

                        // Dr. Doomscroll Pose 2 (bottom-left)
                        BundleImage("Dr Doomscroll Pose 2", contentMode: .fit)
                            .frame(width: w * 0.60, height: h * 0.34)
                    }
                    .frame(width: w, height: h * 0.46, alignment: .bottomLeading)
                }
            }
        }
        .ignoresSafeArea()
        .statusBarHidden(true)
    }

    // MARK: - Actions

    private func handleButtonTap() {
        if !submitted {
            // First tap: lock in the slider value
            appState.dailyHours = sliderValue
            submitted = true
            dialogueId += 1
        } else {
            // Second tap: proceed to statistics
            withAnimation(.easeInOut(duration: 0.5)) {
                appState.phase = .statistics
            }
        }
    }

    // MARK: - Font Sizing

    private func titleFontSize(width: CGFloat) -> CGFloat {
        let s = width / 834
        return max(28, 42 * s)
    }

    private func numberFontSize(width: CGFloat) -> CGFloat {
        let s = width / 834
        return max(16, 24 * s)
    }

    private func buttonFontSize(width: CGFloat) -> CGFloat {
        let s = width / 834
        return max(14, 20 * s)
    }

    private func dialogueFontSize(width: CGFloat) -> CGFloat {
        let s = width / 834
        return max(14, 20 * s)
    }
}
