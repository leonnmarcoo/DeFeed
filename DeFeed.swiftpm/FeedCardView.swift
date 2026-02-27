import SwiftUI

/// A single feed card's content area (Cards 1–4).
///
/// Shows the content image, bottom shadow gradient, caption, and action buttons.
/// The header (character, dialogue, HP) is handled by the parent FeedView.
struct FeedCardView: View {
    let card: CardData

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // MARK: - Content Image
                Image(card.contentImage)
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .frame(width: w * 0.92, height: h * 0.95)
                    .position(x: w * 0.50, y: h * 0.48)

                // MARK: - Action Buttons (right side)
                actionButtons(w: w, h: h)

                // MARK: - Social Media Caption (bottom-left)
                VStack(alignment: .leading, spacing: 2) {
                    Text(card.username)
                        .font(.custom("ComicNeue-Bold", size: captionFontSize(width: w)))
                        .foregroundColor(.white)
                    Text(card.caption)
                        .font(.custom("ComicNeue-Regular", size: captionFontSize(width: w)))
                        .foregroundColor(.white)
                        .lineLimit(3)
                }
                .frame(width: w * 0.60, alignment: .leading)
                .position(x: w * 0.37, y: h * 0.87)
            }
        }
    }

    // MARK: - Action Buttons Column

    @ViewBuilder
    private func actionButtons(w: CGFloat, h: CGFloat) -> some View {
        let buttonSize: CGFloat = w * 0.077
        VStack(spacing: w * 0.04) {
            Image(systemName: "heart.fill")
                .font(.system(size: buttonSize * 0.7))
                .foregroundColor(.white)
                .frame(width: buttonSize, height: buttonSize)

            Image(systemName: "flame.fill")
                .font(.system(size: buttonSize * 0.7))
                .foregroundColor(.white)

            Image(systemName: "bubble.left.fill")
                .font(.system(size: buttonSize * 0.7))
                .foregroundColor(.white)

            Image(systemName: "arrowshape.turn.up.right.fill")
                .font(.system(size: buttonSize * 0.7))
                .foregroundColor(.white)
        }
        .position(x: w * 0.90, y: h * 0.68)
    }

    // MARK: - Font Sizing

    private func captionFontSize(width: CGFloat) -> CGFloat {
        let s = width / 834
        return max(12, 18 * s)
    }
}
