//
//  DeletedArticle.swift
//  HackerNews Articles
//
//  Created by Fernando Garcia on 20-03-20.
//  Copyright © 2020 Fernando Garcia. All rights reserved.
//

import RealmSwift

class DeletedArticle: Object {
    @objc dynamic var articleURL = ""
    @objc dynamic var author = ""
}
