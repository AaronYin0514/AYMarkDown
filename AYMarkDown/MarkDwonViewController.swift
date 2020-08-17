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
                    DispatchQueue.main.async {
                        self.refresh(markdownHTML)
                    }
                } catch {
                    print("解析MarkDown文本异常 - \(error.localizedDescription)")
                }
            } else {
                print("解析MarkDown文本异常 - \(error?.localizedDescription ?? "为知错误")")
            }
        }
    }
    
    func refresh(_ markdown: String) {
//        webView.loadHTMLString(markdown, baseURL: nil)
//        webView.loadHTMLString(markdown, baseURL: URL(string: "file:///"))
        webView.loadHTMLString(markdown, baseURL: URL(string: "file://"))
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
