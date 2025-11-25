import SwiftUI

struct EggView: View {
    @ObservedObject var viewModel: LabubuViewModel
    @State private var wobbleRotation: Double = 0
    @State private var eggScale: CGFloat = 1

    var body: some View {
        ZStack {
            background
            VStack(spacing: 32) {
                Text("Labubu Ei")
                    .font(.largeTitle.weight(.semibold))
                Spacer()
                egg
                Spacer()
                statusPanel
            }
            .padding(48)
        }
        .onTapGesture {
            triggerWobble()
            viewModel.careForEgg()
        }
        .animation(.easeOut(duration: 0.25), value: viewModel.stageDescription())
    }

    private var background: some View {
        LinearGradient(
            colors: [Color.pink.opacity(0.4), Color.purple.opacity(0.6)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var egg: some View {
        Image(systemName: "egg.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.white)
            .frame(width: 240, height: 320)
            .rotationEffect(.degrees(wobbleRotation))
            .scaleEffect(eggScale)
            .shadow(color: .black.opacity(0.2), radius: 20, y: 16)
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
            Text("Tipp: Tippe auf das Ei, um es zu wärmen und zu pflegen.")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
        .padding()
        .frame(maxWidth: 400)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
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

#Preview("EggView iPad") {
    EggView(viewModel: LabubuViewModel())
        .previewInterfaceOrientation(.landscapeLeft)
}
