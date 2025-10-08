//
//  AudioManager.swift
//  Jackie's App
//
//  Created by Matthew Flores on 10/8/25.
//

import AVFoundation

final class AudioManager {
    static let shared = AudioManager()
    private var player: AVAudioPlayer?
    private var fadeTimer: Timer?

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func startAmbientLoop(
        resource: String = "relaxing-lofi-pentekaideca-by-sascha-ende-from-filmmusic-io",
        ext: String = "mp3",
        targetVolume: Float = 0.25,
        fadeDuration: TimeInterval = 0.8
    ) {
        guard let url = Bundle.main.url(forResource: resource, withExtension: ext) else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.volume = 0.0
            player?.prepareToPlay()
            player?.play()
            fade(to: targetVolume, over: fadeDuration)
        } catch {
            print("Ambient error:", error)
        }
    }

    func stopAmbient(fadeDuration: TimeInterval = 0.6) {
        guard player != nil else { return }
        fade(to: 0.0, over: fadeDuration) { [weak self] in
            self?.player?.stop()
            self?.player = nil
        }
    }

    // ✅ Fixed fade implementation
    private func fade(to target: Float, over duration: TimeInterval, completion: (() -> Void)? = nil) {
        fadeTimer?.invalidate()

        // If no duration or no player, just set volume and finish
        guard duration > 0, let p = player else {
            player?.volume = target
            completion?()
            return
        }

        let steps = 30
        let interval = duration / Double(steps)
        let delta = (target - p.volume) / Float(steps)
        var count = 0

        fadeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] t in
            guard let self = self, let pl = self.player else { t.invalidate(); return }
            pl.volume += delta
            count += 1
            if count >= steps {
                pl.volume = target
                t.invalidate()
                completion?()
            }
        }
        // Ensure the timer fires while UI is animating/scrolling
        RunLoop.main.add(fadeTimer!, forMode: .common)
    }
}



