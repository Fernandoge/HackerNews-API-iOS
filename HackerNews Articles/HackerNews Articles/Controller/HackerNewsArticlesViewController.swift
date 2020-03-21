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
    var articlesArray: [[Article]] = []
    var selectedArticleURL = ""
    var hackerNewsManager = HackerNewsManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hackerNewsManager.delegate = self
        hackerNewsManager.fetchArticles()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Reload downloaded articles
        if articlesArray.count > 0 {
            let downloadedArticles = getDownloadedArticles()
            loadArticles(recentArticles: articlesArray[0], downloadedArticles: downloadedArticles)
        }
        
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
    
    let headerTitles = ["Recent Articles", "Downloaded Articles"]
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < headerTitles.count {
            return headerTitles[section]
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel?.textAlignment = .center
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return articlesArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articlesArray[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath)
        cell.textLabel?.text = articlesArray[indexPath.section][indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedArticle = articlesArray[indexPath.section][indexPath.row]
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
    
    func getDownloadedArticles() -> [Article]{
        let downloadedArticles = realm.objects(Article.self)
        let downloadedArticlesArray = Array(downloadedArticles.reversed())
        return downloadedArticlesArray
    }
    
    func loadArticles(recentArticles: [Article], downloadedArticles: [Article]) {
        articlesArray = []
        articlesArray.append(recentArticles)
        articlesArray.append(downloadedArticles)
        DispatchQueue.main.async {
            self.articlesRefresher.endRefreshing()
            self.tableView.reloadData()
        }
    }
}

//MARK: - HackerNewsManagerDelegate

extension HackerNewsArticlesViewController: HackerNewsManagerDelegate {
    func didUpdateArticles(_ hackerNewsManager: HackerNewsManager, articles: [Article]) {
        let downloadedArticles = getDownloadedArticles()
        loadArticles(recentArticles: articles, downloadedArticles: downloadedArticles)
    }
    
    func didFailedWithError(error: Error) {
        print(error.localizedDescription)
    }
}
