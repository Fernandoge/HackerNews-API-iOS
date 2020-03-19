//
//  Article.swift
//  HackerNews Articles
//
//  Created by Fernando Garcia on 19-03-20.
//  Copyright © 2020 Fernando Garcia. All rights reserved.
//

import Foundation

struct Article: Codable {
    var name: String
    var author: String
    var creationElapsedTime: String
    var articleURL: String
}
