//
//  Article.swift
//  HackerNews Articles
//
//  Created by Fernando Garcia on 19-03-20.
//  Copyright © 2020 Fernando Garcia. All rights reserved.
//

import Foundation
import RealmSwift

class Article: Object {
    @objc dynamic var name = ""
    @objc dynamic var author = ""
    @objc dynamic var creationDate = Date()
    @objc dynamic var articleURL = ""
    @objc dynamic var compoundKey = ""
    
    override class func primaryKey() -> String? {
        return "compoundKey"
    }
    
    func compoundKeyValue(){
        compoundKey = "\(articleURL)\(author)"
    }
}
