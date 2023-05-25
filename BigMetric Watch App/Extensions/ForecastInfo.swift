//
//  ForecastInfo.swift
//  howFar Watch App
//
//  Created by Grant Perry on 4/24/23.
//

import Foundation
import WeatherKit
import CoreLocation

struct ForecastData {

   var id = UUID()

   var date: Date
   var condition: String
   var symbolName: String
   var temperature: Temperature
   var precipitation: String
   var precipitationChance: Double
   var windSpeed: Measurement<UnitSpeed>
   var windDirection: Measurement<UnitAngle>
}

extension ForecastData {
   init(_ forecast: DayWeather) {
      date = forecast.date
      condition = forecast.condition.description
      symbolName = forecast.symbolName
      temperature = .daily(high: forecast.highTemperature,
                           low: forecast.lowTemperature)
      precipitation = forecast.precipitation.description
      precipitationChance = forecast.precipitationChance
      windSpeed = forecast.wind.speed
      windDirection = forecast.wind.direction
   }

   init(_ forecast: HourWeather) {
      date = forecast.date
      condition = forecast.condition.description
      symbolName = forecast.symbolName
      temperature = .hourly(forecast.temperature)
      precipitation = forecast.precipitation.description
      precipitationChance = forecast.precipitationChance
      windSpeed = forecast.wind.speed
      windDirection = forecast.wind.direction
   }
}

extension ForecastData {
   enum Temperature {
      typealias Value = Measurement<UnitTemperature>
      case daily(high: Value, low: Value)
      case hourly(Value)

      var isDaily: Bool {
         switch self {
            case .daily:
               return true
            case .hourly:
               return false
         }
      }
   }
}

