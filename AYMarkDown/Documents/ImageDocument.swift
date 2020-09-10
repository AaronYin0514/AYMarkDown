//
//  ImageDocument.swift
//  AYMarkDown
//
//  Created by Aaron on 2020/9/10.
//  Copyright © 2020 Aaron. All rights reserved.
//

import AppKit

class ImageDocument: NSDocument {
    
    private(set) var image: NSImage?
    private(set) var originData: Data?
    
    class func save(fileURL: URL, fileType: String, completion: @escaping (_ document: ImageDocument?, _ error: Error?) -> Void) {
        let type = "public." + fileType
        do {
            let data = try Data(contentsOf: fileURL)
            let document = try ImageDocument(contentsOf: fileURL, ofType: type)
            document.originData = data
            document.image = NSImage(data: data)
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
        image = NSImage(data: data)
    }
    
    override func data(ofType typeName: String) throws -> Data {
        guard let data = originData else {
            throw AYError.markdownSaveDataNull
        }
        return data
    }
    
}

