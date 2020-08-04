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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for item in splitViewItems {
            if item.viewController is DocumentViewController {
                item.maximumThickness = 180
                item.minimumThickness = 180
            } else if item.viewController is NotesViewController {
                item.maximumThickness = 220
                item.minimumThickness = 220
            }
        }
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
}
