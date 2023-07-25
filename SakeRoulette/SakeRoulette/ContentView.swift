//
//  ContentView.swift
//  SakeRoulette
//
//  Created by crazysrot on 2023/07/23.
//

import SwiftUI

struct ContentView: View {
   @State private var sectionTitles = ["Sake1", "Sake2", "Sake3", "Sake4", "Sake5", "Sake6", "Sake7", "Sake8", "Sake9", "Sake10", "Sake11", "Sake12", "Sake13", "Sake14", "Sake15", "Sake16", "Sake17", "Sake18", "Sake19", "Sake20"]
   @State private var newTitle = ""
   @State private var isSpinning: Bool = false
   @State private var rotation: Double = 0
   @Binding private var animationDuration: Double
    

   var body: some View {
       VStack {
           RouletteView(sectionTitles: $sectionTitles, isSpinning: $isSpinning, rotation: $rotation, animationDuration: $animationDuration)
           
           HStack {
               TextField("Add new sake title", text: $newTitle)
                   .textFieldStyle(RoundedBorderTextFieldStyle())
               Button("Add") {
                   if !newTitle.isEmpty {
                       sectionTitles.append(newTitle)
                       newTitle = ""
                       rotation = 0
                       isSpinning = false
                   }
               }
               
           }
           .padding()
           
           List {
               ForEach(sectionTitles.indices, id: \.self) { index in
                   HStack {
                       Text(safeTitle(for: index))
                       Spacer()
                       Button(action: {
                           removeTitle(at: IndexSet(integer: index))
                       }) {
                           Image(systemName: "trash")
                               .foregroundColor(.red)
                       }
                   }
               }
           }

           Button("Start") {
               withAnimation {
                   self.isSpinning = true
                   self.rotation += 1000 + Double(arc4random_uniform(360))
               }
               #imageLiteral(resourceName: "simulator_screenshot_7C09E647-23E9-41C3-A374-D1EE8EDDB7A5.png")
               DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                   withAnimation {
                       self.isSpinning = false
                   }
               }
           }
           .padding()
       }
       // ここで`SpinningAnimation`と`SettingsView`に`$animationDuration`を渡します
       RouletteView(sectionTitles: $sectionTitles, isSpinning: $isSpinning, rotation: $rotation, animationDuration: $animationDuration) // 変更
       SettingsView(sectionTitles: $sectionTitles, rotation: $rotation, isSpinning: $isSpinning, animationDuration: $animationDuration) // 変更
   }
   
    func safeTitle(for index: Int) -> String {
        if sectionTitles.indices.contains(index) {
            return sectionTitles[index] //safeTitle(for: index)
        } else {
            return ""
        }
    }
   private func removeTitle(at offsets: IndexSet) {
       sectionTitles.remove(atOffsets: offsets)
   }
}

struct RouletteView: View {
//   let sectionTitles: [String]
   @Binding var sectionTitles: [String]
   @State var sectionColors: [Color] = []
   @Binding var isSpinning: Bool
   @Binding var rotation: Double
   @Binding var animationDuration: Double

    var body: some View {
           GeometryReader { geometry in
               ZStack {
                   ForEach(0..<self.sectionTitles.count) { i in
                       self.sectionPath(i, geometry: geometry)
                           .fill(self.colorForSection(i))
                   }
                   ForEach(0..<self.sectionTitles.count) { i in
                       self.positionedTextForSection(i, geometry: geometry)
                   }
               }
               .spinning($isSpinning, totalRotation: $rotation, animationDuration: $animationDuration)
           }
        
       }


   func positionedTextForSection(_ index: Int, geometry: GeometryProxy) -> some View {
       Text(self.safeTitle(for: index))
           .font(.system(size: geometry.size.width / 20))
           .rotationEffect(.degrees(Double(index) * (360.0 / Double(self.sectionTitles.count))), anchor: .center)
           .position(x: geometry.size.width / 2, y: geometry.size.height / 4)
           .rotationEffect(.degrees(-Double(index) * (360.0 / Double(self.sectionTitles.count))), anchor: .center)
   }
    
   func sectionPath(_ index: Int, geometry: GeometryProxy) -> Path {
       Path { path in
           let width = geometry.size.width
           let height = geometry.size.height
           let segment = Angle(degrees: 360 / Double(self.sectionTitles.count))
           let start = Angle(degrees: segment.degrees * Double(index))
           path.move(to: .init(x: width / 2, y: height / 2))
           path.addArc(center: .init(x: width / 2, y: height / 2), radius: width / 2, startAngle: start, endAngle: start + segment, clockwise: false)
           path.closeSubpath()
       }
   }
    
   func colorForSection(_ index: Int) -> Color {
       switch index % 4 {
       case 0: return Color(red: 255/255, green: 105/255, blue: 180/255) // HotPink
       case 1: return Color(red: 152/255, green: 251/255, blue: 152/255) // PaleGreen
       case 2: return Color(red: 240/255, green: 230/255, blue: 140/255) // Khaki
       case 3: return Color(red: 135/255, green: 206/255, blue: 235/255) // SkyBlue
       default: return Color.blue // fallback color
       }
   }
    
    func safeTitle(for index: Int) -> String {
            if sectionTitles.indices.contains(index) {
                return sectionTitles[index]
            } else {
                return ""
            }
        }
}

struct SpinningAnimation: AnimatableModifier {
   @Binding var isSpinning: Bool
   var rotation: Double
   @Binding var animationDuration: Double // 追加
   var animatableData: Double {
       get { return rotation }
       set { rotation = newValue }
   }

    func body(content: Content) -> some View {
       return content
           .rotationEffect(Angle(degrees: rotation))
           .animation(isSpinning ? Animation.linear(duration: animationDuration) : .default)
   }
}

extension View {
    func spinning(_ isSpinning: Binding<Bool>, totalRotation: Binding<Double>, animationDuration: Binding<Double>) -> some View {
        self.modifier(SpinningAnimation(isSpinning: isSpinning, rotation: totalRotation.wrappedValue, animationDuration: animationDuration))
    }
}
