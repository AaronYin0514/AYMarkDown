//
//  DocumentManager.swift
//  AYMarkDown
//
//  Created by Aaron on 2020/8/31.
//  Copyright © 2020 Aaron. All rights reserved.
//

import Foundation

class DocumentManager: NSObject {
    
    static let manager = DocumentManager()
    
    struct Scope: OptionSet {
        
        let rawValue: Int
        
        public static let ducument = Scope(rawValue: 1)
    }
    
    struct Condition {
        
        var scops = Scope.ducument
        
        var ignoreTypes: [String] = []
        
        var ignoreFiles: [String] = []
        
    }
    
    // MARK: - Public Method
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(_metadataQueryDidFinishGathering(_:)), name: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: _query)
    }
    
    func asyncQuery(_ condition: Condition, completion: @escaping ([Directory]) -> Void) {
        _queryResultHandler = completion
        _query(condition)
    }
    
    // MARK: - Private
    
    private let _query: NSMetadataQuery = NSMetadataQuery()
    
    private let _parseQueue = DispatchQueue(label: "com.document.parse")
    
    private let _queryQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.document.query"
        return queue
    }()
    
    private var _queryResultHandler: (([Directory]) -> Void)?
    
    private func _queryStart(_ condition: Condition) {
        _query.searchScopes = condition.scops.stringValues
        _query.start()
    }
    
    private func _queryStop() {
        _query.stop()
    }
    
    private func _query(_ condition: Condition) {
        _query.operationQueue = _queryQueue
        _queryStart(condition)
    }
    
    // MARK: - Action
    
    @objc private func _metadataQueryDidFinishGathering(_ notification: Notification) {
        let query = notification.object as! NSMetadataQuery
//        query.disableUpdates()
        query.stop()
        _parseQueue.async {
            if query.resultCount <= 0 { return }
            for i in 0..<query.resultCount {
                guard let item = query.result(at: i) as? NSMetadataItem else  {
                    continue
                }
                guard let type = item.value(forAttribute: NSMetadataItemContentTypeKey) as? String else {
                    continue
                }
                if type != "public.folder" {
                    continue
                }
                guard let name = item.value(forAttribute: NSMetadataItemFSNameKey) as? String else {
                    continue
                }
//            if filterDocuments.contains(name) {
//                continue
//            }
                guard let url = item.value(forAttribute: NSMetadataItemURLKey) as? URL else {
                    continue
                }
//            addData(name, url)
            }
        }
    }
    
}

extension DocumentManager.Scope {
    
    var stringValue: String {
        switch self {
        case .ducument:
            return NSMetadataQueryUbiquitousDocumentsScope
        default:
            return "Unknown"
        }
    }
    
    var stringValues: [String] {
        var result: [String] = []
        if contains(.ducument) {
            result.append(DocumentManager.Scope.ducument.stringValue)
        }
        return result
    }
    
}
