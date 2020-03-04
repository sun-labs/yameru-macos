//
//  USBProtector.swift
//  Yameru
//
//  Created by Victor Ingman on 2020-03-04.
//  Copyright © 2020 Sun Labs. All rights reserved.
//

import Foundation
import IOUSBHost

class YameruTheProtector {
    /// credits: https://stackoverflow.com/questions/26971240/how-do-i-run-an-terminal-command-in-a-swift-script-e-g-xcodebuild
    func shell(_ command: String) -> String {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String

        return output
    }
    func lockComputer () -> String {
        return self.shell("/System/Library/CoreServices/Menu\\ Extras/User.menu/Contents/Resources/CGSession -suspend")
    }
    func getUSBDevices () -> String {
        let spOutput = self.shell("system_profiler SPUSBDataType")
        return spOutput
    }
}
