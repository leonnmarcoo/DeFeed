import SwiftUI

// MARK: - StatisticsView
/// Act 2 — Screen 2: Full-screen dramatic stat panels.
///
/// 4 panels shown one at a time: Week → Month → Year → Lifetime.
/// User taps or swipes left to advance. Comic ink-wipe transition + haptic between panels.
struct StatisticsView: View {
    @EnvironmentObject private var appState: AppState

    // MARK: - Navigation State
    @State private var currentPanel: Int = 0
    @State private var isTransitioning: Bool = false
    @State private var wipeProgress: CGFloat = 0    // 0 = off-screen left, 0.5 = covering, 1 = off-screen right

    // MARK: - Panel 1 (Week) Animation
    @State private var weekFillProgress: CGFloat = 0
    @State private var weekRedPulse: Bool = false

    // MARK: - Panel 2 (Month) Animation
    @State private var monthTilesRevealed: Int = 0

    // MARK: - Panel 3 (Year) Animation
    @State private var yearArcTrim: CGFloat = 0

    // MARK: - Panel 4 (Lifetime) Animation
    @State private var lifetimeReveal: CGFloat = 0

    // MARK: - Panel 5 (Wrap-up) Animation
    @State private var wrapPanelsRevealed: Int = 0

    // MARK: - Computed Statistics

    private var dailyHours: Double { appState.dailyHours }
    private var weeklyHours: Int { Int(dailyHours * 7) }
    private var monthlyDays: Double { (dailyHours * 30) / 24 }
    private var yearlyWeeks: Double { (dailyHours * 365) / (24 * 7) }
    private var lifetimeYears: Double { (dailyHours * Double(72 - 13) * 365) / (24 * 365) }

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // Current panel content
                panelContent(index: currentPanel, w: w, h: h)

                // Ink wipe overlay
                inkWipeOverlay(w: w, h: h)
            }
            .frame(width: w, height: h)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 50)
                    .onEnded { value in
                        if value.translation.width < -50 {
                            handleAdvance(w: w)
                        }
                    }
            )
            .onTapGesture {
                handleAdvance(w: w)
            }
        }
        .ignoresSafeArea()
        .statusBarHidden(true)
        .onAppear {
            animatePanel(0)
        }
    }

    // MARK: - Panel Content Dispatcher

    @ViewBuilder
    private func panelContent(index: Int, w: CGFloat, h: CGFloat) -> some View {
        switch index {
        case 0: weekPanelFull(w: w, h: h)
        case 1: monthPanelFull(w: w, h: h)
        case 2: yearPanelFull(w: w, h: h)
        case 3: lifetimePanelFull(w: w, h: h)
        case 4: wrapPanelFull(w: w, h: h)
        default: EmptyView()
        }
    }

    // MARK: - Ink Wipe Overlay

    @ViewBuilder
    private func inkWipeOverlay(w: CGFloat, h: CGFloat) -> some View {
        // wipeProgress: 0 = fully left (hidden), 0.5 = covering screen, 1.0 = fully right (hidden)
        let xOffset: CGFloat = {
            if wipeProgress <= 0.5 {
                // Moving in from left: -w → 0
                return -w + (wipeProgress / 0.5) * w
            } else {
                // Moving out to right: 0 → w
                return ((wipeProgress - 0.5) / 0.5) * w
            }
        }()

        InkWipeShape()
            .fill(Color.black)
            .frame(width: w + 40, height: h + 40)
            .offset(x: xOffset)
            .opacity(isTransitioning ? 1 : 0)
            .allowsHitTesting(false)
    }

    // MARK: - Panel Transition

    private func handleAdvance(w: CGFloat) {
        // Panel 5 (wrap): final screen — nothing to advance to
        if currentPanel == 4 {
            return
        }
        guard !isTransitioning else { return }
        advancePanel()
    }

    private func advancePanel() {
        guard currentPanel < 4 else { return }
        isTransitioning = true

        // Haptic
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()

        // Phase 1: Ink sweeps in from left, covering screen
        wipeProgress = 0
        withAnimation(.easeIn(duration: 0.28)) {
            wipeProgress = 0.5
        }

        // Phase 2: Switch content behind ink, then sweep out to right
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            currentPanel += 1

            withAnimation(.easeOut(duration: 0.28)) {
                wipeProgress = 1.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
                isTransitioning = false
                wipeProgress = 0
                animatePanel(currentPanel)
            }
        }
    }

    // MARK: - Panel Animation Dispatcher

    private func animatePanel(_ index: Int) {
        switch index {
        case 0: animateWeek()
        case 1: animateMonth()
        case 2: animateYear()
        case 3: animateLifetime()
        case 4: animateWrap()
        default: break
        }
    }

    private func animateWeek() {
        weekFillProgress = 0
        weekRedPulse = false
        let neutralPortion: CGFloat = 96.0 / 168.0 // sleep + work ≈ 96h
        let redPortion: CGFloat = CGFloat(weeklyHours) / 168.0

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeInOut(duration: 1.5)) {
                weekFillProgress = neutralPortion + redPortion
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                weekRedPulse = true
            }
        }
    }

    private func animateMonth() {
        monthTilesRevealed = 0
        for i in 1...30 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(i) * 0.055) {
                withAnimation(.easeIn(duration: 0.1)) {
                    monthTilesRevealed = i
                }
            }
        }
    }

    private func animateYear() {
        yearArcTrim = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeInOut(duration: 2.0)) {
                yearArcTrim = min(CGFloat(yearlyWeeks / 52.0), 1.0)
            }
        }
    }

    private func animateLifetime() {
        lifetimeReveal = 0

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeInOut(duration: 1.5)) {
                lifetimeReveal = 1.0
            }
        }
    }

    private func animateWrap() {
        wrapPanelsRevealed = 0
        let delayPerPanel: Double = 0.5
        for i in 1...5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * delayPerPanel) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    wrapPanelsRevealed = i
                }
            }
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Panel 1: Every Week
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    @ViewBuilder
    private func weekPanelFull(w: CGFloat, h: CGFloat) -> some View {
        ZStack {
            Image("Stats Panel Blue")
                .resizable()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: h * 0.08)

                comicCaption("EVERY WEEK", w: w)

                Spacer()

                // Time bar visualization
                weekTimeBar(w: w, h: h)

                Spacer().frame(height: h * 0.03)

                // Big number
                Text("\(weeklyHours)")
                    .font(.custom("ComicNeue-Bold", size: bigNumberFont(width: w)))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.6), radius: 6, x: 2, y: 3)

                Text("hours swallowed by the feed.")
                    .font(.custom("ComicNeue-Regular", size: bodyFont(width: w)))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.4), radius: 3, x: 1, y: 1)

                Spacer()

                comicCaptionAlt(weekAlternative(), w: w)

                Spacer().frame(height: h * 0.08)
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private func weekTimeBar(w: CGFloat, h: CGFloat) -> some View {
        let barWidth = w * 0.82
        let barHeight: CGFloat = h * 0.05
        let neutralRatio: CGFloat = 96.0 / 168.0
        let totalFill = weekFillProgress * barWidth
        let neutralWidth = min(totalFill, neutralRatio * barWidth)
        let redWidth = max(0, totalFill - neutralRatio * barWidth)

        VStack(spacing: 8) {
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: barHeight / 2)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: barWidth, height: barHeight)

                // Filled segments
                HStack(spacing: 0) {
                    if neutralWidth > 0 {
                        UnevenRoundedRectangle(
                            topLeadingRadius: barHeight / 2,
                            bottomLeadingRadius: barHeight / 2,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: 0
                        )
                        .fill(Color.white.opacity(0.7))
                        .frame(width: neutralWidth, height: barHeight)
                    }
                    if redWidth > 0 {
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: redWidth, height: barHeight)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: barHeight / 2))
                .frame(width: barWidth, alignment: .leading)
            }
            .overlay(
                RoundedRectangle(cornerRadius: barHeight / 2)
                    .stroke(Color.white, lineWidth: 2)
            )

            // Labels beneath the bar
            HStack {
                Text("Sleep + Work")
                    .font(.custom("ComicNeue-Regular", size: smallFont(width: w)))
                    .foregroundColor(.white)
                Spacer()
                Text("\(weeklyHours)h scrolling")
                    .font(.custom("ComicNeue-Bold", size: smallFont(width: w)))
                    .foregroundColor(.red)
                Spacer()
            }
            .frame(width: barWidth)
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Panel 2: Every Month
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    @ViewBuilder
    private func monthPanelFull(w: CGFloat, h: CGFloat) -> some View {
        ZStack {
            Image("Stats Panel Yellow")
                .resizable()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: h * 0.08)

                comicCaption("EACH MONTH", w: w)

                Spacer()

                monthCalendarGrid(w: w, h: h)

                Spacer().frame(height: h * 0.03)

                Text(String(format: "%.1f", monthlyDays))
                    .font(.custom("ComicNeue-Bold", size: bigNumberFont(width: w)))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.6), radius: 6, x: 2, y: 3)

                Text("full days gone. Every month.")
                    .font(.custom("ComicNeue-Regular", size: bodyFont(width: w)))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.4), radius: 3, x: 1, y: 1)

                Spacer()

                comicCaptionAlt(monthAlternative(), w: w)

                Spacer().frame(height: h * 0.08)
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private func monthCalendarGrid(w: CGFloat, h: CGFloat) -> some View {
        let columns = 6
        let spacing: CGFloat = w * 0.015
        let totalSpacing = spacing * CGFloat(columns - 1) + w * 0.12
        let tileSize = (w - totalSpacing) / CGFloat(columns)
        let fullRedDays = Int(monthlyDays)
        let partialFraction = CGFloat(monthlyDays - floor(monthlyDays))

        let gridColumns = Array(repeating: GridItem(.fixed(tileSize), spacing: spacing), count: columns)

        LazyVGrid(columns: gridColumns, spacing: spacing) {
            ForEach(0..<30, id: \.self) { day in
                let isRevealed = day < monthTilesRevealed

                ZStack {
                    // Base tile
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.25))
                        .frame(width: tileSize, height: tileSize)

                    if isRevealed {
                        if day < fullRedDays {
                            // Fully consumed day
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.red)
                                .frame(width: tileSize, height: tileSize)
                        } else if day == fullRedDays && partialFraction > 0 {
                            // Partially consumed day
                            HStack(spacing: 0) {
                                Rectangle()
                                    .fill(Color.red)
                                    .frame(width: tileSize * partialFraction)
                                Spacer(minLength: 0)
                            }
                            .frame(width: tileSize, height: tileSize)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        } else {
                            // Normal day
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.5))
                                .frame(width: tileSize, height: tileSize)
                        }
                    }

                    // Day number
                    Text("\(day + 1)")
                        .font(.custom("ComicNeue-Bold", size: smallFont(width: w)))
                        .foregroundColor(.white)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, w * 0.06)
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Panel 3: Every Year
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    @ViewBuilder
    private func yearPanelFull(w: CGFloat, h: CGFloat) -> some View {
        ZStack {
            Image("Stats Panel Red")
                .resizable()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: h * 0.08)

                comicCaption("EVERY YEAR", w: w)

                Spacer()

                yearRadialArc(w: w, h: h)

                Spacer().frame(height: h * 0.03)

                Text(String(format: "%.1f", yearlyWeeks))
                    .font(.custom("ComicNeue-Bold", size: bigNumberFont(width: w)))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.6), radius: 6, x: 2, y: 3)

                Text("weeks. Every year.")
                    .font(.custom("ComicNeue-Regular", size: bodyFont(width: w)))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.4), radius: 3, x: 1, y: 1)

                Spacer()

                comicCaptionAlt(yearAlternative(), w: w)

                Spacer().frame(height: h * 0.08)
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private func yearRadialArc(w: CGFloat, h: CGFloat) -> some View {
        let arcSize = min(w * 0.48, h * 0.26)
        let lineWidth: CGFloat = arcSize * 0.12

        ZStack {
            // Background ring — full year
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: lineWidth)
                .frame(width: arcSize, height: arcSize)

            // Red arc — scrolling weeks
            Circle()
                .trim(from: 0, to: yearArcTrim)
                .stroke(
                    Color.red,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: arcSize, height: arcSize)

            // Center label
            VStack(spacing: 2) {
                Text(String(format: "%.1f", yearlyWeeks * Double(yearArcTrim > 0 ? 1 : 0)))
                    .font(.custom("ComicNeue-Bold", size: captionFont(width: w) * 1.6))
                    .foregroundColor(.white)
                Text("weeks")
                    .font(.custom("ComicNeue-Regular", size: smallFont(width: w)))
                    .foregroundColor(.white)
            }
        }
        .padding(lineWidth / 2 + 14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white, lineWidth: 2)
        )
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Panel 4: A Lifetime
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    @ViewBuilder
    private func lifetimePanelFull(w: CGFloat, h: CGFloat) -> some View {
        ZStack {
            Image("Stats Panel Green")
                .resizable()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: h * 0.08)

                comicCaption("A LIFETIME", w: w)

                Spacer()

                lifetimeSilhouettes(w: w, h: h)

                Spacer().frame(height: h * 0.03)

                Text(String(format: "%.1f", lifetimeYears))
                    .font(.custom("ComicNeue-Bold", size: bigNumberFont(width: w)))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.6), radius: 6, x: 2, y: 3)

                Text("years of your life.\nHanded to the feed.")
                    .font(.custom("ComicNeue-Regular", size: bodyFont(width: w)))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.4), radius: 3, x: 1, y: 1)

                Spacer()

                comicCaptionAlt(lifetimeAlternative(), w: w)

                Spacer().frame(height: h * 0.08)
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private func lifetimeSilhouettes(w: CGFloat, h: CGFloat) -> some View {
        let totalFigures = 12
        let yearsPerFigure = 59.0 / Double(totalFigures)
        let lostFigures = lifetimeYears / yearsPerFigure
        let figureSize = w * 0.06

        HStack(spacing: w * 0.015) {
            ForEach(0..<totalFigures, id: \.self) { index in
                let reverseIndex = totalFigures - 1 - index
                let isFullLost = Double(reverseIndex) < floor(lostFigures)
                let isPartialLost = Double(reverseIndex) < lostFigures && !isFullLost
                let crackAmount = isFullLost ? lifetimeReveal : (isPartialLost ? lifetimeReveal * CGFloat(lostFigures - floor(lostFigures)) : 0)
                let isAffected = crackAmount > 0

                VStack(spacing: 4) {
                    Image(systemName: "figure.stand")
                        .font(.system(size: figureSize))
                        .foregroundColor(isAffected ? .red : .white)
                        .rotationEffect(isAffected && lifetimeReveal > 0.5
                            ? .degrees(Double(reverseIndex % 2 == 0 ? -5 : 5))
                            : .zero)
                        .scaleEffect(isAffected && lifetimeReveal > 0.5 ? 0.88 : 1.0)

                    Text(decadeLabel(index))
                        .font(.custom("ComicNeue-Regular", size: smallFont(width: w) * 0.85))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white, lineWidth: 2)
        )
    }

    private func decadeLabel(_ index: Int) -> String {
        let labels = ["13", "23", "33", "43", "53", "63"]
        return index < labels.count ? labels[index] : ""
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Panel 5: Doomscroll Wrap
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    @ViewBuilder
    private func wrapPanelFull(w: CGFloat, h: CGFloat) -> some View {
        let pad: CGFloat = w * 0.03
        let panelW = (w - pad * 3) / 2

        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: pad) {
                Spacer(minLength: 0)
                // Top row: Week | Month
                HStack(spacing: pad) {
                    wrapStatPanel(
                        imageName: "Stats Panel Blue",
                        topText: "Every week, you feed me",
                        bigText: "\(weeklyHours)",
                        bottomText: "hours",
                        width: panelW, height: h * 0.30, screenWidth: w
                    )
                    .opacity(wrapPanelsRevealed >= 1 ? 1 : 0)
                    .scaleEffect(wrapPanelsRevealed >= 1 ? 1 : 0.9)

                    wrapStatPanel(
                        imageName: "Stats Panel Yellow",
                        topText: "Each month, that becomes",
                        bigText: String(format: "%.1f", monthlyDays),
                        bottomText: "days erased",
                        width: panelW, height: h * 0.30, screenWidth: w
                    )
                    .opacity(wrapPanelsRevealed >= 2 ? 1 : 0)
                    .scaleEffect(wrapPanelsRevealed >= 2 ? 1 : 0.9)
                }

                // Middle: Container (green, full width)
                wrapContainerPanel(width: w - pad * 2, height: h * 0.26, screenWidth: w)
                    .opacity(wrapPanelsRevealed >= 3 ? 1 : 0)
                    .scaleEffect(wrapPanelsRevealed >= 3 ? 1 : 0.9)

                // Bottom row: Year | Lifetime
                HStack(spacing: pad) {
                    wrapStatPanel(
                        imageName: "Stats Panel Red",
                        topText: "Per year...",
                        bigText: String(format: "%.1f", yearlyWeeks),
                        bottomText: "weeks\nvanish into the void",
                        width: panelW, height: h * 0.28, screenWidth: w
                    )
                    .opacity(wrapPanelsRevealed >= 4 ? 1 : 0)
                    .scaleEffect(wrapPanelsRevealed >= 4 ? 1 : 0.9)

                    wrapStatPanel(
                        imageName: "Stats Panel Blue",
                        topText: "Across a lifetime, that's",
                        bigText: String(format: "%.1f", lifetimeYears),
                        bottomText: "years\nyou won't get back",
                        width: panelW, height: h * 0.28, screenWidth: w
                    )
                    .opacity(wrapPanelsRevealed >= 5 ? 1 : 0)
                    .scaleEffect(wrapPanelsRevealed >= 5 ? 1 : 0.9)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, pad)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private func wrapStatPanel(
        imageName: String,
        topText: String,
        bigText: String,
        bottomText: String,
        width: CGFloat,
        height: CGFloat,
        screenWidth: CGFloat
    ) -> some View {
        ZStack {
            Image(imageName)
                .resizable()
                .frame(width: width, height: height)

            VStack(spacing: 4) {
                Text(topText)
                    .font(.custom("ComicNeue-Regular", size: wrapBodyFont(width: screenWidth)))
                    .foregroundColor(.white)
                Text(bigText)
                    .font(.custom("ComicNeue-Bold", size: wrapBigFont(width: screenWidth)))
                    .foregroundColor(.white)
                Text(bottomText)
                    .font(.custom("ComicNeue-Regular", size: wrapBodyFont(width: screenWidth)))
                    .foregroundColor(.white)
            }
            .multilineTextAlignment(.center)
            .shadow(color: .black.opacity(0.5), radius: 3, x: 1, y: 1)
            .padding(12)
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black, lineWidth: 3)
        )
    }

    @ViewBuilder
    private func wrapContainerPanel(width: CGFloat, height: CGFloat, screenWidth: CGFloat) -> some View {
        ZStack {
            Image("Stats Panel Green")
                .resizable()
                .frame(width: width, height: height)

            HStack(spacing: 0) {
                Image("Dr Doomscroll Pose 3")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width * 0.40, height: height * 0.85)

                VStack(spacing: 8) {
                    Text("No rewind.")
                        .font(.custom("ComicNeue-Bold", size: wrapBigFont(width: screenWidth)))
                    Text("No refund.")
                        .font(.custom("ComicNeue-Bold", size: wrapBigFont(width: screenWidth)))
                    Text("Just gone.")
                        .font(.custom("ComicNeue-Bold", size: wrapBigFont(width: screenWidth)))
                }
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 3, x: 1, y: 1)
                .frame(maxWidth: .infinity)
            }
            .padding(12)
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black, lineWidth: 3)
        )
    }

    private func wrapBodyFont(width: CGFloat) -> CGFloat {
        let s = width / 834
        return max(12, 18 * s)
    }

    private func wrapBigFont(width: CGFloat) -> CGFloat {
        let s = width / 834
        return max(28, 48 * s)
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Comic Caption Boxes
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    /// Yellow caption box — top-of-panel time label.
    @ViewBuilder
    private func comicCaption(_ text: String, w: CGFloat) -> some View {
        Text(text)
            .font(.custom("ComicNeue-Bold", size: captionFont(width: w)))
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
    }

    /// White caption box — bottom-of-panel "what you could do instead" text.
    @ViewBuilder
    private func comicCaptionAlt(_ text: String, w: CGFloat) -> some View {
        Text(text)
            .font(.custom("ComicNeue-Regular", size: bodyFont(width: w) * 0.85))
            .foregroundColor(.black)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: w * 0.80)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.black, lineWidth: 2)
                    )
            )
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Alternative Text
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func weekAlternative() -> String {
        switch weeklyHours {
        case 1...14:  return "A skill practiced. A chapter read."
        case 15...28: return "A short film made. A recipe mastered."
        case 29...42: return "A new language started. A portfolio piece finished."
        default:      return "A part-time job. A side project launched."
        }
    }

    private func monthAlternative() -> String {
        if monthlyDays < 1 { return "A weekend trip planned and taken." }
        if monthlyDays < 3 { return "A short course completed. A friendship deepened." }
        if monthlyDays < 5 { return "A passion project with real progress." }
        return "A vacation. An actual vacation."
    }

    private func yearAlternative() -> String {
        if yearlyWeeks < 1 { return "A solo trip across your country." }
        if yearlyWeeks < 3 { return "A novel written. A certification earned." }
        if yearlyWeeks < 5 { return "A transformative travel experience." }
        return "A sabbatical. A reinvention."
    }

    private func lifetimeAlternative() -> String {
        if lifetimeYears < 1 { return "Time to master something that changes your life." }
        if lifetimeYears < 3 { return "Time to build something the world remembers." }
        return "Time to become someone entirely different."
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Font Sizing
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private func bigNumberFont(width: CGFloat) -> CGFloat {
        let s = width / 834
        return max(56, 96 * s)
    }

    private func captionFont(width: CGFloat) -> CGFloat {
        let s = width / 834
        return max(20, 32 * s)
    }

    private func bodyFont(width: CGFloat) -> CGFloat {
        let s = width / 834
        return max(16, 24 * s)
    }

    private func smallFont(width: CGFloat) -> CGFloat {
        let s = width / 834
        return max(11, 16 * s)
    }
}

// MARK: - Ink Wipe Shape
/// Simple solid ink sweep rectangle.
struct InkWipeShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path(rect)
    }
}
