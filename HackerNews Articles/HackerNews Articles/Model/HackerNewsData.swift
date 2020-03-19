//
//  HackerNewsData.swift
//  HackerNews Articles
//
//  Created by Fernando Garcia on 19-03-20.
//  Copyright © 2020 Fernando Garcia. All rights reserved.
//

import Foundation

struct HackerNewsData: Decodable {
    var hits: [Hits]
}

struct Hits: Decodable {
    let title: String?
    let story_title: String?
    let author: String
    let created_at: String
    let story_url: String?
}
