//
//  Document.swift
//  AYMarkDown
//
//  Created by Aaron on 2020/9/1.
//  Copyright © 2020 Aaron. All rights reserved.
//

import AppKit

protocol Document {
    
    var name: String { set get }
    
    var fileType: String? { set get }
    
    var fileURL: URL? { set get }
    
    var fileModificationDate: Date? { set get }
    
    var fileCreationDate: Date? { set get }
    
    static func create(name: String,
                       fileType: String?,
                       fileURL: URL?,
                       fileCreationDate date1: Date?,
                       fileModificationDate date2: Date?) -> Any?
    
}

struct Directory: Document {
    
    var name: String
    
    var fileType: String?
    
    var fileURL: URL?
    
    var fileModificationDate: Date?
    
    var fileCreationDate: Date?
    
    static func create(name: String,
                       fileType: String?,
                       fileURL: URL?,
                       fileCreationDate date1: Date?,
                       fileModificationDate date2: Date?) -> Any? {
        Directory(name: name, fileType: fileType, fileURL: fileURL, fileModificationDate: date2, fileCreationDate: date1)
    }
    
}

class FileDocument: NSDocument, Document {
    
    var name: String = ""

    var fileCreationDate: Date?

    var originData: Data?

    class func create(name: String, fileType: String?, fileURL: URL?, fileCreationDate date1: Date?, fileModificationDate date2: Date?) -> Any? {
        guard let type = fileType else {
            return nil
        }
        let document = try? FileDocument(type: type)
        
        return document
    }

}

class ImageDocument: FileDocument {

    override class func create(name: String, fileType: String?, fileURL: URL?, fileCreationDate date1: Date?, fileModificationDate date2: Date?) -> Any? {
        return nil
    }
    
}

class TextDocument: FileDocument {

    override class func create(name: String, fileType: String?, fileURL: URL?, fileCreationDate date1: Date?, fileModificationDate date2: Date?) -> Any? {
        return nil
    }

}

class MarkDownDocument: TextDocument {

    override class func create(name: String, fileType: String?, fileURL: URL?, fileCreationDate date1: Date?, fileModificationDate date2: Date?) -> Any? {
        return nil
    }

}


