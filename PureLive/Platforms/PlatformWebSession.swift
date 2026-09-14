import Foundation
import WebKit

@MainActor
final class PlatformWebSession: NSObject, WKNavigationDelegate {
    static let shared = PlatformWebSession()
    private let webView: WKWebView
    private var continuation: CheckedContinuation<String, Error>?

    private override init() {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        webView = WKWebView(frame: .zero, configuration: configuration)
        super.init()
        webView.navigationDelegate = self
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 Version/17.0 Mobile/15E148 Safari/604.1"
    }

    func loadHTML(url: URL, timeout: TimeInterval = 20) async throws -> String {
        if continuation != nil { throw PlatformWebSessionError.busy }
        webView.load(URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeout))
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(timeout))
                if let pending = self.continuation {
                    self.continuation = nil
                    pending.resume(throwing: PlatformWebSessionError.timeout)
                }
            }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.documentElement.outerHTML") { [weak self] result, error in
            guard let self, let continuation = self.continuation else { return }
            self.continuation = nil
            if let error { continuation.resume(throwing: error) }
            else { continuation.resume(returning: String(describing: result ?? "")) }
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { finish(error) }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) { finish(error) }

    private func finish(_ error: Error) {
        guard let continuation else { return }
        self.continuation = nil
        continuation.resume(throwing: error)
    }
}

enum PlatformWebSessionError: Error { case busy, timeout }
