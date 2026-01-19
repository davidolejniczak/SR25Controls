//
//  SR25ControlsApp.swift
//  SR25Controls
//
//  Created by David Olejniczak on 2026-01-17.
//

import SwiftUI
import Combine
import CoreMotion
import Foundation
import Network

class PhoneControls: ObservableObject {
    @Published var gyroEnabled : Bool = false
    @Published var throttle : Int32 = 0
    @Published var roll : Double = 0
    @Published var pitch : Double = 0
    @Published var yaw : Double = 0
    
    private var startRoll : Double = 0
    private var startPitch : Double = 0
    private var startYaw : Double = 0
    
    func resetGYRO () {
        self.roll = startRoll
        self.pitch = startPitch
        self.yaw = startYaw
    }
}

class UDPClient: ObservableObject {
    var connection: NWConnection?
        var host: NWEndpoint.Host
        var port: NWEndpoint.Port

        init(address: String = "", port: UInt16 = 8080) {
            self.host = NWEndpoint.Host(address)
            self.port = NWEndpoint.Port(rawValue: port)!
            connect()
        }

        func connect() {
            connection = NWConnection(host: host, port: port, using: .udp)
            connection?.start(queue: .global())
        }
    
    func sendDatatoApp(p : Double, r : Double, y : Double){
        let instruction = "\(p),\(r),\(y)"
        let data = instruction.data(using: .utf8)
        connection?.send(content: data, completion: .contentProcessed({ error in
            if let error = error {
                print("Send error: \(error)")
            }
        }))
    }
}

class PhoneMotion: ObservableObject {
    
    var phone_controls : PhoneControls
    private let udpClient = UDPClient()
    let motion = CMMotionManager()
    private var referenceAttitude: CMAttitude?
    private let sensorQueue = OperationQueue()
    
    init(controls: PhoneControls) {
        self.phone_controls = controls
        sensorQueue.qualityOfService = .userInteractive
        startMotionUpdates()
        
    }
    
    func startMotionUpdates() {
        if self.motion.isDeviceMotionAvailable {
            self.motion.deviceMotionUpdateInterval = 1.0 / 60.0 // 60Hz
            phone_controls.gyroEnabled = true
            
            let refFrame = CMAttitudeReferenceFrame.xArbitraryZVertical
            motion.startDeviceMotionUpdates(using: refFrame, to: sensorQueue) { (data, error) in
                if error != nil {
                    print("Sensor Error: \(error!.localizedDescription)")
                    return
                }
                
                if let safeData = data {
                    let currentAttitude = safeData.attitude
                    if self.referenceAttitude != nil {
                        currentAttitude.multiply(byInverseOf: self.referenceAttitude!)
                    }
                    let pitch = currentAttitude.pitch
                    let roll = currentAttitude.roll
                    let yaw = currentAttitude.yaw
                    
                    self.udpClient.sendDatatoApp(p: pitch, r: roll, y: yaw) // sent in rad
                    
                    DispatchQueue.main.async {
                        self.phone_controls.pitch = pitch
                        self.phone_controls.roll = roll
                        self.phone_controls.yaw = yaw
                    }
                }
            }
        }
    }
    
    func resetMotion() {
        if let currentAttitude = motion.deviceMotion {
            self.referenceAttitude = currentAttitude.attitude
        }
    }
    
    func stopMotionUpdates() {
        self.motion.stopDeviceMotionUpdates()
        phone_controls.gyroEnabled = false
    }
}


@main
struct SR25ControlsApp: App {
    var body: some Scene {
        WindowGroup {
            let phoneControls = PhoneControls()
            let _ = PhoneMotion(controls: phoneControls)
            ContentView()
                .environmentObject(phoneControls)
        }
    }
}

