@preconcurrency import AVFoundation
import SwiftUI

@MainActor
final class AudioManager: ObservableObject {
    static let shared = AudioManager()

    private var activePlayer: AVAudioPlayer?
    private var incomingPlayer: AVAudioPlayer?

    private var currentTrackName: String?

    private let crossfadeDuration: TimeInterval = 1.5

    private let musicVolume: Float = 0.45

    private var fadeTimer: Timer?

    private init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AudioManager: Failed to configure audio session — \(error)")
        }
    }

    // MARK: - Public API

    func playMusic(for phase: AppPhase) {
        let trackName = trackName(for: phase)

        guard trackName != currentTrackName else { return }

        crossfade(to: trackName)
    }

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

    private func trackName(for phase: AppPhase) -> String {
        switch phase {
        case .onboarding:
            return "Onboarding music"
        case .feed:
            return "Act 1"
        case .input, .statistics:
            return "Act 2"
        }
    }

    private func loadPlayer(named name: String) -> AVAudioPlayer? {
        guard let asset = NSDataAsset(name: name) else {
            print("AudioManager: NSDataAsset '\(name)' not found")
            return nil
        }
        do {
            let player = try AVAudioPlayer(data: asset.data)
            player.numberOfLoops = -1
            player.prepareToPlay()
            return player
        } catch {
            print("AudioManager: Failed to create player for '\(name)' — \(error)")
            return nil
        }
    }

    private func crossfade(to trackName: String) {
        fadeTimer?.invalidate()
        fadeTimer = nil

        guard let newPlayer = loadPlayer(named: trackName) else { return }
        newPlayer.volume = 0
        newPlayer.play()
        incomingPlayer = newPlayer

        nonisolated(unsafe) let fadingIn = newPlayer
        nonisolated(unsafe) let fadingOut = activePlayer
        let steps = 30
        let interval = crossfadeDuration / Double(steps)
        var tick = 0

        fadeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }

                tick += 1
                let progress = Float(tick) / Float(steps)

                fadingIn.volume = progress * self.musicVolume
                fadingOut?.volume = (1.0 - progress) * self.musicVolume

                if tick >= steps {
                    self.fadeTimer?.invalidate()
                    self.fadeTimer = nil
                    fadingOut?.stop()
                    self.activePlayer = fadingIn
                    self.incomingPlayer = nil
                    self.currentTrackName = trackName
                }
            }
        }

        currentTrackName = trackName
    }
}
