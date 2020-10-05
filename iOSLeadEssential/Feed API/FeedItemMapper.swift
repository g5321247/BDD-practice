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
        let items: [RemoteFeedItem]
    }


    private static var OK_200: Int {
        return 200
    }

    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
}
