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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

