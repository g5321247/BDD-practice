//
//  LocalFeedLoaderTests.swift
//  iOSLeadEssentialTests
//
//  Created by 劉峻岫 on 2020/9/29.
//  Copyright © 2020 George Liu. All rights reserved.
//

import XCTest
@testable import iOSLeadEssential

class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date

    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    func save(_ items: [FeedItem]) {
        store.deleteCacheFeed { [unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate())
            }
        }
    }
}

class FeedStore {
    typealias Completion = (Error?) -> Void

    var deleteCacheCount = 0
    private var completions: [Completion] = []
    var insertions: [(items: [FeedItem], timestamp: Date)] = []

    func deleteCacheFeed(completion: @escaping Completion) {
        deleteCacheCount += 1

        completions.append(completion)
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        completions[index](error)
    }

    func completeDeletionSuccess(at index: Int = 0) {
        completions[index](nil)
    }

    func insert(_ items: [FeedItem], timestamp: Date) {
        insertions.append((items: items, timestamp: timestamp))
    }

}

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.deleteCacheCount, 0)
    }

    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]

        sut.save(items)

        XCTAssertEqual(store.deleteCacheCount, 1)
    }

    func test_save_doesNotRequestInsertionOnCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]

        sut.save(items)
        store.completeDeletion(with: anyNSError(), at: 0)
        XCTAssertEqual(store.insertions.count, 0)
    }

    func test_save_requestInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { return timestamp })
        let items = [uniqueItem(), uniqueItem()]

        sut.save(items)
        store.completeDeletionSuccess(at: 0)
        XCTAssertEqual(store.insertions.count, 1)
        XCTAssertEqual(store.insertions.first?.items, items)
        XCTAssertEqual(store.insertions.first?.timestamp, timestamp)
    }

    private func makeSUT(currentDate: @escaping () -> Date = Date.init,file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)

        trackForMemoryLeak(store, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)

        return (sut: sut, store: store)
    }

    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "ant", location: "any", imageURL: anyURL())
    }

    private func anyURL() -> URL {
        return URL(string: "https://anyURL.comt")!
    }

    private func anyNSError() -> NSError {
        return NSError(domain: "Any error", code: 1)
    }

}
