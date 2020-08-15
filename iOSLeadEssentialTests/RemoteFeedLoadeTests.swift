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
        XCTAssertTrue(client.requestURLs.isEmpty)
    }

    func test_load_requestDataFromURL() {
        let url = URL(string: "https://www.youtube.com/")!
        let (sut, client) = makeSUT()
        sut.load()
        XCTAssertEqual(client.requestURLs, [url])
    }

    func test_loadTwice_requestDataFromURL() {
        let (sut, client) = makeSUT()
        sut.load()
        sut.load()

        XCTAssertEqual(client.requestURLs.count, 2)
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
        var requestURLs: [URL] = []

        func get(from url: URL) {
            requestURLs.append(url)
        }
    }
}
