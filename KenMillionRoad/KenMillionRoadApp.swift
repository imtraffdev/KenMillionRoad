import SwiftUI
import UIKit

@main
struct KenMillionRoadApp: App {
    @UIApplicationDelegateAdaptor(KenMillionRoadAppDelegate.self) private var appDelegate
    @StateObject private var KenMillionRoadStore = KenMillionRoadLocalStore()

    var body: some Scene {
        WindowGroup {
            KenMillionRoadRootView()
                .environmentObject(KenMillionRoadStore)
        }
    }
}

@MainActor
final class KenMillionRoadAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        KenMillionRoadOrientationController.current
    }
}

@MainActor
enum KenMillionRoadOrientationController {
    static var current: UIInterfaceOrientationMask = .allButUpsideDown {
        didSet {
            KenMillionRoadRefreshSupportedInterfaceOrientations()
        }
    }

    private static func KenMillionRoadRefreshSupportedInterfaceOrientations() {
        let windowScenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }

        for scene in windowScenes {
            for window in scene.windows {
                KenMillionRoadUpdateSupportedInterfaceOrientations(from: window.rootViewController)
            }

            if #available(iOS 16.0, *) {
                scene.requestGeometryUpdate(.iOS(interfaceOrientations: current))
            }
        }
    }

    private static func KenMillionRoadUpdateSupportedInterfaceOrientations(from viewController: UIViewController?) {
        viewController?.setNeedsUpdateOfSupportedInterfaceOrientations()

        if let navigationController = viewController as? UINavigationController {
            KenMillionRoadUpdateSupportedInterfaceOrientations(from: navigationController.visibleViewController)
        }

        if let tabBarController = viewController as? UITabBarController {
            KenMillionRoadUpdateSupportedInterfaceOrientations(from: tabBarController.selectedViewController)
        }

        if let presentedViewController = viewController?.presentedViewController {
            KenMillionRoadUpdateSupportedInterfaceOrientations(from: presentedViewController)
        }
    }
}
