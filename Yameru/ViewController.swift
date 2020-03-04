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
    var soundPlayer: AVAudioPlayer!
    var pushover: Pushover?
    var updateCounter = 0
    var isLocked = false
    var isStolen = false
    
    
    required init?(coder aCoder: NSCoder) {
        super.init(coder: aCoder)
        self.battery = batteryStatus()
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    override func viewDidLoad() {
        SLPreferences.prepareApplicationDir()
        let defaults  = UserDefaults.standard
        if !isKeyPresentInUserDefaults(key: "setupDone"){
            defaults.set(true, forKey: "setupDone")
            defaults.set(false, forKey: "blockUsb")
            defaults.set("default", forKey: "alarmSound")
        }
        fireTimer()
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func soundTheAlarm () {
        self.soundPlayer.play()
    }
    
    @objc func fireTimer () {
        if (isLocked) {
            safetyRoutine()
        }
        updateUI()
    }
    
    func toggleLock () {
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
        
        let token = SLPreferences.PushoverAppToken
        let userToken = SLPreferences.PushoverUserToken
        if (token != nil && userToken != nil) {
            self.pushover = Pushover(app: token!, user: userToken!)
        } else {
            self.pushover = nil
        }
        isLocked = !isLocked
    }
    @IBAction func lockButtonClick(_ sender: Any) {
        toggleLock()
    }
    
    func isConnected () -> Bool {
        return battery.isCharging()
    }
    
    func safetyRoutine () {
        if (!isConnected()) {
            if (!self.isStolen) { // first run
                if (self.pushover != nil) {
                    self.pushover!.send(message: "ALARM COMPUTER DISCONNECTED!!")
                }
            }
            self.soundPlayer.volume = 1.0
            self.soundPlayer.play()
            self.isStolen = true
        } else {
            if (self.isStolen) { // first after connection
                if (self.pushover != nil) {
                    self.pushover!.send(message: "Computer connected again")
                }
            }
            self.isStolen = false
            self.soundPlayer.stop()
            self.soundPlayer.currentTime = TimeInterval(0)
        }
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
