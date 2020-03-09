//
//  PrefGeneralVC.swift
//  Yameru
//
//  Created by Victor Ingman on 2020-03-02.
//  Copyright © 2020 Sun Labs. All rights reserved.
//

import Preferences
import Cocoa
import AVFoundation
import SwiftHash

class PrefGeneralVC: NSViewController, PreferencePane {
    let preferencePaneIdentifier = PreferencePane.Identifier.general
    let preferencePaneTitle = "General"
    let toolbarItemIcon = NSImage(named: NSImage.preferencesGeneralName)!
    var soundPlayer: AVAudioPlayer!

    override var nibName: NSNib.Name? { "PrefGeneralView" }
    
    @IBOutlet weak var previewButton: NSButton!
    @IBOutlet weak var soundDropdown: NSPopUpButton!
    @IBOutlet weak var filePathLabel: NSTextFieldCell!
    @IBOutlet weak var pinCodeSwitch: NSSegmentedControl!
    
    var isPreviewPlaying = false
    
    
    func setDefaultSound() {
        let url = Bundle.main.url(forResource: "anime-scream", withExtension: "mp3")!
        UserDefaults.standard.set("default", forKey: "alarmSound")
        setAlarmSound(for: url)
    }
    @IBAction func defaultClick(_ sender: Any) {
        setDefaultSound()
    }
    @IBAction func previewClick(_ sender: Any) {
        if (isPreviewPlaying) {
            self.soundPlayer.stop()
            self.previewButton.title = "Preview"
        } else {
            self.soundPlayer.currentTime = TimeInterval(0)
            self.soundPlayer.play()
            self.previewButton.title = "Stop Preview"
        }
        isPreviewPlaying = !isPreviewPlaying
    }
    @IBAction func customSoundClick(_ sender: Any) {
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a .mp3 file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["mp3"];

        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let applicationPath = SLPreferences.getApplicationDir()
                let fm = FileManager()
                
                let fullStorePath = applicationPath.appendingPathComponent(result!.lastPathComponent)
                do {
                    try fm.copyItem(at: result!, to: fullStorePath)
                } catch let error {
                    print(error.localizedDescription)
                }
                print(fullStorePath)
                UserDefaults.standard.set(fullStorePath.path, forKey: "alarmSound")
                setAlarmSound(for: fullStorePath)
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    func setAlarmSound(for path: URL) {
        do {
            self.soundPlayer = try AVAudioPlayer(contentsOf: path)
            filePathLabel.stringValue = path.absoluteString
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func pinCodeSwitch(_ sender: NSSegmentedControl) {
        let defaults  = UserDefaults.standard
        let value = sender.selectedSegment
        defaults.set(value, forKey: "noPinCode")
    }
    
    func getString(title: String, question: String, defaultValue: String = "") -> String {
        let msg = NSAlert()
        msg.addButton(withTitle: "OK")      // 1st button
        msg.addButton(withTitle: "Cancel")  // 2nd button
        msg.messageText = title
        msg.informativeText = question

        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        txt.stringValue = defaultValue

        msg.accessoryView = txt
        let response: NSApplication.ModalResponse = msg.runModal()

        if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
            return txt.stringValue
        } else {
            return ""
        }
    }
    
    @IBAction func clickSetPin(_ sender: Any) {
        let current = SLPreferences.PinCode
        if (current != nil) {
            let userCurrent = getString(title: "Security Check", question: "Please enter current Pin Code")
            let userMD5 = MD5(userCurrent)
            if (current != userMD5) {
                return
            }
        }
        
        let newPin = getString(title: "Security Check", question: "Please enter new Pin Code")
        if (!newPin.isEmpty) {
            SLPreferences.PinCode = newPin
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults  = UserDefaults.standard.string(forKey: "alarmSound")
        if (defaults == "default") {
            setDefaultSound()
            self.filePathLabel.stringValue = "Default Alarm"
        } else {
            self.setAlarmSound(for: URL(fileURLWithPath: defaults!))
        }
        // Setup stuff here
    }
    
    
    
}
