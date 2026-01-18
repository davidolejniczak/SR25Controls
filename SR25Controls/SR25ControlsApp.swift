//
//  SR25ControlsApp.swift
//  SR25Controls
//
//  Created by David Olejniczak on 2026-01-17.
//

import SwiftUI
import Combine 

@main
struct SR25ControlsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


class PhoneControls: ObservableObject {
    @Published var throttle : Int32 = 0
    @Published var roll : Int32 = 0
    @Published var pitch : Int32 = 0
    @Published var yaw : Int32 = 0
    
    func resetRPY () {
        self.roll = 0
        self.pitch = 0
        self.yaw = 0
    }
}
