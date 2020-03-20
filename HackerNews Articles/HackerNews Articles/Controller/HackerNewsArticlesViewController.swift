//
//  ViewController.swift
//  HackerNews Articles
//
//  Created by Fernando Garcia on 19-03-20.
//  Copyright © 2020 Fernando Garcia. All rights reserved.
//

import UIKit

class HackerNewsArticlesViewController: UITableViewController {

    var articlesArray: [Article] = []
    var articleURL = ""
    var hackerNewsManager = HackerNewsManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hackerNewsManager.delegate = self
        hackerNewsManager.fetchArticles()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articlesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath)
        cell.textLabel?.text = articlesArray[indexPath.row].name
        return cell
    }
}

//MARK: - HackerNewsManagerDelegate

extension HackerNewsArticlesViewController: HackerNewsManagerDelegate {
    func didUpdateArticles(_ hackerNewsManager: HackerNewsManager, articles: [Article]) {
        DispatchQueue.main.async {
            self.articlesArray = articles
            self.tableView.reloadData()
        }
    }
    
    func didFailedWithError(error: Error) {
        print(error.localizedDescription)
    }
}
