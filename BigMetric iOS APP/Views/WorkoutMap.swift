//
//  WorkoutMap.swift
//  Workouts
//
//  Created by Grant Perry

import Foundation
import SwiftUI
import MapKit
import CoreLocation
import HealthKit

struct WorkoutMap: View {
   @State var workouts: [HKWorkout] = []
   @State var loadingProgress: Double = 1
   @State var map = MKMapViewWithRenderers()
   @State var cursor = 0
   @State var routes: [[CLLocation]] = []
   @State var hasMore = false
   @State var regionLatLongHeight:CLLocationDistance = 12000 // feet

   func drawRoute(_ route: [CLLocation]) {
      let coordinates = route.map({ (location: CLLocation) in
         return location.coordinate
      })

      let line = MKPolyline(coordinates: coordinates, count: coordinates.count)
      map.mapView.addOverlay(line, level: .aboveRoads)
   }

   func focusLocations() {
      guard routes.count > 0 else {
         return
      }

      let region = MKCoordinateRegion(center: routes[0][0].coordinate,
                                      latitudinalMeters: regionLatLongHeight,
                                      longitudinalMeters: regionLatLongHeight)

      map.mapView.setCenter(routes[0][0].coordinate, animated: true)
      map.mapView.setRegion(region, animated: true)
   }

   func loadBatch(_ workouts: [HKWorkout]) async {
      guard workouts.count > 0 else {
         return
      }
      let nextCursor = min(cursor + 20, workouts.count)
      for i in cursor..<nextCursor {
         self.loadingProgress = Double(i) / Double(nextCursor - 1)
         let workout = workouts[i]
         guard let routesForWorkout = await getWorkoutRoute(workout: workout) else {
            continue
         }
         guard routesForWorkout.count > 0 else {
            continue
         }
         let locations = await getLocationDataForRoute(givenRoute: routesForWorkout[0])
         self.routes.append(locations)
         self.drawRoute(locations)
      }

      self.cursor = nextCursor
      self.hasMore = nextCursor != workouts.count
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
         self.focusLocations()
      }
   }

   var body: some View {
      NavigationView {
         VStack {
            ZStack {
               MapView(mapView: self.map.mapView)
                  .ignoresSafeArea()

               if loadingProgress < 1 {
                  HStack {
                     Spacer()
                     VStack() {
                        Spacer()
                        Text("\(String(format: "Loading %.2f", loadingProgress * 100))%").font(.headline).fontWeight(.bold)
                        Spacer()
                     }
                     Spacer()
                  }

                  .background(.thickMaterial).opacity(0.8)
               } else {
                  if hasMore {
                     VStack {
                        Spacer()
                        HStack {
                           Spacer()
                           Button {
                              Task {
                                 await self.loadBatch(self.workouts)
                              }
                           } label: {
                              Text("Load more")
                           }.buttonStyle(.borderedProminent).padding(4)
                        }
                     }
                  }
               }
            }
         }
         .task {
            guard let workouts = await readWorkouts(100) else {
               return
            }
            self.workouts = workouts

            await self.loadBatch(workouts)
         }
      }
   }
}
