//
//  gpStuff.swift
//  howFar Watch App
//
//  Created by Grant Perry on 4/13/23.
//

import Foundation
import UIKit
import SwiftUI

struct gpNumFormat {

   static func formatNumber<numToFix: BinaryFloatingPoint>(_ number: numToFix, _ decimalPlaces: Int) -> String {
      // utilize: let newFormatNum = gpNumFormat.formatNumber(1234.5678, 1) returns: 1234.5

      if decimalPlaces == 0 {
         return String(format: "%.0f", Double(number))
      } else {
         let formatString = "%.\(decimalPlaces)f"
         return String(format: formatString, Double(number))
      }
   }
}

struct gpDateStuff {

   static func  getDayName(daysFromToday numDaysFromToday: Int) -> String {

      //      var numDaysFromToday = 0
      
      let tomorrow = Calendar.current.date(byAdding: .day, value: numDaysFromToday, to: Date())!
      let dayOfWeek = DateFormatter().shortWeekdaySymbols[Calendar.current.component(.weekday, from: tomorrow) - 1]
      //      dayOfWeek.dateFormat = "EEE"
      return dayOfWeek
   }
}


/// Make a button a double-click button
/// USAGE:
/// DoubleClickButton(Action: { }
struct DoubleClickButton<Content: View>: View {
   @State var selectedTab = 2
   let action: () -> Void
   let content: Content

   init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
      self.action = action
      self.content = content()
   }

   var body: some View {
      content

         .onTapGesture(count: 2, perform: action)

         
   }
}
