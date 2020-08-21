//
//  FeedLoader.swift
//  iOSLeadEssential
//
//  Created by George Liu on 2020/8/21.
//  Copyright © 2020 George Liu. All rights reserved.
//

import Foundation

typealias LoadFeedResult<E: Error> = Result<[FeedItem], E>

protocol FeedLoader {
    associatedtype Error: Swift.Error

    func load(completion: @escaping (LoadFeedResult<Error>) -> Void)
}
