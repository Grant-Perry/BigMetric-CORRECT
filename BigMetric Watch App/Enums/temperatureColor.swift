//
//  TemperatureColor.swift
//  howFar Watch App
//
//  Created by Grant Perry on 4/24/23.
//

import Foundation
import SwiftUI

enum TemperatureColor {
case superCold          // for temperature < -4°F
   case veryCold        // for temperature < 14°F
   case cold            // for temperature < 32°F
   case cool            // for temperature < 50°F
   case moderateCool   // for temperature < 68°F
   case moderateWarm   // for temperature < 86°F
   case warm           // for temperature < 104°F
   case hot            // for temperature < 122°F
   case superHot       // for temperature >= 122°F

   static func from(temperature: Double) -> Color {
      let colors: [(Range<Double>, Color)] = [
         (-(.infinity)..<Double(-4), Color(red: 0.6, green: 0.0, blue: 0.6)),    // purple
         (Double(-4)..<Double(14), Color(red: 0.25, green: 0.25, blue: 0.6)),    // royal blue
         (Double(14)..<Double(32), Color(red: 0.25, green: 0.6, blue: 0.8)),     // light blue
         (Double(32)..<Double(45), Color(red: 0.6, green: 0.8, blue: 0.95)),     // baby blue
         (Double(45)..<Double(68), Color(red: 0.8, green: 0.95, blue: 0.8)),     // light green
         (Double(68)..<Double(74), Color(red: 0.0, green: 1.0, blue: 0.0)),     //  green
         (Double(74)..<Double(85), Color(red: 1.0, green: 0.7, blue: 0.4)),      // warm red to orange
         (Double(85)..<Double(95), Color(red: 1.0, green: 0.2, blue: 0.2)),      // tomato red
         (Double(95)..<Double(101), Color(red: 1.0, green: 0.41, blue: 0.71)),   // hot pink
         (Double(101)..<Double.infinity, Color(red: 0.6, green: 0.0, blue: 0.6)) // purple
      ] 

      for (range, color) in colors {
         if range.contains(temperature) {
            return color
         }
      }
      return Color(red: 0.8, green: 0.0, blue: 0.0) // dark red
   }
}




