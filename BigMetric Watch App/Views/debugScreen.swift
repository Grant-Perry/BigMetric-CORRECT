//
//  debugScreen.swift
//  howFar
//
//  Created by Grant Perry on 1/28/23.
//

import SwiftUI
import Foundation
import Combine

struct debugScreen: View {

   @EnvironmentObject var distanceTracker: DistanceTracker
   @EnvironmentObject var workoutManager:WorkoutManager
   @EnvironmentObject var weatherKitManager: WeatherKitManager
   @EnvironmentObject var geoCodeHelper: GeoCodeHelper
   @State var finalSteps: Int = 0
   @State private var showWeatherStatsView = false


   var body: some View {
#if os(watchOS)
      VStack {
         HStack {
            HStack {
               ScrollView {
                  Spacer()
                  
                  toggleBeep()

                  Button(action: {
                     weatherKitManager.getWeather(for: distanceTracker.currentCoords)
                     showWeatherStatsView = true
                  }) {
                     showAllWeather()
//                     ShowWeather()
                  }
                  .leftJustify()
                  Divider()

                     .sheet(isPresented: $showWeatherStatsView) {
                        WeatherStatsView(weatherKitManager: weatherKitManager, showWeatherStatsView: $showWeatherStatsView)
                     }

                  DebugSummary(
                     icon: "gauge.high",
                     title: "Speed:",
                     val: gpNumFormat.formatNumber(distanceTracker.distance! / distanceTracker.elapsedTime * 3600, 2))
                  .accentColor(.gpGreen)

                  DebugSummary(
                     icon: "timer",
                     title: "Time:",
                     val: distanceTracker.formattedTimeString)
                  .accentColor(.gpYellow)

                  DebugSummary(
                     icon: "shoeprints.fill",
                     title: "Steps:",
                     val: gpNumFormat.formatNumber(Double(finalSteps), 0))
                  .accentColor(.gpPurple)

                  DebugSummary(
                     icon: "mountain.2",
                     title: "Altitude:",
                     val: gpNumFormat.formatNumber(distanceTracker.altitude, 0))
                  .accentColor(.gpPink)

                  DebugSummary(
                     icon: "heart.fill",
                     title: "Heart Rate:",
                     val: gpNumFormat.formatNumber(distanceTracker.heartRate, 0))
                  .accentColor(.gpBlue)
               }
               .edgesIgnoringSafeArea(.bottom)

               .alert(isPresented: $weatherKitManager.isErrorAlert) {
                  Alert(
                     title: Text("No Internet"),
                     message: Text("Please check your Internet connection and try again."),
                     dismissButton: .default(Text("OK"))
                  )
               }
            }
            .environmentObject(distanceTracker)
            .environmentObject(workoutManager)
            .environmentObject(weatherKitManager)
            .environmentObject(geoCodeHelper)
            .overlay(
               GeometryReader { geometry in
                  VStack {
                     HStack {
                        Spacer()
                        smallDistanceView()
                           .environmentObject(distanceTracker)
                           .environmentObject(workoutManager)
                           .scaleEffect(0.6)
                     }
                     Spacer()
                  }
                  .frame(width: geometry.size.width, height: geometry.size.height)
               }
                  .padding(.top, -66)
                  .padding(.leading, 95)
            )
         }
      }
      /*
       the .onAppear updates the steps counter for this view because it's an async func call. There's a
       completion handler in queryStepCount so it has to finish updating before self.finalSteps is updated.
       */
      .onAppear {
         weatherKitManager.getWeather(for: distanceTracker.currentCoords)
         distanceTracker.queryStepCount { steps in
            if let steps = steps {
               finalSteps = steps - distanceTracker.startStepCnt
            } else {
               print("Error retrieving step count for debugScreen view.")
            }
         }
      }
      //      .id(UUID()) // force refresh
      .padding()
#endif
   }
}

struct DebugSummary: View {

   var icon: String
   var title: String
   var val: String
   var body: some View {
      HStack {
         VStack {
            HStack {
               HStack {
                  Image(systemName: icon)
               }
               .rightJustify()

               HStack(spacing: 4) {
                  Text(title)
                     .font(
                        .system(.footnote, design: .rounded))
                     .multilineTextAlignment(.trailing)
                     .frame(width: 80, alignment: .trailing)
                     .foregroundColor(.accentColor)
                     .padding(.trailing)
               }
            }
            .leftJustify()
         }
         VStack {
            Text(val)
               .font(
                  .system(.title3, design: .rounded))
               .frame(alignment: .leading)
               .foregroundColor(.accentColor)
               .padding(.bottom, 2)
         }
         .leftJustify()
      }
      
      Divider()
   }
}

struct toggleBeep: View {
   @EnvironmentObject var distanceTracker: DistanceTracker
   @EnvironmentObject var workoutManager: WorkoutManager
   var body: some View {
      VStack {
         HStack {
//            Image(systemName: "info.circle")
//               .font(.title2)
//               .foregroundColor(.white)


            Text("Summary:")
               .frame(height: 30, alignment: .leading)
               .font(.headline)
               .foregroundColor(.gpPink)
               .alignmentGuide(.top) { $0[.bottom] }
               .baselineOffset(10)
               .leftJustify()
               .padding(.top, -20)
            Spacer()
            Divider()
         }
         .frame(height: 55)
         HStack {
            Image(systemName: "bell.fill")
            Toggle(isOn: $distanceTracker.isBeep) {
               HStack {
                  Text("Haptic:")
                     .rightJustify()
                     .font(.footnote)
                     .foregroundColor(.gpGreen)
                  Text(distanceTracker.isBeep ? "ON: " : "OFF:")
                     .foregroundColor(distanceTracker.isBeep ? .gpGreen : .gpRed)
               }
               .font(.footnote)

            }
            .font(.footnote)
            .padding(.trailing) // Add a trailing padding to the toggle button
            Spacer() // Add a spacer to push the text to the right
         }
         HStack {
            Spacer() // Add a spacer to push the text to the right
         }
      }
      .environmentObject(distanceTracker)
      .environmentObject(workoutManager)
      Divider()
   }
}

extension debugScreen {
   func getSpeed() -> Double {
      let timeComponents = distanceTracker.formattedTimeString.components(separatedBy: ":")
      let hoursIndex = timeComponents.count > 2 ? 0 : -1
      let minutesIndex = hoursIndex + 1
      let secondsIndex = hoursIndex + 2
      let decimalHours = Double(hoursIndex) + Double(minutesIndex)/60.0 + Double(secondsIndex)/3600.0
      let speed = distanceTracker.speedDist / decimalHours
      return speed
   }
}

//struct debugScreen_Previews: PreviewProvider {
//   static var previews: some View {
//      debugScreen()
//         .setupEnvironmentObjects(
//            distanceTracker: DistanceTracker(),
//            workoutManager: WorkoutManager(),
//            weatherKitManager: WeatherKitManager(),
//            geoCodeHelper: GeoCodeHelper()
//         )
//         .previewDisplayName("Debug Screen Preview")
//   }
//}

