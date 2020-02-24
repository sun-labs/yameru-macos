//: A Cocoa based Playground to present user interface

import AppKit
import PlaygroundSupport

import Foundation
import IOKit.ps

func batteryStatus() -> Int {
    // Take a snapshot of all the power source info
    var Charging = 0
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
            print("\(ChargingState)")
            if ChargingState.contains("Battery") {
                Charging = 0
            } else {
                Charging = 1
            }
        }
    }
    return Charging
}


let nibFile = NSNib.Name("MyView")
var topLevelObjects : NSArray?

Bundle.main.loadNibNamed(nibFile, owner:nil, topLevelObjects: &topLevelObjects)
let views = (topLevelObjects as! Array<Any>).filter { $0 is NSView }

// Present the view in Playground
PlaygroundPage.current.liveView = views[0] as! NSView

print(batteryStatus())



