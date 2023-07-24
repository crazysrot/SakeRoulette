//
//  ContentView.swift
//  SakeRoulette
//
//  Created by crazysrot on 2023/07/23.
//

import SwiftUI

struct RouletteSection: Shape {
   let startAngle: Angle
   let endAngle: Angle

   func path(in rect: CGRect) -> Path {
       var path = Path()
       let center = CGPoint(x: rect.midX, y: rect.midY)
       path.move(to: center)
       path.addArc(center: center,
                   radius: rect.width / 2,
                   startAngle: startAngle,
                   endAngle: endAngle,
                   clockwise: false)
       path.addLine(to: center)
       return path
   }
}

struct ContentView: View {
   @State private var sectionTitles = ["Sake1", "Sake2", "Sake3", "Sake4", "Sake5", "Sake6", "Sake7", "Sake8", "Sake9", "Sake10"]
   @State private var newTitle = ""
   @State private var isSpinning: Bool = false
   @State private var rotation: Double = 0

   var body: some View {
       VStack {
           HStack {
               TextField("Add new sake title", text: $newTitle)
                   .textFieldStyle(RoundedBorderTextFieldStyle())
               Button("Add") {
                   if !newTitle.isEmpty {
                       sectionTitles.append(newTitle)
                       newTitle = ""
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
           
           RouletteView(sectionTitles: $sectionTitles, isSpinning: $isSpinning, rotation: $rotation, animationDuration: 10.0)
           Button("Start") {
               withAnimation {
                   self.isSpinning = true
               }
               DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                   withAnimation {
                       self.isSpinning = false
                       self.rotation += 3600 + Double(arc4random_uniform(360))
                   }
               }
           }
           .padding()
       }
   }
   
    func safeTitle(for index: Int) -> String {
        if sectionTitles.indices.contains(index) {
            return safeTitle(for: index)
        } else {
            return ""
        }
    }
   private func removeTitle(at offsets: IndexSet) {
       sectionTitles.remove(atOffsets: offsets)
   }
}

struct RouletteView: View {
   @Binding var sectionTitles: [String]
   @Binding var isSpinning: Bool
   @Binding var rotation: Double
   var animationDuration: Double

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
               .spinning($isSpinning, duration: animationDuration, totalRotation: $rotation)
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
   var animatableData: CGFloat {
       get { return CGFloat(self.isSpinning ? 1 : 0) }
       set { self.isSpinning = newValue > 0.5 }
   }
   var animationDuration: Double
    @Binding var totalRotation: Double  // Add this

   func body(content: Content) -> some View {
       return content
           .rotationEffect(Angle(degrees: totalRotation + Double(self.animatableData)))
           .animation(self.isSpinning ? Animation.linear(duration: self.animationDuration) : .default)
   }
}

extension View {
    func spinning(_ isSpinning: Binding<Bool>, duration: Double, totalRotation: Binding<Double>) -> some View {
        self.modifier(SpinningAnimation(isSpinning: isSpinning, animationDuration: duration, totalRotation: totalRotation))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
