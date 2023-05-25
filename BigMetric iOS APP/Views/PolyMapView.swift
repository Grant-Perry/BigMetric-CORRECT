//
//  ContentView.swift
//  Workouts
//
//  Created by Grant Perry 5/30/23
//

import Foundation
import SwiftUI
import HealthKit

struct PolyMapView: View {
   @State var isReady = false
   @State var currentTab = 1

   var body: some View {
      VStack {
         if isReady {
            TabView(selection: $currentTab) {
               WorkoutList().tabItem {
                  Label {
                     Text("Workouts")
                  } icon: {
                     Image(systemName: "person.fill")
                  }
               }.tag(1)

               WorkoutMap().tabItem { Label {
                  Text("Map")
               } icon: {
                  Image(systemName: "map.fill")
               }
               }.tag(2)
            }
         } else {
            Spacer()
            Text("Authorize Workouts").font(.title)
            Text("Please grant Workouts the required permissions to access workouts stored on your device.")
               .font(.subheadline).foregroundColor(.secondary)
            Spacer()
         }
      }
      .task {
         if !healthKitHasAccess() {
            return
         }
         guard await requestPermission() == true else {
            return
         }

         isReady = true
      }

   }
}
