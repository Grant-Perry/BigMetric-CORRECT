//
//  TimeUnit.swift
//  howFar Watch App
//
//  Created by Grant Perry on 3/31/23.
//

import SwiftUI

enum TimeUnit: String {
   case hours = "H",
        minutes = "m",
        seconds = "s"

   var timeColor: Color {
      switch self {
         case .hours:
            return .red
         case .minutes:
            return Color(red: 171/255, green: 92/255, blue: 132/255)
         case .seconds:
            return Color(red: 100/255, green: 100/255, blue: 48/255)
      }
   }
}
