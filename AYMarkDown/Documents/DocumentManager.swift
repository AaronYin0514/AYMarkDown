//
//  DocumentManager.swift
//  AYMarkDown
//
//  Created by Aaron on 2020/8/31.
//  Copyright © 2020 Aaron. All rights reserved.
//

import Foundation

struct Scope: OptionSet {
    
    let rawValue: Int
    
    public static let ducument = Scope(rawValue: 1)
}

struct Condition {
    
    var scops = Scope.ducument
    
    var type: String?
    
    var directoryURL: URL?
    
    var ignoreTypes: [String] = []
    
    var ignoreFiles: [String] = []
    
}

class DocumentManager<T: Document>: NSObject {
    
    private var _completionHandlers: [DocumentQuery<T>] = []
    
    func asyncQuery(_ condition: Condition, completion: @escaping ([T]) -> Void) {
        let query = DocumentQuery<T>(condition: condition)
        _completionHandlers.append(query)
        query.asyncQuery { [unowned self] (_query, result) in
            completion(result)
            self._completionHandlers.removeAll { (__query) -> Bool in
                return _query.identifier == __query.identifier
            }
        }
    }
    
}

extension Scope {
    
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
            result.append(Scope.ducument.stringValue)
        }
        return result
    }
    
}

private let _document_parseQueue = DispatchQueue(label: "com.document.parse")

class DocumentQuery<T: Document> {
    
    var identifier: String?
    
    let condition: Condition
    
    private let query: NSMetadataQuery
    
    private let _queryQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.document.query"
        return queue
    }()
    
    private var completionClosure: ((DocumentQuery, [T]) -> Void)?
    
    init(condition: Condition) {
        self.condition = condition
        self.query = NSMetadataQuery()
        self.query.searchScopes = condition.scops.stringValues
    }
    
    func asyncQuery(completion: @escaping (DocumentQuery, [T]) -> Void) {
        self.completionClosure = completion
        self.identifier = _start()
    }
    
    private func _start() -> String {
        print("\(Thread.current)")
        let identifier = _createIdentifier()
        _addNotification(by: query)
        query.start()
        return identifier
    }
    
    private func _stop() {
        query.stop()
        _removeNotification(by: query)
    }
    
    private func _addNotification(by query: NSMetadataQuery) {
        let sel = #selector(_metadataQueryDidFinishGathering(_:))
        NotificationCenter.default.addObserver(self, selector: sel, name: .NSMetadataQueryDidFinishGathering, object: query)
    }
    
    private func _removeNotification(by query: NSMetadataQuery) {
        NotificationCenter.default.removeObserver(self, name: .NSMetadataQueryDidFinishGathering, object: query)
    }
    
    // MARK: - Action
    
    @objc private func _metadataQueryDidFinishGathering(_ notification: Notification) {
        guard let query = notification.object as? NSMetadataQuery else {
            return
        }
        guard let completion = completionClosure else {
            return
        }
        _stop()
        _document_parseQueue.async {
            if query.resultCount <= 0 { return }
            var results: [T] = []
            for i in 0..<query.resultCount {
                guard let item = query.result(at: i) as? NSMetadataItem else  {
                    continue
                }
                guard let type = item.value(forAttribute: NSMetadataItemContentTypeKey) as? String else {
                    continue
                }
                print("文件类型：\(type)")
                if let findTpye = self.condition.type {
                    if type != findTpye {
                        continue
                    }
                } else {
                    if self.condition.ignoreTypes.contains(type) {
                        continue
                    }
                }
                guard let name = item.value(forAttribute: NSMetadataItemFSNameKey) as? String else {
                    continue
                }
                if self.condition.ignoreFiles.contains(name) {
                    continue
                }
                guard let url = item.value(forAttribute: NSMetadataItemURLKey) as? URL else {
                    continue
                }
                if let currentDirectoryURL = self.condition.directoryURL {
                    let parentURL = url.deletingLastPathComponent()
                    if parentURL != currentDirectoryURL {
                        continue
                    }
                }
                let fileType = item.value(forAttribute: NSMetadataItemContentTypeKey) as? String
                let fileCreationDate = item.value(forAttribute: NSMetadataItemFSCreationDateKey) as? Date
                let fileModificationDate = item.value(forAttribute: NSMetadataItemFSContentChangeDateKey) as? Date
                if let directory = T.create(name: name, fileType: fileType, fileURL: url, fileCreationDate: fileCreationDate, fileModificationDate: fileModificationDate) as? T {
                    results.append(directory)
                }
            }
            DispatchQueue.main.async {
                completion(self, results)
            }
        }
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
    
}
