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
    
    @IBAction func imageAction(_ sender: NSButton) {
        print("Image Action")
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowsOtherFileTypes = false
        panel.allowedFileTypes = ["png", "jpeg", "jpg"]
        panel.beginSheetModal(for: NSApplication.shared.windows.first!) { [unowned panel] (response) in
            if response == .OK {
                if let url = panel.urls.first {
                    self.uploadImage(with: url)
                }
            }
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
    
    private func uploadImage(with url: URL) {
        guard let noteURL = viewController.markdownViewController.currentURL else {
            alert("请先选中一个文件")
            return
        }
        let docURL = noteURL.deletingLastPathComponent()
        var suffix = "jpg"
        if url.absoluteString.hasSuffix("png") || url.absoluteString.hasSuffix("PNG") {
            suffix = "png"
        } else if url.absoluteString.hasSuffix("jpg") || url.absoluteString.hasSuffix("JPG") {
            suffix = "jpg"
        } else if url.absoluteString.hasSuffix("jpeg") || url.absoluteString.hasSuffix("JPEG") {
            suffix = "jpeg"
        }
        var dateName = "\(NSDate().timeIntervalSince1970)"
        dateName = dateName.replacingOccurrences(of: ".", with: "_")
        let fileName = "\(dateName).\(suffix)"
        let fileURL = docURL.appendingPathComponent(fileName)
        do {
            let document = try AYDocument(type: "img")
            try document.setImage(url)
            document.save(to: fileURL, ofType: "img", for: .saveOperation) { [unowned self] (error) in
                if error != nil {
                    self.alert("图片iCloud保存失败 - \(error!.localizedDescription)")
                } else {
                    self.viewController.markdownViewController.insetImage(with: fileURL)
//                    self.alert("保存成功")
                }
            }
            print("图片获取成功")
        } catch {
            print("获取图片失败 - \(error.localizedDescription)")
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
