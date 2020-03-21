//
//  ArticleViewController.swift
//  HackerNews Articles
//
//  Created by Fernando Garcia on 20-03-20.
//  Copyright © 2020 Fernando Garcia. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class ArticleViewController: UIViewController {
    @IBOutlet weak var articleWebView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    
    var articleURL = ""
    
    override func viewDidLoad() {
        if let url = URL(string: articleURL) {
            articleWebView.navigationDelegate = self
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 10)
            articleWebView.load(request)
        } else {
            activityIndicator.stopAnimating()
            errorLabel.text = "Article is missing the URL"
            errorLabel.isHidden = false
        }
    }
}

//MARK: - WKNavigationDelegate

extension ArticleViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        articleWebView.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showWebViewError(error)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showWebViewError(error)
    }
    
    func showWebViewError(_ error: Error) {
        activityIndicator.stopAnimating()
        errorLabel.isHidden = false
        errorLabel.text = error.localizedDescription
    }
}
