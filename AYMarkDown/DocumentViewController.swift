//
//  DocumentViewController.swift
//  AYMarkDown
//
//  Created by Aaron on 2020/8/4.
//  Copyright © 2020 Aaron. All rights reserved.
//

import Cocoa
import SnapKit

class DocumentViewController: NSViewController {
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    private var tableView: NSTableView {
        return scrollView.documentView as! NSTableView
        
        
    }
    
    private var dataSource: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        dataSource = [
            "One","One","One","One","One","One","One","One"
        ]
    }
    
    private func didEditTitle(row: Int, string: String) {
        if string.count != 0 && row < dataSource.count {
            dataSource[row] = string
        }
        tableView.reloadData()
        print(dataSource)
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
        view?.textField.stringValue = dataSource[row]
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
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        print("oldDescriptors[0] -> (sortDescriptorPrototyp, descending, compare:)")
    }
    
    public func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        print("------------ 要编辑了  \(row)")
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
