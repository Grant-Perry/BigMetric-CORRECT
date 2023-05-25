//
//  PrecipChanceColor.swift
//  howFar Watch App
//
//  Created by Grant Perry on 5/3/23.
//

import Foundation
import SwiftUI

enum PrecipChanceColor {
   case veryLow // for chance < 20%
   case low // for chance < 40%
   case moderate // for chance < 60%
   case high // for chance < 80%
   case veryHigh // for chance >= 80%

   static func from(chance: Int) -> Color {
      let colors: [(Range<Int>, Color)] = [
         (0..<15, Color(red: 1.0, green: 1.0, blue: 1.0)),     // white
         (15..<25, Color(red: 0.6, green: 0.8, blue: 0.95)),   // baby blue
         (25..<35, Color(red: 0.25, green: 0.6, blue: 0.8)),   // light blue
         (35..<45, Color(red: 0.8, green: 0.95, blue: 0.8)),   // light green
         (45..<80, Color(red: 1.0, green: 0.7, blue: 0.4)),    // warm red to orange
         (80..<151, Color(red: 01.0, green: 0.2, blue: 0.2))   // tomato red
      ]

      for (range, color) in colors {
         if range.contains(chance) {
            return color
         }
      }
      return Color.clear
   }
}
