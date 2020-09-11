//
//  DocumentTableCell.swift
//  AYMarkDown
//
//  Created by Aaron on 2020/9/11.
//  Copyright © 2020 Aaron. All rights reserved.
//

import AppKit
import SnapKit

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
