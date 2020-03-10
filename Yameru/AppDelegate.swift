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
import CustomButton

extension PreferencePane.Identifier {
    static let general = Identifier("general")
    static let advanced = Identifier("advanced")
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var menuPropItem: NSMenuItem!
    var window: NSWindow!
    
    @IBOutlet var menuQuitItem: NSMenuItem!
    
    lazy var preferencesWindowController = PreferencesWindowController(
        preferencePanes: [
            PrefGeneralVC(),
            PrefAdvancedVC()
        ],
        hidesToolbarForSingleItem: false
    )
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
    }
    
    @IBOutlet weak var appMenu: NSMenuItem!
    func disableProperties () {
        menuPropItem.isEnabled = false
        menuQuitItem.isEnabled = false
    }
    
    func enableProperties () {
        menuPropItem.isEnabled = true
        menuQuitItem.isEnabled = true
    }
    

    @IBAction func preferencesDidActivate(_ sender: Any) {
        preferencesWindowController.show()
    }
}

