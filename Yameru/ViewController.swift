//
//  ViewController.swift
//  Yameru
//
//  Created by Victor Ingman on 2020-02-26.
//  Copyright © 2020 Sun Labs. All rights reserved.
//

import Foundation
import Cocoa
import AVFoundation

extension Array {
    func diff(_ array: Array) -> Int {
        return self.count - array.count
    }
}

class ViewController: NSViewController {
    @IBOutlet weak var BatteryStatusLabel: NSTextField!
    @IBOutlet weak var lockLabel: NSTextField!
    @IBOutlet weak var lockButton: NSButton!
    
    var battery: batteryStatus!
    var timer: Timer!
    var uiTimer: Timer!
    var soundPlayer: AVAudioPlayer!
    var pushover: Pushover?
    var updateCounter = 0
    var isLocked = false
    var isStolen = false
    var yameru: YameruTheProtector!
    var usbSnapshot: [String] = []
    var userVolume: String!
    
    var usbAlarm = false
    var cableAlarm = false
    var cableActivated = false
    
    @IBOutlet var usbLabel: NSTextView!
    
    required init?(coder aCoder: NSCoder) {
        super.init(coder: aCoder)
        self.battery = batteryStatus()
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        self.uiTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(fireUITimer), userInfo: nil, repeats: true)
        self.yameru = YameruTheProtector()
    }
    
    override func viewDidLoad() {
        SLPreferences.prepareApplicationDir()
        let defaults  = UserDefaults.standard
        if !isKeyPresentInUserDefaults(key: "setupDone"){
            defaults.set(true, forKey: "setupDone")
            defaults.set(false, forKey: "blockUsb")
            defaults.set("default", forKey: "alarmSound")
            defaults.set(0, forKey: "noPinCode")
        }
        defaults.set(0, forKey: "noPinCode") //NOTE: need to be assigned one time
        fireTimer()
        fireUITimer()
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func getSnapshopUsbDevices () -> [String] {
        let devices = self.yameru.getUSBDevices()
        return devices.map {
            let name = $0["name"]
            let location = $0["location"]
            return "\(name ?? "-"):\(location ?? "-")"
        }
    }
    
    func snapshotUsbDevices () {
        self.usbSnapshot = self.getSnapshopUsbDevices()
    }
    
    func updateUSBDevices () {
        let nameList = self.yameru.getUSBDevices().map {
            return $0["name"]!
        }
        setUsbDevicesUI(deviceIds: nameList)
    }
    func setUsbDevicesUI (deviceIds: [String]) {
        let strNameList = deviceIds.joined(separator: "\n")
        self.usbLabel.string = strNameList
    }
    @objc func fireUITimer () {
        updateUSBDevices()
    }
    
    @objc func fireTimer () {
        if (isLocked) {
            safetyRoutine()
        }
        updateUI()
    }
    
    func toggleLock () {
        if (!isLocked) {
        // alarm
        let defaults  = UserDefaults.standard.string(forKey: "alarmSound")!
        var url = URL(fileURLWithPath: defaults)
        print(defaults)
        if (defaults == "default") {
            url = Bundle.main.url(forResource: "anime-scream", withExtension: "mp3")!
        }
        do {
            self.soundPlayer = try AVAudioPlayer(contentsOf: url)
        } catch let error {
            print(error.localizedDescription)
        }
        self.soundPlayer.numberOfLoops = -1
        self.soundPlayer.prepareToPlay()
        
        // pushover
        let token = SLPreferences.PushoverAppToken
        let userToken = SLPreferences.PushoverUserToken
        if (token != nil && userToken != nil) {
            self.pushover = Pushover(app: token!, user: userToken!)
        } else {
            self.pushover = nil
        }
            
        // cable
        self.cableActivated = isConnected()
        
        // usb routine
        snapshotUsbDevices()
        
        // volume
            self.userVolume = self.yameru.getMacVolume()
        } else {
            self.yameru.setMacVolume(to: self.userVolume)
        }
        
        isLocked = !isLocked
    }
    @IBAction func lockButtonClick(_ sender: Any) {
        toggleLock()
    }
    
    func isConnected () -> Bool {
        return battery.isCharging()
    }
    
    func soundTheAlarm() {
        self.soundPlayer.volume = 1.0
        self.soundPlayer.play()
        self.isStolen = true
    }
    
    func stopTheAlarm () {
        self.soundPlayer.stop()
        self.soundPlayer.currentTime = TimeInterval(0)
    }
    
    func resetVolume () {
        self.yameru.setMacVolume(to: self.userVolume)
    }
    
    func cableRoutine () {
        if (cableActivated) {
        if (!isConnected()) {
            self.yameru.setMaxVolume()
            if (!self.cableAlarm) { // first run
                self.yameru.lockComputer()
                self.pushover?.send(message: "🔒 Computer disconnected!")
                soundTheAlarm()
                self.cableAlarm = true
            }
        } else {
            if (self.cableAlarm) { // first after connection
                self.pushover?.send(message: "Computer connected again", priority: "0")
                self.resetVolume()
                self.cableAlarm = false
                stopTheAlarm()
            }
        }
        }
    }
    func usbRoutine() {
        let devices = self.getSnapshopUsbDevices()
        let deviceDiff = devices.diff(self.usbSnapshot)
        var equalDevices = true
        for deviceId in devices {
            if (!self.usbSnapshot.contains(deviceId)) {
                equalDevices = false
                break
            }
        }
        
        let nDevices = devices.count
        let nSnapDevices = self.usbSnapshot.count
        if deviceDiff == 0 && equalDevices {
            if (self.usbAlarm) {
                self.pushover?.send(message: "USB devices back to normal", priority: "0")
                self.usbAlarm = false
                self.resetVolume()
                stopTheAlarm()
            }
        } else {
            self.yameru.setMaxVolume()
            if (!self.usbAlarm) {
                self.yameru.lockComputer()
                if (nDevices > nSnapDevices) {
                    self.pushover?.send(message: "🔒 New USB device connected")
                } else {
                    self.pushover?.send(message: "🔒 USB device removed")
                }
                soundTheAlarm()
                self.usbAlarm = true
            }
        }
    }
    
    func safetyRoutine () {
        cableRoutine()
        usbRoutine()
    }
    
    func updateUI () {
        updateCounter += 1
        let isSafe = !usbAlarm && !cableAlarm
        let isCharging = isConnected()
        lockButton.isEnabled = isSafe
        if (isLocked) {
            lockButton.title = "Unlock Device"
            lockLabel.stringValue = isSafe ? "🔒" : "🚨"
        } else {
            lockButton.title = "Lock Device"
            lockLabel.stringValue = isCharging ? "🔌" : "🔋"
        }
        BatteryStatusLabel.stringValue = "\(isCharging) (\(updateCounter))"
        
    }
}
