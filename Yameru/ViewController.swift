//
//  ViewController.swift
//  Yameru
//
//  Created by Victor Ingman on 2020-02-26.
//  Copyright © 2020 Sun Labs. All rights reserved.
//

import Foundation
import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var BatteryStatusLabel: NSTextField!
    @IBOutlet weak var lockLabel: NSTextField!
    @IBOutlet weak var lockButton: NSButton!
    
    var battery: batteryStatus!
    var timer: Timer!
    var updateCounter = 0
    var isLocked = false
    
    
    required init?(coder aCoder: NSCoder) {
        super.init(coder: aCoder)
        self.battery = batteryStatus()
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    @objc func fireTimer () {
        updateUI()
    }
    
    func toggleLock () {
        isLocked = !isLocked
    }
    @IBAction func lockButtonClick(_ sender: Any) {
        toggleLock()
    }
    
    func updateUI () {
        updateCounter += 1
        let isCharging = battery.isCharging()
        if (isLocked) {
            lockButton.title = "Unlock Device"
            lockLabel.stringValue = isCharging
                ? "🔒"
                : "🚨"
        } else {
            lockButton.title = "Lock Device"
            lockLabel.stringValue = isCharging
                ? "⚡︎"
                : "🔋"
        }
        BatteryStatusLabel.stringValue = "\(isCharging) (\(updateCounter))"
        
    }
}
