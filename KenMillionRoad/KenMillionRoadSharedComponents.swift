import SwiftUI
import UIKit
import AudioToolbox

struct KenMillionRoadHeader: View {
    var title: String
    var subtitle: String
    var balance: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 25, weight: .black))
                    .lineLimit(2)
                    .minimumScaleFactor(0.68)
                Text(subtitle)
                    .font(.system(size: 11, weight: .heavy))
                    .tracking(1.2)
                    .foregroundStyle(KenMillionRoadTheme.cyan)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                KenMillionRoadCurrencyPill(balance: balance)
            }
        }
    }
}

struct KenMillionRoadCurrencyPill: View {
    var balance: String

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: "dollarsign.circle.fill")
            Text(balance)
                .lineLimit(1)
                .minimumScaleFactor(0.58)
        }
        .font(.system(size: 12, weight: .black))
        .foregroundStyle(KenMillionRoadTheme.abyss)
        .frame(width: 118)
        .padding(.horizontal, 9)
        .padding(.vertical, 8)
        .background(KenMillionRoadTheme.gold, in: Capsule())
    }
}

struct KenMillionRoadPanelModifier: ViewModifier {
    var cornerRadius: CGFloat = 18

    func body(content: Content) -> some View {
        content
            .background(KenMillionRoadTheme.panel.opacity(0.94), in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(KenMillionRoadTheme.line, lineWidth: 1))
    }
}

extension View {
    func KenMillionRoadPanel(cornerRadius: CGFloat = 18) -> some View {
        modifier(KenMillionRoadPanelModifier(cornerRadius: cornerRadius))
    }

    func KenMillionRoadInputSurface() -> some View {
        padding(13)
            .background(KenMillionRoadTheme.raised, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(KenMillionRoadTheme.line, lineWidth: 1))
    }
}

struct KenMillionRoadPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .black))
            .foregroundStyle(KenMillionRoadTheme.abyss)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [
                        KenMillionRoadTheme.gold.opacity(configuration.isPressed ? 0.72 : 1),
                        KenMillionRoadTheme.orange.opacity(configuration.isPressed ? 0.76 : 1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 14)
            )
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.28), lineWidth: 1))
    }
}

struct KenMillionRoadSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .black))
            .foregroundStyle(KenMillionRoadTheme.frost)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(configuration.isPressed ? KenMillionRoadTheme.asphalt.opacity(0.72) : KenMillionRoadTheme.raised, in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(KenMillionRoadTheme.line, lineWidth: 1))
    }
}

struct KenMillionRoadSmallPill: View {
    var text: String
    var color: Color = KenMillionRoadTheme.cyan

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .black))
            .foregroundStyle(color)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(color.opacity(0.15), in: Capsule())
    }
}

struct KenMillionRoadToastView: View {
    var text: String

    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(KenMillionRoadTheme.frost)
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(Color.black.opacity(0.82), in: Capsule())
            .overlay(Capsule().stroke(KenMillionRoadTheme.line))
    }
}

struct KenMillionRoadModalShell<Content: View>: View {
    var title: String
    var onClose: () -> Void
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            Color.black.opacity(0.58).ignoresSafeArea()
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(title)
                        .font(.system(size: 22, weight: .black))
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(KenMillionRoadTheme.frost)
                            .frame(width: 34, height: 34)
                            .background(Color.white.opacity(0.10), in: Circle())
                    }
                    .buttonStyle(.plain)
                }
                content
            }
            .padding(18)
            .KenMillionRoadPanel(cornerRadius: 22)
            .padding(18)
        }
    }
}

enum KenMillionRoadSound {
    static func KenMillionRoadPlay(_ id: SystemSoundID, enabled: Bool) {
        guard enabled else { return }
        AudioServicesPlaySystemSound(id)
    }
}

enum KenMillionRoadHaptics {
    static func KenMillionRoadTap(enabled: Bool = true) {
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func KenMillionRoadSuccess(enabled: Bool = true) {
        guard enabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
