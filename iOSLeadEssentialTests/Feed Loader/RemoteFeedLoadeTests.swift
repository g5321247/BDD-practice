//
//  iOSLeadEssentialTests.swift
//  iOSLeadEssentialTests
//
//  Created by George Liu on 2020/8/15.
//  Copyright © 2020 George Liu. All rights reserved.
//

import XCTest
@testable import iOSLeadEssential

class RemoteFeedLoadeTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        XCTAssertTrue(client.messages.isEmpty)
    }

    func test_load_requestDataFromURL() {
        let url = URL(string: "https://www.youtube.com/")!
        let (sut, client) = makeSUT()
        sut.load {_ in }
        XCTAssertEqual(client.requestURLs, [url])
    }

    func test_loadTwice_requestDataFromURL() {
        let (sut, client) = makeSUT()
        sut.load {_ in }
        sut.load {_ in }

        XCTAssertEqual(client.requestURLs.count, 2)
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()

        expect(sut, completeWithResult: .failure(.connectivity), when: {
            let err = NSError(domain: "Test", code: 0)
            client.complete(with: err, at: 0)
        })
    }

    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [100, 201, 300, 400, 500]

        samples.enumerated().forEach { index, code in
            expect(sut, completeWithResult: .failure(.invalidData), when: {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }

    func test_load_deliversInvalidDataOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut, completeWithResult: .failure(.invalidData), when: {
            let invalidJSONData = Data("invalid JSON".utf8)
            client.complete(withStatusCode: 200, data: invalidJSONData)
        })
    }

    func test_load_deliversEmptyItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut, completeWithResult: .success([]), when: {
            let emptyJSONList = Data("{\"items\":[]}".utf8)
            client.complete(withStatusCode: 200, data: emptyJSONList)
        })
    }

    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        let item1 = makeFeedItem(
            id: UUID(),
            imageURL: URL(string: "https://www.youtube.com/")!
        )
        let item2 = makeFeedItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "https://www.youtube.com/")!
        )

        expect(sut, completeWithResult: .success([item1.model, item2.model]), when: {
            let josnData = makeItemsJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: josnData)
        })
    }

    func test_load_doesNotDeliverResultAfterSUTDeallocated() {
        let client = HTTPClientSpy()
        let url = URL(string: "https://www.youtube.com/")!
        var sut: RemoteFeedLoader? = RemoteFeedLoader(client: client, url: url)

        var captureResults = [RemoteFeedLoader.Result]()
        sut?.load { (result) in
            captureResults.append(result)
        }
        sut = nil

        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        XCTAssertTrue(captureResults.isEmpty)
    }
}

// MARK: Helper
private extension RemoteFeedLoadeTests {

    func makeSUT(url: URL = URL(string: "https://www.youtube.com/")!, file: StaticString = #file, line: UInt = #line) -> (sut:  RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(
            client: client,
            url: url
        )

        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(client, file: file, line: line)

        return (sut: sut, client: client)
    }

    func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been delocated. Potential memory leak" ,file:file, line: line)
        }

    }

    func expect(_ sut: RemoteFeedLoader, completeWithResult expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {

        let exp = expectation(description: "wait for load completion")

        sut.load { (receivedResult) in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) but got \(receivedResult) instead")
            }

            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)
    }

    class HTTPClientSpy: HTTPClient {
        // closure retain here, it might cause retain cycle
        var messages: [(url: URL, completion: (HTTPResult) -> Void)] = []

        var requestURLs: [URL] {
            return messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (HTTPResult) -> Void) {
            messages.append((url: url, completion: completion))
        }

        func complete(with err: Error, at index: Int = 0) {
            messages[index].completion(.failure(err))
        }

        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {

            let response = HTTPURLResponse(
                url: requestURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
                )!
            messages[index].completion(.success((data, response)))
        }
    }

    func makeFeedItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(
            id: id,
            description: description,
            location: location,
            imageURL: imageURL
        )

        let json = [
            "id": item.id.uuidString,
            "description": item.description,
            "location": item.location,
            "image": item.imageURL.absoluteString
        ].compactMapValues { $0 }

        return (item, json)
    }

    func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = try! JSONSerialization.data(withJSONObject: ["items": items], options: [])
        return json
    }
}
