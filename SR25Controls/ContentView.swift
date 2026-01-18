//
//  ContentView.swift
//  SR25Controls
//
//  Created by David Olejniczak on 2026-01-17.
//

import SwiftUI
import Combine

extension Color {
    static let darkBackground = Color(red: 0.309, green: 0.4274, blue: 0.5490)
    static let panelGray = Color(red: 0.21, green: 0.20, blue: 0.22)
    static let safetyOrange = Color(red: 1.0, green: 0.6, blue: 0.0)
    static let radarGreen = Color(red: 0.2, green: 0.9, blue: 0.4)
}

struct VerticalSlider: View {
    @Binding var value: Double
    var inRange: ClosedRange<Double>
    var step: Double
    var height: CGFloat = 300
    var accentColor: Color
    
    var body: some View {
        Slider(value: $value, in: inRange, step: step)
            .frame(width: height)
            .rotationEffect(.degrees(-90))
            .frame(width: 80, height: height)
            .scaleEffect(x: 3.0)
            .tint(accentColor)
    }
}

struct ContentView: View {
    
    @StateObject private var controls = PhoneControls()
    
    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
            
            HStack(spacing: 0) {
                VerticalSlider(
                    value: Binding(
                        get: { Double(controls.throttle) },
                        set: { controls.throttle = Int32($0) }
                    ),
                    inRange: 0...3,
                    step: 1,
                    height: 325,
                    accentColor: .radarGreen
                ).background(Color.panelGray) // Panel background
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                Spacer()
                
                
                VStack(spacing: 30){
                    Text("Throttle Level")
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundColor(.black)
                        .padding(.top)
                    
                    Text("\(controls.throttle)")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(.safetyOrange)
                    Button(action: {
                        controls.pitch = 0
                        controls.yaw = 0
                        controls.roll = 0
                    }){
                        Text("RESET GYRO")
                            .font(.system(size: 16, weight: .heavy, design: .monospaced))
                            .foregroundColor(.black)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 30)
                            .background(Color.gray) // Matte Gray button
                            .cornerRadius(30)
                        // A "Safety Warning" border
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.black, lineWidth: 3)
                            )
                            .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 5)
                    }
                }
                
                Spacer()
                VerticalSlider(
                    value: Binding(
                        get: { Double(controls.throttle) },
                        set: { controls.throttle = Int32($0) }
                    ),
                    inRange: 0...3,
                    step: 1,
                    height: 325,
                    accentColor: .radarGreen
                    
                ).background(Color.panelGray) // Panel background
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    ).padding(10)
            }
        }
    }
}

    
#Preview {
    ContentView()
}
