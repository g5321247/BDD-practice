//
//  FeedStore.swift
//  iOSLeadEssential
//
//  Created by George Liu on 2020/10/4.
//  Copyright © 2020 George Liu. All rights reserved.
//

import Foundation

protocol FeedStore {
    typealias DeleteCompletion = (Error?) -> Void
    typealias InsertCompletion = (Error?) -> Void

    func deleteCacheFeed(completion: @escaping DeleteCompletion)
    func insert(_ items: [LocalFeedItem], timestamp: Date, compltion: @escaping InsertCompletion)
}

struct LocalFeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
