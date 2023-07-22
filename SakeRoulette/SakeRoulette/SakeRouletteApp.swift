//
//  SakeRouletteApp.swift
//  SakeRoulette
//
//  Created by crazysrot on 2023/07/23.
//

import SwiftUI

@main
struct ListAppApp: App {
    var body: some Scene {
        WindowGroup {
            RouletteContentView()
        }
    }
}

struct RouletteContentView: View {
    @State private var isSpinning: Bool = false
    @State private var rotation: Double = 0

    var body: some View {
        VStack {
            ZStack {
                RouletteView(numberOfSections: 10, isSpinning: $isSpinning, rotation: $rotation, animationDuration: 5.0) // DurationSetting1
                
                // The fixed bar is added outside the rotating RouletteView.
                GeometryReader { geometry in
                    Path { path in
                        let width = geometry.size.width / 20 // Adjust this value to change the base of the triangle
                        let height = geometry.size.height / 15 // Adjust this value to change the height of the triangle
                        path.move(to: CGPoint(x: geometry.size.width / 2 - width / 2, y: 0))
                        path.addLine(to: CGPoint(x: geometry.size.width / 2 + width / 2, y: 0))
                        path.addLine(to: CGPoint(x: geometry.size.width / 2, y: height))
                        path.closeSubpath()
                    }
                    .fill(Color.red) // Color of the triangle
                    .offset(x: 0, y: geometry.size.height / 6)
                }
            }
            
            Button("Start") {
                withAnimation {
                    self.isSpinning = true
                    self.rotation += 3600 + Double(arc4random_uniform(360))
                }
            }
            .padding()
        }
    }
}
