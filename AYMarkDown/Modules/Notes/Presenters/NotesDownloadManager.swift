//
//  NotesDownloadManager.swift
//  AYMarkDown
//
//  Created by Aaron on 2020/9/16.
//  Copyright © 2020 Aaron. All rights reserved.
//

import Foundation

class NotesDownloadManager: NSObject {

    private let _manager = DocumentManager<MarkDownDocument>()

    static let manager = NotesDownloadManager()

    func async(url: URL, completion: @escaping ([MarkDownDocument]) -> Void) {
        let _condition = Condition(type: "net.daringfireball.markdown", directoryURL: url)
        _manager.asyncQuery(_condition, completion: completion)
    }
}
