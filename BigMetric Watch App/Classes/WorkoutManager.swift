// Original WorkoutManager class
import HealthKit
import CoreLocation
import UIKit
import SwiftUI
import Foundation
import Combine


class WorkoutManager: NSObject, ObservableObject, CLLocationManagerDelegate {

   // MARK: - Workout Metrics
   @ObservedObject var distanceTracker: DistanceTracker = DistanceTracker()
   @Published var distanceCollected: Double = 0
   @Published var workoutSessionState: HKWorkoutSessionState = .notStarted
   @Published var initialLocation: CLLocation?
   @Published var averageHeartRate: Double = 0
   @Published var heartRate: Double = 0
   @Published var activeEnergy: Double = 0
   @Published var workoutDistance: Double = 0
   @Published var workout: HKWorkout?
   @Published var stepCounter: Double = 0
   @Published var heading = ""
   @Published var routeHeading: Double = 0
   @Published var course: Double = 0
   @Published var isLocateMgr: Bool = false
   @Published var altitude:Double = 0
   let healthStore = HKHealthStore()
   var session: HKWorkoutSession?
   var builder: HKLiveWorkoutBuilder?

   // set up the locationManager to capture location coords
   let locationManager = CLLocationManager()
   // property to initialize the HKWorkoutRouteBuilder
   private var routeBuilder: HKWorkoutRouteBuilder?
   var selectedWorkout: HKWorkoutActivityType? {
      didSet {
         guard let selectedWorkout = selectedWorkout else { return }
         startWorkout(workoutType: selectedWorkout)
      }
   }

   func endWorkoutbuilder() {
      print("endWorkoutbuilder called")
      self.session?.end()
      distanceTracker.cleanVars = true
   }

   func startWorkout(workoutType: HKWorkoutActivityType) {
      initialLocation = nil
      let configuration = HKWorkoutConfiguration()
      configuration.activityType = workoutType
      configuration.locationType = .outdoor

      do {
         session = try HKWorkoutSession(healthStore: healthStore,
                                        configuration: configuration)
         builder = session?.associatedWorkoutBuilder()
         session?.delegate = self
         builder?.delegate = self
      } catch {
         // Handle any exceptions.
         return
      }
      
      builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore,
                                                    workoutConfiguration: configuration)
      session?.delegate = self
      builder?.delegate = self

      // Start the workout session and begin data collection.
      let startDate = Date()
      session?.startActivity(with: startDate)
      builder?.beginCollection(withStart: startDate, completion: { success, error in
         // The workout has started
      })

      // implement the locationManager delegate start...
      locationManager.delegate = self
      locationManager.distanceFilter = 1
      locationManager.allowsBackgroundLocationUpdates = true
      locationManager.desiredAccuracy = kCLLocationAccuracyBest

      
      DispatchQueue.global(qos: .userInitiated).async { [self] in
         locationManager.requestWhenInUseAuthorization()
         locationManager.startUpdatingLocation()
      }
      routeBuilder = HKWorkoutRouteBuilder(healthStore: healthStore, device: nil)
   }

   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      // make certain there is a valid/current location returned
      guard let _ = locations.last else {
         distanceTracker.isInitialLocationObtained = false
         print("/nSeeking Location inside WorkoutManager/n/n")
         return
      }

      // Now make certain we have started the workout before utilizing the GPS data
      if workoutSessionState == .notStarted { return }

      // Now set the minimumAccuracy to 50 meters
      let minimumAccuracy: CLLocationAccuracy = 50.0 // Adjust this value based on your desired accuracy in meters

      // If we have an accurate location that's received after the start button pressed,
      // set initialLocation for continued collection
      if workoutSessionState == .running &&  initialLocation == nil {
         if let accurateLocation = locations.first(where: { $0.horizontalAccuracy <= minimumAccuracy }) {
            initialLocation = accurateLocation
            distanceTracker.isInitialLocationObtained = true
         } else {
            distanceTracker.isInitialLocationObtained = false
            print("Location accuracy is insufficient to commence - accuracy: \(locations.first?.horizontalAccuracy ?? 0)")
         }
      }

      // continue CLLocation collection now because we know this location data is collected AFTER the
      // user has pressed the start button
      var collectedLocationsFromDevice: [CLLocation] = []
      locations.forEach { collectedLocations in
         isLocateMgr = false // reset state for CompassView blurred background
                             // get the cardinal letter representation of the heading - i.e. NW, E, SE
         course = collectedLocations.course
         heading = CardinalDirection(course: collectedLocations.course).rawValue
         altitude = collectedLocations.altitude

         collectedLocationsFromDevice.append(
            CLLocation(
               coordinate: collectedLocations.coordinate,
               altitude: collectedLocations.altitude,
               horizontalAccuracy: collectedLocations.horizontalAccuracy,
               verticalAccuracy: collectedLocations.verticalAccuracy,
               course: collectedLocations.course,
               speed: collectedLocations.speed,
               timestamp: collectedLocations.timestamp
            )
         )
      }

      let totalAltitude = collectedLocationsFromDevice.reduce(0) { (result, location) -> CLLocationDistance in
         return result + location.altitude
      }

      let numberOfLocations = Double(collectedLocationsFromDevice.count)
      altitude = numberOfLocations > 0 ? totalAltitude / numberOfLocations : 0


      // Add location to the route builder - this makes me so very happy - 3/18/23
      //// insertRouteData is the key to asynchronously add one or more CLLocation to the series.
      routeBuilder?.insertRouteData(collectedLocationsFromDevice) { [self] success, error in
         if let error = error {
            print("Error adding location to the route builder: \(error.localizedDescription)")
         } else {
            DispatchQueue.main.async  { [self] in
               distanceTracker.builderDebugStr = "Location successfully added to builder: " + success.description
               isLocateMgr = false // toggle for .blur under compass view button
                                   //            print("Location successfully added to the route builder")
            }
         }
      }
   }

   func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
      switch status {
         case .authorizedAlways, .authorizedWhenInUse:
           return
         case .notDetermined, .denied, .restricted:
            locationManager.requestWhenInUseAuthorization()
         @unknown default:
            fatalError()
      }
   }

   // locationManager for didUpdateHeading for the compass
   func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
         isLocateMgr = true // state for the CompassView button background blur
         routeHeading = newHeading.trueHeading
   }

   func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print("-WorkoutManager LM - Location manager error: \(error.localizedDescription)")
   }
}

extension WorkoutManager {
   // MARK: - State Control
   func pause() {
      session?.pause()
      locationManager.stopUpdatingLocation()
   }

   func resume() {
      session?.resume()
      locationManager.startUpdatingLocation()
   }

   func togglePause() {
      if distanceTracker.weIsRecording {
         pause()
      } else {
         resume()
      }
   }

   func resetWorkout() {
      selectedWorkout = nil
      initialLocation = nil
      builder = nil
      session = nil
      workout = nil
      distanceCollected = 0
      activeEnergy = 0
      averageHeartRate = 0
      heartRate = 0
      workoutDistance = 0
      stepCounter = 0
      workoutSessionState = .notStarted
   }
}

extension WorkoutManager: HKWorkoutSessionDelegate {

   func workoutSession(_ workoutSession: HKWorkoutSession,
                       didChangeTo toState: HKWorkoutSessionState,
                       from fromState: HKWorkoutSessionState,
                       date: Date) {

      print("Workout session state changed from \(fromState.rawValue) to \(toState.rawValue)")
      print("Current view: \(type(of: self).description())\n")
      let callingFunction = #function
      print("Called from function: \(callingFunction)\n\n")
      let stack = Thread.callStackSymbols
      if stack.count > 1 {
         print("Caller: \(stack[1]) - and \(stack[0]) \n\n")
      }

      DispatchQueue.main.async { [self] in
         distanceTracker.weIsRecording = toState == .running
         workoutSessionState = toState
         distanceTracker.builderDebugStr = "Builder: " + String(toState.rawValue)
      }


      // stop locationManager and builder
      if toState == .ended {
         builder?.endCollection(withEnd: date, completion: { [self] success, error in
            if let error = error {
               print("Error ending the collection: \(error.localizedDescription)")
            } else {
               print("Collection ended successfully - \(success.description)")
               DispatchQueue.main.async { [self] in
                  distanceTracker.builderDebugStr += "Collection ended - \(success.description)\n"
               }
               builder?.finishWorkout(completion: { workout, error in
                  DispatchQueue.main.async {
                     self.workout = workout
                     guard let workout = workout else {
                        print("Workout is nil, cannot finish the route")
                        return
                     }
                     self.routeBuilder?.finishRoute(with: workout, metadata: nil, completion: { (route, error) in
                        if let error = error {
                           print("Error finishing route: \(error.localizedDescription)")
                        } else if let route = route {
                           self.healthStore.add([route], to: workout) { (success, error) in
                              if let error = error {
                                 print("Error adding route to workout: \(error.localizedDescription)")
                              } else {
                                 print("Route successfully added to workout")
                                 DispatchQueue.main.async { [self] in
                                    distanceTracker.builderDebugStr += "Route successfully added to workout\n"
                                 }
                              }
                           }
                        }
                     })
                  }
               })
            }
         })
// stop locationManager updates
         locationManager.stopUpdatingLocation()
      }
   }

   func workoutSession(_ workoutSession: HKWorkoutSession,
                       didFailWithError error: Error) {
      print("Workout session failed with error: \(error.localizedDescription)")
   }
}

// MARK: - HKLiveWorkoutBuilderDelegate
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
   typealias HKQ = HKQuantityType
   func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
      //      print("liveWorkoutBuilder collected:\n")
      DispatchQueue.main.async { [self] in
         for (quantityType, statistics) in workoutBuilder.allStatistics {
            if let sum = statistics.sumQuantity() {
               print("Sum: \(sum)")
               if quantityType.identifier == HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue {
                  let distanceUnit = HKUnit.mile()
                  distanceCollected += sum.doubleValue(for: distanceUnit)

                  print("distanceCollected sum: \(distanceCollected)\n")
               }
            }
         }
         print("\n")
      }
   }

   func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder,
                       didFinishWith workout: HKWorkout,
                       error: Error?) {
      print("Workout builder - [didFinishWith]")
      if let error = error {
         print("Error with workout builder: \(error.localizedDescription) - [didFinishWith]")
         return
      }
      routeBuilder?.finishRoute(with: workout, metadata: nil) { (route, error) in
         if let error = error {
            print("Error finishing route: \(error.localizedDescription)")
         } else {
            print("Route successfully added to workout - [didFinishWith]")
            // Check if the workout session is still active before ending the collection.
            if self.session?.state == .running {
               print("Workout session is running, ending collection...[didFinishWith]")
               workoutBuilder.endCollection(withEnd: workout.endDate, completion: { (success, error) in
                  if success {
                     print("Collection ended successfully - [didFinishWith]")
                  } else if let error = error {
                     print("Error ending the collection: \(error.localizedDescription) - [didFinishWith]")
                  }
               })
            } else {
               print("Workout session is not active, no need to end the collection. - [didFinishWith]")
            }
         }
      }
   }

   func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder,
                       didCollectDataOf collectedTypes: Set<HKSampleType>) {
      for type in collectedTypes {
         guard let quantityType = type as? HKQ else { return }
         let statistics = workoutBuilder.statistics(for: quantityType)

         // Update the published values.
         updateForStatistics(statistics)
      }
   }

   func updateForStatistics(_ statistics: HKStatistics?) {
      guard let statistics = statistics else {return }
      //  print("statistics: \(statistics)\n")

      DispatchQueue.main.async {
         switch statistics.quantityType {
            case HKQ.quantityType(forIdentifier: .heartRate):
               let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
               self.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
               self.averageHeartRate = statistics.averageQuantity()?.doubleValue(for: heartRateUnit) ?? 0
               //print("heartRate: \(self.heartRate) - averageHeartRate: \(self.averageHeartRate)")

            case HKQ.quantityType(forIdentifier: .activeEnergyBurned):
               let energyUnit = HKUnit.kilocalorie()
               self.activeEnergy = statistics.sumQuantity()?.doubleValue(for: energyUnit) ?? 0
               //print("activeEnergy: \(self.activeEnergy)")


            case HKQ.quantityType(forIdentifier: .stepCount):
               let stepUnit = HKUnit.mile()
               self.stepCounter = statistics.sumQuantity()?.doubleValue(for: stepUnit ) ?? 0
               //print("stepCounter: \(self.stepCounter)")


            case HKQ.quantityType(forIdentifier: .distanceWalkingRunning),
               HKQ.quantityType(forIdentifier: .distanceWalkingRunning):
               let meterUnit = HKUnit.mile()
               self.workoutDistance = statistics.sumQuantity()?.doubleValue(for: meterUnit) ?? 0
               //print("workoutDistance: \(self.workoutDistance)")

            default: return
         }
      }
   }

   // Request authorization to access Healthkit.
   func requestHKAuth() {

      // The quantity type to write to the health store.
      let typesToShare: Set = [HKQ.workoutType()]

      // The quantity types to read from the health store.
      let typesToRead: Set = [
         HKQ.quantityType(forIdentifier: .heartRate)!,
         HKQ.quantityType(forIdentifier: .activeEnergyBurned)!,
         HKQ.quantityType(forIdentifier: .distanceWalkingRunning)!,
         HKQ.quantityType(forIdentifier: .distanceCycling)!,
         HKQ.quantityType(forIdentifier: .stepCount)!,
         HKQ.quantityType(forIdentifier: .bodyTemperature)!,
         HKObjectType.activitySummaryType()
      ]

      // Request authorization for those quantity types
      healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
         // Handle error.
      }
   }
}

extension HKWorkoutSession {
   func end(completion: ((Error?) -> Void)? = nil) {
      let endWorkoutOperation = BlockOperation {
         self.end()
      }

      endWorkoutOperation.completionBlock = {
         completion?(nil)
      }

      endWorkoutOperation.start()
   }
}




