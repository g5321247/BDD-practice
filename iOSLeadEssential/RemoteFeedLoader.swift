//
//  FeedLoader.swift
//  iOSLeadEssentialTests
//
//  Created by George Liu on 2020/8/15.
//  Copyright © 2020 George Liu. All rights reserved.
//

import Foundation


protocol HTTPClient {
    typealias HTTPResult = Result<(Data, HTTPURLResponse), Error>

    func get(from url: URL, completion: @escaping (HTTPResult) -> Void)
}

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
            case .success(let data, _):
//                if response.statusCode != 200 {
                if let _ = try? JSONSerialization.jsonObject(with: data, options: []) {
                    completion(.success([]))
                } else {
                    completion(.failure(.invalidData))
                }

//                }
            case .failure(_):
                completion(.failure(.connectivity))
            }
        })
    }
}

//private struct Root {
//    let items: [FeedItem]
//}
