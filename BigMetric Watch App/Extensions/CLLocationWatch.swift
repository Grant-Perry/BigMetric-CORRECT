//
//  watchCLLocation.swift
//  howFar Watch App
//
//  Created by Grant Perry on 3/31/23.
//

import SwiftUI
import CoreLocation

///adds a computed property cardinalDirection to instances of CLLocation.
///The cardinalDirection property returns a CardinalDirection value, which is calculated based on the course property of
///the CLLocation object. The course property of a CLLocation object is the direction of travel in degrees relative
///to due north (0 degrees).
///
extension CLLocation {
   var cardinalDirection: CardinalDirection {
      return CardinalDirection(course: course)
   }
}



