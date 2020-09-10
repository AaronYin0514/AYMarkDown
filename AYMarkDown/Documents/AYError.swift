//
//  AYError.swift
//  AYMarkDown
//
//  Created by Aaron on 2020/8/6.
//  Copyright © 2020 Aaron. All rights reserved.
//

import Foundation

enum AYError: Error {
    case markdownSaveDataNull
    case iCloudNotOpen
}

extension AYError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .markdownSaveDataNull:
            return "MarkDown内容为空"
        case .iCloudNotOpen:
            return "没有开启iCloud功能"
        }
    }
    
}
