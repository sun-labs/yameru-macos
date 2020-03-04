//
//  SLPreferences.swift
//  Yameru
//
//  Created by Victor Ingman on 2020-03-04.
//  Copyright © 2020 Sun Labs. All rights reserved.
//

import Foundation

class SLPreferences {
    
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
