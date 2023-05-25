//
//  HKExtensions.swift
//  howFar Watch App
//
//  Created by Grant Perry on 3/19/23.
//

import HealthKit

extension DistanceTracker { // Authorization methods

   // Request authorization to access Healthkit.
   func requestAuthorization() {

      // The quantity type to write to the health store.
      let typesToShare: Set = [HKQuantityType.workoutType()]

      // The quantity types to read from the health store.
      let typesToRead: Set = [
         HKQuantityType.quantityType(forIdentifier: .heartRate)!,
         HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
         HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
         HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
         HKQuantityType.quantityType(forIdentifier: .stepCount)!,
         HKQuantityType.quantityType(forIdentifier: .bodyTemperature)!,
         HKObjectType.activitySummaryType()
      ]

      // Request authorization for those quantity types
      HKStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
         // Handle error.
      }
   }

   //
   //   func authorizeHealthKit() {
   //      // Used to define the identifiers that create quantity type objects.
   //      let healthKitTypes: Set = [
   //         HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]
   //      // Requests permission to save and read the specified data types.
   //      HKStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { _, _ in }
   //   }

   func locationAuthorization() {
      switch LMDelegate.authorizationStatus {
         case .authorizedWhenInUse:
            return
         case .authorizedAlways:
            print("Authorized")
            return
         case .denied:
            print("Denied")
         case .restricted:
            print("Restricted")
         case .notDetermined:
            print("Not Determined")
         @unknown default:
            print("Unknown")
      }
      LMDelegate.requestWhenInUseAuthorization()
   }
   // HeartRate helper methods

}

  

