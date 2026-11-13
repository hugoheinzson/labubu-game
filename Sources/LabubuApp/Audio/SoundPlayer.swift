import AVFoundation

enum GameSound: String, CaseIterable {
    case tap, crack, hatch, giggle, chomp, hap, nope, click, snore, star, unlock, swish
}

/// Spielt die kurzen Effekt-Töne aus `Resources`. Fehlt eine Datei, bleibt es einfach still.
@MainActor
final class SoundPlayer {
    static let shared = SoundPlayer()

    private var players: [GameSound: AVAudioPlayer] = [:]
    private var music: AVAudioPlayer?

    private init() {
        // .ambient: mischt sich mit anderer Musik und unterbricht nichts.
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        for sound in GameSound.allCases {
            guard let url = Bundle.module.url(forResource: sound.rawValue, withExtension: "wav"),
                  let player = try? AVAudioPlayer(contentsOf: url) else { continue }
            player.enableRate = true
            player.prepareToPlay()
            players[sound] = player
        }
        if let url = Bundle.module.url(forResource: "musicbox", withExtension: "wav") {
            music = try? AVAudioPlayer(contentsOf: url)
            music?.numberOfLoops = -1
            music?.enableRate = true
            music?.prepareToPlay()
        }
    }

    /// `pitchVariation` > 0 spielt den Ton leicht schneller/langsamer, damit wiederholtes Tippen nicht eintönig klingt.
    func play(_ sound: GameSound, pitchVariation: Float = 0) {
        guard !UserDefaults.standard.bool(forKey: "audioMuted") else { return }
        guard UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true else { return }
        guard let player = players[sound] else { return }
        player.volume = sound == .snore ? 0.18 : 0.55
        player.rate = 1 + Float.random(in: -pitchVariation...pitchVariation)
        player.currentTime = 0
        player.play()
    }

    func stopEffects() {
        for player in players.values { player.stop() }
    }

    func updateMusic(enabled: Bool, sleeping: Bool, active: Bool) {
        guard enabled, active, !AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint else {
            music?.pause()
            return
        }
        music?.rate = sleeping ? 0.8 : 1
        music?.setVolume(sleeping ? 0.06 : 0.12, fadeDuration: 1)
        if music?.isPlaying == false { music?.play() }
    }
}
