//
//  AuthViewController.swift
//  Spotify
//
//  Created by user on 23/03/2021.
//

import UIKit
import WebKit

class AuthViewController: UIViewController, WKNavigationDelegate {
    
    private let webView: WKWebView = {
        let pref = WKWebpagePreferences()
        pref.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = pref
        let webView = WKWebView(frame: .zero, configuration: config)
        return webView
    }()
    
    private let loadingView: UIView = {
        let boxView = UIView(frame: .zero)
        boxView.backgroundColor = .label
        boxView.clipsToBounds = true
        boxView.alpha = 0.6
        boxView.layer.cornerRadius = 10    // Spin config:
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.frame = CGRect(x: 30, y: 12, width: 40, height: 40)
        spinner.color = .systemBackground
        spinner.startAnimating()
        
        // Text config:
        let textLabel = UILabel(frame: CGRect(x: 0, y: 55, width: 100, height: 30))
        textLabel.textColor = .systemBackground
        textLabel.textAlignment = .center
        textLabel.font = .systemFont(ofSize: 13.0, weight: .semibold)
        textLabel.text = "Loading..."    // Activate:
        boxView.addSubview(spinner)
        boxView.addSubview(textLabel)
        return boxView
    }()
    
    public var completionHandler: ((Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign In"
        
        view.backgroundColor = .systemBackground
        webView.navigationDelegate = self
        view.addSubview(webView)
        guard let url = AuthManager.shared.signInURL else {
            return
        }
        webView.load(URLRequest(url: url))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
        loadingView.frame = CGRect(x: (view.width - 100)/2, y: (view.height - 90)/2, width: 100, height: 90)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else {
            return
        }
        
        guard let code = URLComponents(string: url.absoluteString)?.queryItems?.first(where: {$0.name == "code"})?.value else {
            return
        }
        
       // exchange the code for access token
        AuthManager.shared.exchangeCodeForToken(code: code) { [weak self] (success) in
            DispatchQueue.main.async {
                self?.navigationController?.popViewController(animated: true)
                self?.completionHandler?(success)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        view.addSubview(loadingView)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingView.removeFromSuperview()
    }
}
