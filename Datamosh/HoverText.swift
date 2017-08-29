//
//  HoverText.swift
//  Datamosh
//
//  Created by fairy-slipper on 8/28/17.
//  Copyright © 2017 fairy-slipper. All rights reserved.
//

import Cocoa

class HoverText: NSTextView {
    
    func fade() {
        NSAnimationContext.runAnimationGroup({_ in
            NSAnimationContext.current().duration = 0.5
            self.animator().alphaValue = 0.0
        }, completionHandler:{
        })
    }
}
