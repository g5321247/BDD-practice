//
//  FeedLoader.swift
//  iOSLeadEssentialTests
//
//  Created by George Liu on 2020/8/15.
//  Copyright © 2020 George Liu. All rights reserved.
//

import Foundation

struct RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL

    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }

    init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }

    func load(completion: @escaping (Result) -> Void) {
        client.get(from: url, completion: { (result) in

            switch result {
            case let .success((data, response)):
                do {
                    let items = try FeedItemMapper.map(data, response)
                    completion(.success(items))
                } catch {
                    completion(.failure(.invalidData))
                }

            case .failure(_):
                completion(.failure(.connectivity))
            }
        })
    }
}


