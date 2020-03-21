//
//  ViewController.swift
//  HackerNews Articles
//
//  Created by Fernando Garcia on 19-03-20.
//  Copyright © 2020 Fernando Garcia. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class HackerNewsArticlesViewController: UITableViewController {

    @IBOutlet weak var articlesRefresher: UIRefreshControl!
    
    let realm = try! Realm()
    var articlesArray: [[Article]] = []
    var selectedArticleURL = ""
    var hackerNewsManager = HackerNewsManager()
    var currentDate = Date()
    
    //MARK: -- View lifecycle
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! SwipeTableViewCell
        let article = articlesArray[indexPath.section][indexPath.row]
        cell.textLabel?.text = article.name
        let articleElapsedTime = article.creationDate.elapsedTime(toDate: currentDate)
        cell.detailTextLabel?.text = "\(article.author) - \(articleElapsedTime)"
        cell.delegate = self
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
    
    func saveDeletedArticle(article: Article) {
        let deletedArticle = DeletedArticle()
        deletedArticle.articleURL = article.articleURL
        deletedArticle.author = article.author
        do {
            try realm.write {
                realm.add(deletedArticle)
            }
        } catch {
            print ("Error saving deleted article \(error)")
        }
    }
    
    func deleteArticle(article: Article, isDownloaded: Bool) {
        saveDeletedArticle(article: article)
        //Delete the article from database if it's was downloaded before
        if isDownloaded {
            try! realm.write {
                realm.delete(article)
            }
        }
    }
    
    func getDownloadedArticles() -> [Article]{
        let downloadedArticles = realm.objects(Article.self)
        let downloadedArticlesArray = Array(downloadedArticles)
        let sortedDownloadedArticles = downloadedArticlesArray.sorted(by: { $0.creationDate.compare($1.creationDate) == .orderedDescending } )
        return sortedDownloadedArticles
    }
    
    func loadArticles(recentArticles: [Article], downloadedArticles: [Article]) {
        //Get current date to calculate article creation elapsed time
        currentDate = Date()
        //Create the new articles array using fetched articles and the articles from the database
        articlesArray = []
        articlesArray.append(recentArticles)
        articlesArray.append(downloadedArticles)
        //End refresher and reload table view data
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

//MARK: - SwipeTableViewCellDelegate

extension HackerNewsArticlesViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            let removedArticle = self.articlesArray[indexPath.section][indexPath.row]
            let isDownloaded = indexPath.section == 0 ? false : true
            self.deleteArticle(article: removedArticle, isDownloaded: isDownloaded)
            self.articlesArray[indexPath.section].remove(at: indexPath.row)
        }

        return [deleteAction]
        
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        return options
    }
}
