
//
//  CLLocation.swift
//  howFar
//
//  Created by Grant Perry on 3/7/23.
//

import Foundation
import CoreLocation

////  There are 2 computed properties in this extension; distance and elevation.
///
/// To get the total distance of a [CLLocation]...
///
///     let locations: [CLLocation]
///     let distance: Double
///     let elevation: Double
///     var sumDistance = locations.distance
///     var totElevation = locations.elevation
///
/////  This is an extension on the Array type where the element type is CLLocation. It adds two computed properties distance and elevation to the Array of CLLocation.
////  The distance property calculates the total distance traveled based on the locations in the array. It first checks if the array has more than one location, and then iterates over the array       and calculates the distance between each pair of consecutive locations. It adds up all the distances and returns the total distance traveled.
////
///The elevation property calculates the total elevation gain based on the   locations in the array. It first checks if the array has more than one location, and then iterates over the array and calculates the difference in altitude between each pair of consecutive  locations. If the difference in altitude is positive, it adds it to the total elevation gain. It returns the total elevation gain.
/////

extension Array where Element == CLLocation {
   var distance: Double {
      guard count > 1 else { return 0 }
      var mapDistance = Double.zero

      for i in 0..<count-1 {
         let location = self[i]
         let nextLocation = self[i+1]
         mapDistance += nextLocation.distance(from: location)
      }
      return mapDistance / 1609.344
   }

   var elevation: Double {
      guard count > 1 else { return 0 }
      var mapElevation = Double.zero

      for i in 0..<count-1 {
         let location = self[i]
         let nextLocation = self[i+1]
         let delta = nextLocation.altitude - location.altitude
         if delta > 0 {
            mapElevation += delta
         }
      }
      return mapElevation
   }
}

extension CLLocationCoordinate2D {
   var location: CLLocation {
      CLLocation(latitude: latitude, longitude: longitude)
   }
}

