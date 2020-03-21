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
import RealmSwift

class ArticleViewController: UIViewController {
    @IBOutlet weak var articleWebView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    
    let realm = try! Realm()
    var article = Article()
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        if let url = URL(string: article.articleURL) {
            articleWebView.navigationDelegate = self
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 10)
            articleWebView.load(request)
        } else {
            activityIndicator.stopAnimating()
            errorLabel.text = "Article is missing the URL"
            errorLabel.isHidden = false
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    func saveDownloadedArticle(article: Article) {
        do {
            try realm.write {
                realm.add(article, update: .modified)
            }
        } catch {
            print ("Error saving downloaded article \(error)")
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
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        saveDownloadedArticle(article: article)
    }
    
    func showWebViewError(_ error: Error) {
        activityIndicator.stopAnimating()
        errorLabel.isHidden = false
        errorLabel.text = error.localizedDescription
    }
}
