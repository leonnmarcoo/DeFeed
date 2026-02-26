import SwiftUI
import CoreText

@main
struct MyApp: App {
    @StateObject private var appState = AppState()

    init() {
        Self.registerCustomFonts()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }

    /// Registers bundled ComicNeue .ttf fonts so they can be used with `.custom(...)`.
    private static func registerCustomFonts() {
        let fontNames = ["ComicNeue-Regular", "ComicNeue-Bold"]
        for fontName in fontNames {
            if let url = Bundle.main.url(forResource: fontName, withExtension: "ttf", subdirectory: "Assets")
                ?? Bundle.main.url(forResource: fontName, withExtension: "ttf") {
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
    }
}
