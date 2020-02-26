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
    var battery: batteryStatus!
    var timer: Timer!
    var updateCounter = 0
    
    required init?(coder aCoder: NSCoder) {
        super.init(coder: aCoder)
        self.battery = batteryStatus()
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    @objc func fireTimer () {
        updateUI()
    }
    
    func updateUI () {
        updateCounter += 1
        let isCharging = battery.isCharging()
        lockLabel.stringValue = isCharging ? "🔒" : "🔓"
        BatteryStatusLabel.stringValue = "\(isCharging) (\(updateCounter))"
        
    }
}
