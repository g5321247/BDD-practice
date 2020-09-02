//
//  XCTestCaseExtension.swift
//  iOSLeadEssentialTests
//
//  Created by George Liu on 2020/9/2.
//  Copyright © 2020 George Liu. All rights reserved.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been delocated. Potential memory leak" ,file:file, line: line)
        }
    }
}
