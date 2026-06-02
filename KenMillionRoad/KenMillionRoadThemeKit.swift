import SwiftUI

enum KenMillionRoadTheme {
    static let asphalt = Color(red: 0.12, green: 0.09, blue: 0.15)
    static let deep = Color(red: 0.05, green: 0.04, blue: 0.08)
    static let panel = Color(red: 0.18, green: 0.12, blue: 0.20)
    static let raised = Color(red: 0.25, green: 0.17, blue: 0.27)
    static let gold = Color(red: 1.00, green: 0.74, blue: 0.20)
    static let orange = Color(red: 1.00, green: 0.38, blue: 0.38)
    static let green = Color(red: 0.44, green: 0.90, blue: 0.56)
    static let cyan = Color(red: 0.40, green: 0.86, blue: 1.00)
    static let purple = Color(red: 0.91, green: 0.38, blue: 1.00)
    static let frost = Color(red: 1.00, green: 0.97, blue: 1.00)
    static let muted = Color(red: 0.78, green: 0.70, blue: 0.82)
    static let line = Color.white.opacity(0.16)
    static let abyss = Color(red: 0.05, green: 0.03, blue: 0.06)
    static let warning = Color(red: 1.00, green: 0.27, blue: 0.18)
}

struct KenMillionRoadAppBackground: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: [
                        KenMillionRoadTheme.deep,
                        Color(red: 0.18, green: 0.07, blue: 0.20),
                        KenMillionRoadTheme.asphalt
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: proxy.size.width, height: proxy.size.height)

                Image("KenMillionRoadBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .opacity(0.18)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .ignoresSafeArea()
    }
}

struct KenMillionRoadSplashView: View {
    var stage: Int
    var progress: Double
    var isOffline = false

    private var message: String {
        if isOffline { return "Opening your local plan" }
        return ["Polishing the route", "Setting the first target", "Arranging milestones", "Rolling out the plan"][min(stage, 3)]
    }

    var body: some View {
        ZStack {
            KenMillionRoadAppBackground()
            VStack(spacing: 20) {
                Image("KenMillionRoadLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300)
                    .shadow(color: KenMillionRoadTheme.purple.opacity(0.48), radius: 26, y: 10)
                ZStack(alignment: .bottom) {
                    GeometryReader { proxy in
                        ZStack(alignment: .bottom) {
                            Image("KenMillionRoadBackground")
                                .resizable()
                                .scaledToFill()
                                .frame(width: proxy.size.width, height: 210)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 28))
                            HStack(alignment: .bottom) {
                                Image("KenMillionRoadKen")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 190)
                                    .offset(x: CGFloat(progress) * 80 - 35)
                                Spacer()
                                Image("KenMillionRoadMark")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 72, height: 72)
                            }
                            .padding(.horizontal, 18)
                        }
                    }
                }
                .frame(height: 210)
                .padding(.horizontal, 22)
                Text(message)
                    .font(.system(size: 18, weight: .black))
                ProgressView(value: progress)
                    .tint(KenMillionRoadTheme.gold)
                    .padding(.horizontal, 42)
            }
            .foregroundStyle(KenMillionRoadTheme.frost)
        }
    }
}
