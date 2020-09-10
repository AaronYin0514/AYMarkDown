//
//  HTMLDocument.swift
//  AYMarkDown
//
//  Created by Aaron on 2020/9/10.
//  Copyright © 2020 Aaron. All rights reserved.
//

import AppKit

class HTMLDocument: NSDocument {
    
    private(set) var html: String?
    private(set) var originData: Data?
    
    class func save(html: String, fileURL: URL, completion: @escaping (_ document: HTMLDocument?, _ error: Error?) -> Void) {
        guard let data = html.data(using: .utf8) else {
            completion(nil, AYError.markdownSaveDataNull)
            return
        }
        let type = "public.html"
        do {
            let document = try HTMLDocument(contentsOf: fileURL, ofType: type)
            document.originData = data
            document.html = html
            document.fileURL = fileURL
            document.save(to: fileURL, ofType: type, for: .saveOperation) { (error) in
                DispatchQueue.main.async {
                    if error != nil {
                        completion(nil, error)
                    } else {
                        completion(document, nil)
                    }
                }
            }
        } catch {
            completion(nil, error)
        }
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        originData = data
        html = String(data: data, encoding: .utf8)
    }
    
    override func data(ofType typeName: String) throws -> Data {
        guard let data = originData else {
            throw AYError.markdownSaveDataNull
        }
        return data
    }
    
}
