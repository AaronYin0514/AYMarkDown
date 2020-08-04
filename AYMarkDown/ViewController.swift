//
//  ViewController.swift
//  AYMarkDown
//
//  Created by Aaron on 2020/8/3.
//  Copyright © 2020 Aaron. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController {

    @IBOutlet weak var scrollView: NSScrollView!
    
    @IBOutlet weak var webView: WKWebView!
    
    private var textView: NSTextView {
        return scrollView.documentView as! NSTextView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        print(textView.documentView)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
}

