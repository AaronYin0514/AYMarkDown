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
        
        var type: String?
        
        var ignoreTypes: [String] = []
        
        var ignoreFiles: [String] = []
        
    }
    
    // MARK: - Public Method
    
    func asyncQuery(_ condition: Condition, completion: @escaping ([Directory]) -> Void) {
        let query = _queryStart(by: condition)
        _completionHandlers[query] = (condition, completion)
    }
    
    // MARK: - Private
    
    private let _parseQueue = DispatchQueue(label: "com.document.parse")
    
    private let _queryQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.document.query"
        return queue
    }()
    
    private var _completionHandlers: [NSMetadataQuery: (Condition, ([Directory]) -> Void)] = [:]
    
    private func _queryStart(by condition: Condition) -> NSMetadataQuery {
        let query = NSMetadataQuery()
        query.searchScopes = condition.scops.stringValues
//        query.operationQueue = _queryQueue
        _addNotification(by: query)
        query.start()
        return query
    }
    
    private func _queryStop(by query: NSMetadataQuery) {
        query.stop()
        if _completionHandlers.removeValue(forKey: query) != nil {
            print("移除成功")
        }
        _removeNotification(by: query)
    }
    
    private func _addNotification(by query: NSMetadataQuery) {
        let sel = #selector(_metadataQueryDidFinishGathering(_:))
        NotificationCenter.default.addObserver(self, selector: sel, name: .NSMetadataQueryDidFinishGathering, object: query)
    }
    
    private func _removeNotification(by query: NSMetadataQuery) {
        NotificationCenter.default.removeObserver(self, name: .NSMetadataQueryDidFinishGathering, object: query)
    }
    
    // MARK: - Utils
    
    private let _identifierFomtter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmssSSS"
        return formatter
    }()
    
    private func _createIdentifier() -> String {
        let formatterString = _identifierFomtter.string(from: Date())
        let random = arc4random() % 10000
        return formatterString + "\(random)"
    }
    
    // MARK: - Action
    
    @objc private func _metadataQueryDidFinishGathering(_ notification: Notification) {
        guard let query = notification.object as? NSMetadataQuery else {
            return
        }
        guard let condition = _completionHandlers[query]?.0, let completion = _completionHandlers[query]?.1 else {
                return
        }
        _queryStop(by: query)
        _parseQueue.async {
            if query.resultCount <= 0 { return }
            var results: [Directory] = []
            for i in 0..<query.resultCount {
                guard let item = query.result(at: i) as? NSMetadataItem else  {
                    continue
                }
                guard let type = item.value(forAttribute: NSMetadataItemContentTypeKey) as? String else {
                    continue
                }
                if let findTpye = condition.type {
                    if type != findTpye {
                        continue
                    }
                } else {
                    if condition.ignoreTypes.contains(type) {
                        continue
                    }
                }
                guard let name = item.value(forAttribute: NSMetadataItemFSNameKey) as? String else {
                    continue
                }
                if condition.ignoreFiles.contains(name) {
                    continue
                }
                guard let url = item.value(forAttribute: NSMetadataItemURLKey) as? URL else {
                    continue
                }
                let directory = Directory(name: name, fileURL: url)
                results.append(directory)
            }
            DispatchQueue.main.async {
                completion(results)
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
