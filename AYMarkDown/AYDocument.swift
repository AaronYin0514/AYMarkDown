//
//  AYDocument.swift
//  AYMarkDown
//
//  Created by Aaron on 2020/8/5.
//  Copyright © 2020 Aaron. All rights reserved.
//

import AppKit

class AYDocument: NSDocument {
    
    private var _ay_data: Data?
    
    private(set) var text: String?
    
    private(set) var remoteFileURL: URL?
    
    func set(data: Data) {
        _ay_data = data
    }
    
    override func read(from url: URL, ofType typeName: String) throws {
        try super.read(from: url, ofType: typeName)
        remoteFileURL = url
    }
    
    override func read(from data: Data, ofType typeName: String) throws {
        _ay_data = data
        text = String(data: data, encoding: .utf8)
    }
    
    override func data(ofType typeName: String) throws -> Data {
        if _ay_data == nil {
            throw AYError.markdownSaveDataNull
        }
        return _ay_data!
    }
    
}
