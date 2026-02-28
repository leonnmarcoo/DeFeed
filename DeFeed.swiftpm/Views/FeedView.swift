import SwiftUI

/// Act 1 — The Feed.
///
/// Layout: Fixed header (character, dialogue, HP) at top,
/// scrollable content cards (with shadow, caption, buttons) beneath.
/// Card 5 (Mirror) is a full-screen takeover.
struct FeedView: View {
    @EnvironmentObject private var appState: AppState

    @State private var currentPage: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var showMirror: Bool = false
    @State private var dialogueId: Int = 0

    private let cards = CardData.all

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                if !showMirror {
                    feedLayout(w: w, h: h)
                        .transition(.opacity)
                } else {
                    MirrorCardView(villainHP: 100) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            appState.phase = .input
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showMirror)
        }
        .ignoresSafeArea()
        .statusBarHidden(true)
        .onAppear {
            updateHP(for: 0)
        }
    }

    // MARK: - Feed Layout (Cards 1–4 with fixed header, scrollable content)

    @ViewBuilder
    private func feedLayout(w: CGFloat, h: CGFloat) -> some View {
        let headerHeight: CGFloat = h * 0.20

        ZStack {
            // Background (full bleed)
            Image("Stats Panel Red")
                .resizable()
                .ignoresSafeArea()

            // MARK: - Scrollable Content (below header)
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: headerHeight)

                GeometryReader { contentGeo in
                    let cH = contentGeo.size.height

                    VStack(spacing: 0) {
                        ForEach(Array(cards.enumerated()), id: \.element.id) { _, card in
                            FeedCardView(card: card)
                                .frame(width: w, height: cH)
                        }
                    }
                    .offset(y: -CGFloat(currentPage) * cH + dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation.height
                            }
                            .onEnded { value in
                                handleSwipe(translation: value.translation.height, contentHeight: cH)
                            }
                    )
                }
                .clipped()
            }

            // MARK: - Fixed Header (character, dialogue, HP — topmost)
            VStack {
                headerView(w: w, headerHeight: headerHeight)
                    .frame(height: headerHeight)
                Spacer()
            }
        }
    }

    // MARK: - Fixed Header

    @ViewBuilder
    private func headerView(w: CGFloat, headerHeight: CGFloat) -> some View {
        ZStack {
            // Dr. Doomscroll Pose 2 (left side)
            Image("Dr Doomscroll Pose 2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: w * 0.24, height: headerHeight * 0.82)
                .position(x: w * 0.155, y: headerHeight * 0.55)

            // Speech bubble with dialogue (center)
            SpeechBubbleView(tailDirection: .bottomLeft, cornerRadius: 12, borderWidth: 2) {
                TypewriterText(
                    cards[currentPage].dialogue,
                    font: .custom("ComicNeue-Regular", size: dialogueFontSize(width: w)),
                    color: .black,
                    characterDelay: .milliseconds(30)
                )
                .multilineTextAlignment(.center)
                .frame(width: w * 0.28, alignment: .center)
                .id(dialogueId)
            }
            .frame(width: w * 0.40)
            .position(x: w * 0.43, y: headerHeight * 0.52)

            // HP bar (right side)
            HPBarView(hp: appState.villainHP)
                .frame(width: w * 0.30, height: 36)
                .position(x: w * 0.78, y: headerHeight * 0.40)
        }
    }

    // MARK: - Swipe Handling

    private func handleSwipe(translation: CGFloat, contentHeight: CGFloat) {
        let threshold = contentHeight * 0.15

        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            if translation < -threshold {
                if currentPage < cards.count - 1 {
                    currentPage += 1
                    dialogueId += 1
                } else {
                    // Last card → transition to mirror
                    showMirror = true
                }
            } else if translation > threshold && currentPage > 0 {
                currentPage -= 1
                dialogueId += 1
            }
            dragOffset = 0
        }

        // Update HP with its own timing
        withAnimation(.easeInOut(duration: 0.6)) {
            appState.villainHP = showMirror ? 100 : hpForPage(currentPage)
        }
    }

    // MARK: - HP Logic

    private func hpForPage(_ page: Int) -> Double {
        Double(page + 1) * 20
    }

    private func updateHP(for page: Int) {
        withAnimation(.easeInOut(duration: 0.6)) {
            appState.villainHP = hpForPage(page)
        }
    }

    // MARK: - Font Sizing

    private func dialogueFontSize(width: CGFloat) -> CGFloat {
        let s = width / 834
        return max(14, 20 * s)
    }
}
