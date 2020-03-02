//
//  PrefGeneralVC.swift
//  Yameru
//
//  Created by Victor Ingman on 2020-03-02.
//  Copyright © 2020 Sun Labs. All rights reserved.
//

import Preferences
import Cocoa

class PrefGeneralVC: NSViewController, PreferencePane {
    let preferencePaneIdentifier = PreferencePane.Identifier.general
    let preferencePaneTitle = "General"
    let toolbarItemIcon = NSImage(named: NSImage.preferencesGeneralName)!

    override var nibName: NSNib.Name? { "PrefGeneralView" }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup stuff here
    }
    
}
