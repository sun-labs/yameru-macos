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
    
    var usbAlarm = false
    var cableAlarm = false
    
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
        self.soundPlayer.prepareToPlay()
        
        // pushover
        let token = SLPreferences.PushoverAppToken
        let userToken = SLPreferences.PushoverUserToken
        if (token != nil && userToken != nil) {
            self.pushover = Pushover(app: token!, user: userToken!)
        } else {
            self.pushover = nil
        }
        
        // usb routine
        snapshotUsbDevices()
        
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
    
    func cableRoutine () {
        if (!isConnected()) {
            if (!self.cableAlarm) { // first run
                self.pushover?.send(message: "ALARM COMPUTER DISCONNECTED!!")
                soundTheAlarm()
                self.cableAlarm = true
            }
        } else {
            if (self.cableAlarm) { // first after connection
                self.pushover?.send(message: "Computer connected again", priority: "0")
                self.cableAlarm = false
                stopTheAlarm()
            }
        }
    }
    func usbRoutine() {
        let devices = self.yameru.getUSBDevices()
        if devices.count == self.usbSnapshot.count {
            self.usbAlarm = false
            stopTheAlarm()
        } else {
            soundTheAlarm()
            self.usbAlarm = true
        }
    }
    
    func safetyRoutine () {
        cableRoutine()
        usbRoutine()
    }
    
    func updateUI () {
        updateCounter += 1
        let isCharging = isConnected()
        lockButton.isEnabled = isCharging
        if (isLocked) {
            lockButton.title = "Unlock Device"
            lockLabel.stringValue = isCharging ? "🔒" : "🚨"
        } else {
            lockButton.title = "Lock Device"
            lockLabel.stringValue = isCharging ? "🔌" : "🔋"
        }
        BatteryStatusLabel.stringValue = "\(isCharging) (\(updateCounter))"
        
    }
}
