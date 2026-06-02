import SwiftUI
import UIKit
import WebKit

final class KenMillionRoadWebNavigationController: ObservableObject {
    @Published var KenMillionRoadCanGoBack = false
    @Published var KenMillionRoadCanGoForward = false

    private weak var KenMillionRoadWebView: WKWebView?
    private var KenMillionRoadStartURL: URL?

    func KenMillionRoadAttach(_ KenMillionRoadWebView: WKWebView, startURL: URL) {
        self.KenMillionRoadWebView = KenMillionRoadWebView
        self.KenMillionRoadStartURL = startURL
        KenMillionRoadUpdateState()
    }

    func KenMillionRoadUpdateState() {
        KenMillionRoadCanGoBack = KenMillionRoadPreviousAllowedItem() != nil
        KenMillionRoadCanGoForward = KenMillionRoadWebView?.canGoForward ?? false
    }

    func KenMillionRoadGoBack() {
        guard let KenMillionRoadWebView, let item = KenMillionRoadPreviousAllowedItem() else { return }
        KenMillionRoadWebView.go(to: item)
        KenMillionRoadUpdateStateSoon()
    }

    func KenMillionRoadGoForward() {
        guard let KenMillionRoadWebView, KenMillionRoadWebView.canGoForward else { return }
        KenMillionRoadWebView.goForward()
        KenMillionRoadUpdateStateSoon()
    }

    private func KenMillionRoadUpdateStateSoon() {
        KenMillionRoadUpdateState()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.KenMillionRoadUpdateState()
        }
    }

    private func KenMillionRoadPreviousAllowedItem() -> WKBackForwardListItem? {
        guard let KenMillionRoadWebView else { return nil }
        return KenMillionRoadWebView.backForwardList.backList.reversed().first { item in
            !KenMillionRoadIsStartURL(item.url)
        }
    }

    private func KenMillionRoadIsStartURL(_ url: URL) -> Bool {
        guard let KenMillionRoadStartURL else { return false }
        return KenMillionRoadNormalizedURL(url) == KenMillionRoadNormalizedURL(KenMillionRoadStartURL)
    }

    private func KenMillionRoadNormalizedURL(_ url: URL) -> String {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.fragment = nil
        var normalized = components?.url?.absoluteString ?? url.absoluteString
        while normalized.hasSuffix("/") {
            normalized.removeLast()
        }
        return normalized.lowercased()
    }
}

struct KenMillionRoadGateWebContainer: View {
    let KenMillionRoadURL: URL
    let KenMillionRoadOnBlockedResponse: () -> Void
    @State private var KenMillionRoadIsWebViewVisible = false
    @StateObject private var KenMillionRoadNavigationController = KenMillionRoadWebNavigationController()

    init(url: URL, onBlockedResponse: @escaping () -> Void) {
        self.KenMillionRoadURL = url
        self.KenMillionRoadOnBlockedResponse = onBlockedResponse
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            KenMillionRoadGateWebView(url: KenMillionRoadURL, onReady: {
                KenMillionRoadIsWebViewVisible = true
            }, onBlockedResponse: KenMillionRoadOnBlockedResponse, onWebViewReady: { KenMillionRoadWebView in
                KenMillionRoadNavigationController.KenMillionRoadAttach(KenMillionRoadWebView, startURL: KenMillionRoadURL)
            }, onNavigationStateChange: { KenMillionRoadCanGoBack, KenMillionRoadCanGoForward in
                KenMillionRoadNavigationController.KenMillionRoadUpdateState()
            })
            .background(Color.black)
            .opacity(KenMillionRoadIsWebViewVisible ? 1 : 0)

            KenMillionRoadWebNavigationOverlay(
                KenMillionRoadCanGoBack: KenMillionRoadNavigationController.KenMillionRoadCanGoBack,
                KenMillionRoadCanGoForward: KenMillionRoadNavigationController.KenMillionRoadCanGoForward,
                KenMillionRoadGoBack: KenMillionRoadNavigationController.KenMillionRoadGoBack,
                KenMillionRoadGoForward: KenMillionRoadNavigationController.KenMillionRoadGoForward
            )
            .opacity(KenMillionRoadIsWebViewVisible ? 1 : 0)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            KenMillionRoadOrientationController.current = UIDevice.current.userInterfaceIdiom == .pad ? .all : .allButUpsideDown
        }
        .task {
            try? await Task.sleep(nanoseconds: 8_000_000_000)
            await MainActor.run {
                if !KenMillionRoadIsWebViewVisible {
                    KenMillionRoadOnBlockedResponse()
                }
            }
        }
        .onDisappear {
            KenMillionRoadOrientationController.current = UIDevice.current.userInterfaceIdiom == .pad ? .all : .allButUpsideDown
        }
    }
}

struct KenMillionRoadGateWebView: UIViewRepresentable {
    let url: URL
    let onReady: () -> Void
    let onBlockedResponse: () -> Void
    let onWebViewReady: (WKWebView) -> Void
    let onNavigationStateChange: (Bool, Bool) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onReady: onReady,
            onBlockedResponse: onBlockedResponse,
            onNavigationStateChange: onNavigationStateChange
        )
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.customUserAgent = KenMillionRoadWebUserAgent.KenMillionRoadSafariLike
        webView.isOpaque = true
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        context.coordinator.webView = webView
        onWebViewReady(webView)
        webView.load(KenMillionRoadWebUserAgent.KenMillionRoadSafariRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        let onReady: () -> Void
        let onBlockedResponse: () -> Void
        let onNavigationStateChange: (Bool, Bool) -> Void
        weak var webView: WKWebView?

        init(
            onReady: @escaping () -> Void,
            onBlockedResponse: @escaping () -> Void,
            onNavigationStateChange: @escaping (Bool, Bool) -> Void
        ) {
            self.onReady = onReady
            self.onBlockedResponse = onBlockedResponse
            self.onNavigationStateChange = onNavigationStateChange
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            if navigationAction.targetFrame == nil, ["http", "https"].contains(url.scheme?.lowercased()) {
                webView.load(navigationAction.request)
                decisionHandler(.cancel)
                return
            }

            if let scheme = url.scheme?.lowercased(), !["http", "https", "about"].contains(scheme) {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }

            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            KenMillionRoadUpdateNavigationState(webView)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            KenMillionRoadUpdateNavigationState(webView)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            KenMillionRoadUpdateNavigationState(webView)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            KenMillionRoadUpdateNavigationState(webView)
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            if navigationResponse.isForMainFrame,
               let response = navigationResponse.response as? HTTPURLResponse,
               (400...599).contains(response.statusCode) {
                decisionHandler(.cancel)
                DispatchQueue.main.async { [onBlockedResponse] in
                    onBlockedResponse()
                }
                return
            }

            if navigationResponse.isForMainFrame {
                DispatchQueue.main.async { [onReady] in
                    onReady()
                }
            }

            decisionHandler(.allow)
        }

        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            if let requestURL = navigationAction.request.url {
                webView.load(KenMillionRoadWebUserAgent.KenMillionRoadSafariRequest(url: requestURL))
            } else {
                webView.load(navigationAction.request)
            }
            return nil
        }

        func webViewDidClose(_ webView: WKWebView) {
            self.webView?.goBack()
        }

        func webView(
            _ webView: WKWebView,
            runJavaScriptAlertPanelWithMessage message: String,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping () -> Void
        ) {
            KenMillionRoadPresentWebDialog(
                title: webView.url?.host ?? "Message",
                message: message,
                actions: [UIAlertAction(title: "OK", style: .default) { _ in completionHandler() }],
                fallback: completionHandler
            )
        }

        func webView(
            _ webView: WKWebView,
            runJavaScriptConfirmPanelWithMessage message: String,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping (Bool) -> Void
        ) {
            KenMillionRoadPresentWebDialog(
                title: webView.url?.host ?? "Confirm",
                message: message,
                actions: [
                    UIAlertAction(title: "Cancel", style: .cancel) { _ in completionHandler(false) },
                    UIAlertAction(title: "OK", style: .default) { _ in completionHandler(true) }
                ],
                fallback: { completionHandler(false) }
            )
        }

        func webView(
            _ webView: WKWebView,
            runJavaScriptTextInputPanelWithPrompt prompt: String,
            defaultText: String?,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping (String?) -> Void
        ) {
            let alert = UIAlertController(title: webView.url?.host ?? "Input", message: prompt, preferredStyle: .alert)
            alert.addTextField { textField in
                textField.text = defaultText
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completionHandler(nil) })
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completionHandler(alert.textFields?.first?.text)
            })

            KenMillionRoadPresentAlertController(alert, fallback: { completionHandler(nil) })
        }

        func webView(
            _ webView: WKWebView,
            requestMediaCapturePermissionFor origin: WKSecurityOrigin,
            initiatedByFrame frame: WKFrameInfo,
            type: WKMediaCaptureType,
            decisionHandler: @escaping (WKPermissionDecision) -> Void
        ) {
            decisionHandler(.prompt)
        }

        private func KenMillionRoadUpdateNavigationState(_ webView: WKWebView) {
            DispatchQueue.main.async { [onNavigationStateChange] in
                onNavigationStateChange(webView.canGoBack, webView.canGoForward)
            }
        }

        private func KenMillionRoadPresentWebDialog(
            title: String,
            message: String,
            actions: [UIAlertAction],
            fallback: @escaping () -> Void
        ) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            actions.forEach(alert.addAction)
            KenMillionRoadPresentAlertController(alert, fallback: fallback)
        }

        private func KenMillionRoadPresentAlertController(_ alert: UIAlertController, fallback: @escaping () -> Void) {
            DispatchQueue.main.async {
                guard let presenter = UIApplication.shared.KenMillionRoadTopMostViewController() else {
                    fallback()
                    return
                }

                if presenter.presentedViewController == nil {
                    presenter.present(alert, animated: true)
                } else {
                    fallback()
                }
            }
        }
    }
}

struct KenMillionRoadWebNavigationOverlay: View {
    var KenMillionRoadCanGoBack: Bool
    var KenMillionRoadCanGoForward: Bool
    var KenMillionRoadGoBack: () -> Void
    var KenMillionRoadGoForward: () -> Void

    var body: some View {
        GeometryReader { proxy in
            VStack {
                Spacer()
                HStack(spacing: 10) {
                    KenMillionRoadNavButton(direction: .left, enabled: KenMillionRoadCanGoBack, action: KenMillionRoadGoBack)
                    KenMillionRoadNavButton(direction: .right, enabled: KenMillionRoadCanGoForward, action: KenMillionRoadGoForward)
                }
                .padding(8)
                .background(Color.black.opacity(0.42), in: Capsule())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 14)
                .padding(.bottom, max(6, proxy.safeAreaInsets.bottom - 18))
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }

    private func KenMillionRoadNavButton(direction: KenMillionRoadWebArrowDirection, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            KenMillionRoadWebArrow(direction: direction, color: enabled ? Color.white : Color.white.opacity(0.28))
                .frame(width: 13, height: 13)
                .frame(width: 32, height: 32)
                .background(Color.white.opacity(enabled ? 0.14 : 0.06), in: Circle())
                .contentShape(Circle())
        }
        .disabled(!enabled)
        .buttonStyle(.plain)
        .allowsHitTesting(enabled)
    }
}

private enum KenMillionRoadWebArrowDirection {
    case left
    case right
}

private struct KenMillionRoadWebArrow: View {
    var direction: KenMillionRoadWebArrowDirection
    var color: Color

    var body: some View {
        Image(systemName: direction == .left ? "chevron.left" : "chevron.right")
            .font(.system(size: 13, weight: .black))
            .foregroundStyle(color)
    }
}

private enum KenMillionRoadWebUserAgent {
    static var KenMillionRoadSafariLike: String {
        let osVersion = UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")
        let majorVersion = UIDevice.current.systemVersion.split(separator: ".").first.map(String.init) ?? "18"
        return "Mozilla/5.0 (iPhone; CPU iPhone OS \(osVersion) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/\(majorVersion).0 Mobile/15E148 Safari/604.1"
    }

    static func KenMillionRoadSafariRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url, timeoutInterval: 30)
        request.setValue(KenMillionRoadSafariLike, forHTTPHeaderField: "User-Agent")
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue(Locale.preferredLanguages.prefix(3).joined(separator: ","), forHTTPHeaderField: "Accept-Language")
        return request
    }
}

private extension UIApplication {
    func KenMillionRoadTopMostViewController(
        base: UIViewController? = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController
    ) -> UIViewController? {
        if let navigationController = base as? UINavigationController {
            return KenMillionRoadTopMostViewController(base: navigationController.visibleViewController)
        }

        if let tabBarController = base as? UITabBarController {
            return KenMillionRoadTopMostViewController(base: tabBarController.selectedViewController)
        }

        if let presented = base?.presentedViewController {
            return KenMillionRoadTopMostViewController(base: presented)
        }

        return base
    }
}
