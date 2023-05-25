//
//  WorkoutListItem.swift
//  BigMetric
//
//  Created by Grant Perry on 5/31/23.
//

import Foundation
import HealthKit
import SwiftUI
import CoreLocation
import MapKit

struct WorkoutListItem: View {
   let workout: HKWorkout
   let mapView: MKMapView = MKMapView()
   @State var healthStore = HKHealthStore()
   @State var locations: [CLLocation]? = nil
   @State private var numRouteCoords: Int = 0
   @State var regionLatLongHeight:CLLocationDistance = 3000 // feet

   // this is the map view displayed when user selects a workout from the List
   func focusLocations() {
      guard let locations = self.locations?.filter({ $0.coordinate.latitude != 0 || $0.coordinate.longitude != 0 }) else { return }
      guard locations.count > 0 else { return }
      let coordinates = locations.map({ (location: CLLocation) in
         return location.coordinate
      })

      let delegate = MapViewDelegate()
      mapView.delegate = delegate
      let polyLine = MKPolyline(coordinates: coordinates, count: coordinates.count)
      let region = MKCoordinateRegion(center: coordinates[0],
                                      latitudinalMeters: regionLatLongHeight,
                                      longitudinalMeters: regionLatLongHeight)

      mapView.addOverlay(polyLine)
      mapView.setCenter(coordinates[0], animated: true)
      mapView.setRegion(region, animated: true)
   }

   var body: some View {
      NavigationLink {
         VStack {
            // on initial load, locations = nil so this part of the block does not run
            if let locations = self.locations {
               VStack {
                  Text("\(self.formatDateName())")
                     .theHead()
               }
               VStack {
                  Text("Distance: \(String(format: "%.2f", locations.distance))") +
                  Text(" | Duration: \(formatDuration(duration: workout.duration))") +
                  Text(" | Calories: \(Int(workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0))")
               }
               .headSmall()
               Text("Found \(locations.count) waypoints")
                  .font(.caption)
               MapView(mapView:mapView)
                  .ignoresSafeArea()
            }
         }
         Spacer()
         // Initial: go get the workout routes

            .task {
               guard let routes = await getWorkoutRoute(workout: workout) else {
                  return
               }
               guard routes.count > 0 else {
                  // clear locations from last query and get it ready for next
                  self.locations = []
                  return
               }

               if routes.count > 1 {
                  print("found \(routes.count) route samples for workout")
               }
               self.locations = await getLocationDataForRoute(givenRoute: routes[0])
               DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                  self.focusLocations()
               }
            }
      }
   label: {
      HStack(spacing: 10) {
         let workoutActivityType = workout.workoutActivityType
         let workoutIconEnum = WorkoutIcon(hkType: workoutActivityType)
         Image(systemName: workoutIconEnum.icon).foregroundColor(workoutIconEnum.colors)
         Text("\(self.formatDate())")
            .theRows()
         Text("\(formatDuration(duration: workout.duration))")
            .theRows()
         Text("\(numRouteCoords)")
            .theRows()
      }
      .font(.caption)
      .onAppear {
         // Move the data fetching logic here, so it's triggered when the row appears
         Task {
            let hasCoords = await calcNumCoords(workout)
            self.numRouteCoords = hasCoords
         }
      }
   }
   }
}

extension WorkoutListItem {

   func formatDate() -> String {
      let dateToStringFormatter = DateFormatter()
      dateToStringFormatter.timeStyle = .short
      dateToStringFormatter.dateStyle = .short

      return dateToStringFormatter.string(from: workout.startDate)
   }

   func formatDateName() -> String {
      let dateToStringFormatter = DateFormatter()
      dateToStringFormatter.dateFormat = "MMMM d, yyyy"

      return dateToStringFormatter.string(from: workout.startDate)
   }
}



