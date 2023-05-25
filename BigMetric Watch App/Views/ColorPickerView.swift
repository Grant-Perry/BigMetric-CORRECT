//
//  ColorPickerView.swift
//  howFar Watch App
//
//  Created by Grant Perry on 5/10/23.
//

import SwiftUI

struct ColorPickerView: View {
//   @AppStorage("walkBtnColor") var walkBtnColor = Color(.white)
   @State private var colorPicked: Color = .white
   @State private var red: Double = 0.5
   @State private var green: Double = 0.5
   @State private var blue: Double = 0.5

   private var currentColor: Color {
      Color(red: red, green: green, blue: blue)
   }

   var body: some View {
      VStack {
         Text("Color Picker")
            .font(.headline)
            .padding(.bottom, 10)

         RoundedRectangle(cornerRadius: 10)
            .fill(colorPicked)
            .overlay(
               VStack {
                  Text("R: \(Int(red * 255))")
                  Text("G: \(Int(green * 255))")
                  Text("B: \(Int(blue * 255))")
               }
                  .foregroundColor(.black)
            )
            .frame(width: 80, height: 70)
            .padding(.bottom, 20)
            .shadow(color: Color(rgb:41, 42, 49), radius: 8, x: 3, y: 4)
            .horizontallyCentered()


         VStack {
            // green = 127,
            ColorSlider(value: $red, label: "R", color: .red, step: 0.06)
            ColorSlider(value: $green, label: "G", color: .green, step: 0.06)
            ColorSlider(value: $blue, label: "B", color: .blue, step: 0.06)
         }
         .font(.footnote)

         Button("Select This Color") {
            colorPicked = currentColor
         }
      }
      .scaleEffect(0.85)
      .ignoresSafeArea()
      .background(currentColor)
      .padding(.top, 30)
   }
}

struct ColorSlider: View {
   @Binding var value: Double
   let label: String
   let color: Color
   let step: Double

   var body: some View {
      HStack {
         Text(label)
         Slider(value: $value, in: 0...1, step: step)
            .accentColor(color)
            .frame( height: 23)
      }
   }
}


struct ColorPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ColorPickerView()
    }
}
