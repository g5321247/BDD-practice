//
//  FeedItemMapper.swift
//  iOSLeadEssential
//
//  Created by George Liu on 2020/8/20.
//  Copyright © 2020 George Liu. All rights reserved.
//

import Foundation

final class FeedItemMapper {

    struct Root: Decodable {
        let items: [Item]

        var feedItems: [FeedItem] {
            return items.map { $0.item }
        }
    }

    struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL

        var item: FeedItem {
            return FeedItem(
                id: id,
                description: description,
                location: location,
                imageURL: image
            )
        }
    }

    private static var OK_200: Int {
        return 200
    }

    static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(.invalidData)
        }
        return .success(root.feedItems)
    }
}
