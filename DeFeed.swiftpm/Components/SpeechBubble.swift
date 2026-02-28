import SwiftUI

// MARK: - Tail Direction

/// Where the speech-bubble tail points.
enum BubbleTailDirection {
    case bottomLeft
    case bottomRight
    case bottomCenter
}

// MARK: - SpeechBubbleShape

/// A classic comic-book speech bubble drawn entirely in SwiftUI.
/// Rounded rectangle body with a fixed-size triangular tail.
struct SpeechBubbleShape: Shape {
    var cornerRadius: CGFloat = 16
    var tailDirection: BubbleTailDirection = .bottomLeft
    /// Fixed tail height in points.
    var tailHeight: CGFloat = 14
    /// Fixed tail base width in points.
    var tailWidth: CGFloat = 20
    /// Whether this is for stroke only (no overlap to avoid visible seam line)
    var isStroke: Bool = false

    func path(in rect: CGRect) -> Path {
        let tailH = min(tailHeight, rect.height * 0.25)
        let tailW = min(tailWidth, rect.width * 0.25)
        // Body occupies the top portion; tail hangs below.
        let bodyRect = CGRect(x: rect.minX, y: rect.minY,
                              width: rect.width, height: rect.height - tailH)
        var path = Path(roundedRect: bodyRect, cornerRadius: cornerRadius)

        // Tail triangle — slight overlap for fill to avoid seam, none for stroke
        let tailBaseY = isStroke ? bodyRect.maxY : bodyRect.maxY - 1
        let tailTipY = rect.maxY

        let tailBaseX: CGFloat
        let tailTipX: CGFloat

        switch tailDirection {
        case .bottomLeft:
            tailBaseX = cornerRadius + 6
            tailTipX = cornerRadius
        case .bottomRight:
            tailBaseX = rect.width - cornerRadius - tailW - 6
            tailTipX = rect.width - cornerRadius
        case .bottomCenter:
            tailBaseX = (rect.width - tailW) / 2
            tailTipX = rect.width / 2
        }

        var tail = Path()
        tail.move(to: CGPoint(x: tailBaseX, y: tailBaseY))
        tail.addLine(to: CGPoint(x: tailTipX, y: tailTipY))
        tail.addLine(to: CGPoint(x: tailBaseX + tailW, y: tailBaseY))
        tail.closeSubpath()

        path.addPath(tail)
        return path
    }
}

// MARK: - SpeechBubbleView

/// A ready-to-use speech bubble with white fill, black border, and content.
/// Padding is uniform on all sides; the tail extends below the padded area.
struct SpeechBubbleView<Content: View>: View {
    var tailDirection: BubbleTailDirection = .bottomLeft
    var cornerRadius: CGFloat = 16
    var borderWidth: CGFloat = 3
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(14) // uniform padding on all sides
            .padding(.bottom, 14) // extra space reserved for the tail
            .background(
                SpeechBubbleShape(
                    cornerRadius: cornerRadius,
                    tailDirection: tailDirection,
                    isStroke: false
                )
                .fill(Color.white)
            )
            .overlay(
                SpeechBubbleShape(
                    cornerRadius: cornerRadius,
                    tailDirection: tailDirection,
                    isStroke: true
                )
                .stroke(Color.black, lineWidth: borderWidth)
            )
    }
}
