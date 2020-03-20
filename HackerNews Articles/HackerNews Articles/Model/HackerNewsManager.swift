//
//  HackerNewsManager.swift
//  HackerNews Articles
//
//  Created by Fernando Garcia on 19-03-20.
//  Copyright © 2020 Fernando Garcia. All rights reserved.
//

import Foundation

protocol HackerNewsManagerDelegate {
    func didUpdateArticles(_ hackerNewsManager: HackerNewsManager, articles: [Article])
    func didFailedWithError(error: Error)
}

class HackerNewsManager: NSObject, URLSessionDataDelegate, URLSessionTaskDelegate {
    
    var delegate: HackerNewsManagerDelegate?
    
    let hackerNewsURL = "https://hn.algolia.com/api/v1/search_by_date?query=ios"
    
    lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        if let delegate = self.delegate {
            return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        } else {
            return URLSession(configuration: config)
        }
    }()
    
    private var dataTask: URLSessionDataTask!
    var results = [String: NSMutableData]()
    let formatter = DateFormatter()
    let currentDate = Date()
    
    func fetchArticles() {
        let url = URL(string: hackerNewsURL)!
        
        dataTask = session.dataTask(with: url)
        dataTask.resume()
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let key = String(dataTask.taskIdentifier)
        var result = results[key]
        if result == nil {
            result = NSMutableData(data: data)
            results[key] = result
        } else {
            result?.append(data)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let _ = error {
                delegate?.didUpdateArticles(self, articles: [])
        } else {
            let key = String(task.taskIdentifier)
            if let result = results[key] as Data? {
                if let articles = self.parseJSONToArticle(articlesData: result) {
                    delegate?.didUpdateArticles(self, articles: articles)
                }
            } else {
                delegate?.didUpdateArticles(self, articles: [])
            }
        }
    }
    
    func parseJSONToArticle(articlesData: Data) -> [Article]? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(HackerNewsData.self, from: articlesData)
            let articles = loopDataForArticles(data: decodedData)
            
            return articles

        }catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    func loopDataForArticles(data: HackerNewsData) -> [Article] {
        var articles = [Article]()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000Z"
        
        for hit in data.hits {
            var name = ""
            if let safeName = hit.story_title {
                name = safeName
            } else if let safeName = hit.title {
                name = safeName
            }
            
            let author = hit.author
            
            let creationDate = hit.created_at
            if let date = formatter.date(from: creationDate) {
                let relativeData = date.elapsedTime(toDate: currentDate)
                print(relativeData)
            }
            
            var URL = ""
            if let safeURL = hit.story_url {
                URL = safeURL
            }
            
            let articleModel = Article(name: name, author: author, creationElapsedTime: creationDate, articleURL: URL)
            articles.append(articleModel)
        }
        return articles
    }
}
