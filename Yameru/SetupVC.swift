//
//  SetupVC.swift
//  Yameru
//
//  Created by Victor Ingman on 2020-03-11.
//  Copyright © 2020 Sun Labs. All rights reserved.
//

import Foundation
import Cocoa

class SetupVC : NSViewController {
    @IBOutlet weak var txtPinCode: NSTextField!
    @IBOutlet weak var checkSecureMode: NSButton!
    @IBOutlet weak var lblErrPinCode: NSTextField!
    
    func showError (message: String? = nil) {
        if let msg = message {
            lblErrPinCode.stringValue = msg
        }
        lblErrPinCode.isHidden = false
    }
    
    func hideError () {
        lblErrPinCode.isHidden = true
    }
    
    func validateForm() {
        let enteredPinCode = txtPinCode.stringValue
        if !enteredPinCode.isEmpty {
            hideError()
            SLPreferences.PinCode = enteredPinCode
            SLPreferences.SecureMode = checkSecureMode.state.rawValue == 1
            dismiss(self)
        } else {
            
            showError()
        }
    }
    
    @IBAction func clickDone(_ sender: Any) {
        validateForm()
    }
}
