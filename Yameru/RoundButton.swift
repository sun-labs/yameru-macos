//
//  RoundButton.swift
//  Yameru
//
//  Created by Victor Ingman on 2020-03-10.
//  Copyright © 2020 Sun Labs. All rights reserved.
//

import Foundation
import Cocoa

@IBDesignable class RoundButton : NSButton {
    
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if let layer = self.layer {
           layer.cornerRadius = layer.frame.height / 2
            layer.backgroundColor = CGColor(red: 1, green: 0, blue: 0, alpha: 1)
            layer.borderWidth = 2
            layer.borderColor = CGColor(gray: 1.0, alpha: 1.0)
        }
    }
}
