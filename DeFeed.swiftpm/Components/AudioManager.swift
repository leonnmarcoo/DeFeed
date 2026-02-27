import AVFoundation
import SwiftUI

/// Manages looping background music with crossfade transitions between tracks.
@MainActor
final class AudioManager: ObservableObject {
    static let shared = AudioManager()

    /// The two players used for crossfading.
    private var activePlayer: AVAudioPlayer?
    private var incomingPlayer: AVAudioPlayer?

    /// Tracks which asset is currently playing to avoid redundant switches.
    private var currentTrackName: String?

    /// Duration of the crossfade in seconds.
    private let crossfadeDuration: TimeInterval = 1.5

    /// Master volume for music (0–1).
    private let musicVolume: Float = 0.45

    private var fadeTimer: Timer?

    private init() {
        // Configure audio session for background music mixing
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AudioManager: Failed to configure audio session — \(error)")
        }
    }

    // MARK: - Public API

    /// Determines the correct track for a given app phase and crossfades to it.
    func playMusic(for phase: AppPhase) {
        let trackName = trackName(for: phase)

        // Don't restart the same track
        guard trackName != currentTrackName else { return }

        crossfade(to: trackName)
    }

    /// Stops all music immediately.
    func stopAll() {
        fadeTimer?.invalidate()
        fadeTimer = nil
        activePlayer?.stop()
        incomingPlayer?.stop()
        activePlayer = nil
        incomingPlayer = nil
        currentTrackName = nil
    }

    // MARK: - Private Helpers

    /// Maps each app phase to an asset catalog dataset name.
    private func trackName(for phase: AppPhase) -> String {
        switch phase {
        case .onboarding:
            return "Onboarding music"
        case .feed:
            return "Act 1"
        case .input, .statistics, .defeat:
            return "Act 2"
        }
    }

    /// Loads an AVAudioPlayer from a dataset in the asset catalog.
    private func loadPlayer(named name: String) -> AVAudioPlayer? {
        guard let asset = NSDataAsset(name: name) else {
            print("AudioManager: NSDataAsset '\(name)' not found")
            return nil
        }
        do {
            let player = try AVAudioPlayer(data: asset.data)
            player.numberOfLoops = -1           // Loop forever
            player.prepareToPlay()
            return player
        } catch {
            print("AudioManager: Failed to create player for '\(name)' — \(error)")
            return nil
        }
    }

    /// Crossfades from the active player to a new track.
    private func crossfade(to trackName: String) {
        // Cancel any ongoing fade
        fadeTimer?.invalidate()
        fadeTimer = nil

        // Prepare the incoming player
        guard let newPlayer = loadPlayer(named: trackName) else { return }
        newPlayer.volume = 0
        newPlayer.play()
        incomingPlayer = newPlayer

        let oldPlayer = activePlayer
        let steps = 30
        let interval = crossfadeDuration / Double(steps)
        var tick = 0

        fadeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }

                tick += 1
                let progress = Float(tick) / Float(steps)

                // Fade in new, fade out old
                newPlayer.volume = progress * self.musicVolume
                oldPlayer?.volume = (1.0 - progress) * self.musicVolume

                if tick >= steps {
                    self.fadeTimer?.invalidate()
                    self.fadeTimer = nil
                    oldPlayer?.stop()
                    self.activePlayer = newPlayer
                    self.incomingPlayer = nil
                    self.currentTrackName = trackName
                }
            }
        }

        // Update track name immediately so rapid phase changes don't double-trigger
        currentTrackName = trackName
    }
}
