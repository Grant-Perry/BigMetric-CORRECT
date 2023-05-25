//
//  displayWorkout.swift
//  howFar
//
//  Created by Grant Perry on 3/20/23.
//

import Foundation
import HealthKit
import CoreLocation

/*
 To create a [CLLocation] array of coordinates from a specific workout and display the
 distance and elevation from that workout, follow these steps:

 Retrieve the HKWorkoutRoute associated with the workout.
 Access the CLLocationCoordinate2D values from the HKWorkoutRoute data.
 Create an array of CLLocation objects from the coordinates.
 Use the distance and elevation computed properties from your Array extension to calculate
 and display the distance and elevation.

 UTILIZE:
 displayWorkoutDetails(workout: workout, healthStore: healthStore)
 */

func displayWorkoutDetails(workout: HKWorkout, healthStore: HKHealthStore) {
   var cDist:Double = 0
   var cElev:Double = 0

   // 1. Retrieve the HKWorkoutRoute associated with the workout
   let workoutRouteType = HKSeriesType.workoutRoute()
   let workoutPredicate = HKQuery.predicateForObjects(from: workout)
   let workoutRouteQuery = HKSampleQuery(sampleType: workoutRouteType,
                                         predicate: workoutPredicate,
                                         limit: 1,
                                         sortDescriptors: nil) { (query, samples, error) in
      guard let workoutRoute = samples?.first as? HKWorkoutRoute else {
         print("Error: No workout route found for the workout in displayWorkoutDetails: \(String(describing: error?.localizedDescription))")
         return
      }

      // 2. Access the CLLocationCoordinate2D values from the HKWorkoutRoute data
      let routeDataQuery = HKWorkoutRouteQuery(route: workoutRoute) { (query, locationsOrNil, done, errorOrNil) in
         if let error = errorOrNil {
            print("Error: \(error.localizedDescription)")
            return
         }

         guard let locations = locationsOrNil else {
            print("Error: No locations found for the workout route.")
            return
         }

         if done {
            // 3. Create an array of CLLocation objects from the coordinates
            let clLocations = locations.map { location -> CLLocation in
               return CLLocation(
                  coordinate: location.coordinate,
                  altitude: location.altitude,
                  horizontalAccuracy: location.horizontalAccuracy,
                  verticalAccuracy: location.verticalAccuracy,
                  timestamp: location.timestamp
               )
            }

            // 4. Use the distance and elevation computed properties to calculate and display the distance and elevation
            cDist = clLocations.distance
            cElev = clLocations.elevation

            print("Total Distance: \(cDist) meters")
            print("Total Elevation: \(cElev) meters")
         }
      }
      healthStore.execute(routeDataQuery)
   }
   healthStore.execute(workoutRouteQuery)

}

