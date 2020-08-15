//
//  FeedLoader.swift
//  iOSLeadEssentialTests
//
//  Created by George Liu on 2020/8/15.
//  Copyright © 2020 George Liu. All rights reserved.
//

import Foundation

protocol HTTPClient {
    func get(from: URL, completion: @escaping (Error) -> Void)
}

struct RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL

    enum Error: Swift.Error {
        case connectivity
    }

    init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }

    func load(completion: @escaping (Error) -> Void) {
        client.get(from: url, completion: { err in
            completion(.connectivity)
        })
    }
}


