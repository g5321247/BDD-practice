//
//  LocalFeedLoaderTests.swift
//  iOSLeadEssentialTests
//
//  Created by 劉峻岫 on 2020/9/29.
//  Copyright © 2020 George Liu. All rights reserved.
//

import XCTest

class LocalFeedLoader {
    let store: FeedStore

    init(store: FeedStore) {
        self.store = store
    }

    func loadFeed() {
    }
}

class FeedStore {
    var deleteCacheCount = 0
}

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        let _ = LocalFeedLoader(store: store)

        XCTAssertEqual(store.deleteCacheCount, 0)
    }
}
