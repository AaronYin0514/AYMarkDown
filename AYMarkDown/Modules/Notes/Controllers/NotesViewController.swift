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
    
    private var dataSource: [MarkDownDocument] = []
    
    let query = NSMetadataQuery()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func loadData(_ url: URL) {
        _loadData(url, forcedRefresh: false)
    }
    
    func reloadData(_ url: URL) {
        _loadData(url, forcedRefresh: true)
    }
    
    func insert(_ document: MarkDownDocument) {
        dataSource.insert(document, at: 0)
        tableView.reloadData()
    }
    
    func replace(_ document: MarkDownDocument, by url: URL) {
        var index: Int = NSNotFound
        for (idx, d) in dataSource.enumerated() {
            if d.fileURL == url {
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
        if let url = d.fileURL {
            didSelectDocument?(d.text, url)
        }
    }
    
    func select(url: URL) {
        var index: Int = NSNotFound
        for (idx, d) in dataSource.enumerated() {
            if d.fileURL == url {
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
        NotesDownloadManager.manager.async(url: url) { (documents) in
            self.dataSource = documents
            self.tableView.reloadData()
            self.select(row: 0)
//            let time = DispatchTime.now().advanced(by: .milliseconds(250))
//            DispatchQueue.main.asyncAfter(deadline: time) {
//                self.select(row: 0)
//            }
        }
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
        return 120
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var view = tableView.makeView(withIdentifier: NoteTableCell.cellID, owner: self) as? NoteTableCell
        if (view == nil) {
            view = NoteTableCell(frame: .zero)
        }
        if row < dataSource.count {
            view?.textField.attributedStringValue = dataSource[row].richText
        }
        if row == selectedRow {
            view?.selectedBackground.layer?.backgroundColor = NSColor.red.cgColor
        } else {
            view?.selectedBackground.layer?.backgroundColor = NSColor.lightGray.cgColor
        }
        return view
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return NoteTableRowView()
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
            if let url = d.fileURL {
                didSelectDocument?(d.text, url)
                tableView.reloadData()
            }
        }
        return true
    }
    
}
