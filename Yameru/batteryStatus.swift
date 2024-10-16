//
//  batteryStatus.swift
//  Yameru
//
//  Created by Linus on 2020-02-25.
//  Copyright © 2020 Sun Labs. All rights reserved.
//

import Cocoa
import SwiftUI
import AppKit

import Foundation
import IOKit.ps

class batteryStatus {
    
    func isCharging() -> Bool {
        // Take a snapshot of all the power source info
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        // Pull out a list of power sources
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array
        // For each power source...
        for ps in sources {
            // Fetch the information for a given power source out of our snapshot
            let info = IOPSGetPowerSourceDescription(snapshot, ps).takeUnretainedValue() as! [String: AnyObject]

            // Pull out the name and status
            if let _ = info[kIOPSNameKey] as? String,
                let ChargingState = info[kIOPSPowerSourceStateKey] as? String{
                return !ChargingState.contains("Battery")
            }
        }
        return false
    }
}
