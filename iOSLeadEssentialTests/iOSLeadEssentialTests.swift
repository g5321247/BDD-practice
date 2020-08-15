//
//  iOSLeadEssentialTests.swift
//  iOSLeadEssentialTests
//
//  Created by George Liu on 2020/8/15.
//  Copyright © 2020 George Liu. All rights reserved.
//

import XCTest
@testable import iOSLeadEssential

class iOSLeadEssentialTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        let url = URL(string: "https://www.youtube.com/")!
        let _ = FeedLoader(
            client: client,
            url: url
        )

        XCTAssertNil(client.requestURL)
    }

    func test_load_requestDataFromURL() {
        let client = HTTPClientSpy()
        let url = URL(string: "https://www.youtube.com/")!
        let sut = FeedLoader(
            client: client,
            url: url
        )

        sut.load()
        XCTAssertEqual(client.requestURL, url)
    }


}

// MARK: Client Spy
private extension iOSLeadEssentialTests {
    class HTTPClientSpy: HTTPClient {
        var requestURL: URL?

        func get(from url: URL) {
            requestURL = url
        }
    }
}
