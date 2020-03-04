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

    @IBOutlet weak var txtPushoverUserToken: NSTextField!
    @IBOutlet weak var txtPushoverToken: NSTextField!
    override func viewDidLoad() {
        txtPushoverUserToken.stringValue = SLPreferences.PushoverUserToken ?? ""
        txtPushoverToken.stringValue = SLPreferences.PushoverAppToken ?? ""
    }
    
    @IBAction func onTestNotification(_ sender: Any) {
        let token = SLPreferences.PushoverAppToken
        let userToken = SLPreferences.PushoverUserToken
        if (token != nil && userToken != nil) {
            let push = Pushover(app: token!, user: userToken!)
            push.test()
        } else {
            
        }
    }
    @IBAction func pushoverTokenChange(_ sender: NSTextField) {
        SLPreferences.PushoverAppToken = sender.stringValue
    }
    @IBAction func pushoverUserTokenChange(_ sender: NSTextField) {
        SLPreferences.PushoverUserToken = sender.stringValue
    }
}
