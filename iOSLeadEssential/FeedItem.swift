//
//  FeedItem.swift
//  iOSLeadEssential
//
//  Created by George Liu on 2020/8/18.
//  Copyright © 2020 George Liu. All rights reserved.
//

import Foundation

struct FeedItem: Equatable, Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}

extension FeedItem {
    enum CodingKeys: String, CodingKey {
        case id
        case description
        case location
        case imageURL = "image"
    }
}
