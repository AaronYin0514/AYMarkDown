//
//  NotesViewController.swift
//  AYMarkDown
//
//  Created by Aaron on 2020/8/4.
//  Copyright © 2020 Aaron. All rights reserved.
//

import Cocoa

class NotesViewController: NSViewController {

    var currentURL: URL?
    
    var didSelectDocument: ((_: String, _: URL) -> Void)?
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    var selectedRow: Int {
        return tableView.selectedRow
    }
    
    private var tableView: NSTableView {
        return scrollView.documentView as! NSTableView
    }
    
    private var dataSource: [AYDocument] = []
    
    let query = NSMetadataQuery()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(finishedGetNewDocument(_:)), name: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: query)
    }
    
    func loadData(_ url: URL) {
        _loadData(url, forcedRefresh: false)
    }
    
    func reloadData(_ url: URL) {
        _loadData(url, forcedRefresh: true)
    }
    
    func insert(_ document: AYDocument) {
        dataSource.insert(document, at: 0)
        tableView.reloadData()
    }
    
    func replace(_ document: AYDocument, by url: URL) {
        var index: Int = NSNotFound
        for (idx, d) in dataSource.enumerated() {
            if d.remoteFileURL == url {
                index = idx
                break
            }
        }
        if index != NSNotFound {
            dataSource[index] = document
            tableView.reloadData()
        }
    }
    
    func clear() {
        tableView.deselectAll(nil)
    }
    
    func select(row: Int) {
        if row < 0 || row >= dataSource.count {
            return
        }
        let indexs = IndexSet(arrayLiteral: row)
        tableView.selectRowIndexes(indexs, byExtendingSelection: false)
        let d = dataSource[row]
        if let text = d.text, let url = d.remoteFileURL {
            didSelectDocument?(text, url)
        }
    }
    
    func select(url: URL) {
        var index: Int = NSNotFound
        for (idx, d) in dataSource.enumerated() {
            if d.remoteFileURL == url {
                index = idx
                break
            }
        }
        if index != NSNotFound {
            select(row: index)
        }
    }
    
    private func _loadData(_ url: URL, forcedRefresh: Bool) {
        if !forcedRefresh && url == currentURL {
            return
        }
        dataSource.removeAll()
        currentURL = url
        query.searchScopes = [
            NSMetadataQueryUbiquitousDocumentsScope
        ]
        query.start()
    }
    
    @objc func finishedGetNewDocument(_ notification: Notification) {
        guard let URL = currentURL else {
            return
        }
        let query = notification.object as! NSMetadataQuery
//        query.disableUpdates()
        query.stop()
        if query.resultCount <= 0 {
            return
        }
        for i in 0..<query.resultCount {
            guard let item = query.result(at: i) as? NSMetadataItem else  {
                continue
            }
            guard let type = item.value(forAttribute: NSMetadataItemContentTypeKey) as? String else {
                continue
            }
            if type == "public.folder" {
                continue
            }
            guard let url = item.value(forAttribute: NSMetadataItemURLKey) as? URL else {
                continue
            }
            let parentURL = url.deletingLastPathComponent()
            if parentURL != URL {
                continue
            }
            do {
                let document = try AYDocument(type: "md")
                try document.read(from: url, ofType: "md")
                dataSource.append(document)
            } catch {
                alert("读取失败 - \(error.localizedDescription)")
            }
        }
        tableView.reloadData()
    }
    
    private func alert(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "提示"
        alert.informativeText = message
        alert.addButton(withTitle: "确定")
        alert.runModal()
    }
}

extension NotesViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var view = tableView.makeView(withIdentifier: NoteTableCell.cellID, owner: self) as? NoteTableCell
        if (view == nil) {
            view = NoteTableCell(frame: .zero)
        }
        if row < dataSource.count {
            view?.textField.stringValue = dataSource[row].text ?? ""
        }
        return view
    }
    
    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
//        print("addRow")
    }
    
    func tableView(_ tableView: NSTableView, didRemove rowView: NSTableRowView, forRow row: Int) {
//        print("removeRow")
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if row < dataSource.count {
            let d = dataSource[row]
            if let text = d.text, let url = d.remoteFileURL {
                didSelectDocument?(text, url)
            }
        }
        return true
    }
    
}

class NoteTableCell: NSView {
    
    static let cellID = NSUserInterfaceItemIdentifier(rawValue: "NoteTableCellID")
    
    let textField: NSTextField = {
        let textField = NSTextField(wrappingLabelWithString: "")
        textField.isBordered = false
        textField.isEditable = false
        textField.isSelectable = false
        textField.backgroundColor = NSColor.clear
        textField.font = NSFont(name: "PingFang-SC-Semibold", size: 14)
        return textField
    }()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        addSubview(textField)
        
        textField.snp.makeConstraints { (maker) in
            maker.edges.equalTo(NSEdgeInsetsMake(4, 8, 4, 8))
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
