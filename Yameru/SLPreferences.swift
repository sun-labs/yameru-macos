//
//  SLPreferences.swift
//  Yameru
//
//  Created by Victor Ingman on 2020-03-04.
//  Copyright © 2020 Sun Labs. All rights reserved.
//

import Foundation
import SwiftHash

class SLPreferences {
    
    static var PushoverAppToken: String? {
        get {
            return UserDefaults.standard.string(forKey: "pushoverAppToken")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "pushoverAppToken")
        }
    }
    static var PushoverUserToken: String? {
        get {
            return UserDefaults.standard.string(forKey: "pushoverUserToken")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "pushoverUserToken")
        }
    }
    
    static var USBCheckActivated: Bool? {
        get { return UserDefaults.standard.bool(forKey: "usbCheckActivated") }
        set { UserDefaults.standard.set(newValue, forKey: "usbCheckActivated") }
    }
    
    static var PinCode: String? {
        get { return UserDefaults.standard.string(forKey: "pinCode") }
        set {
            UserDefaults.standard.set(
                newValue != nil
                    ? MD5(newValue!)
                    : "",
                forKey: "pinCode"
            )
        }
    }
    
    static func prepareApplicationDir () {
        if !SLPreferences.applicationDirExists() {
            let fm = FileManager()
            do {
                try fm.createDirectory(at: SLPreferences.getApplicationDir(), withIntermediateDirectories: false)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    static func applicationDirExists () -> Bool {
        let fm = FileManager()
        let path = SLPreferences.getApplicationDir()
        return fm.fileExists(atPath: path.absoluteString)
    }
    
    static func getApplicationDir() -> URL {
        let applicationPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return applicationPath.appendingPathComponent("se.sunlabs.yameru")
    }
}
