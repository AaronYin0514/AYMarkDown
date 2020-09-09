//
//  DocumentViewController.swift
//  AYMarkDown
//
//  Created by Aaron on 2020/8/4.
//  Copyright © 2020 Aaron. All rights reserved.
//

import Cocoa
import SnapKit

class DocumentDownloadManager: NSObject {
    
    private let _manager = DocumentManager<Directory>()
    
    private let _condition = Condition(type: "public.folder", ignoreFiles: [__resources_document_name])
    
    static let manager = DocumentDownloadManager()
    
    func async(completion: @escaping ([Directory]) -> Void) {
        _manager.asyncQuery(_condition, completion: completion)
    }
    
}

class DocumentViewController: NSViewController {
    
    let filterDocuments: [String] = [
        __resources_document_name
    ]
    
    var selectedURL: URL? {
        if tableView.selectedRow < 0 || tableView.selectedRow >= dataSource.count {
            return nil
        }
        return dataSource[tableView.selectedRow].fileURL
    }
    
    var didSelectURL: ((_: URL) -> Void)?
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    private var tableView: NSTableView {
        return scrollView.documentView as! NSTableView
    }
    
    private var dataSource: [Directory] = []
    
    let query = NSMetadataQuery()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.enclosingScrollView?.drawsBackground = false
        loadData()
    }
    
    private func loadData() {
        DocumentDownloadManager.manager.async { (results) in
            self.dataSource = results
            self.tableView.reloadData()
        }
    }
    
    private func fixData(_ row: Int, _ name: String, _ url: URL) {
        if row >= dataSource.count {
            return
        }
//        names[row] = name
//        urls[row] = url
    }
    
    @IBAction func createDocumentAction(_ sender: Any) {
        createDocument()
    }
    
    private func didEditTitle(row: Int, string: String) {
        if string.count == 0 || row >= dataSource.count {
            return
        }
        do {
//            if let newURL = try renameDocument(url: urls[row], newName: string) {
//                fixData(row, string, newURL)
//                tableView.reloadData()
//                alert("名称修改成功")
//            }
        } catch {
            tableView.reloadData()
            alert("名称修改失败 - \(error.localizedDescription)")
        }
    }
    
    private func createDocument() {
        guard let url = checkIClould() else {
            alert("请先开启iCloud功能")
            return
        }
//        let sysDocumentsURL = url.appendingPathComponent("Documents", isDirectory: true)
//        var index = 0
//        for s in names {
//            if s.hasPrefix("新建文件夹") {
//                index += 1
//            }
//        }
//        let name = index == 0 ? "新建文件夹" : "新建文件夹\(index)"
//        let newDucumentURL = sysDocumentsURL.appendingPathComponent(name)
//        do {
//            try FileManager.default.createDirectory(at: newDucumentURL, withIntermediateDirectories: true, attributes: nil)
//            addData(name, newDucumentURL)
//            tableView.reloadData()
//        } catch {
//            alert("文件夹创建失败 - \(error.localizedDescription)")
//            print(error)
//        }
        
    }
    
    private func renameDocument(url: URL, newName: String) throws -> URL? {
        guard let rootURL = checkIClould() else {
            alert("请先开启iCloud功能")
            return nil
        }
        let sysDocumentsURL = rootURL.appendingPathComponent("Documents", isDirectory: true)
        let newURL = sysDocumentsURL.appendingPathComponent(newName, isDirectory: true)
        try FileManager.default.moveItem(at: url, to: newURL)
        return newURL
    }
    
    private func checkIClould() -> URL? {
        FileManager.default.url(forUbiquityContainerIdentifier: "iCloud.com.aaron.brain")
    }
    
    private func alert(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "提示"
        alert.informativeText = message
        alert.addButton(withTitle: "确定")
        alert.runModal()
    }
    
}

extension DocumentViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var view = tableView.makeView(withIdentifier: DocumentTableCell.cellID, owner: self) as? DocumentTableCell
        if (view == nil) {
            view = DocumentTableCell(frame: .zero)
        }
        view?.textField.stringValue = dataSource[row].name
        unowned let unownedView = view
        view?.textField.endEditClosure = { [unowned self] (string) in
            if let vw = unownedView {
                let row = tableView.row(for: vw)
                self.didEditTitle(row: row, string: string)
            }
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
        if row >= dataSource.count {
            return false
        }
        if let url = dataSource[row].fileURL {
            didSelectURL?(url)
        }
        return true
    }
    
}

class DocumentTableCell: NSView {
    
    static let cellID = NSUserInterfaceItemIdentifier(rawValue: "DocumentTableCellID")
    
    let textField: DocumentTextField = {
        let textField = DocumentTextField(frame: .zero)
        return textField
    }()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        addSubview(textField)
        
        textField.snp.makeConstraints { (maker) in
            maker.edges.equalTo(NSEdgeInsetsMake(4, 16, 4, 16))
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

class DocumentTextField: NSTextField {
    
    var endEditClosure: ((_: String) -> Void)?
    
    override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            commonInit()
        }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        isBordered = false
        bezelStyle = .squareBezel
        isEditable = true
//        isSelectable = false
        backgroundColor = NSColor.clear
        font = NSFont(name: "PingFang-SC-Semibold", size: 15)
    }
    
    override func selectText(_ sender: Any?) {
        super.selectText(sender)
        backgroundColor = NSColor.white
    }
    
    override func textDidEndEditing(_ notification: Notification) {
        backgroundColor = NSColor.clear
        endEditClosure?(stringValue)
    }
    
}
