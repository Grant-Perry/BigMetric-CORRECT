//
//  largeTime.swift
//  howFar Watch App
//
//  Created by Grant Perry on 3/12/23.
//

import SwiftUI

struct largeTime: View {
   @EnvironmentObject var distanceTracker: DistanceTracker
   @EnvironmentObject var workoutManager: WorkoutManager
   @State var gradStart = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
   @State var gradStop = Color(#colorLiteral(red: 0.984064281, green: 0.8393800855, blue: 0.01998443156, alpha: 1))
   @State var secColor = Color(#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1))
   @State var timeUnit: TimeUnit = .seconds
   @State var timePace = true
   @State var hasMin = 0
   @State var hours = 0
   @State var newSteps = 0.0
   @State var newDist = 0.0
   @State var formattedString: String = "00:00:00" {
      didSet {
         let components = distanceTracker.formattedTimeString.components(separatedBy: ":")
         if components.count > 2 {
            hours = Int(components[0]) ?? 0
         }
      }
   }

   var body: some View {
      VStack {
         ZStack {
            ButtonView(stateBtnColor: Color(.white),
                       startColor: gradStart,
                       endColor: gradStop,
                       isUp: workoutManager.isLocateMgr)
         }
         .overlay(
            VStack {
               if distanceTracker.formattedTimeString.components(separatedBy: ":").count > 2 {
                  VStack {
                     Text("\(String(format: "%01d", workoutManager.cutTime(.hours))) hour\((hours > 1) ? "s" : "")")
                        .modHours(.hours)
                  }
               } else {
                  Spacer(); Spacer()
               }
               HStack {
                  Spacer()
                  Text(String(format: "%02d", workoutManager.cutTime(.minutes)))
                     .modMinutes(.minutes)
                  Spacer()
                  if hasMin > 0 {
                     Text(" \(String(format: "%02d", workoutManager.cutTime(.seconds))) \(hasMin)")
                        .modMinutes(.minutes)
                  } else {
                     Text(String(format: "%02d", workoutManager.cutTime(.seconds)))
                        .modSeconds(.seconds)
                  }
                  Spacer()
               }
               Spacer()
            }
               .padding(.top, distanceTracker.formattedTimeString.components(separatedBy: ":").count > 2 ? 15 : -55)
         )

         //         .scaleEffect(0.85)
         .onReceive(distanceTracker.$formattedTimeString) { formattedString in
            let components = formattedString.components(separatedBy: ":")
            if components.count > 2 {
               hours = Int(components[0]) ?? 0
            } else {
               hours = 0
            }
         }
         VStack {
            HStack {
               HStack {
                  Text("Steps: \(Int(newSteps))")
               }
               HStack {
                  Text("Dist: \(String(format: "%.2f", newDist))")
               }
            }
         }
         .onReceive(workoutManager.$stepCounter) { newStepVal in
            newSteps = newStepVal
         }
         .onReceive(distanceTracker.$distance) { newDistVal in
            newDist = Double(newDistVal ?? 0)
         }
         .font(.footnote)
      }
      .environmentObject(distanceTracker)
      .environmentObject(workoutManager)
   }
}

extension largeTime {

}

//struct largeTime_Previews: PreviewProvider {
//   static var previews: some View {
//      largeTime()
//         .environmentObject(DistanceTracker())
//         .environmentObject(WorkoutManager())
//   }
//}





