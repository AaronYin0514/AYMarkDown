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
        
    }
    
    func insertUnorderedList() {
        textView.string = textView.string + "* "
    }
    
    func insertOrderedList() {
        textView.string = textView.string + "1. "
    }
    
    // MARK: - Method
    
    private func parsingMarkDown(_ string: String) {
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
    
    func refresh(_ markdown: String) {
        guard let url = checkIClould() else {
            print("请先开启iCloud功能")
            return
        }
        let docURL = url.appendingPathComponent("Documents/\(__resources_document_name)", isDirectory: true)
        let fileName = "tmp.html"
        let fileURL = docURL.appendingPathComponent(fileName)
        do {
            let document = try AYDocument(type: "html")
            document.setText(markdown)
            document.save(to: fileURL, ofType: "html", for: .saveOperation) { [unowned self] (error) in
                if error != nil {
                    print("iCloud创建失败 - \(error!.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        self.webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
                    }
                }
            }
        } catch {
            print("创建失败 - \(error.localizedDescription)")
        }
    }
    
    private func checkIClould() -> URL? {
        FileManager.default.url(forUbiquityContainerIdentifier: "iCloud.com.aaron.brain")
    }
    
}

extension MarkDwonViewController: NSTextViewDelegate {
    
    func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
        if replacementString == "\n" {
            parsingMarkDown(textView.string)
        }
        return true
    }
    
}

extension MarkDwonViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
}
