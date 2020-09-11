//
//  DocumentDownloadManager.swift
//  AYMarkDown
//
//  Created by Aaron on 2020/9/11.
//  Copyright © 2020 Aaron. All rights reserved.
//

import AppKit

class DocumentDownloadManager: NSObject {
    
    private let _manager = DocumentManager<Directory>()
    
    private let _condition = Condition(type: "public.folder", ignoreFiles: [__resources_document_name])
    
    static let manager = DocumentDownloadManager()
    
    func async(completion: @escaping ([Directory]) -> Void) {
        _manager.asyncQuery(_condition, completion: completion)
    }
    
}
