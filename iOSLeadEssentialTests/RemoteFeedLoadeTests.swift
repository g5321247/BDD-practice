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
        let err = NSError(domain: "Test", code: 0)

        var captureErrors: [RemoteFeedLoader.Error] = []
        sut.load { (err) in
            captureErrors.append(err)
        }

        client.complete(with: err, at: 0)

        XCTAssertEqual(captureErrors, [.connectivity])
    }

    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [100, 201, 300, 400, 500]

        samples.enumerated().forEach { index, code in
            var captureErrors: [RemoteFeedLoader.Error] = []
            sut.load { (err) in
                captureErrors.append(err)
            }

            client.complete(withStatusCode: code, at: index)
            XCTAssertEqual(captureErrors, [.invalidData])
        }
    }
}

// MARK: Helper
private extension RemoteFeedLoadeTests {

    func makeSUT(url: URL = URL(string: "https://www.youtube.com/")!) -> (sut:  RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(
            client: client,
            url: url
        )

        return (sut: sut, client: client)
    }

    class HTTPClientSpy: HTTPClient {
        var messages: [(url: URL, completion: (Result<HTTPURLResponse, Error>) -> Void)] = []

        var requestURLs: [URL] {
            return messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (Result<HTTPURLResponse, Error>) -> Void) {
            messages.append((url: url, completion: completion))
        }

        func complete(with err: Error, at index: Int = 0) {
            messages[index].completion(.failure(err))
        }

        func complete(withStatusCode code: Int, at index: Int = 0) {

            let response = HTTPURLResponse(
                url: requestURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(response))
        }
    }
}
