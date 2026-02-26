import SwiftUI

/// Loads a PNG image from the app bundle.
///
/// The Package.swift uses `.copy("Assets")` so the entire `Assets/` directory
/// is preserved as-is inside the bundle. Images are found via subdirectory lookup.
///
/// Usage:
///   `BundleImage("Onboarding Background")`           — looks in Assets/
///   `BundleImage("Blue", subdirectory: "Assets/Background")` — looks in Assets/Background/
struct BundleImage: View {
    let name: String
    let subdirectory: String
    var contentMode: ContentMode = .fill

    init(_ name: String, subdirectory: String = "Assets", contentMode: ContentMode = .fill) {
        self.name = name
        self.subdirectory = subdirectory
        self.contentMode = contentMode
    }

    var body: some View {
        if let uiImage = Self.loadImage(name: name, subdirectory: subdirectory) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } else {
            // Debug placeholder — visible during development
            Color.red.opacity(0.3)
                .overlay(
                    VStack(spacing: 4) {
                        Text("Missing: \(name)")
                            .font(.caption).bold()
                        Text("in: \(subdirectory)")
                            .font(.caption2)
                        Text("bundle: \(Bundle.main.bundlePath.suffix(40))")
                            .font(.caption2)
                    }
                    .foregroundColor(.white)
                    .padding(8)
                )
        }
    }

    /// Tries multiple bundle lookup strategies to find the image.
    static func loadImage(name: String, subdirectory: String) -> UIImage? {
        let bundle = Bundle.main

        // Strategy 1: Direct subdirectory lookup (works with .copy("Assets"))
        if let url = bundle.url(forResource: name, withExtension: "png", subdirectory: subdirectory),
           let img = UIImage(contentsOfFile: url.path) {
            return img
        }

        // Strategy 2: No subdirectory — SPM might flatten resources
        if let url = bundle.url(forResource: name, withExtension: "png"),
           let img = UIImage(contentsOfFile: url.path) {
            return img
        }

        // Strategy 3: UIImage(named:) — searches asset catalogs & bundle
        if let img = UIImage(named: name) {
            return img
        }

        // Strategy 4: Walk the bundle tree to find the file anywhere
        if let resourcePath = bundle.resourcePath {
            let target = "\(name).png"
            let fm = FileManager.default
            if let items = fm.enumerator(atPath: resourcePath) {
                while let path = items.nextObject() as? String {
                    let filename = (path as NSString).lastPathComponent
                    if filename == target {
                        let fullPath = (resourcePath as NSString).appendingPathComponent(path)
                        if let img = UIImage(contentsOfFile: fullPath) {
                            return img
                        }
                    }
                }
            }
        }

        // Strategy 5: Try constructing path manually from bundle root
        if let resourcePath = bundle.resourcePath {
            let manualPath = (resourcePath as NSString).appendingPathComponent("\(subdirectory)/\(name).png")
            if let img = UIImage(contentsOfFile: manualPath) {
                return img
            }
        }

        print("⚠️ BundleImage: Failed to load '\(name).png' — tried subdirectory '\(subdirectory)' and all fallbacks")
        return nil
    }
}
