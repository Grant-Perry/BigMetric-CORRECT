//
//  WeatherConditions.swift
//  howFar Watch App
//
//  Created by Grant Perry on 4/23/23.
//

import Foundation
import SwiftUI

enum WeatherConditions: Int, Decodable {
   case thunderstorm = 200,
         drizzle = 300,
         rain = 500,
         snow = 600,
         atmosphere = 700,
         clear = 800,
         clouds = 801

   init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      let id = try container.decode(Int.self)

      switch id {
         case 200...232:
            self = .thunderstorm
         case 300...321:
            self = .drizzle
         case 500...531:
            self = .rain
         case 600...622:
            self = .snow
         case 701, 711, 721, 731, 741, 751, 761, 762, 771, 781:
            self = .atmosphere
         case 800:
            self = .clear
         case 801...804:
            self = .clouds
         default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid weather condition ID")
      }
   }


   func getWeatherSymbol() -> String {
      switch self {
         case .thunderstorm:
            return "cloud.bolt.rain.fill"
         case .drizzle:
            return "cloud.drizzle.fill"
         case .rain:
            return "cloud.rain.fill"
         case .snow:
            return "snow"
         case .atmosphere:
            return "cloud.fog.fill"
         case .clear:
            return "sun.max.fill"
         case .clouds:
            return "cloud.fill"
      }
   }
}

