//
//  endWorkout.swift
//  howFar Watch App
//
//  Created by Grant Perry on 2/9/23.
//

import SwiftUI
import CoreMotion
import CoreLocation
import HealthKit
import Combine
import UIKit

struct endWorkout: View {
   @Environment(\.colorScheme) var colorScheme
   @EnvironmentObject var distanceTracker: DistanceTracker
   @EnvironmentObject var workoutManager: WorkoutManager
   @Binding var selectedTab: Int
//   @State var mySelectedTab = 6

   var screenBounds = WKInterfaceDevice.current().screenBounds
   @State var yardsOrMiles = false
   @State private var isRecording = true
   @State var timeOut = Color(#colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1))
   @State var paceColor = Color(#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1))
   @State var headerBGColor = Color(#colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1))
   @State var isRecordingColor = Color(#colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1))
   @State var isStoppingColor = Color(#colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1))
   @State var yardsBGStartColor = Color(#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1))
   @State var yardsBGEndColor = Color(#colorLiteral(red: 1, green: 0.1271572973, blue: 0.969772532, alpha: 1))
   @State var yardsBGColor = Color(#colorLiteral(red: 0.6330649164, green: 0.5231830424, blue: 1, alpha: 1))
   @State var gradStopColor = Color(#colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1))
   @State var isStopping = true // state of running / ending workout

   var body: some View {
      VStack {
         ButtonView(stateBtnColor: Color(.white),
                    startColor: headerBGColor,
                    endColor: isStoppingColor,
                    isUp: !self.isStopping)
            .overlay(
               VStack {
                  Button(action: {
                     isStopping = false
                     PlayHaptic.tap(PlayHaptic.start)
                     workoutManager.endWorkoutbuilder() // stop the HKWorkoutBuilder
                     _ = distanceTracker.stopUpdates(false)  // stop the locationManager updates
                     distanceTracker.cleanVars = true // didSet will handle reset
                     isStopping = true
                     PlayHaptic.tap(PlayHaptic.stop)
                     self.selectedTab = 6 //  show summary
                  }) {
                     Text(isStopping ? "End Workout" : "Writing Workout")
                        .padding(.top, -20)
                  }
               }
            )
         TimeView()
            .environmentObject(distanceTracker)
            .environmentObject(workoutManager)
      }
      .environmentObject(distanceTracker)
      .environmentObject(workoutManager)
   }
}

extension View {
   func modTimeHead(_ timeOut: Color) -> some View {
      self
         .frame(maxWidth: .infinity, alignment: .center)
         .padding(.top, 8)
         .font(.caption2)
         .foregroundColor(timeOut)
         .background(Color.white.opacity(0.15))
         .cornerRadius(10)
   }

   func modTimeVal(_ headText: Color) -> some View {
      self
         .frame(maxWidth: .infinity, alignment: .center)
         .baselineOffset(16)
         .foregroundColor(headText)
         .font(.caption2)
   }
}

//struct endWorkout_Previews: PreviewProvider {
//   static var previews: some View {
//      endWorkout(selectedTab: .constant(0))
//         .environmentObject(DistanceTracker())
//         .environmentObject(WorkoutManager())
//         .preferredColorScheme(.dark)
//   }
//
//}

