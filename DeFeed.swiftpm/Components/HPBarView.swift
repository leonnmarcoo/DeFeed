import SwiftUI

/// The villain HP bar overlay — a comic book power meter.
///
/// Layout from Figma:
/// - HP Icon (heart in circle, 60×60) on the left
/// - Health bar (rounded right end, white background with green fill) to the right
struct HPBarView: View {
    let hp: Double           // 0...100
    let maxHP: Double = 100

    /// Animated fill fraction
    private var fillFraction: Double {
        min(max(hp / maxHP, 0), 1)
    }

    /// Bar color shifts from green → yellow → red as HP increases
    private var barColor: Color {
        if fillFraction < 0.4 {
            return Color(red: 0.314, green: 0.588, blue: 0.298) // #50964C
        } else if fillFraction < 0.7 {
            return .yellow
        } else {
            return .red
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            // HP Icon — heart in a white circle
            ZStack {
                Circle()
                    .fill(.white)
                Circle()
                    .stroke(Color.black, lineWidth: 3)
                Image(systemName: "heart.fill")
                    .font(.title2)
                    .foregroundColor(Color(red: 0.85, green: 0.13, blue: 0.14)) // #D92025
            }
            .frame(width: 50, height: 50)

            // Health bar
            GeometryReader { geo in
                let barWidth = geo.size.width
                let barHeight = geo.size.height

                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: barHeight / 2)
                        .fill(.white)
                        .frame(width: barWidth, height: barHeight)

                    // Fill
                    RoundedRectangle(cornerRadius: barHeight / 2)
                        .fill(barColor)
                        .frame(width: barWidth * fillFraction, height: barHeight)
                        .animation(.easeInOut(duration: 0.6), value: fillFraction)

                    // Black outline
                    RoundedRectangle(cornerRadius: barHeight / 2)
                        .stroke(Color.black, lineWidth: 3)
                        .frame(width: barWidth, height: barHeight)
                }
            }
            .frame(height: 24)
        }
        .padding(.horizontal, 4)
    }
}
