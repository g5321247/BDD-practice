//
//  LocalFeedLoaderTests.swift
//  iOSLeadEssentialTests
//
//  Created by 劉峻岫 on 2020/9/29.
//  Copyright © 2020 George Liu. All rights reserved.
//

import XCTest
@testable import iOSLeadEssential

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
        let localItems = items.map { LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }

        sut.save(items) { _ in }
        store.completeDeletionSuccess(at: 0)
        XCTAssertEqual(store.messages, [.delete, .insert(localItems, timestamp)])
    }

    func test_save_failOnDeletionError() {
        let (sut, store) = makeSUT()
        let expectedError = anyNSError()

        expect(sut, with: expectedError, when: ({
            store.completeDeletion(with: anyNSError(), at: 0)
        }))
    }

    func test_save_failOnInsertionError() {
        let (sut, store) = makeSUT()
        let expectedError = anyNSError()

        expect(sut, with: expectedError, when: ({
            store.completeDeletionSuccess()
            store.completeInsertion(with: expectedError, at: 0)
        }))
    }

    func test_save_successOnInsertion() {
        let (sut, store) = makeSUT()

        expect(sut, with: nil, when: ({
            store.completeDeletionSuccess()
            store.completeInsertionSuccessfully()
        }))
    }

    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDealloacted() {
        let store = FeedStoreSpy()
        let timestamp = Date()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: { return timestamp })

        var receiveResult: [LocalFeedLoader.SaveResult] = []
        sut?.save([], completion: { error in
            receiveResult.append(error)
        })

        sut = nil
        store.completeDeletion(with: anyNSError())
        XCTAssertTrue(receiveResult.isEmpty)
    }

    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDealloacted() {
        let store = FeedStoreSpy()
        let timestamp = Date()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: { return timestamp })

        var receiveResult: [LocalFeedLoader.SaveResult] = []
        sut?.save([], completion: { error in
            receiveResult.append(error)
        })

        store.completeDeletionSuccess()
        sut = nil
        store.completeInsertion(with: anyNSError())
        XCTAssertTrue(receiveResult.isEmpty)
    }


    private func expect(_ sut: LocalFeedLoader, with expectedError: NSError?, when: () -> Void, file: StaticString = #file, line: UInt = #line) {

        let expect = expectation(description: "Wait for save completion")
        var receiveError: Error?

        sut.save([uniqueItem()]) { error in
            receiveError = error
            expect.fulfill()
        }

        when()
        wait(for: [expect], timeout: 1.0)

        XCTAssertEqual(receiveError as NSError?, expectedError, file: file, line: line)
    }

    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
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

extension CacheFeedUseCaseTests {
    private class FeedStoreSpy: FeedStore {

        private var deleteCompletions: [DeleteCompletion] = []
        private var insertCompletions: [InsertCompletion] = []

        var messages: [ReceiveMessage] = []

        enum ReceiveMessage: Equatable {
            case delete
            case insert([LocalFeedItem], Date)
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

        func insert(_ items: [LocalFeedItem], timestamp: Date, compltion: @escaping InsertCompletion) {
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
}
