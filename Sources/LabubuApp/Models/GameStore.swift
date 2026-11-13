import Foundation

/// Speichert den Spielstand als JSON-Datei, damit das Ei nach einem Neustart nicht wieder kalt ist.
struct GameStore {
    let fileURL: URL

    static let standard: GameStore = {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return GameStore(fileURL: base.appendingPathComponent("labubu-spielstand.json"))
    }()

    func load() -> LabubuState? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(LabubuState.self, from: data)
    }

    func save(_ state: LabubuState) {
        do {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try JSONEncoder().encode(state).write(to: fileURL, options: .atomic)
        } catch {
            assertionFailure("Spielstand konnte nicht gespeichert werden: \(error)")
        }
    }
}
