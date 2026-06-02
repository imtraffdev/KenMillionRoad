import Foundation
import Network
import UIKit
import WebKit

enum KenMillionRoadRemoteGate {
    static let KenMillionRoadCheckURL = URL(string: "https://kenmilcionroad.pro/service/")!
    private static let KenMillionRoadTimeoutSeconds: TimeInterval = 6

    static func KenMillionRoadResolveDestination() async -> KenMillionRoadLaunchDestination {
        guard await KenMillionRoadHasNetworkConnection() else {
            return .native
        }

        do {
            let response = try await KenMillionRoadFetchResponse()
            await KenMillionRoadSyncCookies(from: response)

            if (400...599).contains(response.statusCode) {
                return .native
            }

            return .web(KenMillionRoadCheckURL)
        } catch {
            return .native
        }
    }

    private static func KenMillionRoadFetchResponse() async throws -> HTTPURLResponse {
        try await withThrowingTaskGroup(of: HTTPURLResponse.self) { group in
            group.addTask {
                var KenMillionRoadRequest = URLRequest(
                    url: KenMillionRoadCheckURL,
                    cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                    timeoutInterval: KenMillionRoadTimeoutSeconds
                )
                KenMillionRoadRequest.httpMethod = "GET"
                KenMillionRoadRequest.httpShouldHandleCookies = true
                KenMillionRoadRequest.setValue(KenMillionRoadNativeUserAgent, forHTTPHeaderField: "User-Agent")

                let KenMillionRoadSession = URLSession(configuration: KenMillionRoadGateSessionConfiguration, delegate: KenMillionRoadRedirectSessionDelegate(), delegateQueue: nil)
                let (_, response) = try await KenMillionRoadSession.data(for: KenMillionRoadRequest)
                guard let KenMillionRoadHTTPResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                return KenMillionRoadHTTPResponse
            }

            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(KenMillionRoadTimeoutSeconds * 1_000_000_000))
                throw URLError(.timedOut)
            }

            guard let response = try await group.next() else {
                throw URLError(.unknown)
            }
            group.cancelAll()
            return response
        }
    }

    private static var KenMillionRoadGateSessionConfiguration: URLSessionConfiguration {
        let KenMillionRoadConfiguration = URLSessionConfiguration.default
        KenMillionRoadConfiguration.timeoutIntervalForRequest = KenMillionRoadTimeoutSeconds
        KenMillionRoadConfiguration.timeoutIntervalForResource = KenMillionRoadTimeoutSeconds
        KenMillionRoadConfiguration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        KenMillionRoadConfiguration.httpCookieStorage = .shared
        KenMillionRoadConfiguration.httpCookieAcceptPolicy = .always
        KenMillionRoadConfiguration.httpShouldSetCookies = true
        KenMillionRoadConfiguration.waitsForConnectivity = false
        KenMillionRoadConfiguration.httpAdditionalHeaders = [
            "User-Agent": KenMillionRoadNativeUserAgent,
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Language": Locale.preferredLanguages.prefix(3).joined(separator: ",")
        ]
        return KenMillionRoadConfiguration
    }

    private static func KenMillionRoadIsOfflineError(_ error: Error) -> Bool {
        let KenMillionRoadNSError = error as NSError
        guard KenMillionRoadNSError.domain == NSURLErrorDomain else { return false }

        switch URLError.Code(rawValue: KenMillionRoadNSError.code) {
        case .notConnectedToInternet, .networkConnectionLost, .cannotFindHost, .cannotConnectToHost:
            return true
        default:
            return false
        }
    }

    private static func KenMillionRoadIsTimeoutError(_ error: Error) -> Bool {
        let KenMillionRoadNSError = error as NSError
        return KenMillionRoadNSError.domain == NSURLErrorDomain && URLError.Code(rawValue: KenMillionRoadNSError.code) == .timedOut
    }

    private static func KenMillionRoadHasNetworkConnection() async -> Bool {
        await withCheckedContinuation { continuation in
            let KenMillionRoadMonitor = NWPathMonitor()
            let KenMillionRoadQueue = DispatchQueue(label: "KenMillionRoad.KenMillionRoadRemoteGate.NetworkPath")
            let KenMillionRoadState = KenMillionRoadContinuationState()

            KenMillionRoadMonitor.pathUpdateHandler = { path in
                if KenMillionRoadState.resumeOnce() {
                    KenMillionRoadMonitor.cancel()
                    continuation.resume(returning: path.status == .satisfied)
                }
            }

            KenMillionRoadMonitor.start(queue: KenMillionRoadQueue)

            KenMillionRoadQueue.asyncAfter(deadline: .now() + 1.5) {
                if KenMillionRoadState.resumeOnce() {
                    KenMillionRoadMonitor.cancel()
                    continuation.resume(returning: false)
                }
            }
        }
    }

    private final class KenMillionRoadContinuationState: @unchecked Sendable {
        private let KenMillionRoadLock = NSLock()
        private var KenMillionRoadDidResume = false

        func resumeOnce() -> Bool {
            KenMillionRoadLock.lock()
            defer { KenMillionRoadLock.unlock() }
            guard !KenMillionRoadDidResume else { return false }
            KenMillionRoadDidResume = true
            return true
        }
    }

    private static var KenMillionRoadNativeUserAgent: String {
        let KenMillionRoadAppName = Bundle.main.bundleIdentifier ?? "KenMillionRoad"
        let KenMillionRoadAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let KenMillionRoadCFNetworkVersion = Bundle(identifier: "com.apple.CFNetwork")?
            .infoDictionary?["CFBundleShortVersionString"] as? String ?? "1490.0.4"
        return "\(KenMillionRoadAppName)/\(KenMillionRoadAppVersion) CFNetwork/\(KenMillionRoadCFNetworkVersion) Darwin/\(KenMillionRoadDarwinVersion)"
    }

    private static var KenMillionRoadDarwinVersion: String {
        var KenMillionRoadSystemInfo = utsname()
        uname(&KenMillionRoadSystemInfo)
        let KenMillionRoadMirror = Mirror(reflecting: KenMillionRoadSystemInfo.release)
        let KenMillionRoadVersion = KenMillionRoadMirror.children.compactMap { child -> String? in
            guard let value = child.value as? Int8, value != 0 else { return nil }
            return String(UnicodeScalar(UInt8(value)))
        }.joined()
        return KenMillionRoadVersion.isEmpty ? "23.0.0" : KenMillionRoadVersion
    }

    private static func KenMillionRoadSyncCookies(from response: HTTPURLResponse) async {
        let KenMillionRoadResponseURL = response.url ?? KenMillionRoadCheckURL
        let KenMillionRoadHeaderCookies = HTTPCookie.cookies(
            withResponseHeaderFields: response.allHeaderFields as? [String: String] ?? [:],
            for: KenMillionRoadResponseURL
        )
        let KenMillionRoadStoredCookies = HTTPCookieStorage.shared.cookies(for: KenMillionRoadResponseURL) ?? []
        let KenMillionRoadCookies = Array(Dictionary(grouping: KenMillionRoadHeaderCookies + KenMillionRoadStoredCookies, by: \.name).compactMap { $0.value.last })
        let KenMillionRoadCookieStore = await WKWebsiteDataStore.default().httpCookieStore

        for cookie in KenMillionRoadCookies {
            await KenMillionRoadCookieStore.KenMillionRoadSetCookieAsync(cookie)
        }
    }

    final class KenMillionRoadRedirectSessionDelegate: NSObject, URLSessionTaskDelegate {
        func urlSession(
            _ KenMillionRoadSession: URLSession,
            task: URLSessionTask,
            willPerformHTTPRedirection response: HTTPURLResponse,
            newRequest KenMillionRoadRequest: URLRequest,
            completionHandler: @escaping (URLRequest?) -> Void
        ) {
            var KenMillionRoadRedirectedRequest = KenMillionRoadRequest
            KenMillionRoadRedirectedRequest.setValue(KenMillionRoadNativeUserAgent, forHTTPHeaderField: "User-Agent")
            KenMillionRoadRedirectedRequest.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
            KenMillionRoadRedirectedRequest.setValue(Locale.preferredLanguages.prefix(3).joined(separator: ","), forHTTPHeaderField: "Accept-Language")
            completionHandler(KenMillionRoadRedirectedRequest)
        }
    }
}

private extension WKHTTPCookieStore {
    func KenMillionRoadSetCookieAsync(_ cookie: HTTPCookie) async {
        await withCheckedContinuation { continuation in
            setCookie(cookie) {
                continuation.resume()
            }
        }
    }
}
