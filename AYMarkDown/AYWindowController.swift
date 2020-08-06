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
        print("点击了button")
        
    }
    
    @IBAction func saveAction(_ sender: Any) {
        guard let docURL = viewController.documnetViewController.selectedURL else {
            alert("请先选中一个文件夹")
            return
        }
        let text = viewController.markdownViewController.text
        if text.count == 0 {
            alert("文章不能为空")
            return
        }
        var dateName = "\(NSDate().timeIntervalSince1970)"
        dateName = dateName.replacingOccurrences(of: ".", with: "_")
        let fileName = "\(dateName).md"
        let fileURL = docURL.appendingPathComponent(fileName)
        do {
//            let document = try AYDocument(contentsOf: fileURL, ofType: "markdown")
            let document = try AYDocument(type: "md")
            guard let data = text.data(using: .utf8) else {
                alert("数据转换失败")
                return
            }
            document.set(data: data)
            document.save(to: fileURL, ofType: "md", for: .saveAsOperation) { [unowned self] (error) in
                if error != nil {
                    self.alert("iCloud保存失败 - \(error!.localizedDescription)")
                } else {
                    self.alert("保存成功")
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
