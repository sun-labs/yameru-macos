//
//  ContentView.swift
//  Yameru
//
//  Created by Linus on 2020-02-25.
//  Copyright © 2020 Sun Labs. All rights reserved.
//

import SwiftUI
import AppKit

import Foundation
import IOKit.ps

struct ContentView: View {
    let battery = batteryStatus()
    
    var body: some View {
            Text(" Status \(self.battery.BatteryStatus())")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
