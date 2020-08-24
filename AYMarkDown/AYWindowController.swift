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
        createResourcesDocument()
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
    
    private func uploadImage(with imageURL: URL) {
        guard let url = checkIClould() else {
            alert("请先开启iCloud功能")
            return
        }
        let docURL = url.appendingPathComponent("Documents/Resources", isDirectory: true)
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
            try document.setImage(imageURL)
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
    
    private func createResourcesDocument() {
        guard let url = checkIClould() else {
            alert("请先开启iCloud功能")
            return
        }
        let sysDocumentsURL = url.appendingPathComponent("Documents/Resources", isDirectory: true)
        var isDirectory: ObjCBool = false
        let exist = FileManager.default.fileExists(atPath: sysDocumentsURL.path, isDirectory: &isDirectory)
        if !exist || !isDirectory.boolValue {
            do {
                try FileManager.default.createDirectory(at: sysDocumentsURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("文件夹创建失败 - \(error.localizedDescription)")
            }
        }
    }
    
    private func checkIClould() -> URL? {
        FileManager.default.url(forUbiquityContainerIdentifier: "iCloud.com.aaron.brain")
    }
    
    // MARK: - Action
    
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
    
    @IBAction func imageAction(_ sender: NSButton?) {
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
    
    @IBAction func imageLinkAction(_ sender: NSButton) {
        viewController.markdownViewController.insetImageLink()
    }
    
    @IBAction func h1Action(_ sender: NSButton) {
        viewController.markdownViewController.insertH1()
    }
    
    @IBAction func h2Action(_ sender: NSButton) {
        viewController.markdownViewController.insertH2()
    }
    
    @IBAction func h3Action(_ sender: NSButton) {
        viewController.markdownViewController.insertH3()
    }
    
    @IBAction func h4Action(_ sender: NSButton) {
        viewController.markdownViewController.insertH4()
    }
    
    @IBAction func h5Action(_ sender: NSButton) {
        viewController.markdownViewController.insertH5()
    }
    
    @IBAction func h6Action(_ sender: NSButton) {
        viewController.markdownViewController.insertH6()
    }
    
    @IBAction func linkAction(_ sender: NSButton) {
        viewController.markdownViewController.insertLink()
    }
    
    @IBAction func strongAction(_ sender: NSButton) {
        viewController.markdownViewController.insertStrong()
    }
    
    @IBAction func emphasizeAction(_ sender: NSButton) {
        viewController.markdownViewController.insertEmphasize()
    }
    
    @IBAction func clockquoteAction(_ sender: NSButton) {
        viewController.markdownViewController.insertClockquote()
    }
    
    @IBAction func codeAction(_ sender: NSButton) {
        viewController.markdownViewController.insertCode()
    }
    
    @IBAction func tableAction(_ sender: NSButton) {
        viewController.markdownViewController.insertTable()
    }
    
    @IBAction func unorderedAction(_ sender: NSButton) {
        viewController.markdownViewController.insertUnorderedList()
    }
    
    @IBAction func orderedAction(_ sender: NSButton) {
        viewController.markdownViewController.insertOrderedList()
    }
    
}
