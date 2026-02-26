import SwiftUI

/// A view that reveals text one character at a time with a typewriter effect.
struct TypewriterText: View {
    let fullText: String
    let font: Font
    let color: Color
    let characterDelay: Duration
    var onComplete: (() -> Void)?

    @State private var displayedText: String = ""
    @State private var isAnimating: Bool = false

    init(
        _ text: String,
        font: Font = .custom("ComicNeue-Regular", size: 24),
        color: Color = .black,
        characterDelay: Duration = .milliseconds(40),
        onComplete: (() -> Void)? = nil
    ) {
        self.fullText = text
        self.font = font
        self.color = color
        self.characterDelay = characterDelay
        self.onComplete = onComplete
    }

    var body: some View {
        Text(displayedText)
            .font(font)
            .foregroundColor(color)
            .onAppear {
                guard !isAnimating else { return }
                isAnimating = true
                startTyping()
            }
    }

    private func startTyping() {
        displayedText = ""
        Task { @MainActor in
            for character in fullText {
                displayedText.append(character)
                try? await Task.sleep(for: characterDelay)
            }
            onComplete?()
        }
    }
}
