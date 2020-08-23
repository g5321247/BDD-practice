//
//  URLSessionHTTPClientTests.swift
//  iOSLeadEssentialTests
//
//  Created by George Liu on 2020/8/23.
//  Copyright © 2020 George Liu. All rights reserved.
//

import XCTest
@testable import iOSLeadEssential

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

class URLSessionHTTPClient {

    let session: HTTPSession

    init(session: HTTPSession) {
        self.session = session
    }

    func get(from url: URL, completion: @escaping (HTTPResult) -> Void) {
        session.dataTask(with: url, completionHandler: {_, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }).resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_resumeDataTaskWithURL() {
        let url = URL(string: "http://anyURL.com")!
        let session = URLSessionSpy()
        let dataTask = URLSessionDataTaskSpy()
        session.stub(with: url, dataTask: dataTask)

        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url) { _ in }

        XCTAssertEqual(dataTask.count, 1)
    }

    func test_getFromURL_failOnRequestError() {
        let url = URL(string: "http://anyURL.com")!
        let session = URLSessionSpy()
        let dataTask = URLSessionDataTaskSpy()
        let error = NSError(domain: "", code: 1)
        session.stub(with: url, error: error)

        let exp = expectation(description: "Wait for completion")

        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("Expected failure with error \(error), get \(result) instead")
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

}

private extension URLSessionHTTPClientTests {
    class URLSessionSpy: HTTPSession {
        private var stubs = [URL: Stub]()

        private struct Stub {
            let task: HTTPSessionTask
            let error: Error?
        }

        func stub(with url: URL, dataTask: HTTPSessionTask = URLSessionDataTaskSpy(), error: Error? = nil) {
            stubs[url] = Stub(task: dataTask, error: error)
        }

        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {

            guard let stub = stubs[url] else {
                fatalError("Couldn't find stub for \(url)")
            }

            completionHandler(nil, nil, stub.error)
            return stub.task
        }
    }

    class URLSessionDataTaskFake: HTTPSessionTask {
        func resume() {
        }
    }

    class URLSessionDataTaskSpy: HTTPSessionTask {
        var count = 0
        func resume() {
            count += 1
        }
    }
}
