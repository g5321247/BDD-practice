//
//  LocalFeedItem.swift
//  iOSLeadEssential
//
//  Created by 劉峻岫 on 2020/10/5.
//  Copyright © 2020 George Liu. All rights reserved.
//

import Foundation

struct LocalFeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
