import AVFoundation

enum GameSound: String, CaseIterable {
    case tap, crack, hatch, giggle, chomp, nope, click, snore
}

/// Spielt die kurzen Effekt-Töne aus `Resources`. Fehlt eine Datei, bleibt es einfach still.
@MainActor
final class SoundPlayer {
    static let shared = SoundPlayer()

    private var players: [GameSound: AVAudioPlayer] = [:]

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
    }

    /// `pitchVariation` > 0 spielt den Ton leicht schneller/langsamer, damit wiederholtes Tippen nicht eintönig klingt.
    func play(_ sound: GameSound, pitchVariation: Float = 0) {
        guard let player = players[sound] else { return }
        player.rate = 1 + Float.random(in: -pitchVariation...pitchVariation)
        player.currentTime = 0
        player.play()
    }
}
