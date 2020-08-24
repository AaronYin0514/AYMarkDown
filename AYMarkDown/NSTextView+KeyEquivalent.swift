//
//  NSTextView+KeyEquivalent.swift
//  AYMarkDown
//
//  Created by Aaron on 2020/8/20.
//  Copyright © 2020 Aaron. All rights reserved.
//

import Cocoa

extension NSTextView {
    
    open override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if (event.type != .keyDown) {
            return super.performKeyEquivalent(with: event)
        }
        switch event.charactersIgnoringModifiers {
        case "a":
            return NSApp.sendAction(#selector(NSText.selectAll(_:)), to: self.window?.firstResponder, from: self)
        case "c":
            return NSApp.sendAction(#selector(NSText.copy(_:)), to: self.window?.firstResponder, from: self)
        case "v":
            return NSApp.sendAction(#selector(NSText.paste(_:)), to: self.window?.firstResponder, from: self)
        case "x":
            return NSApp.sendAction(#selector(NSText.cut(_:)), to: self.window?.firstResponder, from: self)
        default:
            break
        }
        if event.modifierFlags.contains(.command) {
            switch event.charactersIgnoringModifiers {
            case "b":
                return keyEquivalentStrong()
            case "B":
                return keyEquivalentClockquote()
            case "i":
                return keyEquivalentEmphasize()
            case "1":
                return keyEquivalentH1()
            case "2":
                return keyEquivalentH2()
            case "3":
                return keyEquivalentH3()
            case "4":
                return keyEquivalentH4()
            case "5":
                return keyEquivalentH5()
            case "6":
                return keyEquivalentH6()
            case "k":
                return keyEquivalentCode()
            case "I":
                print("等待完成")
                return true
            case "P":
                return keyEquivalentImageLink()
            case "K":
                return keyEquivalentLink()
            case "T":
                return keyEquivalentTable()
            case "U":
                return keyEquivalentUnorderedList()
            case "O":
                return keyEquivalentOrderedList()
            default:
                break
            }
        }
        return super.performKeyEquivalent(with: event)
        
    }
    
    private func keyEquivalentH1() -> Bool {
        if let controller = window?.contentViewController as? ViewController {
            controller.markdownViewController.insertH1()
        }
        return true
    }
    
    private func keyEquivalentH2() -> Bool {
        if let controller = window?.contentViewController as? ViewController {
            controller.markdownViewController.insertH2()
        }
        return true
    }
    
    private func keyEquivalentH3() -> Bool {
        if let controller = window?.contentViewController as? ViewController {
            controller.markdownViewController.insertH3()
        }
        return true
    }
    
    private func keyEquivalentH4() -> Bool {
        if let controller = window?.contentViewController as? ViewController {
            controller.markdownViewController.insertH4()
        }
        return true
    }
    
    private func keyEquivalentH5() -> Bool {
        if let controller = window?.contentViewController as? ViewController {
            controller.markdownViewController.insertH5()
        }
        return true
    }
    
    private func keyEquivalentH6() -> Bool {
        if let controller = window?.contentViewController as? ViewController {
            controller.markdownViewController.insertH6()
        }
        return true
    }
    
    private func keyEquivalentLink() -> Bool {
        if let controller = window?.contentViewController as? ViewController {
            controller.markdownViewController.insertLink()
        }
        return true
    }
    
    private func keyEquivalentStrong() -> Bool {
        if let controller = window?.contentViewController as? ViewController {
            controller.markdownViewController.insertStrong()
        }
        return true
    }
    
    private func keyEquivalentEmphasize() -> Bool {
        if let controller = window?.contentViewController as? ViewController {
            controller.markdownViewController.insertEmphasize()
        }
        return true
    }
    
    private func keyEquivalentClockquote() -> Bool {
        if let controller = window?.contentViewController as? ViewController {
            controller.markdownViewController.insertClockquote()
        }
        return true
    }
    
    private func keyEquivalentCode() -> Bool {
        if let controller = window?.contentViewController as? ViewController {
            controller.markdownViewController.insertCode()
        }
        return true
    }
    
    private func keyEquivalentTable() -> Bool {
        if let controller = window?.contentViewController as? ViewController {
            controller.markdownViewController.insertTable()
        }
        return true
    }
    
    private func keyEquivalentUnorderedList() -> Bool {
        if let controller = window?.contentViewController as? ViewController {
            controller.markdownViewController.insertUnorderedList()
        }
        return true
    }
    
    private func keyEquivalentOrderedList() -> Bool {
        if let controller = window?.contentViewController as? ViewController {
            controller.markdownViewController.insertOrderedList()
        }
        return true
    }
    
    func keyEquivalentImageLink() -> Bool {
        if let controller = window?.contentViewController as? ViewController {
            controller.markdownViewController.insetImageLink()
        }
        return true
    }
    
}
