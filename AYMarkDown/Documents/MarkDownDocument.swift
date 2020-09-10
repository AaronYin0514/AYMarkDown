//
//  MarkDownDocument.swift
//  AYMarkDown
//
//  Created by Aaron on 2020/9/10.
//  Copyright © 2020 Aaron. All rights reserved.
//

import AppKit

class MarkDownDocument: NSDocument, Document {

    var name: String = ""

    var fileCreationDate: Date?

    private(set) var originData: Data?
    private(set) var text: String = ""
    private(set) var richText: NSAttributedString = NSAttributedString(string: "")
    
    class func create(name: String, fileType: String?, fileURL: URL?, fileCreationDate date1: Date?, fileModificationDate date2: Date?) -> Any? {
        guard let type = fileType, let url = fileURL else {
            return nil
        }
        let document = try? MarkDownDocument(type: type)
        document?.fileURL = url
        try? document?.read(from: url, ofType: type)
        document?.fileCreationDate = date1
        document?.fileModificationDate = date2
        return document
    }
    
    class func create(text: String, name: String, fileURL: URL, completion: @escaping (_ document: MarkDownDocument?, _ error: Error?) -> Void) {
        let date = Date()
        let type = DocumentType.markdown.rawValue
        let document = MarkDownDocument.create(name: name, fileType: type, fileURL: fileURL, fileCreationDate: date, fileModificationDate: date) as? MarkDownDocument
        document?.text = text
        document?.richText = MMMarkdown.test(text)
        document?.save(to: fileURL, ofType: type, for: .saveAsOperation) { (error) in
            DispatchQueue.main.async {
                if error != nil {
                    completion(nil, error)
                } else {
                    completion(document, nil)
                }
            }
        }
    }
    
    class func save(text: String, fileURL: URL, completion: @escaping (_ document: MarkDownDocument?, _ error: Error?) -> Void) {
        let date = Date()
        let type = DocumentType.markdown.rawValue
        let name = fileURL.lastPathComponent
        let document = MarkDownDocument.create(name: name, fileType: type, fileURL: fileURL, fileCreationDate: date, fileModificationDate: date) as? MarkDownDocument
        document?.text = text
        document?.richText = MMMarkdown.test(text)
        document?.save(to: fileURL, ofType: type, for: .saveOperation) { (error) in
            DispatchQueue.main.async {
                if error != nil {
                    completion(nil, error)
                } else {
                    completion(document, nil)
                }
            }
        }
    }
    
    override func read(from url: URL, ofType typeName: String) throws {
        try super.read(from: url, ofType: typeName)
        fileURL = url
    }
    
    override func save(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, completionHandler: @escaping (Error?) -> Void) {
        fileURL = url
        super.save(to: url, ofType: typeName, for: saveOperation, completionHandler: completionHandler)
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        originData = data
        text = String(data: data, encoding: .utf8) ?? ""
        if text != "" {
            richText = MMMarkdown.test(text)
        }
    }
    
    override func data(ofType typeName: String) throws -> Data {
        guard let data = originData else {
            throw AYError.markdownSaveDataNull
        }
        return data
    }

}
