//
//  ViewController.swift
//  AYMarkDown
//
//  Created by Aaron on 2020/8/3.
//  Copyright © 2020 Aaron. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSSplitViewController {
    
    var documnetViewController: DocumentViewController!
    var notesViewController: NotesViewController!
    var markdownViewController: MarkDwonViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for item in splitViewItems {
            if item.viewController is DocumentViewController {
                documnetViewController = item.viewController as? DocumentViewController
                documnetViewController.didSelectURL = { [unowned self] (url) in
                    self.notesViewController.loadData(url)
                }
                item.maximumThickness = 180
                item.minimumThickness = 180
            } else if item.viewController is NotesViewController {
                notesViewController = item.viewController as? NotesViewController
                notesViewController.didSelectDocument = { [unowned self] (text, url) in
                    self.markdownViewController.set(text: text, url: url)
                }
                item.maximumThickness = 220
                item.minimumThickness = 220
            } else if item.viewController is MarkDwonViewController {
                markdownViewController = item.viewController as? MarkDwonViewController
            }
        }
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
}
