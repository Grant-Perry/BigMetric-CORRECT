//
//  WorkoutManagerExt.swift
//  howFar Watch App
//
//  Created by Grant Perry on 4/9/23.
//

import SwiftUI

extension WorkoutManager {
   
   func cutTime(_ unitOfTime: TimeUnit) -> Int {
      let timeComponents = distanceTracker.formattedTimeString.components(separatedBy: ":")
      let hoursIndex = timeComponents.count > 2 ? 0 : -1
      let minutesIndex = hoursIndex + 1
      let secondsIndex = hoursIndex + 2
//      let decimalHours = Double(hoursIndex) + Double(minutesIndex)/60.0 + Double(secondsIndex)/3600.0

      switch unitOfTime {
         case .hours:
            return Int(timeComponents[hoursIndex]) ?? 0
         case .minutes:
            return Int(timeComponents[minutesIndex]) ?? 0
         case .seconds:
            return Int(timeComponents[secondsIndex]) ?? 00
        
      }
   }
}
