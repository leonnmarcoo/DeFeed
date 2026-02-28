import SwiftUI

struct HPBarView: View {
    let hp: Double
    let maxHP: Double = 100

    private var fillFraction: Double {
        min(max(hp / maxHP, 0), 1)
    }

    private var barColor: Color {
        if fillFraction < 0.4 {
            return Color(red: 0.314, green: 0.588, blue: 0.298)
        } else if fillFraction < 0.7 {
            return .yellow
        } else {
            return .red
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(.white)
                Circle()
                    .stroke(Color.black, lineWidth: 3)
                Image(systemName: "heart.fill")
                    .font(.title2)
                    .foregroundColor(Color(red: 0.85, green: 0.13, blue: 0.14))
            }
            .frame(width: 50, height: 50)

            GeometryReader { geo in
                let barWidth = geo.size.width
                let barHeight = geo.size.height

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: barHeight / 2)
                        .fill(.white)
                        .frame(width: barWidth, height: barHeight)

                    RoundedRectangle(cornerRadius: barHeight / 2)
                        .fill(barColor)
                        .frame(width: barWidth * fillFraction, height: barHeight)
                        .animation(.easeInOut(duration: 0.6), value: fillFraction)

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
