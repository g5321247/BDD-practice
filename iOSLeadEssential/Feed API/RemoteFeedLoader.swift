//
//  FeedLoader.swift
//  iOSLeadEssentialTests
//
//  Created by George Liu on 2020/8/15.
//  Copyright © 2020 George Liu. All rights reserved.
//

import Foundation

class RemoteFeedLoader: FeedLoader {
    private let client: HTTPClient
    private let url: URL

    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    typealias Result = LoadFeedResult<Error>

    init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }

    func load(completion: @escaping (Result) -> Void) {
        client.get(from: url, completion: { [weak self] (result) in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                completion(RemoteFeedLoader.map(data: data, response: response))

            case .failure(_):
                completion(.failure(.connectivity))
            }
        })
    }

    private static func map(data: Data, response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemMapper.map(data, response)
            return .success(items.toModel())
        } catch {
            return .failure(.invalidData)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModel() -> [FeedItem] {
        return map { FeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image) }
    }
}
