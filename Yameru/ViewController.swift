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
    var updateCounter = 0
    var isLocked = false
    
    
    required init?(coder aCoder: NSCoder) {
        super.init(coder: aCoder)
        self.battery = batteryStatus()
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    override func viewDidLoad() {
        fireTimer()
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
        let url = Bundle.main.url(forResource: "anime-scream", withExtension: "mp3")!
        do {
            self.soundPlayer = try AVAudioPlayer(contentsOf: url)
        } catch let error {
            print(error.localizedDescription)
        }
        self.soundPlayer.prepareToPlay()
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
            self.soundPlayer.play()
        } else {
            self.soundPlayer.stop()
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
