//
//  ViewController.swift
//  HackerNews Articles
//
//  Created by Fernando Garcia on 19-03-20.
//  Copyright © 2020 Fernando Garcia. All rights reserved.
//

import UIKit
import RealmSwift

class HackerNewsArticlesViewController: UITableViewController {

    @IBOutlet weak var articlesRefresher: UIRefreshControl!
    
    let realm = try! Realm()
    var articlesArray: [Article] = []
    var selectedArticleURL = ""
    var hackerNewsManager = HackerNewsManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hackerNewsManager.delegate = self
        hackerNewsManager.fetchArticles()
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showArticle") {
            if let destiny = segue.destination as? ArticleViewController {
                destiny.articleURL = selectedArticleURL
            }
        }
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        hackerNewsManager.fetchArticles()
    }
    
    //MARK: -- Table view methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articlesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath)
        cell.textLabel?.text = articlesArray[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedArticle = articlesArray[indexPath.row]
        selectedArticleURL = selectedArticle.articleURL
        saveDownloadedArticle(article: selectedArticle)
        performSegue(withIdentifier: "showArticle", sender: self)
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

//MARK: - HackerNewsManagerDelegate

extension HackerNewsArticlesViewController: HackerNewsManagerDelegate {
    func didUpdateArticles(_ hackerNewsManager: HackerNewsManager, articles: [Article]) {
        DispatchQueue.main.async {
            self.articlesArray = articles
            self.articlesRefresher.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    func didFailedWithError(error: Error) {
        print(error.localizedDescription)
    }
}
