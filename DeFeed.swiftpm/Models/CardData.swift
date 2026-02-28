import SwiftUI

struct CardData: Identifiable {
    let id: Int
    let contentImage: String
    let dialogue: String
    let username: String
    let caption: String
    let hpGain: Double

    static let all: [CardData] = [
        CardData(
            id: 1,
            contentImage: "Feed Content 1",
            dialogue: "You compared yourself to this. It was never real. Now, scroll.",
            username: "@DailyDreamer",
            caption: "My authentic morning routine #blessed #dayinmylife\n#viral #fyp",
            hpGain: 20
        ),
        CardData(
            id: 2,
            contentImage: "Feed Content 2",
            dialogue: "Doomscrolling feeds anxiety, not awareness. Now, scroll.",
            username: "@PanicScroll",
            caption: "Did you know? Staying informed means constant fear #doomscroll #anxiety #news #fyp",
            hpGain: 20
        ),
        CardData(
            id: 3,
            contentImage: "Feed Content 3",
            dialogue: "Everyone looks busy, but still, everyone feels alone. Now, scroll.",
            username: "@RelatableFeels",
            caption: "POV: Surrounded by people but totally alone. #connection #lonely #socialmedia #fyp",
            hpGain: 20
        ),
        CardData(
            id: 4,
            contentImage: "Feed Content 4",
            dialogue: "Your emotional state is a product. Your engagement is the revenue. Now, scroll.",
            username: "@TruthSeeker",
            caption: "The things they don't tell you: Your feelings are their profit #algorithm #data #privacy #fyp",
            hpGain: 20
        ),
    ]
}
