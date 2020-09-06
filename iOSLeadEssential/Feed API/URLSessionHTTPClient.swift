//
//  URLSessionHTTPClient.swift
//  iOSLeadEssential
//
//  Created by George Liu on 2020/9/7.
//  Copyright © 2020 George Liu. All rights reserved.
//

import Foundation

// 在測試的保護下，即使物件改成 URLSession 的 extension，跑測試還是沒問題
class URLSessionHTTPClient: HTTPClient {

    let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    struct UnexpectedValuesRepresentation: Error {}

    func get(from url: URL, completion: @escaping (HTTPResult) -> Void) {
        session.dataTask(with: url, completionHandler: { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }).resume()
    }
}
