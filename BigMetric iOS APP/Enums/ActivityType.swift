//
//  ActivityType.swift
//  polyMap
//
//  Created by Grant Perry on 3/9/23.
//

import HealthKit
import SwiftUI

enum WorkoutIcon: String, CaseIterable {
   case walk = "Walk",
        run = "Run",
        cycle = "Bike",
        other = "Other"

   var icon: String {
      switch self {
         case .walk:
            return "figure.walk.circle.fill"
         case .run:
            return "figure.run.circle.fill"
         case .cycle:
            return "bicycle.circle.fill"
         case .other:
            return "exclamationmark.octagon.fill"
      }
   }

   var colors: Color {
      switch self {
         case .walk:
            return .green
         case .run:
            return .yellow
         case .cycle:
            return .blue
         case .other:
            return .red
      }
   }

   var name: String {
      return self.rawValue
   }

   init(hkType: HKWorkoutActivityType) {
      switch hkType {
         case .walking:
            self = .walk
         case .running:
            self = .run
         case .cycling:
            self = .cycle
         case .other:
            self = .other
         default:
            fatalError("Unsupported workout activity type")
      }
   }
}
