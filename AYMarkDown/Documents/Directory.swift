//
//  Directory.swift
//  AYMarkDown
//
//  Created by Aaron on 2020/9/10.
//  Copyright © 2020 Aaron. All rights reserved.
//

import AppKit

struct Directory: Document {
    
    var name: String
    
    var fileType: String? = DocumentType.directory.rawValue
    
    var fileURL: URL?
    
    var fileModificationDate: Date? = Date()
    
    var fileCreationDate: Date? = Date()
    
    static func create(name: String,
                       fileType: String?,
                       fileURL: URL?,
                       fileCreationDate date1: Date?,
                       fileModificationDate date2: Date?) -> Any? {
        Directory(name: name, fileType: fileType, fileURL: fileURL, fileModificationDate: date2, fileCreationDate: date1)
    }
    
    
    
}
