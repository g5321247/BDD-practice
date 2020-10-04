//
//  LocalFeedLoader.swift
//  iOSLeadEssential
//
//  Created by George Liu on 2020/10/4.
//  Copyright © 2020 George Liu. All rights reserved.
//

import Foundation

class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date

    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCacheFeed { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                completion(error)
            } else {
                self.insert(items: items, completion: completion)
            }
        }
    }

    private func insert(items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.insert(items, timestamp: currentDate(), compltion: { [weak self] error in
            guard self != nil else { return }
            completion(error)
        })
    }
}

protocol FeedStore {
    typealias DeleteCompletion = (Error?) -> Void
    typealias InsertCompletion = (Error?) -> Void

    func deleteCacheFeed(completion: @escaping DeleteCompletion)
    func insert(_ items: [FeedItem], timestamp: Date, compltion: @escaping InsertCompletion)
}
