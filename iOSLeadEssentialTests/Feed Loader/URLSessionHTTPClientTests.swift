//
//  URLSessionHTTPClientTests.swift
//  iOSLeadEssentialTests
//
//  Created by George Liu on 2020/8/23.
//  Copyright © 2020 George Liu. All rights reserved.
//

import XCTest

class URLSessionHTTPClient {

    let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func get(from url: URL) {
        session.dataTask(with: url, completionHandler: {_, _, _ in}).resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_resumeDataTaskWithURL() {
        let url = URL(string: "http://anyURL.com")!
        let session = URLSessionSpy()
        let dataTask = URLSessionDataTaskSpy()
        session.stub(with: url, dataTask: dataTask)

        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url)

        XCTAssertEqual(dataTask.count, 1)
    }

}

private extension URLSessionHTTPClientTests {
    class URLSessionSpy: URLSession {
        private var stubs = [URL: URLSessionDataTask]()

        func stub(with url: URL, dataTask: URLSessionDataTask) {
            stubs[url] = dataTask
        }

        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            return stubs[url] ?? URLSessionDataTaskFake()
        }
    }

    class URLSessionDataTaskFake: URLSessionDataTask {}

    class URLSessionDataTaskSpy: URLSessionDataTask {
        var count = 0
        override func resume() {
            count += 1
        }
    }
}
