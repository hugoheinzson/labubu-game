import SwiftUI

/// Drei große Eier zur Auswahl – Clara braucht dafür weder Text noch ein Menü.
struct EggSelectionView: View {
    let onSelect: (EggVariant) -> Void

    var body: some View {
        GeometryReader { geo in
            let width = min(220, (geo.size.width - 80) / 3.4)
            VStack(spacing: 28) {
                Text("🥚  💕  🥚")
                    .font(.system(size: 44))
                    .accessibilityHidden(true)
                HStack(alignment: .bottom, spacing: 20) {
                    ForEach(EggVariant.allCases) { variant in
                        Button {
                            onSelect(variant)
                        } label: {
                            VStack(spacing: 16) {
                                VariantEggArt(variant: variant)
                                    .frame(width: width, height: width * 1.25)
                                    .shadow(color: .black.opacity(0.12), radius: 12, y: 10)
                                Circle()
                                    .fill(.white.opacity(0.7))
                                    .frame(width: 56, height: 56)
                                    .overlay(Text(marker(for: variant)).font(.system(size: 32)))
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 8)
                            .background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 32))
                            .overlay(RoundedRectangle(cornerRadius: 32).stroke(.white.opacity(0.65), lineWidth: 3))
                            .contentShape(RoundedRectangle(cornerRadius: 32))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(label(for: variant))
                        .accessibilityHint("Antippen, um dieses Ei ins Nest zu legen")
                        .accessibilityIdentifier("egg-choice-\(variant.rawValue)")
                    }
                }
                Text("👆")
                    .font(.system(size: 54))
                    .accessibilityHidden(true)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private func marker(for variant: EggVariant) -> String {
        switch variant {
        case .classic: return "🌼"
        case .rose: return "🌸"
        case .mint: return "🍀"
        }
    }

    private func label(for variant: EggVariant) -> String {
        switch variant {
        case .classic: return "Beiges Ei auswählen"
        case .rose: return "Rosa Ei auswählen"
        case .mint: return "Mintfarbenes Ei auswählen"
        }
    }
}

/// Dieselbe Grafik und dieselben Risse in allen Phasen – nur die Pastellfarbe variiert.
struct VariantEggArt: View {
    let variant: EggVariant
    var crackLevel = 0

    var body: some View {
        EggArt(crackLevel: crackLevel)
            .colorMultiply(tint)
    }

    private var tint: Color {
        switch variant {
        case .classic: return .white
        case .rose: return Color(red: 1, green: 0.80, blue: 0.92)
        case .mint: return Color(red: 0.76, green: 1, blue: 0.88)
        }
    }
}
