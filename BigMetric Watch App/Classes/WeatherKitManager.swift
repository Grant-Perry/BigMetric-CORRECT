//
//  WeatherKitManager.swift
//  howFar Watch App
//
//  Created by Grant Perry on 4/16/23.
//

import Foundation
import WeatherKit
import CoreLocation
import SwiftUI
import Combine

class WeatherKitManager: NSObject, ObservableObject {
   @ObservedObject var distanceTracker: DistanceTracker = DistanceTracker()
   @ObservedObject var geoCodeHelper: GeoCodeHelper = GeoCodeHelper()

   let weatherService = WeatherService()
   let sharedService = WeatherService.shared
   var dailyForecast: Forecast<DayWeather>?
   var hourlyForecast: Forecast<HourWeather>?
   var date: Date = .now
   var latitude: Double = 0
   var longitude: Double = 0
   @Published var isErrorAlert: Bool = false

   @Published var symbolVar: String = "xmark"
   @Published var tempVar: String = ""
   @Published var tempHour: String = ""
   @Published var windSpeedVar: Double = 0
   @Published var windDirectionVar: String = ""
   @Published var highTempVar: String = ""
   @Published var lowTempVar: String = ""
   @Published var locationName: String = ""
   @Published var weekForecast: [Forecasts] = []
   @Published var precipForecast: Double = 0
   @Published var precipForecast2: Double = 0
   @Published var precipForecastAmount: Double = 0
   @Published var symbolHourly: String = ""
   @Published var currentWeathers = [Forecast<CurrentWeather>]()
   @Published var hourlyForecasts = [Forecast<HourWeather>]()
   @Published var dailyForecasts = [Forecast<DayWeather>]()

   var cLocation: CLLocation {
      CLLocation(latitude: latitude, longitude: longitude)
   }

   var dailyForecastInfo: [ForecastData] {
      guard let dailyForecast = dailyForecast else { return [] }
      return dailyForecast.forecast
         .filter { $0.date >= date }
         .prefix(7) // next 7 days [first 7 results]
         .map(ForecastData.init)
   }

   var hourlyForecastInfo: [ForecastData] {
      guard let hourlyForecast = hourlyForecast else { return [] }
      return hourlyForecast.forecast
         .filter { $0.date >= date }
         .prefix(7)
         .map(ForecastData.init)
   }

   // main method to retrieve the currentForecast and hourlyForecast
   func getWeather(for coordinate: CLLocationCoordinate2D) {
      Task {
         do {
            print("lat: \(coordinate.latitude) - long: \(coordinate.longitude) - [getWeather]\n")
            let weather = try await fetchWeather(for: coordinate)

//            let hourWeather = await hourlyForecast(for: coordinate)
//            precipForecast = hourWeather?.forecast.first?.precipitationChance ?? 0
//            symbolHourly = hourWeather?.forecast.first?.symbolName ?? "unknown"
//            tempHour = String(format: "%.0f", hourWeather?.forecast.first?.temperature.converted(to: .fahrenheit).value ?? "unknown")

            precipForecast2 = hourlyForecast?.first?.precipitationChance ?? 0
            precipForecast = weather.hourlyForecast.first?.precipitationAmount.value ?? 0
            symbolHourly = weather.hourlyForecast.first?.symbolName ?? "sun.max"
            tempHour = String(format: "%.0f", weather.hourlyForecast.first?.temperature.converted(to: .fahrenheit).value ?? 0)
            symbolVar = weather.currentWeather.symbolName
            tempVar = String(format: "%.0f", weather.currentWeather.temperature.converted(to: .fahrenheit).value)
            highTempVar = String(format: "%.0f", weather.dailyForecast[0].highTemperature.converted(to: .fahrenheit).value)
            lowTempVar = String(format: "%.0f", weather.dailyForecast[0].lowTemperature.converted(to: .fahrenheit).value)
            windSpeedVar = weather.currentWeather.wind.speed.converted(to: .milesPerHour).value
            windDirectionVar = CardinalDirection(course: weather.currentWeather.wind.direction.converted(to: .degrees).value).rawValue
            locationName = distanceTracker.locationName

            // get next howManyDays days forecast
            let howManyDays = 7
            weekForecast = (1...howManyDays).map { index in
               let dailyWeather = weather.dailyForecast[Int(index)]
               let symbolName = dailyWeather.symbolName
               let minTemp = String(format: "%.0f", dailyWeather.lowTemperature.converted(to: .fahrenheit).value)
               let maxTemp = String(format: "%.0f", dailyWeather.highTemperature.converted(to: .fahrenheit).value)
               return Forecasts(symbolName: symbolName, minTemp: minTemp, maxTemp: maxTemp)
            }
         } catch {
            if error.localizedDescription == "networkError: The Internet connection appears to be offline." {
               print(error.localizedDescription)
               isErrorAlert = true
            } else {
               print(error.localizedDescription)
             //  fatalError("\(error)")
            }
         }
      }
   }

   @discardableResult
   private func fetchWeather(for coordinate: CLLocationCoordinate2D) async throws -> Weather {
      let weather = try await Task.detached(priority: .userInitiated) {
         return try await self.sharedService.weather(for:
               .init(latitude: Double(coordinate.latitude),
                     longitude: Double(coordinate.longitude)))
      }.value
      return weather
   }

   @discardableResult
   func weatherGet(for coordinate: CLLocationCoordinate2D) async -> CurrentWeather? {
      let currentWeather = await Task.detached(priority: .userInitiated) {
         let currentCoord = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
         let currentForecast = try? await self.sharedService.weather(
            for: currentCoord,
            including: .current)
         return currentForecast
      }.value
//      currentWeathers = currentForecast
      return currentWeather
   }

   @discardableResult
   func dailyForecast(for coordinate: CLLocationCoordinate2D) async -> Forecast<DayWeather>? {
      let dayWeather = await Task.detached(priority: .userInitiated) {
         let dayForecast = try? await self.sharedService.weather(
            for: self.convertCLL(coordinate),
            including: .daily)
         return dayForecast
      }.value
      return dayWeather
   }

   @discardableResult
   func hourlyForecast(for coordinate: CLLocationCoordinate2D) async -> Forecast<HourWeather>? {
      let hourWeather = await Task.detached(priority: .userInitiated) {
         let hourForecast = try? await self.sharedService.weather(
            for: self.convertCLL(coordinate),
            including: .hourly)
         return hourForecast
      }.value
      return hourWeather
   }

   func convertCLL(_ coordinate: CLLocationCoordinate2D) -> CLLocation {
      return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
   }

   struct Forecasts: Identifiable {
      let id = UUID()
      let symbolName: String
      let minTemp: String
      let maxTemp: String
   }
}
