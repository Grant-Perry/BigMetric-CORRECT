//  howFarGPS.swift
//  howFar Watch App
//
//  Created by Grant Perry on 1/21/23.
//

import SwiftUI
import CoreMotion
import CoreLocation
import HealthKit
import Combine
import Foundation
import WatchConnectivity

struct howFarGPS: View {
#if os(watchOS)
   @State var screenBounds = WKInterfaceDevice.current().screenBounds
#else
   @State var screenBounds = UIScreen.main.bounds
#endif
   @EnvironmentObject var distanceTracker: DistanceTracker
   @EnvironmentObject  var workoutManager: WorkoutManager
   @Environment(\.colorScheme) var colorScheme
   @State var debug = false
   @State var debugStr = ""
   @State var resetDist = false
   @State var isAuthorized = false
   @State var gpsLoc = "GPS"
   @State var gradStopColor = Color(#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1))
   //// ------------- Main Button Colors --------------------
   @State var bgYardsStopTop = Color(#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1))
   @State var bgYardsStopBottom = Color(#colorLiteral(red: 1, green: 0.1271572973, blue: 0.969772532, alpha: 1))
   @State var bgYardsStartTop = Color(#colorLiteral(red: 1, green: 0.5212053061, blue: 1, alpha: 1))
   @State var bgYardsStartBottom = Color(#colorLiteral(red: 1, green: 0.1271572973, blue: 0.969772532, alpha: 1))
   @State var bgMilesStopTop = Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1))
   @State var bgMilesStopBottom = Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
   @State var bgMilesStartTop = Color(#colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1))
   @State var bgMilesStartBottom = Color(#colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1))
   //// -------------- End Button Colors  --------------------
   @State var timeOut = Color(#colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1))
   @State var backColor = Color(#colorLiteral(red: 0.8699219823, green: 0.9528884292, blue: 0.8191569448, alpha: 1))
   @State var isHealthUpdateOn = Color(#colorLiteral(red: 0.2760013003, green: 0.4030833564, blue: 0.8549019694, alpha: 1))
   @State var isUpdatingOn = Color(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1))
   @State var isUpdatingOnStop = Color(#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1))
   @State var isUpdatingOff = Color(#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1))
   @State var isUpdatingOffStop = Color(#colorLiteral(red: 0.9260191787, green: 0.1247814497, blue: 0.4070666561, alpha: 1))
   @State var isRecordingColor = Color(#colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1))
   @State var isHealthUpdate = false
   @State var distanceHowFarGPS: Double = 0
   @State var selectedDistance = "Miles"
   //   @State var iIsUpdating = false
   var isUp: Bool {
      return distanceTracker.isUpdating
   }
   var isRecording: Bool {
      return distanceTracker.weIsRecording
   }
   var timePadding = 70.0
   var width = 65.0
   var height = 25.0
   
   var body: some View {
      VStack(alignment: .center, spacing:0) {
         
         VStack(spacing: 0) {
            VStack { // top spacer
            }
            .frame(height: 70)
            VStack(alignment: .center, spacing: 0) {
               
               ButtonView(stateBtnColor: isRecording ? (isUp ? isRecordingColor : .white) : .black,
                          startColor: !isRecording ? (distanceTracker.yardsOrMiles ? bgMilesStopTop : bgYardsStopTop) : (distanceTracker.yardsOrMiles ? bgMilesStartTop : bgYardsStartTop),
                          endColor: !isRecording ? (distanceTracker.yardsOrMiles ? bgMilesStopBottom : bgYardsStopBottom) : (distanceTracker.yardsOrMiles ? bgMilesStartBottom : bgYardsStartBottom),
                          isUp: self.isUp,
                          screenBounds: self.screenBounds)
               .overlay(
                  VStack {
                     DoubleClickButton(action: {
                        // check to be certain we have garnered an accurate initial location
                        if distanceTracker.isInitialLocationObtained {
                           if !isRecording {
                              if distanceTracker.isBeep {
                                 PlayHaptic.tap(PlayHaptic.start)
                              }
                              
                              let wmState = workoutManager.workoutSessionState
                              if wmState == .notStarted || wmState == .ended  {
                                 // start/restart the routeManger and initialize startStepCnt & lastLocation

                                 // bleach the properties
                                 workoutManager.resetWorkout()
                                 distanceTracker.cleanVars = true

                                 distanceTracker.queryStepCount { steps in
                                    if let steps = steps {
                                       distanceTracker.startStepCnt = steps
                                       print("Number of steps inside wmState: \(steps)")
                                    } else {
                                       print("Error retrieving step count.") } }
                                 distanceTracker.lastLocation = nil  // reset to be certain there is nothing cached
                                 distanceTracker.holdCLLocations = []
                                 // no builder created yet so create one
                                 workoutManager.startWorkout(workoutType: .walking) // start the HKWorkoutLive
                              } else {
                                 workoutManager.togglePause()
                              }
                              distanceTracker.toggleWeIsRecording(true)
                              distanceTracker.showStartText = false // used for the Start text on the button
                                                                    // Request the current location
                              if CLLocationManager.locationServicesEnabled() {
                                 distanceTracker.requestCurrentLocation()
                              }
                              distanceTracker.startUpdates()
                           } else {
                              if distanceTracker.isBeep {
                                 PlayHaptic.tap(PlayHaptic.stop)
                              }
                              workoutManager.togglePause()
                              distanceTracker.toggleWeIsRecording(false)
                              _ = distanceTracker.stopUpdates(false) // stop but do not refresh properties
                           }
                        }
                     })
                      {
                     // MARK: - Distance text
                     InsideButtonTextView()
                      }
                  }
                     .sheet(isPresented: Binding(get: { !distanceTracker.isInitialLocationObtained }, set: { _ in })) {
                        //                                             .sheet(isPresented: $showStartText) {
                        ZStack {
                           LocationProgressView(message: "GPS Position")
                        }
                     }
                     .tint(Color(.clear))
                     .foregroundColor(.white)
               )
               .padding(.top, -35)
               // MARK: - Time Display
               ShowTimeOrSpeed()
            }
            
            VStack {
               HStack(alignment: .center, spacing:7) {
                  // MARK: - Reset Button
                  HStack {
                     DoubleClickButton(action: {
                        distanceTracker.showStartText = true
                        _ = distanceTracker.stopUpdates(true)
                        workoutManager.resetWorkout()
                     }) {
                        Text("+/-")
                           .font(.footnote)
                           .fontWeight(.medium)
                           .foregroundColor(.white)
                           .cornerRadius(10)
                     }
                     .frame(width: 43, height: height, alignment: .center)
                     .background(LinearGradient(gradient: Gradient(colors: [.blue, gradStopColor]), startPoint: .bottomLeading, endPoint: .topLeading))
                     .cornerRadius(15)
                  }
                  HStack {
                     DoubleClickButton(action: {
                        distanceTracker.showStartText = true
                        distanceTracker.yardsOrMiles = false
                        distanceTracker.toggleYMBool(false)
                     }) {
                        Text("Yards")
                           .font(.footnote)
                           .foregroundColor(.white)
                           .cornerRadius(10)
                     }
                     .frame(width: width, height: height, alignment: .center)
                     .background(LinearGradient(gradient: Gradient(colors: [bgYardsStopTop, bgYardsStopBottom]), startPoint: .bottomLeading, endPoint: .topLeading))
                     .cornerRadius(15)
                     .overlay(
                        RoundedRectangle(cornerRadius: 15)
                           .stroke(distanceTracker.yardsOrMiles ? .black : .white, lineWidth: 3)
                     )
                  }
                  
                  HStack {
                     DoubleClickButton(action: {
                        distanceTracker.yardsOrMiles = true
                        distanceTracker.showStartText = true
                        //              self.isRecording = false
                        distanceTracker.toggleYMBool(true)
                     }) {
                        
                        Text("Miles")
                           .font(.footnote)
                           .foregroundColor(.white)
                           .cornerRadius(10)
                     }
                     .frame(width: width, height: height, alignment: .center)
                     .background(LinearGradient(gradient: Gradient(colors: [
                        distanceTracker.yardsOrMiles ? (!isRecording ? bgMilesStopTop : bgMilesStartTop) : bgMilesStopTop,
                        distanceTracker.yardsOrMiles ? (!isRecording ? bgMilesStopBottom : bgMilesStartBottom) : bgMilesStopBottom
                     ]), startPoint: .bottomLeading, endPoint: .topLeading))
                     .cornerRadius(15)
                     .overlay(
                        RoundedRectangle(cornerRadius: 15)
                           .stroke(!distanceTracker.yardsOrMiles ? .black : .white, lineWidth: 3)
                     )
                  }
               }
               .frame(width: (screenBounds.width / 0.5), height: 100)
            }
            .padding(.top, -30)
         }
         //         .environmentObject(distanceTracker)
         //         .environmentObject(workoutManager)
         
         // MARK: - isUpdating beacon
         ZStack {
            Circle()
               .fill(LinearGradient(gradient: Gradient(colors: [isUp ? isUpdatingOn :
                                                                  (isHealthUpdate ? isHealthUpdateOn :
                                                                     isUpdatingOff), isUp ? isUpdatingOnStop :
                                                                  isUpdatingOffStop]), startPoint: .topLeading, endPoint: .bottomTrailing))
               .frame(width: 10, height: 10)
               .offset(x: 90, y: (-screenBounds.height / 2))
         }
         .frame(height:15.0)
         .background(.black)
      }
      .environmentObject(distanceTracker)
      .environmentObject(workoutManager)
      .preferredColorScheme(.dark)
   }

   
   func updateDebugStr(_ var1: Bool, _ var2: Bool) {
      debugStr = "YM: \(String(var1)) - isRec: \(String(var2))"
   }
   
}

struct ShowTimeOrSpeed: View {
   @EnvironmentObject var distanceTracker: DistanceTracker
   @EnvironmentObject var workoutManager: WorkoutManager
   @State var isSpeed:Bool = true // MPH-BPM state
   var body: some View {
      VStack {
         HStack {
            Text(!isSpeed ? "" : workoutManager.heading)
               .font(.callout)
               .fontWeight(.bold)
               .foregroundColor(.white)

            Button(action: {
               self.isSpeed.toggle()
            }) {
               Text(isSpeed ?
                    (distanceTracker.distance! / distanceTracker.elapsedTime * 3600).isNaN ||
                    (distanceTracker.distance! / distanceTracker.elapsedTime * 3600).isInfinite ?
                    "0" : "\(gpNumFormat.formatNumber(distanceTracker.distance! / distanceTracker.elapsedTime * 3600, 1))" :
                     distanceTracker.formattedTimeString)
               .foregroundColor(isSpeed ? .white : .gpYellow)
               .font(isSpeed ? .title2 : (distanceTracker.numTimerHours() > 0 ? .title3 : .title2))
            }
            // remove the gray background from the button
            .buttonStyle(PlainButtonStyle())
            .background(Color.clear)
            .frame(width: 95, height: 45)

            Text(isSpeed ? "MPH" : "Time")
               .font(.system(size: 13))
               .padding(.top, -16)
               .padding(.leading, -10)
               .foregroundColor(.white)
               .bold()
         }
         .environmentObject(distanceTracker)
         .environmentObject(workoutManager)
         .frame(height: 45)
         .horizontallyCentered()

         Spacer()
      }
      .padding(.top, -15)
   }

}

//struct howFarGPS_Previews: PreviewProvider {
//   static var previews: some View {
//      howFarGPS()
//         .setupEnvironmentObjects(
//            distanceTracker: DistanceTracker(),
//            workoutManager: WorkoutManager(),
//            weatherKitManager: WeatherKitManager()
//         )
//         .preferredColorScheme(.dark)
//   }
//}

