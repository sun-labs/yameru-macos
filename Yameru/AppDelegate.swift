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

    var window: NSWindow!
    lazy var preferencesWindowController = PreferencesWindowController(
        preferencePanes: [
            SettingsGeneralViewController()
        ]
    )

    @IBAction func preferencesDidActivate(_ sender: Any) {
        preferencesWindowController.show()
    }
    //    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        // Create the SwiftUI view that provides the window contents.
//        let contentView = ContentView()
//
//        // Create the window and set the content view.
//        window = NSWindow(
//            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
//            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
//            backing: .buffered, defer: false)
//        window.center()
//        window.setFrameAutosaveName("Yameru")
//        window.contentView = NSHostingView(rootView: contentView)
//        window.makeKeyAndOrderFront(nil)
//    }

//    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
//    }
}

