//
//  PrefAdvancedVC.swift
//  Yameru
//
//  Created by Victor Ingman on 2020-03-04.
//  Copyright © 2020 Sun Labs. All rights reserved.
//

import Foundation
import Cocoa
import Preferences

class PrefAdvancedVC: NSViewController, PreferencePane {
    let preferencePaneIdentifier = PreferencePane.Identifier.advanced
    let preferencePaneTitle = "Advanced"
    let toolbarItemIcon = NSImage(named: NSImage.advancedName)!

    override var nibName: NSNib.Name? { "PrefAdvancedView" }

}
