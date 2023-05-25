//
//  summary.swift
//  howFar Watch App
//
//  Created by Grant Perry on 3/21/23.
//

import SwiftUI
import Combine
import HealthKit

struct summary: View {
   @EnvironmentObject var distanceTracker: DistanceTracker
   @EnvironmentObject var workoutManager:WorkoutManager
   @Binding var selectedTab:Int
   @State private var finalSteps: Int = 0
   @State private var durationFormatter: DateComponentsFormatter = {
      let formatter = DateComponentsFormatter()
      formatter.allowedUnits = [.hour, .minute, .second]
      formatter.zeroFormattingBehavior = .pad
      return formatter
   }()

   var body: some View {
      ZStack {
         if workoutManager.workout == nil {
            VStack(spacing: 20) {
               ProgressView("Saving Workout")
                  .progressViewStyle(CircularProgressViewStyle())
               Text("")
               Text("")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundColor(.teal)
            .background(Color.black)
            .navigationBarHidden(true)

         } else {
            ScrollView(.vertical) {
               VStack(alignment: .leading) {

                  SummaryMetricView(
                     title: "Total Distance",
                     value: gpNumFormat.formatNumber(distanceTracker.lastDist, 2))
                  .accentColor(.gpYellow)

                  SummaryMetricView(
                     title: "Total Time",
                     value: distanceTracker.formattedTimeString)
                  .accentColor(.gpGreen)

                  Group {
                     SummaryMetricView(
                        title: "Total Steps",
                        value: gpNumFormat.formatNumber(Double(finalSteps), 0))
                     .accentColor(.blue)
                  }
                  .onAppear {
                     distanceTracker.queryStepCount { steps in
                        if let steps = steps {
                           self.finalSteps = steps - distanceTracker.startStepCnt
                           print("\n-------------------\nstartStepCnt: \(distanceTracker.startStepCnt) - steps: \(steps) = finalSteps: \(self.finalSteps)\n-------------------\n")
                           distanceTracker.startStepCnt = 0 // reset the starting step counter in distanceTracker
                        } else { print("Error retrieving step count for summary view") }
                     }
                  }

                  SummaryMetricView(
                     title: "Total Energy",
                     value: Measurement(
                        value: workoutManager.workout?.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0, unit: UnitEnergy.kilocalories
                     ).formatted(
                        .measurement(
                           width: .abbreviated,
                           usage: .workout,
                           numberFormatStyle:
                              FloatingPointFormatStyle
                              .number
                              .precision(.fractionLength(0))
                        )
                     )
                  )
                  .accentColor(.pink)

                  SummaryMetricView(
                     title: "Avg. Heart Rate",
                     value: gpNumFormat.formatNumber(distanceTracker.heartRate, 0)
                     +
                     " bpm"
                  )
                  .accentColor(.red)

                  Text("Activity Rings")
                  ActivityRingsView(healthStore: HKHealthStore())
                     .frame(width: 50, height: 50)

                  Button("Done") {
                     self.selectedTab = 2
                  }
               }
               .scenePadding()
            }
            .environmentObject(distanceTracker)
            .environmentObject(workoutManager)
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
         }
      }
      .environmentObject(distanceTracker)
      .environmentObject(workoutManager)
   }
   
}

struct SummaryMetricView: View {
   @EnvironmentObject var distanceTracker: DistanceTracker
   @EnvironmentObject var workoutManager:WorkoutManager

   var title: String
   var value: String

   var body: some View {
      Group {
         Text(title)
         Text(value)
            .font(
               .system(.title2, design: .rounded)
               .lowercaseSmallCaps()
            )
            .foregroundColor(.accentColor)
      }
      .environmentObject(distanceTracker)
      .environmentObject(workoutManager)
      Divider()
   }
}


//struct summary_Previews: PreviewProvider {
//   @State static var selectedTab = 0
//   static var previews: some View {
//      summary(selectedTab: $selectedTab)
//         .environmentObject(DistanceTracker())
//         .environmentObject(WorkoutManager())
//
//   }
//}
