//
//  DocumentViewController.swift
//  AYMarkDown
//
//  Created by Aaron on 2020/8/4.
//  Copyright © 2020 Aaron. All rights reserved.
//

import Cocoa

class DocumentViewController: NSViewController {
    
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
    
    @IBAction func createDocumentAction(_ sender: Any) {
        createDocument()
    }
    
    private func didEditTitle(row: Int, string: String) {
        if string.count == 0 || row >= dataSource.count {
            return
        }
        var directory = dataSource[row]
        guard let url = directory.fileURL else {
            return
        }
        do {
            if let newURL = try renameDocument(url: url, newName: string) {
                directory.name = string
                directory.fileURL = newURL
                dataSource[row] = directory
                tableView.reloadData()
            }
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
        let sysDocumentsURL = url.appendingPathComponent("Documents", isDirectory: true)
        let name = newDirectoryPlaceName(from: dataSource)
        let newDucumentURL = sysDocumentsURL.appendingPathComponent(name)
        do {
            try FileManager.default.createDirectory(at: newDucumentURL, withIntermediateDirectories: true, attributes: nil)
            let directory = Directory(name: name, fileURL: newDucumentURL)
            dataSource.insert(directory, at: 0)
            tableView.reloadData()
            let time = DispatchTime.now().advanced(by: .milliseconds(300))
            DispatchQueue.main.asyncAfter(deadline: time) {
                if let cell = self.tableView.view(atColumn: 0, row: 0, makeIfNecessary: false) as? DocumentTableCell {
                    cell.textField.becomeFirstResponder()
                }
            }
        } catch {
            alert("文件夹创建失败 - \(error.localizedDescription)")
        }
    }
    
    private func newDirectoryPlaceName(from dataSource: [Directory]) -> String {
        func isDirectoryPlaceNameFotmat(_ name: String) -> Bool {
            let regex = "新建文件夹\\d*"
            let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
            return predicate.evaluate(with: name)
        }
        func indexFromDirectoryPlaceName(_ name: String) -> Int? {
            if name == "新建文件夹" {
                return 0
            }
            if !isDirectoryPlaceNameFotmat(name) {
                return nil
            }
            do {
                let regex = try NSRegularExpression(pattern: "\\d+", options: .caseInsensitive)
                if let result = regex.firstMatch(in: name, options: .reportCompletion, range: NSRange(location: 0, length: name.count)) {
                    return Int((name as NSString).substring(with: result.range))
                } else {
                    return nil
                }
            } catch {
                return nil
            }
        }
        var index = 0
        for d in dataSource {
            if let newIndex = indexFromDirectoryPlaceName(d.name), newIndex >= index {
                index = newIndex + 1
            }
        }
        return index <= 0 ? "新建文件夹" : "新建文件夹\(index)"
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
