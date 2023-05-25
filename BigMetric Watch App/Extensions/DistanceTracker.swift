//
//  DistanceTracker.swift
//  howFar
//
//  Created by Grant Perry on 1/24/23.
//

import Foundation
import CoreLocation
import HealthKit
import Combine
import SwiftUI
import UIKit

class DistanceTracker: NSObject, ObservableObject, CLLocationManagerDelegate {

   @EnvironmentObject var workoutManager: WorkoutManager
   @AppStorage("isBeep") var isBeep = true
   @Published var longitude: CLLocationDegrees?
   @Published var latitude: CLLocationDegrees?
   @Published var altitude: Double = 0
//   @Published var altitudes: [Double] = []
   @Published var altitudes: [AltitudeDataPoint] = []

   @Published var currentCoords = CLLocationCoordinate2D()
   @Published var locationName: String = ""
   @Published var showStartText = true
   @Published var isInitialLocationObtained: Bool = true
   @Published var yardsOrMiles = true
   @Published var distance: Double? = 0.0
   @Published var speedDist: Double = 0.0
   @Published var formattedTimeString: String = "00:00:00"
   @Published var debugStr = "debug"
   @Published var isUpdating = false
   @Published var isHealthUpdate = false
   @Published var isNotAuthorized = false
   @Published var superBug = "debugs REALLY big"
   @Published var superAuthBug = "Not determined"
   @Published var builderDebugStr = "[nil]"
   @Published var heartRate:Double = 0.0
   @Published var healthRecordsCount = 0
   @Published var isWorkoutLive = false
   @Published var lastDist:Double = 0
   @Published var routeBuilder = HKWorkoutRouteBuilder(healthStore: HKHealthStore(), device: nil)
   @Published var lastHapticMile: Int = 0
   @Published var startStepCnt: Int = 0
   
   //   @Published var isBeep: Bool = true
   @Published var cleanVars: Bool = false {
      didSet {
         if cleanVars {
            self.cleanVars = false
            resetVars()
         }
      }
   }
   @Published var timer: Timer?
   @Published var plusMinus = "+="
   @Published var weIsRecording = false
   @Published var holdDist:Double = 0.0
   @Published var YMCalc = true
   @Published var initRun = true
   @Published var elapsedTime: Double = 0
   @Published var formatter = DateComponentsFormatter()
   @Published var lastLocation: CLLocation?
   @Published var firstLocation: CLLocation?
   @Published var startRouteBuilder = true
   @Published var HKStore = HKHealthStore()
   var LMDelegate = CLLocationManager()
   
   var isAuthorizedForPreciseLocation = true
   //   var holdDistance = 0.0
   //   var locations: [CLLocation] = []
   var healthRecordExists = false
   var healthRecordsDelete = false
   var holdCLLocations: [CLLocation] = []
//   var initialized = false

   override init() {
      super.init()
      setupLocationManager()
//      LMDelegate.delegate = self
//      LMDelegate.desiredAccuracy = kCLLocationAccuracyBest // kCLLocationAccuracyBestForNavigation
//      LMDelegate.allowsBackgroundLocationUpdates = true
//      LMDelegate.distanceFilter = 1
//      LMDelegate.activityType = .fitness // .automotiveNavigation
   }

   private func setupLocationManager() {
      LMDelegate.delegate = self
      LMDelegate.desiredAccuracy = kCLLocationAccuracyBest
      LMDelegate.allowsBackgroundLocationUpdates = true
      LMDelegate.distanceFilter = 1
      LMDelegate.activityType = .fitness
   }

   func resetLocationManager() {
      LMDelegate.delegate = nil
      LMDelegate = CLLocationManager()
      setupLocationManager()
   }

   func locationManager(_ manager: CLLocationManager, didUpdateLocations GPSLocation: [CLLocation]) {
      // check to verify there is a valid initial location
      guard let isLocation = GPSLocation.last else {
         isInitialLocationObtained = false
         print("/nDidn't find a location but inside locationManager-didUpdateLocations.../n/n")
         return
      }
      // now set isInitialLocationObtained state = true
      if !isInitialLocationObtained && isLocation.horizontalAccuracy <= 50.0 {
         isInitialLocationObtained = true
         print("isInitialLocationObtained = true")
         let geocoder = CLGeocoder()
         geocoder.reverseGeocodeLocation(isLocation) { [self] (placemarks, error) in
            guard error == nil, let placemark = placemarks?.first else { return }
            locationName = placemark.locality ?? ""
         }
#if os(watchOS)
         if isBeep {
            PlayHaptic.tap(PlayHaptic.up)
         }
#endif
      }
      if weIsRecording {
         if let location = GPSLocation.last {
            altitude = location.altitude * 3.28084
            //       Append altitude to altitudes[] for point chart
            let newDataPoint = AltitudeDataPoint(value: altitude, dist: distance ?? 0)
            // collect coords for weather data
            self.altitudes.append(newDataPoint)
            self.latitude = Double(location.coordinate.latitude)
            self.longitude = Double(location.coordinate.longitude)
            self.currentCoords = location.coordinate
         }
         //         print("Lat: \(currentCoords.latitude) - Long: \(currentCoords.longitude) - [DistanceTracker]\n")

         let filteredLocations = GPSLocation.filter { (location: CLLocation) -> Bool in
            location.horizontalAccuracy <= 50.0
         }
         guard !filteredLocations.isEmpty else { return }
         holdCLLocations = filteredLocations
         blinkRecordBtn(true, 2)
         guard let existingLocation = holdCLLocations.last else { return }

         // make certain we're not updating firstLocation unless it's the FIRST time it has a value
         if firstLocation == nil {
            firstLocation = existingLocation
            authHealthKitForHeart()
            getHKAuth()
            // fetch the starting step counter
            queryStepCount { steps in
               if let steps = steps {
                  self.startStepCnt = steps
                  print("---------\nNumber of steps: \(self.startStepCnt) \n-----------------")
               } else { print("Error retrieving step count.") } } }
         if initRun {
            isInitialLocationObtained = false // set state to false to correctly allow initial location to produce a value
            isWorkoutLive = true
            initRun = false
         }
         // MARK: - Distance Calculations
         calcDistance(existingLocation)
         lastDist = distance ?? 0 // hold distance for summaryView
         lastLocation = existingLocation

         // check to see if mile haptic needs to fire
#if os(watchOS)
         let currentMile = Int(distance!)
         if currentMile > lastHapticMile {
            lastHapticMile = currentMile
            if self.isBeep {
               PlayHaptic.tap(PlayHaptic.notify)
            }
         }
#endif
         debugStr = "debug"
         buildDebugStr()
         DispatchQueue.main.async {
            self.superBug = self.debugStr + "\n\ndistance: " + String(self.distance!)
            self.debugStr = self.debugStr
         }
      }
   }

   func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print("LocationManager LM - locationManager failed with error: \(error.localizedDescription)")
   }

   /// start the CLLocation updates
   func startUpdates() {
      if LMDelegate.authorizationStatus !=  .authorizedWhenInUse {
         LMDelegate.requestWhenInUseAuthorization()
         isNotAuthorized = true
      }
      self.weIsRecording = true
      if startRouteBuilder {
         getHKAuth()
         startRouteBuilder = false
      }

      LMDelegate.startUpdatingLocation()
      timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
         guard let self = self else { return }
         if self.weIsRecording {
            self.elapsedTime += 1
            self.formattedTimeString = self.stringFromTimeInterval(interval: self.elapsedTime)
         }
      }
   }

   func numTimerHours() -> Int {
      return Int(elapsedTime / 3600)

   }

   func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
      switch status {
         case .authorizedAlways, .authorizedWhenInUse:
            return
         case .notDetermined, .denied, .restricted:
            manager.requestWhenInUseAuthorization()
         @unknown default:
            fatalError()
      }
   }

   // main distance increment-or
   func calcDistance(_ existingLocation: CLLocation) {
      if !YMCalc {  // YARDS
         if let originalLocation = firstLocation {
            distance = existingLocation.distance(from: originalLocation) / 1609.344
            plusMinus = "="
         }
      } else { // MILES
         if let lastLocation = lastLocation {
            holdDist = existingLocation.distance(from: lastLocation) / 1609.344
            self.distance! += holdDist
            speedDist = self.distance!
            plusMinus = "+="
         }
      }
   }

   /// Stop the CLLocation update
   /// - Parameter: should all the counter be reset
   /// - Returns: timeString
   func stopUpdates(_ resetDist: Bool) -> String {
      // write the collected GPS data to the iPhone
      // var tmpLoc: [CLLocation] = []
      // writeGPSData(tmpLoc, true)
      LMDelegate.stopUpdatingLocation()
      timer?.invalidate()
      weIsRecording = false
      firstLocation = nil
      lastLocation = nil
      let timeString = formattedTimeString
      cleanVars = resetDist // didSet will handle reset
                            //      if resetDist {
                            //         // stop the routeBuilder
                            //         //         routeBuilder.discard()
                            //      }
      return timeString
   }

   public func endWorkout() {
      let activityType: HKWorkoutActivityType = .walking // .running
      let startDate = Date()
      let endDate = startDate.addingTimeInterval(3600) // 1 hour later
                                                       //      let duration = endDate.timeIntervalSince(startDate)
      let workOut = HKWorkout(activityType: activityType,
                              start: startDate,
                              end: endDate,
                              workoutEvents: nil,
                              totalEnergyBurned: nil,
                              totalDistance: nil,
                              metadata: [:])

      routeBuilder.finishRoute(with: workOut,
                               metadata: nil,
                               completion: { workoutRoute, error in
         if workoutRoute == nil {
            print("error saving workout route inside endWorkout with: - \(error!)")
         } else {
            print("SUCCESS -> workoutRoute inside endWorkout - Workout = \(workOut)")
         }
      })
      LMDelegate.stopUpdatingLocation()
      cleanVars = true // didSet will handle reset
                       //      resetVars()
   }

   func requestCurrentLocation() {
      DispatchQueue.global(qos: .userInitiated).async { [self] in
         LMDelegate.requestLocation()
      }
   }
}

extension DistanceTracker { // misc helper methods
   func buildDebugStr() {
      if let fl = firstLocation, let ll = lastLocation {
         debugStr = plusMinus + " | Last: (\(ll.coordinate.latitude), \(ll.coordinate.longitude))\nFirst: (\(fl.coordinate.latitude), \(fl.coordinate.longitude))"
      } else {
         debugStr = "FL: nil | LL: nil"
      }
   }

   func stringFromTimeInterval(interval: TimeInterval) -> String {
      let interval = Int(interval)
      let seconds = interval % 60
      let minutes = (interval / 60) % 60
      let hours = (interval / 3600)
      return hours > 0 ? String(format: "%02d:%02d:%02d", hours, minutes, seconds) : String(format: "%02d:%02d", minutes, seconds)
   }

   func blinkRecordBtn(_ toggleState: Bool, _ blinkTime: Int) {
      DispatchQueue.main.async {
         if toggleState { self.isUpdating = true } else { self.isHealthUpdate = true }
         DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(blinkTime)) {
            if toggleState { self.isUpdating = false } else { self.isHealthUpdate = false }
            // used for the green / red status button on screen
         }
      }
   }

   func resetVars() {
      LMDelegate.stopUpdatingLocation()
      resetLocationManager()
      holdCLLocations.removeAll()
      holdCLLocations = []
      altitudes.removeAll()
//      altitudes = []
      distance = 0
      holdDist = 0
      elapsedTime = 0
      heartRate = 0
      lastHapticMile = 0
      firstLocation = nil
      lastLocation = nil
      initRun = true
      isUpdating = false
      isHealthUpdate = false
      weIsRecording = false
      isWorkoutLive = false
      isInitialLocationObtained = true
      startStepCnt = 0
   }
}

extension DistanceTracker { // toggle stuff

   func toggleYMBool(_ ymState: Bool)  {
      YMCalc = ymState
      _ = stopUpdates(true)
   }

   func toggleYMBoolFalse() {
      YMCalc = false
   }

   func toggleWeIsRecording(_ RecState: Bool)  {
      weIsRecording = RecState
   }
}



