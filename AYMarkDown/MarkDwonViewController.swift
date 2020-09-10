//
//  MarkDwonViewController.swift
//  AYMarkDown
//
//  Created by Aaron on 2020/8/4.
//  Copyright © 2020 Aaron. All rights reserved.
//

import Cocoa
import WebKit

class MarkDwonViewController: NSViewController {

    var currentURL: URL?
    
    var text: String {
        return textView.string
    }
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    @IBOutlet weak var webView: WKWebView! {
        didSet {
            webView.configuration.preferences.setValue(NSNumber(booleanLiteral: true), forKey: "allowFileAccessFromFileURLs")
            webView.navigationDelegate = self
        }
    }
    
    private var textView: NSTextView {
        return scrollView.documentView as! NSTextView
    }
    
    private let queue = DispatchQueue(label: "ay.markdown.parsing")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.textContainerInset = CGSize(width: 24, height: 24)
        textView.font = NSFont(name: "PingFang-SC-Regular", size: 15)
        textView.delegate = self
    }
    
    // MARK: - Public
    
    func set(text: String, url: URL) {
        textView.string = text
        currentURL = url
    }
    
    func clear() {
        textView.string = ""
        currentURL = nil
    }
    
    // MARK: - Method
    
    
    
    private func checkIClould() -> URL? {
        FileManager.default.url(forUbiquityContainerIdentifier: "iCloud.com.aaron.brain")
    }
    
}

extension MarkDwonViewController: NSTextViewDelegate {
    
    func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
        let string = (textView.string as NSString).replacingCharacters(in: affectedCharRange, with: replacementString ?? "")
        var refreshNow = false
        if replacementString == "\n" {
            refreshNow = true
            let range = (textView.string as NSString).range(of: "\n", options: .backwards)
            if range.location != NSNotFound {
                let sss = (textView.string as NSString).substring(from: range.location + 1)
                print("-----------+++++++++ \(sss)")
                if sss.hasPrefix("* ") {
                    if sss != "* " {
                        textView.string = string + "* "
                        return false
                    } else {
                        let length = textView.string.count - range.location - 1
                        let deleteRange = NSRange(location: range.location + 1, length: length)
                        let ttt = (textView.string as NSString).replacingCharacters(in: deleteRange, with: "")
                        textView.string = ttt
                        return false
                    }
                } else {
                    let pattern = "^[0-9]*\\. "
                    let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
                    if let resultRange = regex.firstMatch(in: sss, options: .anchored, range: NSRange(location: 0, length: sss.count))?.range {
                        if resultRange.location == 0 && resultRange.length > 2 {
                            if resultRange.length != sss.count {
                                let indexString = (sss as NSString).substring(with: NSRange(location: 0, length: resultRange.length - 2))
                                if let index = Int(indexString) {
                                    textView.string = string + "\(index + 1). "
                                    return false
                                }
                            } else {
                                let length = textView.string.count - range.location - 1
                                let deleteRange = NSRange(location: range.location + 1, length: length)
                                let ttt = (textView.string as NSString).replacingCharacters(in: deleteRange, with: "")
                                textView.string = ttt
                                return false
                            }
                        }
                    }
                }
            }
        }
        textViewChange(string: string, refreshNow: refreshNow)
        return true
    }
    
}

extension MarkDwonViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
}

// MARK: - 解析MarkDown

extension MarkDwonViewController {
    
    private func textViewChange(string: String, refreshNow: Bool) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        if refreshNow {
            self.perform(#selector(self.parsingMarkDown(_:)), with: string)
        } else {
            self.perform(#selector(self.parsingMarkDown(_:)), with: string
                , afterDelay: 0.25)
        }
    }
    
    private func textViewChange(originString: String, affectedCharRange: NSRange, replacementString: String?) {
        let string = (originString as NSString).replacingCharacters(in: affectedCharRange, with: replacementString ?? "")
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        if replacementString == "\n" {
            self.perform(#selector(self.parsingMarkDown(_:)), with: string)
        } else {
            self.perform(#selector(self.parsingMarkDown(_:)), with: string
                , afterDelay: 0.25)
        }
    }
    
    @objc private func parsingMarkDown(_ string: String) {
        queue.async {
            var error: NSError?
            let contentHTML = MMMarkdown.htmlString(withMarkdown: string, extensions: .gitHubFlavored, error: &error)
            if error == nil {
                guard let path = Bundle.main.path(forResource: "markdown", ofType: "html") else {
                    return
                }
                do {
                    let formatHTML = try String(contentsOfFile: path, encoding: .utf8)
                    let markdownHTML = formatHTML.replacingOccurrences(of: "${webview_content}", with: contentHTML)
                    self.refresh(markdownHTML)
                } catch {
                    print("解析MarkDown文本异常 - \(error.localizedDescription)")
                }
            } else {
                print("解析MarkDown文本异常 - \(error?.localizedDescription ?? "为知错误")")
            }
        }
    }
    
    private func refresh(_ markdown: String) {
        guard let url = checkIClould() else {
            print("请先开启iCloud功能")
            return
        }
        let docURL = url.appendingPathComponent("Documents/\(__resources_document_name)", isDirectory: true)
        let fileName = "tmp.html"
        let fileURL = docURL.appendingPathComponent(fileName)
        HTMLDocument.save(html:markdown, fileURL: fileURL) { (document, error) in
            if error != nil {
                print("iCloud创建失败 - \(error!.localizedDescription)")
            } else {
                self.webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
            }
        }
    }
    
}

// MARK: - 快捷键

extension MarkDwonViewController {
    
    func insetImage(with url: URL) {
        textView.string = textView.string + "![](\(url.absoluteString))"
        parsingMarkDown(textView.string)
    }
    
    func insetImageLink() {
        textView.string = textView.string + "![]()"
        
    }
    
    func insertH1() {
        textView.string = textView.string + "# "
    }
    
    func insertH2() {
        textView.string = textView.string + "## "
    }
    
    func insertH3() {
        textView.string = textView.string + "### "
    }
    
    func insertH4() {
        textView.string = textView.string + "#### "
    }
    
    func insertH5() {
        textView.string = textView.string + "##### "
    }
    
    func insertH6() {
        textView.string = textView.string + "###### "
    }
    
    func insertLink() {
        textView.string = textView.string + "[]()"
    }
    
    func insertStrong() {
        textView.string = textView.string + "****"
    }
    
    func insertEmphasize() {
        textView.string = textView.string + "**"
    }
    
    func insertClockquote() {
        textView.string = textView.string + "> "
    }
    
    func insertCode() {
        textView.string = textView.string + "```\n\n```"
    }
    
    func insertTable() {
        textView.string = textView.string + """
        |  表头   | 表头  |
        |  ----  | ----  |
        | 单元格  | 单元格 |
        | 单元格  | 单元格 |\n
        """
    }
    
    func insertUnorderedList() {
        textView.string = textView.string + "* "
    }
    
    func insertOrderedList() {
        textView.string = textView.string + "1. "
    }
    
}
