//
//  NoteTableCell.swift
//  AYMarkDown
//
//  Created by Aaron on 2020/9/16.
//  Copyright © 2020 Aaron. All rights reserved.
//

import Cocoa

class NoteTableCell: NSView {
    
    static let cellID = NSUserInterfaceItemIdentifier(rawValue: "NoteTableCellID")
    
    let textFieldBackground: NSView = {
        let view = NSView(frame: .zero)
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        return view
    }()
    
    let selectedBackground: NSView = {
        let view = NSView(frame: .zero)
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
        return view
    }()
    
    let shadowView: NSShadow = {
        let view = NSShadow()
        view.shadowColor = NSColor.lightGray
        view.shadowOffset = NSSize(width: 1, height: -1)
        view.shadowBlurRadius = 3.5
        return view
    }()
    
    let textField: NSTextField = {
        let textField = NSTextField(wrappingLabelWithString: "")
        textField.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        textField.isBordered = false
        textField.isEditable = false
        textField.isSelectable = false
        textField.font = NSFont(name: "PingFang-SC-Semibold", size: 14)
        return textField
    }()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        addSubview(textFieldBackground)
        textFieldBackground.shadow = shadowView
        textFieldBackground.addSubview(selectedBackground)
        textFieldBackground.addSubview(textField)
        textFieldBackground.snp.makeConstraints { (maker) in
            maker.edges.equalTo(NSEdgeInsetsMake(8, 8, 8, 8))
        }
        selectedBackground.snp.makeConstraints { (maker) in
            maker.leading.equalTo(textFieldBackground)
            maker.top.equalTo(textFieldBackground)
            maker.bottom.equalTo(textFieldBackground)
            maker.width.equalTo(8)
        }
        textField.snp.makeConstraints { (maker) in
            maker.edges.equalTo(NSEdgeInsetsMake(8, 16, 8, 8))
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
