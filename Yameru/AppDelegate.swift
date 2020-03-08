//
//  AppDelegate.swift
//  Yameru
//
//  Created by Linus on 2020-02-25.
//  Copyright © 2020 Sun Labs. All rights reserved.
//

import Cocoa
import SwiftUI
import Preferences

extension PreferencePane.Identifier {
    static let general = Identifier("general")
    static let advanced = Identifier("advanced")
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var menuPropItem: NSMenuItem!
    var window: NSWindow!
    
    
    lazy var preferencesWindowController = PreferencesWindowController(
        preferencePanes: [
            PrefGeneralVC(),
            PrefAdvancedVC()
        ],
        hidesToolbarForSingleItem: false
    )
    
    @IBOutlet weak var appMenu: NSMenuItem!
    func disableProperties () {
        menuPropItem.isEnabled = false
    }
    
    func enableProperties () {
        menuPropItem.isEnabled = true
    }
    

    @IBAction func preferencesDidActivate(_ sender: Any) {
        preferencesWindowController.show()
    }
}

