//
//  AYWindowController.swift
//  AYMarkDown
//
//  Created by Aaron on 2020/8/6.
//  Copyright © 2020 Aaron. All rights reserved.
//

import Cocoa

class AYWindowController: NSWindowController {

    var viewController: ViewController {
        return contentViewController as! ViewController
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }

    @IBAction func editAction(_ sender: NSButton) {
        guard let _ = viewController.documnetViewController.selectedURL else {
            alert("请先选择一个文件夹")
            return
        }
        viewController.notesViewController.clear()
        viewController.markdownViewController.clear()
    }
    
    @IBAction func saveAction(_ sender: Any) {
        let text = viewController.markdownViewController.text
        if text.count == 0 {
            alert("文章不能为空")
            return
        }
        if let noteURL = viewController.markdownViewController.currentURL {
            saveNote(noteURL, text)
        } else {
            createNote(text)
        }
    }
    
    private func createNote(_ text: String) {
        guard let docURL = viewController.documnetViewController.selectedURL else {
            alert("请先选中一个文件夹")
            return
        }
        var dateName = "\(NSDate().timeIntervalSince1970)"
        dateName = dateName.replacingOccurrences(of: ".", with: "_")
        let fileName = "\(dateName).md"
        let fileURL = docURL.appendingPathComponent(fileName)
        do {
            let document = try AYDocument(type: "md")
            document.setText(text)
            document.save(to: fileURL, ofType: "md", for: .saveAsOperation) { [unowned self] (error) in
                if error != nil {
                    self.alert("iCloud创建失败 - \(error!.localizedDescription)")
                } else {
                    self.viewController.notesViewController.insert(document)
                    self.viewController.notesViewController.select(row: 0)
                    //self.alert("创建成功")
                }
            }
        } catch {
            alert("创建失败 - \(error.localizedDescription)")
        }
    }
    
    private func saveNote(_ url: URL, _ text: String) {
        do {
            let document = try AYDocument(type: "md")
            document.setText(text)
            document.save(to: url, ofType: "md", for: .saveOperation) { [unowned self] (error) in
                if error != nil {
                    self.alert("iCloud保存失败 - \(error!.localizedDescription)")
                } else {
                    self.viewController.notesViewController.replace(document, by: url)
                    self.viewController.notesViewController.select(url: url)
                    //self.alert("保存成功")
                }
            }
        } catch {
            alert("保存失败 - \(error.localizedDescription)")
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
