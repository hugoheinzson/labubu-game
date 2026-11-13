import SwiftUI

struct EggView: View {
    @ObservedObject var viewModel: LabubuViewModel
    @State private var wobbleRotation: Double = 0
    @State private var eggScale: CGFloat = 1

    var body: some View {
        ZStack {
            background
            content
                .padding(48)
        }
        .onTapGesture {
            guard viewModel.state.stage != .hatched else { return }
            triggerWobble()
            viewModel.careForEgg()
        }
        .animation(.easeOut(duration: 0.25), value: viewModel.state.stage)
    }

    private var background: some View {
        LinearGradient(
            colors: [Color.pink.opacity(0.4), Color.purple.opacity(0.6)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state.stage {
        case .hatched:
            hatchedScene
        case .egg, .incubating:
            eggScene(for: viewModel.state.stage)
        }
    }

    private func eggScene(for stage: HatchStage) -> some View {
        VStack(spacing: 32) {
            Text(stage == .egg ? "Labubu Ei" : "Ei öffnet sich")
                .font(.largeTitle.weight(.semibold))
            Spacer()
            eggImage(for: stage)
            Spacer()
            statusPanel
        }
    }

    private func eggImage(for stage: HatchStage) -> some View {
        let assetName = stage == .egg ? "EggClosed" : "EggIncubating"
        return artwork(assetName, fallbackSymbol: "oval.portrait.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.white)
            .frame(width: 420, height: 300)
            .rotationEffect(.degrees(stage == .egg ? wobbleRotation : wobbleRotation * 0.2))
            .scaleEffect(stage == .egg ? eggScale : 1.02)
            .shadow(color: .black.opacity(0.15), radius: 30, y: 18)
    }

    private var statusPanel: some View {
        VStack(spacing: 12) {
            Text(viewModel.stageDescription())
                .font(.title3)
            ProgressView(value: viewModel.state.careProgress)
                .tint(.yellow)
            Text(viewModel.progressLabel())
                .font(.footnote)
            ProgressView(value: viewModel.state.warmth)
                .tint(.orange)
            Text(viewModel.warmthLabel())
                .font(.footnote)
            Text(instructionText)
                .font(.footnote)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
        .padding()
        .frame(maxWidth: 400)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var hatchedScene: some View {
        VStack(spacing: 32) {
            Text("Baby Labubu ist geschlüpft!")
                .font(.largeTitle.weight(.bold))
            artwork("BabyLabubu", fallbackSymbol: "teddybear.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white)
                .frame(maxWidth: 480)
                .shadow(color: .black.opacity(0.2), radius: 25, y: 20)
            Text("Weiter pflegen, damit es glücklich bleibt.")
                .font(.title3)
            statusPanel
        }
    }

    /// Lädt ein Bild aus `Resources`. Fehlt es, wird ein SF-Symbol als Platzhalter gezeigt,
    /// damit die App auch ohne fertige Grafiken spielbar bleibt.
    private func artwork(_ name: String, fallbackSymbol: String) -> Image {
        if let image = UIImage(named: name, in: .module, compatibleWith: nil) {
            return Image(uiImage: image)
        }
        return Image(systemName: fallbackSymbol)
    }

    private var instructionText: String {
        switch viewModel.state.stage {
        case .egg:
            return "Tipp: Tippe auf das Ei, damit es wackelt und warm wird."
        case .incubating:
            return "Noch etwas wärmen, dann schlüpft Labubu!"
        case .hatched:
            return "Labubu ist da – jetzt beginnt die Pflege."
        }
    }

    private func triggerWobble() {
        let baseAnimation = Animation.interactiveSpring(response: 0.25, dampingFraction: 0.35, blendDuration: 0.05)
        withAnimation(baseAnimation) {
            wobbleRotation = Double.random(in: -12...12)
            eggScale = 1.05
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.easeOut(duration: 0.2)) {
                wobbleRotation = 0
                eggScale = 1
            }
        }
    }
}

#Preview("EggView iPad", traits: .landscapeLeft) {
    EggView(viewModel: LabubuViewModel())
}
