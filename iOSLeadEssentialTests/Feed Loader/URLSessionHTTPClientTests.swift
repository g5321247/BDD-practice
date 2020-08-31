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

    func get(from url: URL, completion: @escaping (HTTPResult) -> Void) {
        let url = URL(string: "http://any.com")!

        session.dataTask(with: url, completionHandler: {_, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }).resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_failOnRequestError() {
        URLProtocolStub.startInterceptingRequest()
        let url = URL(string: "http://anyURL.com")!
        let error = NSError(domain: "Any error", code: 1)
        URLProtocolStub.stub(with: url, data: nil, response: nil, error: error)

        let exp = expectation(description: "Wait for completion")

        let sut = URLSessionHTTPClient()
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
        URLProtocolStub.unregisterClass(URLProtocolStub.self)
    }

}

private extension URLSessionHTTPClientTests {
    class URLProtocolStub: URLProtocol {
        private static var stub: Stub?

        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
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
        }

        override class func canInit(with request: URLRequest) -> Bool {
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
