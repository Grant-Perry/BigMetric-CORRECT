//
//  Cardinal.swift
//  howFar Watch App
//
//  Created by Grant Perry on 3/30/23.
//

import SwiftUI

enum CardinalDirection: String {
   case north = "N",
        northeast = "NE",
        east = "E",
        southeast = "SE",
        south = "S",
        southwest = "SW",
        west = "W",
        northwest = "NW"

//  below is a computed property option
//   extension CLLocation {
//   var courseDirection: CardinalDirection {
//      let course = self.course

   init(course: CLLocationDirection) {
      switch course {
         case 0..<45:
            self = .north
         case 45..<90:
            self = .northeast
         case 90..<135:
            self = .east
         case 135..<180:
            self = .southeast
         case 180..<225:
            self = .south
         case 225..<270:
            self = .southwest
         case 270..<315:
            self = .west
         case 315..<360:
            self = .northwest
         default:
            self = .north
      }
   }

   var degrees: Double {
      switch self {
         case .north: return 0
         case .northeast: return 45
         case .east: return 90
         case .southeast: return 135
         case .south: return 180
         case .southwest: return 225
         case .west: return 270
         case .northwest: return 315
      }
   }
}

