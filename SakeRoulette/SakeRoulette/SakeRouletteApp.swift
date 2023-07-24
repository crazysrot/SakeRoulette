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
    @State private var sectionTitles = ["Sake1", "Sake2", "Sake3", "Sake4", "Sake5", "Sake6", "Sake7", "Sake8", "Sake9", "Sake10"]
    @State private var isSpinning: Bool = false
    @State private var rotation: Double = 0

    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    RouletteView(sectionTitles: $sectionTitles, isSpinning: $isSpinning, rotation: $rotation, animationDuration: 10.0)

                    GeometryReader { geometry in
                        Path { path in
                            let width = geometry.size.width / 20
                            let height = geometry.size.height / 15
                            path.move(to: CGPoint(x: geometry.size.width / 2 - width / 2, y: 0))
                            path.addLine(to: CGPoint(x: geometry.size.width / 2 + width / 2, y: 0))
                            path.addLine(to: CGPoint(x: geometry.size.width / 2, y: height))
                            path.closeSubpath()
                        }
                        .fill(Color.red)
                        .offset(x: 0, y: geometry.size.height / 9)
                    }
                }

                Button("Start") {
                    withAnimation {
                        self.isSpinning = true
                        self.rotation += 3600 + Double(arc4random_uniform(360))
                    }
                }
                .padding()
                
                NavigationLink(destination: SettingsView(sectionTitles: $sectionTitles, rotation: $rotation, isSpinning: $isSpinning)) {
                    Text("Settings")
                }
                .padding()
                
            }
            .navigationTitle("Roulette")
        }
    }
}

struct SettingsView: View {
    @Binding var sectionTitles: [String]
    @Binding var rotation: Double
    @Binding var isSpinning: Bool
    @State private var newTitle = ""
    @State private var editingIndex: Int?

    var body: some View {
        VStack {
            HStack {
                TextField("Add new sake title", text: $newTitle, onCommit:  {
                    if !newTitle.isEmpty {
                        sectionTitles.append(newTitle)
                        newTitle = ""
                        resetRoulette()
                    }
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Add") {
                    if !newTitle.isEmpty {
                        sectionTitles.append(newTitle)
                        newTitle = ""
                        resetRoulette()
                    }
                }
            }
            .padding()

            List {
                ForEach(sectionTitles.indices, id: \.self) { index in
                    HStack {
                        if editingIndex == index {
                            TextField("Edit sake title", text: Binding(
                                get: { self.sectionTitles[index] },
                                set: { self.sectionTitles[index] = $0 }
                            ), onCommit: {
                                self.editingIndex = nil
                                resetRoulette()
                            })
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            Text(sectionTitles[index])
                                .onTapGesture {
                                    self.editingIndex = index
                                }
                        }
                        Spacer()
                        Button(action: {
                            removeTitle(at: IndexSet(integer: index))
                            resetRoulette()
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .navigationTitle("Settings")
    }

    private func removeTitle(at offsets: IndexSet) {
        sectionTitles.remove(atOffsets: offsets)
    }

    private func resetRoulette() {
        rotation = 0
        isSpinning = false
    }
}
