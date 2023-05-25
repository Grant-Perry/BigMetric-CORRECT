
//  WorkoutType.swift
//  howFar
//
//  Created by Grant Perry on 2/25/23.
//

import HealthKit
import SwiftUI

enum WorkoutType: String, CaseIterable {
   case walk = "Walk"
   case run = "Run"
   case cycle = "Cycle"
   case other = "Other"

   var colour: Color {
      switch self {
         case .walk:
            return .purple
         case .run:
            return .red
         case .cycle:
            return .blue
         case .other:
            return .yellow
      }
   }

   var hkType: HKWorkoutActivityType {
      switch self {
         case .walk:
            return .walking
         case .run:
            return .running
         case .cycle:
            return .cycling
         case .other:
            return .other
      }
   }

   init(hkType: HKWorkoutActivityType) {
      switch hkType {
         case .walking:
            self = .walk
         case .running:
            self = .run
         case .cycling:
            self = .cycle
         default:
            self = .other
      }
   }
}
