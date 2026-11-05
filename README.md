<div align="center">
  <img src="DeFeed.swiftpm/Assets.xcassets/AppIcon.appiconset/App%20Icon.png" alt="DeFeed app icon: Dr. Doomscroll grinning over steepled fingers" width="200"/>
  <h1>DeFeed 📱💥</h1>
</div>

> **Every scroll heals the villain.**  
> A comic-book iOS app where you feed Dr. Doomscroll, then find out how much of your life the feed will cost you.

---

## 🦹 What Is DeFeed?

**DeFeed** is a short interactive comic for iPhone and iPad. It looks like a social feed, but there's a villain living inside it. Each post you scroll past makes **Dr. Doomscroll** stronger, and at full health the villain turns around and shows you the bill: your screen time, added up over a lifetime.

No accounts, no network calls, no Screen Time access. The only number DeFeed uses is the one you confess on the slider, and it isn't saved anywhere.

---

## 📖 How It Plays

| Stage | What happens |
| --- | --- |
| 🟢 **Onboarding** | Meet Dr. Doomscroll through typewriter speech bubbles. Tap to continue. |
| 🔴 **The Feed** | Swipe through four satirical posts. Each one adds 20 HP to the villain's health bar, with narration on what the feed does to you: comparison, anxiety, loneliness, and your emotions sold as a product. |
| 💥 **Full HP** | Scroll past the last post and the health bar hits 100 HP. _"Now that my health is full, you've met the real villain."_ |
| 🔵 **The Confession** | Drag the slider to admit your daily screen time, from 1 to 10 hours. |
| 🎨 **Doomscroll Wrap** | Your hours turn into comic panels for a week, a month, a year, and a lifetime, then one wrap-up page. _"No rewind. No refund. Just gone."_ |
| 🟢 **The Ending** | Three habits to fight back with, plus a **New Issue** button to start over. |

Along the way you get ink-wipe page transitions with haptics, music that crossfades between three tracks, and Comic Neue lettering throughout.

---

## 🧮 The Math Behind the Wrap

| Panel | Formula | At 3 hours a day |
| --- | --- | --- |
| Every week | hours × 7 | **21** hours |
| Each month | hours × 30 ÷ 24 | **3.8** days |
| Every year | hours × 365 ÷ 168 | **6.5** weeks |
| A lifetime | hours × 59 ÷ 24 | **7.4** years |

The lifetime panel assumes you scroll from age 13 to age 72.

---

## 🎨 From the Comic

The four posts in the feed, plus Dr. Doomscroll at full HP. These are the app's own art assets.

<div align="center">
  <img src="DeFeed.swiftpm/Assets.xcassets/Feed%20Content%201.imageset/Feed%20Content%201.png" alt="Feed post: a child watches a perfect life on a phone screen, propped up by a fake stage set" width="200"/>
  <img src="DeFeed.swiftpm/Assets.xcassets/Feed%20Content%202.imageset/Feed%20Content%202%20PNG.png" alt="Feed post: a person on their phone caught in a tornado of alarming headlines" width="200"/>
  <img src="DeFeed.swiftpm/Assets.xcassets/Feed%20Content%203.imageset/Feed%20Content%203.png" alt="Feed post: four people on a bench, each sealed inside their own cracked phone" width="200"/>
  <img src="DeFeed.swiftpm/Assets.xcassets/Feed%20Content%204.imageset/Feed%20Content%204.png" alt="Feed post: a claw pulls the heart from a person on their phone and turns it into revenue" width="200"/>
</div>

<div align="center">
  <img src="DeFeed.swiftpm/Assets.xcassets/Dr%20Doomscroll%20Pose%203.imageset/Dr%20Doomscroll%20Pose%203.png" alt="Dr. Doomscroll laughing and holding a glowing phone in the air" width="320"/>
</div>

---

## 🛠️ Tech Stack

| | |
| --- | --- |
| **Language** | Swift 6 |
| **UI** | SwiftUI, targeting iOS 16+ on iPhone and iPad |
| **Audio** | AVFoundation |
| **Fonts** | Comic Neue, registered with Core Text |
| **Packaging** | Swift Playgrounds app package (`.swiftpm`) |

---

## 🚀 How to Run

You'll need a Mac with Xcode, or Swift Playgrounds.

```bash
git clone https://github.com/leonnmarcoo/DeFeed.git
open DeFeed/DeFeed.swiftpm
```

Pick an iPhone or iPad simulator and press **⌘R**. To install on a real device, swap in your own team and bundle identifier in `Package.swift`.

> ⚠️ **Building with Xcode 27?** The Swift 6 compiler stops at `Components/AudioManager.swift:96` with `sending 'tick' risks causing data races`. Until that's fixed, change the last setting in `Package.swift` to `swiftLanguageVersions: [.version("5")]` and it builds.

---

## 🗂️ Project Structure

```
DeFeed.swiftpm/
├── MyApp.swift, ContentView.swift   App entry and page transitions
├── Models/                          App state and the feed posts
├── Views/                           Onboarding, feed, slider, and the Wrap
├── Components/                      HP bar, speech bubbles, typewriter text, audio
├── Assets.xcassets/                 Art and music
└── Font/                            Comic Neue
```

---

<div align="center">
  Made by <a href="https://github.com/leonnmarcoo">Leon Marco Devela</a>. Now go touch grass. 🌱
</div>
