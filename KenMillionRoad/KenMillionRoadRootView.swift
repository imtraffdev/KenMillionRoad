import SwiftUI

struct KenMillionRoadRootView: View {
    @State private var KenMillionRoadLaunchStage = 0
    @State private var KenMillionRoadLaunchProgress = 0.0
    @State private var KenMillionRoadLaunchDestinationState: KenMillionRoadLaunchDestination?
    @State private var KenMillionRoadDidStartLaunch = false
    @State private var KenMillionRoadToast: String?

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                KenMillionRoadAppBackground()

                if let destination = KenMillionRoadLaunchDestinationState {
                    switch destination {
                    case .native:
                        KenMillionRoadAppShell(KenMillionRoadShowToast: KenMillionRoadShowToast)
                            .transition(.opacity)
                    case .web(let url):
                        KenMillionRoadGateWebContainer(url: url) {
                            var transaction = Transaction()
                            transaction.disablesAnimations = true
                            withTransaction(transaction) {
                                KenMillionRoadLaunchDestinationState = .native
                            }
                        }
                        .transition(.opacity)
                    case .offline:
                        KenMillionRoadSplashView(stage: KenMillionRoadLaunchStage, progress: KenMillionRoadLaunchProgress, isOffline: true)
                    }
                } else {
                    KenMillionRoadSplashView(stage: KenMillionRoadLaunchStage, progress: KenMillionRoadLaunchProgress)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
        .ignoresSafeArea(.container, edges: [.top, .bottom])
        .animation(.easeInOut(duration: 0.22), value: KenMillionRoadLaunchDestinationState)
        .overlay(alignment: .bottom) {
            if let KenMillionRoadToast {
                KenMillionRoadToastView(text: KenMillionRoadToast)
                    .padding(.horizontal, 18)
                    .padding(.bottom, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .foregroundStyle(KenMillionRoadTheme.frost)
        .tint(KenMillionRoadTheme.cyan)
        .preferredColorScheme(.dark)
        .task { await KenMillionRoadRunLaunchGate() }
    }

    private func KenMillionRoadRunLaunchGate() async {
        guard !KenMillionRoadDidStartLaunch else { return }
        KenMillionRoadDidStartLaunch = true
        async let splash: Void = KenMillionRoadRunSplashSequence()
        async let gate = KenMillionRoadRemoteGate.KenMillionRoadResolveDestination()
        let destination = await gate
        _ = await splash
        withAnimation { KenMillionRoadLaunchDestinationState = destination }
    }

    private func KenMillionRoadRunSplashSequence() async {
        for step in 0...28 {
            await MainActor.run {
                KenMillionRoadLaunchProgress = Double(step) / 28.0
                KenMillionRoadLaunchStage = min(3, step / 7)
            }
            try? await Task.sleep(nanoseconds: 54_000_000)
        }
        try? await Task.sleep(nanoseconds: 240_000_000)
    }

    private func KenMillionRoadShowToast(_ text: String) {
        withAnimation { KenMillionRoadToast = text }
        Task {
            try? await Task.sleep(nanoseconds: 1_700_000_000)
            await MainActor.run {
                withAnimation {
                    if KenMillionRoadToast == text { KenMillionRoadToast = nil }
                }
            }
        }
    }
}
