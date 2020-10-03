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

    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCacheFeed { [unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate(), compltion: completion)
            } else {
                completion(error)
            }
        }
    }
}

class FeedStore {
    typealias DeleteCompletion = (Error?) -> Void
    typealias InsertCompletion = (Error?) -> Void

    private var deleteCompletions: [DeleteCompletion] = []
    private var insertCompletions: [InsertCompletion] = []

    var messages: [ReceiveMessage] = []

    enum ReceiveMessage: Equatable {
        case delete
        case insert([FeedItem], Date)
    }

    func deleteCacheFeed(completion: @escaping DeleteCompletion) {
        messages.append(.delete)
        deleteCompletions.append(completion)
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        deleteCompletions[index](error)
    }

    func completeDeletionSuccess(at index: Int = 0) {
        deleteCompletions[index](nil)
    }

    func insert(_ items: [FeedItem], timestamp: Date, compltion: @escaping InsertCompletion) {
        messages.append(.insert(items, timestamp))
        insertCompletions.append(compltion)
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
        insertCompletions[index](error)
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
        insertCompletions[index](nil)
    }
}

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.messages.count, 0)
    }

    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]

        sut.save(items) { _ in }

        XCTAssertEqual(store.messages, [.delete])
    }

    func test_save_doesNotRequestInsertionOnCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]

        sut.save(items) { _ in }
        store.completeDeletion(with: anyNSError(), at: 0)
        XCTAssertEqual(store.messages, [.delete])
    }

    func test_save_requestInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { return timestamp })
        let items = [uniqueItem(), uniqueItem()]

        sut.save(items) { _ in }
        store.completeDeletionSuccess(at: 0)
        XCTAssertEqual(store.messages, [.delete, .insert(items, timestamp)])
    }

    func test_save_failOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]

        let expect = expectation(description: "Wait for save completion")
        var captureError: Error?

        sut.save(items) { error in
            captureError = error
            expect.fulfill()
        }

        store.completeDeletion(with: anyNSError(), at: 0)
        wait(for: [expect], timeout: 1.0)

        XCTAssertEqual(captureError as NSError?, anyNSError())
    }

    func test_save_failOnInsertionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]

        let expect = expectation(description: "Wait for save completion")
        var captureError: Error?

        sut.save(items) { error in
            captureError = error
            expect.fulfill()
        }

        store.completeDeletionSuccess()
        store.completeInsertion(with: anyNSError(), at: 0)
        wait(for: [expect], timeout: 1.0)

        XCTAssertEqual(captureError as NSError?, anyNSError())
    }

    func test_save_successOnInsertion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]

        let expect = expectation(description: "Wait for save completion")
        var captureError: Error?

        sut.save(items) { error in
            captureError = error
            expect.fulfill()
        }

        store.completeDeletionSuccess()
        store.completeInsertionSuccessfully()
        wait(for: [expect], timeout: 1.0)

        XCTAssertNil(captureError)
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
