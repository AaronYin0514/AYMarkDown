//
//  Document.swift
//  AYMarkDown
//
//  Created by Aaron on 2020/9/1.
//  Copyright © 2020 Aaron. All rights reserved.
//

import AppKit

enum DocumentType: String {
    case directory = "public.folder"
    case markdown = "net.daringfireball.markdown"
    case html = "public.html"
    case image = "public.image"
}

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
