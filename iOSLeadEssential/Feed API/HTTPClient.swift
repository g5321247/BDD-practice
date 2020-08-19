//
//  HTTPClient.swift
//  iOSLeadEssential
//
//  Created by George Liu on 2020/8/20.
//  Copyright © 2020 George Liu. All rights reserved.
//

import Foundation

typealias HTTPResult = Result<(Data, HTTPURLResponse), Error>

protocol HTTPClient {

    func get(from url: URL, completion: @escaping (HTTPResult) -> Void)
}

