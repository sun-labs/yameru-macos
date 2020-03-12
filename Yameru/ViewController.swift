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
import SwiftHash

extension Array {
    func diff(_ array: Array) -> Int {
        return self.count - array.count
    }
}

class ViewController: NSViewController {
    
    @IBOutlet weak var lockButton: NSButton!
    @IBOutlet weak var txtPinCode: NSTextField!
    @IBOutlet weak var lblPinCode: NSTextField!
    
    var battery: batteryStatus!
    var timer: Timer!
    var uiTimer: Timer!
    var soundPlayer: AVAudioPlayer!
    var soundPlayerUsb: AVAudioPlayer!
    var pushover: Pushover?
    var updateCounter = 0
    var isLocked = false
    var yameru: YameruTheProtector!
    var usbSnapshot: [String] = []
    var userVolume: String!
    var curImage = "yameru-logo-normal"
    
    var usbAlarm = false
    var cableAlarm = false
    var cableActivated = false
    var usbActivated = true
    
    @IBOutlet weak var deviceLblValue: NSTextField!
    @IBOutlet weak var powerCableLblValue: NSTextField!
    @IBOutlet weak var yameruImage: NSImageView!
    
    required init?(coder aCoder: NSCoder) {
        super.init(coder: aCoder)
        self.battery = batteryStatus()
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        self.yameru = YameruTheProtector()
    }
    
    override func viewDidAppear() {
        if !isKeyPresentInUserDefaults(key: "setupDone") {
            performSegue(withIdentifier: "setupSegue", sender: self)
            UserDefaults.standard.set(true, forKey: "setupDone")
        }
    }
    
    override func viewDidLoad() {
        SLPreferences.prepareApplicationDir()
        let defaults  = UserDefaults.standard
        if !isKeyPresentInUserDefaults(key: "setupDone"){
            defaults.set(false, forKey: "blockUsb")
            defaults.set("default", forKey: "alarmSound")
            defaults.set(0, forKey: "noPinCode")
            defaults.set(true, forKey: "secureMode")
        }
        txtPinCode.isHidden = true
        lblPinCode.isHidden = true
        yameruImage.animates = true
        fireTimer()
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
    
    @objc func fireTimer () {
        if (isLocked) {
            safetyRoutine()
        }
        updateUI()
    }
    
    @IBAction func textFieldEnterClick(_ sender: NSSecureTextField) {
        self.toggleLock ()
    }
    func hideError() {
        txtPinCode.layer?.borderWidth = 0
        txtPinCode.textColor = NSColor.black
        txtPinCode.stringValue = ""
    }
    func showError () {
        txtPinCode.textColor = NSColor.red
        txtPinCode.wantsLayer = true
        txtPinCode.layer?.borderColor = NSColor.red.cgColor
        txtPinCode.layer?.borderWidth = 3.0
        txtPinCode.layer?.cornerRadius = 0.0
    }
    
    func toggleLock () {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        if (!isLocked) {
        // run sudo related commands
        if (SLPreferences.SecureMode!) {
            let response = self.yameru.disableLidSleep()
            if (response == nil) {
                return
            }
        }
        // alarm
        let defaults  = UserDefaults.standard.string(forKey: "alarmSound")!
        var url = URL(fileURLWithPath: defaults)
        print(defaults)
        if (defaults == "default") {
            url = Bundle.main.url(forResource: "anime-scream", withExtension: "mp3")!
        }
        do {
            self.soundPlayer = try AVAudioPlayer(contentsOf: url)
            self.soundPlayerUsb = try AVAudioPlayer(contentsOf: url)
        } catch let error {
            print(error.localizedDescription)
        }
            self.soundPlayerUsb.numberOfLoops = -1
            self.soundPlayerUsb.prepareToPlay()
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
        // ui related
            self.lblPinCode.isHidden = false
            self.txtPinCode.isHidden = false
            appDelegate.disableProperties()
            self.view.window!.styleMask.remove(.closable)
            
        // toggle on
        isLocked = true
            
        } else {
            if let pinCode = SLPreferences.PinCode{
                print(pinCode)
                let enteredPin = txtPinCode.stringValue
                if !pinCode.isEmpty {
                    if (!enteredPin.isEmpty) {
                        if MD5(enteredPin) == pinCode {
                            unlock()
                            hideError()
                        } else {
                            showError()
                            
                        }
                    } else {
                        showError()
                    }
                } else {
                    hideError()
                    unlock()
                }
            } else {
                hideError()
                unlock()
            }
            self.yameru.setMacVolume(to: self.userVolume)
        }
    }
    func unlock () {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        // run sudo related commands
        if (SLPreferences.SecureMode! == true) {
            let response = self.yameru.enableLidSleep()
            if (response == nil) {
                return
            }
        }
        self.isLocked = false
        txtPinCode.isHidden = true
        lblPinCode.isHidden = true
        appDelegate.enableProperties()
        self.view.window!.styleMask.insert(.closable)
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
    }
    
    func soundUsbAlarm() {
        self.soundPlayerUsb.volume = 1.0
        self.soundPlayerUsb.play()
    }
    
    func stopUsbAlarm() {
        self.soundPlayerUsb.stop()
        self.soundPlayerUsb.currentTime = TimeInterval(0)
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
                self.pushover?.send(message: "🚨 Computer disconnected!")
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
                stopUsbAlarm()
            }
        } else {
            self.yameru.setMaxVolume()
            if (!self.usbAlarm) {
                self.yameru.lockComputer()
                if (nDevices > nSnapDevices) {
                    self.pushover?.send(message: "🚨 New USB device connected")
                } else {
                    self.pushover?.send(message: "🚨 USB device removed")
                }
                soundUsbAlarm()
                self.usbAlarm = true
            }
        }
    }
    
    func safetyRoutine () {
        cableRoutine()
        usbRoutine()
    }
    
    func setYameruImage (name: String) {
       if (self.curImage != name) {
        self.curImage = name
        self.yameruImage.image = NSImage(named: name)
        }
    }
    
    func setYameruGifImage (name: String) {
        if (self.curImage != name) {
            self.curImage = name
            self.yameruImage.image = NSImage(data: NSDataAsset(name: name)!.data)
        }
    }
    
    func updateUI () {
        updateCounter += 1
        lockButton.title = isLocked
            ? "Unlock Device"
            : "Lock Device"
        let isSafe = !usbAlarm && !cableAlarm
        let isCharging = isConnected()
        if (isLocked) {
            powerCableLblValue.stringValue = cableActivated
                ? cableAlarm
                    ? "🚨 Disconnected"
                    : "🔒 Armed"
                : "⚠️ Not Activated"
            deviceLblValue.stringValue = usbAlarm
                ? "🚨 Danger"
                : "🔒 Armed"
            if (isSafe) {
                self.setYameruGifImage(name: "yameru-active")
            } else {
                self.setYameruGifImage(name: "yameru-alarm")
            }
        } else {
            powerCableLblValue.stringValue = isCharging
                ? "Ready"
                : "⚠️ Not Connected"
            deviceLblValue.stringValue = usbActivated
                ? "Ready"
                : "⚠️ Not Activated"
            self.setYameruImage(name: "yameru-logo-normal")
        }
        
    }
}
