//
//  AYDocument.swift
//  AYMarkDown
//
//  Created by Aaron on 2020/8/5.
//  Copyright © 2020 Aaron. All rights reserved.
//

import AppKit

class AYDocument: NSDocument {
    
    enum DocumentType {
        case text, image
    }
    
    private var _ay_data: Data?
    
    private(set) var text: String?
    
    private(set) var image: NSImage?
    
    private(set) var remoteFileURL: URL?
    
    var documentType = DocumentType.text
    
    /// 标题 - Markdown解析的标题，第一个
    private(set) var richText: NSAttributedString?
    
    func setText(_ text: String) {
        self.text = text
        if let data = text.data(using: .utf8) {
            _ay_data = data
        }
    }
    
    func setImage(_ url: URL) throws {
        _ay_data = try Data(contentsOf: url)
    }
    
    override func read(from url: URL, ofType typeName: String) throws {
        try super.read(from: url, ofType: typeName)
        remoteFileURL = url
    }
    
    override func save(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, completionHandler: @escaping (Error?) -> Void) {
        remoteFileURL = url
        super.save(to: url, ofType: typeName, for: saveOperation, completionHandler: completionHandler)
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        _ay_data = data
        
        text = String(data: data, encoding: .utf8)
        if text != nil {
            richText = MMMarkdown.test(text!)
        }
    }
    
    override func data(ofType typeName: String) throws -> Data {
        if _ay_data == nil {
            throw AYError.markdownSaveDataNull
        }
        return _ay_data!
    }
    
    
    
}
