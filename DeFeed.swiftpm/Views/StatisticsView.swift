import SwiftUI

// MARK: - StatisticsView
/// Act 2 — Screen 2: Full-screen dramatic stat panels.
///
/// 4 panels shown one at a time: Week → Month → Year → Lifetime.
/// User taps or swipes left to advance. Comic ink-wipe transition + haptic between panels.
struct StatisticsView: View {
    @EnvironmentObject private var appState: AppState

    /// Vivid comic-book red for screen time visualizations
    private let comicRed = Color(red: 0.90, green: 0.10, blue: 0.10)

    // MARK: - Navigation State
    @State private var currentPanel: Int = 0
    @State private var isTransitioning: Bool = false
    @State private var isAnimating: Bool = false
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

    // MARK: - Panel 6 (Ending) Animation
    @State private var endingRevealed: Bool = false

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
        case 5: endingPanelFull(w: w, h: h)
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

    // MARK: - Restart App

    private func restartApp() {
        appState.phase = .onboarding
        appState.villainHP = 0
        appState.dailyHours = 3
    }

    // MARK: - Panel Transition

    private func handleAdvance(w: CGFloat) {
        // Panel 5 (ending): final screen — nothing to advance to
        if currentPanel == 5 {
            return
        }
        guard !isTransitioning && !isAnimating else { return }
        advancePanel()
    }

    private func advancePanel() {
        guard currentPanel < 5 else { return }
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
        case 5: animateEnding()
        default: break
        }
    }

    private func animateWeek() {
        weekFillProgress = 0
        weekRedPulse = false
        isAnimating = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeInOut(duration: 1.5)) {
                weekFillProgress = 1.0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isAnimating = false
        }
    }

    private func animateMonth() {
        monthTilesRevealed = 0
        isAnimating = true
        for i in 1...30 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(i) * 0.055) {
                withAnimation(.easeIn(duration: 0.1)) {
                    monthTilesRevealed = i
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
            isAnimating = false
        }
    }

    private func animateYear() {
        yearArcTrim = 0
        isAnimating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeInOut(duration: 2.0)) {
                yearArcTrim = min(CGFloat(yearlyWeeks / 52.0), 1.0)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            isAnimating = false
        }
    }

    private func animateLifetime() {
        lifetimeReveal = 0
        isAnimating = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeInOut(duration: 1.5)) {
                lifetimeReveal = 1.0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isAnimating = false
        }
    }

    private func animateWrap() {
        wrapPanelsRevealed = 0
        isAnimating = true
        let delayPerPanel: Double = 0.5
        for i in 1...5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * delayPerPanel) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    wrapPanelsRevealed = i
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            isAnimating = false
        }
    }

    private func animateEnding() {
        endingRevealed = false
        isAnimating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.8)) {
                endingRevealed = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isAnimating = false
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
                    .comicOutline()

                Text("hours swallowed by the feed.")
                    .font(.custom("ComicNeue-Regular", size: bodyFont(width: w)))
                    .foregroundColor(.white)
                    .comicOutline()

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
        let screenRatio = min(CGFloat(weeklyHours) / 168.0, 1.0)
        let redWidth = weekFillProgress * screenRatio * barWidth

        VStack(spacing: 8) {
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: barHeight / 2)
                    .fill(Color.white)
                    .frame(width: barWidth, height: barHeight)

                // Red fill from left — screen time
                if redWidth > 0 {
                    RoundedRectangle(cornerRadius: barHeight / 2)
                        .fill(comicRed)
                        .frame(width: redWidth, height: barHeight)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: barHeight / 2)
                    .stroke(Color.black, lineWidth: 3)
            )
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
                    .comicOutline()

                Text("full days gone. Every month.")
                    .font(.custom("ComicNeue-Regular", size: bodyFont(width: w)))
                    .foregroundColor(.white)
                    .comicOutline()

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
                        .fill(Color.white)
                        .frame(width: tileSize, height: tileSize)

                    if isRevealed {
                        if day < fullRedDays {
                            // Fully consumed day
                            RoundedRectangle(cornerRadius: 4)
                                .fill(comicRed)
                                .frame(width: tileSize, height: tileSize)
                        } else if day == fullRedDays && partialFraction > 0 {
                            // Partially consumed day
                            HStack(spacing: 0) {
                                Rectangle()
                                    .fill(comicRed)
                                    .frame(width: tileSize * partialFraction)
                                Spacer(minLength: 0)
                            }
                            .frame(width: tileSize, height: tileSize)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }

                    // Day number
                    Text("\(day + 1)")
                        .font(.custom("ComicNeue-Bold", size: smallFont(width: w)))
                        .foregroundColor(.white)
                        .comicOutline()
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.black, lineWidth: 2)
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
            Image("Stats Panel Green")
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
                    .comicOutline()

                Text("weeks. Every year.")
                    .font(.custom("ComicNeue-Regular", size: bodyFont(width: w)))
                    .foregroundColor(.white)
                    .comicOutline()

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
                .stroke(Color.white, lineWidth: lineWidth)
                .frame(width: arcSize, height: arcSize)

            // Red arc — scrolling weeks
            Circle()
                .trim(from: 0, to: yearArcTrim)
                .stroke(
                    comicRed,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: arcSize, height: arcSize)

            // Black outline on the ring
            Circle()
                .stroke(Color.black, lineWidth: 2)
                .frame(width: arcSize + lineWidth, height: arcSize + lineWidth)
            Circle()
                .stroke(Color.black, lineWidth: 2)
                .frame(width: arcSize - lineWidth, height: arcSize - lineWidth)

            // Center label
            VStack(spacing: 2) {
                Text(String(format: "%.1f", yearlyWeeks * Double(yearArcTrim > 0 ? 1 : 0)))
                    .font(.custom("ComicNeue-Bold", size: captionFont(width: w) * 1.6))
                    .foregroundColor(.white)
                    .comicOutline()
                Text("weeks")
                    .font(.custom("ComicNeue-Regular", size: smallFont(width: w)))
                    .foregroundColor(.white)
                    .comicOutline()
            }
        }
        .padding(lineWidth / 2 + 14)
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Panel 4: A Lifetime
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    @ViewBuilder
    private func lifetimePanelFull(w: CGFloat, h: CGFloat) -> some View {
        ZStack {
            Image("Stats Panel Blue")
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
                    .comicOutline()

                Text("years of your life.\nHanded to the feed.")
                    .font(.custom("ComicNeue-Regular", size: bodyFont(width: w)))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .comicOutline()

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
                let isFullLost = Double(index) < floor(lostFigures)
                let isPartialLost = Double(index) < lostFigures && !isFullLost
                let crackAmount = isFullLost ? lifetimeReveal : (isPartialLost ? lifetimeReveal * CGFloat(lostFigures - floor(lostFigures)) : 0)
                let isAffected = crackAmount > 0

                VStack(spacing: 4) {
                    Image(systemName: "figure.stand")
                        .font(.system(size: figureSize))
                        .foregroundColor(isAffected ? comicRed : .white)
                        .comicOutline()
                        .rotationEffect(isAffected && lifetimeReveal > 0.5
                            ? .degrees(Double(index % 2 == 0 ? -5 : 5))
                            : .zero)
                        .scaleEffect(isAffected && lifetimeReveal > 0.5 ? 0.88 : 1.0)

                    Text(decadeLabel(index))
                        .font(.custom("ComicNeue-Regular", size: smallFont(width: w) * 0.85))
                        .foregroundColor(.white)
                        .comicOutline()
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    private func decadeLabel(_ index: Int) -> String {
        let labels = ["13", "18", "23", "28", "33", "38", "43", "48", "53", "58", "63", "68"]
        return index < labels.count ? labels[index] : ""
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Panel 5: Doomscroll Wrap
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    @ViewBuilder
    private func wrapPanelFull(w: CGFloat, h: CGFloat) -> some View {
        let pad: CGFloat = w * 0.04
        let panelW = (w - pad * 3) / 2

        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: pad) {
                Spacer(minLength: 0)
                // Top row: Week | Month
                HStack(spacing: pad) {
                    wrapWeekPanel(width: panelW, height: h * 0.30, screenWidth: w)
                        .opacity(wrapPanelsRevealed >= 1 ? 1 : 0)
                        .scaleEffect(wrapPanelsRevealed >= 1 ? 1 : 0.9)

                    wrapMonthPanel(width: panelW, height: h * 0.30, screenWidth: w)
                        .opacity(wrapPanelsRevealed >= 2 ? 1 : 0)
                        .scaleEffect(wrapPanelsRevealed >= 2 ? 1 : 0.9)
                }

                // Middle: Container (green, full width)
                wrapContainerPanel(width: w - pad * 2, height: h * 0.26, screenWidth: w)
                    .opacity(wrapPanelsRevealed >= 3 ? 1 : 0)
                    .scaleEffect(wrapPanelsRevealed >= 3 ? 1 : 0.9)

                // Bottom row: Year | Lifetime
                HStack(spacing: pad) {
                    wrapYearPanel(width: panelW, height: h * 0.28, screenWidth: w)
                        .opacity(wrapPanelsRevealed >= 4 ? 1 : 0)
                        .scaleEffect(wrapPanelsRevealed >= 4 ? 1 : 0.9)

                    wrapLifetimePanel(width: panelW, height: h * 0.28, screenWidth: w)
                        .opacity(wrapPanelsRevealed >= 5 ? 1 : 0)
                        .scaleEffect(wrapPanelsRevealed >= 5 ? 1 : 0.9)
                }
                Spacer(minLength: 0)
            }
            .padding(pad)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Wrap Sub-Panels with Mini Visualizations

    @ViewBuilder
    private func wrapWeekPanel(width: CGFloat, height: CGFloat, screenWidth: CGFloat) -> some View {
        let barW = width * 0.70
        let barH = max(6, height * 0.04)
        let screenRatio = min(CGFloat(weeklyHours) / 168.0, 1.0)

        ZStack {
            Image("Stats Panel Blue").resizable().frame(width: width, height: height)

            VStack(spacing: 2) {
                Text("Every week")
                    .font(.custom("ComicNeue-Regular", size: wrapBodyFont(width: screenWidth)))
                    .foregroundColor(.white)
                    .comicOutline()

                Spacer(minLength: 0)

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: barH / 2)
                        .fill(Color.white)
                        .frame(width: barW, height: barH)
                    if screenRatio > 0 {
                        RoundedRectangle(cornerRadius: barH / 2)
                            .fill(comicRed)
                            .frame(width: barW * screenRatio, height: barH)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: barH / 2)
                        .stroke(Color.black, lineWidth: 2)
                )

                Spacer(minLength: 0)

                Text("\(weeklyHours)")
                    .font(.custom("ComicNeue-Bold", size: wrapBigFont(width: screenWidth)))
                    .foregroundColor(.white)
                    .comicOutline()
                Text("hours staring\nat screen")
                    .font(.custom("ComicNeue-Regular", size: wrapBodyFont(width: screenWidth)))
                    .foregroundColor(.white)
                    .comicOutline()
            }
            .multilineTextAlignment(.center)
            .padding(10)
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black, lineWidth: 3))
    }

    @ViewBuilder
    private func wrapMonthPanel(width: CGFloat, height: CGFloat, screenWidth: CGFloat) -> some View {
        let cols = 6
        let tileSpacing: CGFloat = 2
        let gridPad: CGFloat = width * 0.25
        let usableW = width - gridPad * 2
        let tileSize = (usableW - tileSpacing * CGFloat(cols - 1)) / CGFloat(cols)
        let fullRedDays = Int(monthlyDays)
        let partialFraction = CGFloat(monthlyDays - floor(monthlyDays))

        ZStack {
            Image("Stats Panel Yellow").resizable().frame(width: width, height: height)

            VStack(spacing: 2) {
                Text("Each month")
                    .font(.custom("ComicNeue-Regular", size: wrapBodyFont(width: screenWidth)))
                    .foregroundColor(.white)
                    .comicOutline()

                Spacer(minLength: 0)

                let gridColumns = Array(repeating: GridItem(.fixed(tileSize), spacing: tileSpacing), count: cols)
                LazyVGrid(columns: gridColumns, spacing: tileSpacing) {
                    ForEach(0..<30, id: \.self) { day in
                        ZStack {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white)
                                .frame(width: tileSize, height: tileSize)
                            if day < fullRedDays {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(comicRed)
                                    .frame(width: tileSize, height: tileSize)
                            } else if day == fullRedDays && partialFraction > 0 {
                                HStack(spacing: 0) {
                                    Rectangle()
                                        .fill(comicRed)
                                        .frame(width: tileSize * partialFraction)
                                    Spacer(minLength: 0)
                                }
                                .frame(width: tileSize, height: tileSize)
                                .clipShape(RoundedRectangle(cornerRadius: 2))
                            }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(Color.black, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, gridPad)

                Spacer(minLength: 0)

                Text(String(format: "%.1f", monthlyDays))
                    .font(.custom("ComicNeue-Bold", size: wrapBigFont(width: screenWidth)))
                    .foregroundColor(.white)
                    .comicOutline()
                Text("days erased")
                    .font(.custom("ComicNeue-Regular", size: wrapBodyFont(width: screenWidth)))
                    .foregroundColor(.white)
                    .comicOutline()
            }
            .multilineTextAlignment(.center)
            .padding(10)
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black, lineWidth: 3))
    }

    @ViewBuilder
    private func wrapYearPanel(width: CGFloat, height: CGFloat, screenWidth: CGFloat) -> some View {
        let arcSize = min(width * 0.44, height * 0.34)
        let lineW: CGFloat = arcSize * 0.12
        let ratio = min(yearlyWeeks / 52.0, 1.0)

        ZStack {
            Image("Stats Panel Green").resizable().frame(width: width, height: height)

            VStack(spacing: 2) {
                Text("Per year")
                    .font(.custom("ComicNeue-Regular", size: wrapBodyFont(width: screenWidth)))
                    .foregroundColor(.white)
                    .comicOutline()

                Spacer(minLength: 0)

                ZStack {
                    Circle()
                        .stroke(Color.white, lineWidth: lineW)
                        .frame(width: arcSize, height: arcSize)
                    Circle()
                        .trim(from: 0, to: ratio)
                        .stroke(comicRed, style: StrokeStyle(lineWidth: lineW, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: arcSize, height: arcSize)
                    Circle()
                        .stroke(Color.black, lineWidth: 1.5)
                        .frame(width: arcSize + lineW, height: arcSize + lineW)
                    Circle()
                        .stroke(Color.black, lineWidth: 1.5)
                        .frame(width: arcSize - lineW, height: arcSize - lineW)
                }
                .padding(lineW / 2 + 4)

                Spacer(minLength: 0)

                Text(String(format: "%.1f", yearlyWeeks))
                    .font(.custom("ComicNeue-Bold", size: wrapBigFont(width: screenWidth)))
                    .foregroundColor(.white)
                    .comicOutline()
                Text("weeks gone")
                    .font(.custom("ComicNeue-Regular", size: wrapBodyFont(width: screenWidth)))
                    .foregroundColor(.white)
                    .comicOutline()
            }
            .multilineTextAlignment(.center)
            .padding(10)
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black, lineWidth: 3))
    }

    @ViewBuilder
    private func wrapLifetimePanel(width: CGFloat, height: CGFloat, screenWidth: CGFloat) -> some View {
        let totalFigures = 12
        let yearsPerFigure = 59.0 / Double(totalFigures)
        let lostFigures = lifetimeYears / yearsPerFigure
        let figSize = width * 0.09

        ZStack {
            Image("Stats Panel Blue").resizable().frame(width: width, height: height)

            VStack(spacing: 2) {
                Text("A lifetime")
                    .font(.custom("ComicNeue-Regular", size: wrapBodyFont(width: screenWidth)))
                    .foregroundColor(.white)
                    .comicOutline()

                Spacer(minLength: 0)

                // Mini silhouettes — 2 rows of 6
                VStack(spacing: 4) {
                    ForEach(0..<2, id: \.self) { row in
                        HStack(spacing: width * 0.012) {
                            ForEach(0..<6, id: \.self) { col in
                                let index = row * 6 + col
                                let isLost = Double(index) < lostFigures
                                Image(systemName: "figure.stand")
                                    .font(.system(size: figSize))
                                    .foregroundColor(isLost ? comicRed : .white)
                                    .comicOutline()
                            }
                        }
                    }
                }

                Spacer(minLength: 0)

                Text(String(format: "%.1f", lifetimeYears))
                    .font(.custom("ComicNeue-Bold", size: wrapBigFont(width: screenWidth)))
                    .foregroundColor(.white)
                    .comicOutline()
                Text("years lost")
                    .font(.custom("ComicNeue-Regular", size: wrapBodyFont(width: screenWidth)))
                    .foregroundColor(.white)
                    .comicOutline()
            }
            .multilineTextAlignment(.center)
            .padding(10)
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black, lineWidth: 3))
    }

    @ViewBuilder
    private func wrapContainerPanel(width: CGFloat, height: CGFloat, screenWidth: CGFloat) -> some View {
        ZStack {
            Image("Stats Panel Red")
                .resizable()
                .frame(width: width, height: height)

            HStack(spacing: 0) {
                Image("Dr Doomscroll Pose 3")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width * 0.40, height: height * 0.90)
                    .offset(y: height * 0.05)

                VStack(spacing: 8) {
                    Text("No rewind.")
                        .font(.custom("ComicNeue-Bold", size: wrapBigFont(width: screenWidth)))
                    Text("No refund.")
                        .font(.custom("ComicNeue-Bold", size: wrapBigFont(width: screenWidth)))
                    Text("Just gone.")
                        .font(.custom("ComicNeue-Bold", size: wrapBigFont(width: screenWidth)))
                }
                .foregroundColor(.white)
                .comicOutline()
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
        return max(16, 24 * s)
    }

    private func wrapBigFont(width: CGFloat) -> CGFloat {
        let s = width / 834
        return max(36, 60 * s)
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Panel 6: Ending
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    @ViewBuilder
    private func endingPanelFull(w: CGFloat, h: CGFloat) -> some View {
        let cardPad: CGFloat = w * 0.06

        ZStack {
            Image("Stats Panel Green")
                .resizable()
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: h * 0.03) {
                    Spacer().frame(height: h * 0.06)

                    // Yellow header text
                    Text("DeFeedted today. But tomorrow? That's up to you. Three things stand between you and the feed.")
                        .font(.custom("ComicNeue-Bold", size: captionFont(width: w)))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .frame(maxWidth: w * 0.85)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.yellow)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black, lineWidth: 3)
                                )
                        )

                    Spacer().frame(height: h * 0.02)

                    // Card 1
                    endingCard(
                        number: "1",
                        title: "Be intentional before you open your phone.",
                        body: "Ask yourself why. Boredom, avoidance, or habit — before your thumb moves.",
                        w: w, cardPad: cardPad
                    )

                    // Card 2
                    endingCard(
                        number: "2",
                        title: "Create more than you consume.",
                        body: "Write, build, cook, draw — anything that produces something instead of just absorbing it.",
                        w: w, cardPad: cardPad
                    )

                    // Card 3
                    endingCard(
                        number: "3",
                        title: "Let boredom happen.",
                        body: "The urge to scroll peaks in 2 minutes and passes. Sit with it once. It gets easier.",
                        w: w, cardPad: cardPad
                    )

                    // New Issue button
                    Button(action: {
                        restartApp()
                    }) {
                        Text("NEW ISSUE")
                            .font(.custom("ComicNeue-Bold", size: captionFont(width: w)))
                            .foregroundColor(.black)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color.yellow)
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.black, lineWidth: 3)
                                    )
                            )
                    }

                    Spacer().frame(height: h * 0.06)
                }
                .frame(maxWidth: .infinity)
            }
            .opacity(endingRevealed ? 1 : 0)
        }
    }

    @ViewBuilder
    private func endingCard(number: String, title: String, body: String, w: CGFloat, cardPad: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(number). \(title)")
                .font(.custom("ComicNeue-Bold", size: bodyFont(width: w) * 1.1))
                .foregroundColor(.black)
            Text(body)
                .font(.custom("ComicNeue-Regular", size: bodyFont(width: w)))
                .foregroundColor(.black)
        }
        .padding(18)
        .frame(maxWidth: w * 0.85, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black, lineWidth: 3)
                )
        )
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
        case 1...14:  return "That's a full episode of a show you actually chose to watch. Or a proper meal cooked from scratch."
        case 15...28: return "That's a gym session, a shower, and still time left to call someone you've been meaning to call."
        case 29...42: return "That's a full school project done before the deadline. Without the panic."
        default:      return "That's an entire part-time shift. You worked for free, for the algorithm."
        }
    }

    private func monthAlternative() -> String {
        if monthlyDays < 1 { return "A proper sleep-in Saturday. Breakfast included." }
        if monthlyDays < 3 { return "Every overdue errand. Done. Plus a night out you didn't have to cancel." }
        if monthlyDays < 5 { return "A short trip somewhere you keep saying you'll go. You could have gone." }
        return "A full work week. Handed to a screen. For free."
    }

    private func yearAlternative() -> String {
        if yearlyWeeks < 1 { return "Every birthday you forgot to plan for. Planned. Every friend you've been meaning to catch up with. Caught up with." }
        if yearlyWeeks < 3 { return "A holiday. A real one. Flights, hotel, memories, not screenshots." }
        if yearlyWeeks < 5 { return "The side project you've been drafting in your notes app for two years. Actually started. Possibly finished." }
        return "Enough time to get genuinely good at something. Not watched-a-tutorial good. Actually good."
    }

    private func lifetimeAlternative() -> String {
        if lifetimeYears < 1 { return "Time to finish every book you've bought and never opened." }
        if lifetimeYears < 3 { return "Time to raise a child through their first two years of life. Or build a business from zero to running." }
        return "Long enough to learn a language, move to a new city, fall in love, and still have time left over."
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
