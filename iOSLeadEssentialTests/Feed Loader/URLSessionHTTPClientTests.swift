//
//  URLSessionHTTPClientTests.swift
//  iOSLeadEssentialTests
//
//  Created by George Liu on 2020/8/23.
//  Copyright © 2020 George Liu. All rights reserved.
//

import XCTest
@testable import iOSLeadEssential

class URLSessionHTTPClient {

    let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    struct UnexpectedValuesRepresentation: Error {}

    func get(from url: URL, completion: @escaping (HTTPResult) -> Void) {
        session.dataTask(with: url, completionHandler: {_, _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }).resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequest()
    }

    override class func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequest()
    }

    func test_getFromURL_performGetRequestWithURL() {
        let url = anyURL()
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")

        URLProtocolStub.observeRequsets { (request) in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }

        sut.get(from: url) { _ in }

        wait(for: [exp], timeout: 1.0)

    }
    func test_getFromURL_failOnRequestError() {
        let url = anyURL()
        let error = NSError(domain: "Any error", code: 1)
        URLProtocolStub.stub(with: url, data: nil, response: nil, error: error)

        let exp = expectation(description: "Wait for completion")

        let sut = makeSUT()
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

    func test_getFromURL_failOnAllNilValues() {
        let url = anyURL()
        URLProtocolStub.stub(with: url, data: nil, response: nil, error: nil)

        let exp = expectation(description: "Wait for completion")

        let sut = makeSUT()
        sut.get(from: url) { result in
            switch result {
            case .failure:
                break
            default:
                XCTFail("Expected failure with error, get \(result) instead")
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }


}

private extension URLSessionHTTPClientTests {

    func anyURL() -> URL {
        return URL(string: "http://anyURL.com")!
    }

    func makeSUT(file: StaticString = #file, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }

    class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?

        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }

        static func observeRequsets(observer: @escaping ((URLRequest) -> Void)) {
            requestObserver = observer
        }

        static func stub(with url: URL, data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }

        static func startInterceptingRequest() {
            URLProtocolStub.registerClass(URLProtocolStub.self)
        }

        static func stopInterceptingRequest() {
            URLProtocolStub.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }

        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            guard let stub = URLProtocolStub.stub else { return }

            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }

            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }

            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}

    }
}
