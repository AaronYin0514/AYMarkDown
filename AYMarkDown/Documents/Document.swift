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
    
}

struct DocumentInfo: Document {
    
    var name: String
    
    var fileType: String?
    
    var fileURL: URL?
    
    var fileModificationDate: Date?
    
    var fileCreationDate: Date?
    
}

struct Directory: Document {
    
    var name: String
    
    var fileType: String?
    
    var fileURL: URL?
    
    var fileModificationDate: Date?
    
    var fileCreationDate: Date?
    
}

class FileDocument: NSDocument, Document {
    
    var name: String = ""
    
    var fileCreationDate: Date?
    
    var originData: Data?
    
    
    
}

class ImageDocument: FileDocument {
    
    
    
}

class TextDocument: FileDocument {
    
    
    
}

class MarkDownDocument: TextDocument {
    
    
    
}


