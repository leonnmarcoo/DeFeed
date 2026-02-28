import SwiftUI

// MARK: - Comic Text Outline

extension View {
    func comicOutline(color: Color = .black, radius: CGFloat = 0, width: CGFloat = 1.5) -> some View {
        self
            .shadow(color: color, radius: radius, x: width, y: 0)
            .shadow(color: color, radius: radius, x: -width, y: 0)
            .shadow(color: color, radius: radius, x: 0, y: width)
            .shadow(color: color, radius: radius, x: 0, y: -width)
            .shadow(color: color, radius: radius, x: width, y: width)
            .shadow(color: color, radius: radius, x: -width, y: -width)
            .shadow(color: color, radius: radius, x: width, y: -width)
            .shadow(color: color, radius: radius, x: -width, y: width)
    }
}
