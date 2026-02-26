import SwiftUI

/// Data model for a single feed card (Cards 1–4).
struct CardData: Identifiable {
    let id: Int
    let contentImage: String       // Asset name inside Assets/
    let dialogue: String           // Dr. Doomscroll's speech bubble text
    let username: String           // Social media handle
    let caption: String            // Post caption text
    let hpGain: Double             // How much villain HP this card adds

    /// All 4 regular feed cards.
    static let all: [CardData] = [
        CardData(
            id: 1,
            contentImage: "Feed Content 1",
            dialogue: "You compared yourself to this. It was never real.",
            username: "@DailyDreamer",
            caption: "My authentic morning routine #blessed #dayinmylife\n#viral #fyp",
            hpGain: 20
        ),
        CardData(
            id: 2,
            contentImage: "Feed Content 2",
            dialogue: "Doomscrolling feeds anxiety, not awareness.",
            username: "@PanicScroll",
            caption: "Did you know? Staying informed means constant fear #doomscroll #anxiety #news #fyp",
            hpGain: 20
        ),
        CardData(
            id: 3,
            contentImage: "Feed Content 3",
            dialogue: "Everyone looks busy. Everyone feels alone. Scrolling together, separately",
            username: "@RelatableFeels",
            caption: "POV: Surrounded by people but totally alone. #connection #lonely #socialmedia #fyp",
            hpGain: 20
        ),
        CardData(
            id: 4,
            contentImage: "Feed Content 4",
            dialogue: "Your emotional state is a product. Your engagement is the revenue.",
            username: "@TruthSeeker",
            caption: "The things they don't tell you: Your feelings are their profit #algorithm #data #privacy #fyp",
            hpGain: 20
        ),
    ]
}
