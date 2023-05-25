//
//  howFarApp.swift
//  howFar Watch App
//
//  Created by Grant Perry on 1/17/23.     --- Watch
//

import SwiftUI

@main
struct howFar_Watch_AppApp: App {
  @Environment(\.scenePhase) var scenePhase
   @StateObject var distanceTracker = DistanceTracker()
   @StateObject var workoutManager = WorkoutManager()
   @StateObject var weatherKitManager = WeatherKitManager()
   @StateObject var geoCodeHelper = GeoCodeHelper()

   @State private var distanceTrackerInitialized = false
   
  /*  This is the root - @MiN view so @StateObject is the parent - all other views needing access to the ParentObject
      need to use @ObservedObject or @EnvironmentObject

      @StateObject is the parent initializer for the object to be utilized in all child views. In order to be part of the "family", any child view requiring access to any of the components in the parent's need to use an ObservedObject or EnvirontmentObject to "attach" to the parent's (and subsequent child) view components.

      The parent view initializes the child view with a modifier .environmentObject(observed-object-name) to share    */
   
   @State private var selectedTab = 2

   var body: some Scene {
      WindowGroup {
         TabView(selection: $selectedTab) {
            
            AltitudeView()
               .tabItem { Image(systemName: "circle.fill") }
               .tag(0)

            endWorkout(selectedTab: $selectedTab) // when end workout is finished
               .tabItem { Image(systemName: "circle.fill") }
               .tag(1)

            howFarGPS()
               .tabItem { Image(systemName: "circle.fill") }
               .tag(2)

            debugScreen()
               .tabItem { Image(systemName: "circle.fill") }
               .tag(3)

            CompassView(heading: .constant(0), routeHeading: .constant(0))
               .tabItem { Image(systemName: "circle.fill") }
               .tag(4)

            showHeartBeat()
               .tabItem { Image(systemName: "circle.fill") }
               .tag(5)

            summary(selectedTab: $selectedTab)
               .tag(6)
         }
         .environmentObject(distanceTracker)
         .environmentObject(workoutManager)
         .environmentObject(weatherKitManager)
         .environmentObject(geoCodeHelper)
         .onAppear {
            self.selectedTab = 2
            workoutManager.requestHKAuth()
         }
         .environmentObject(distanceTracker)
         .environmentObject(workoutManager)
         .tabViewStyle(PageTabViewStyle())
      }
   }
}

//struct howFarApp_Previews: PreviewProvider {
//   static var previews: some View {
//      howFar_Watch_AppApp()
//         .environmentObject(DistanceTracker())
//         .environmentObject(WorkoutManager())
//         .environmentObject(WeatherKitManager())
//         .environmentObject(GeoCodeHelper())
//         .previewDisplayName("Debug Screen Preview")
//   }
//}

