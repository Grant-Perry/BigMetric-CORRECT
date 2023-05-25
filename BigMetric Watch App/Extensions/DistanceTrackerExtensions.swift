//
//  DistanceTrackerExtensions.swift
//  howFar
//
//  Created by Grant Perry on 3/26/23.
//

import HealthKit

extension DistanceTracker {
   func startHeartRate() {
      authHealthKitForHeart()
      startHeartRateQuery(quantityTypeIdentifier: .heartRate)
   }

   func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
      // We want data points from our current device
      let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
      // A query that returns changes to the HealthKit store, including a snapshot of new changes and continuous monitoring as a long-running query.
      let updateHandler: (HKAnchoredObjectQuery,
                          [HKSample]?,
                          [HKDeletedObject]?,
                          HKQueryAnchor?, Error?) -> Void = {
         query, samples, deletedObjects, queryAnchor, error in
         // A sample that represents a quantity, including the value and the units.
         guard let samples = samples as? [HKQuantitySample] else {
            return
         }
         self.processHeartRate(samples, type: quantityTypeIdentifier)
      }
      // It provides us with both the ability to receive a snapshot of data, and then on subsequent calls, a snapshot of what has changed.
      let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!,
                                        predicate: devicePredicate,
                                        anchor: nil,
                                        limit: HKObjectQueryNoLimit,
                                        resultsHandler: updateHandler)
      query.updateHandler = updateHandler
      // query execution
      HKStore.execute(query)
   }

   func processHeartRate(_ samples: [HKQuantitySample],
                         type: HKQuantityTypeIdentifier) {
      // variable initialization
      var lastHeartRate = 0.0
      let heartRateQuantity = HKUnit(from: "count/min")
      // cycle and value assignment
      for sample in samples {
         if type == .heartRate {
            lastHeartRate = sample.quantity.doubleValue(for:  heartRateQuantity)
         }
         DispatchQueue.main.async {
            self.heartRate = lastHeartRate
         }
      }
   }

   public func authHealthKitForHeart() {
      var holdStatus = "Looked but not yet"
      let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
      HKStore.requestAuthorization(toShare: [heartRateType], read: [heartRateType]) { (success, error) in
         let authorizationStatus = self.HKStore.authorizationStatus(for: heartRateType)
         if authorizationStatus == .notDetermined {
            holdStatus = "\n\nHealth: Not Determined"
         } else if authorizationStatus == .sharingDenied {
            holdStatus = "\n\nHealth: Sharing Denied"
         } else if authorizationStatus == .sharingAuthorized {
            holdStatus = "\n\nHealth: Authorized"
         }
         DispatchQueue.main.async {
            self.superAuthBug = holdStatus
         }
      }
   }

   func getHKAuth() {
      let healthStore = HKHealthStore()
      let dataTypesToWrite: Set<HKSampleType> = [HKWorkoutType.workoutType(), HKSeriesType.workoutRoute()]
      let dataTypesToRead: Set<HKObjectType> =  [HKWorkoutType.workoutType(), HKSeriesType.workoutRoute()]
      healthStore.requestAuthorization(toShare: dataTypesToWrite, read: dataTypesToRead) { (success, error) in
         if !success {
            print("Error requesting HealthKit authorization: \(error?.localizedDescription ?? "Unknown Error")")
         }
         else {
            print("Authorization Success at getHKAuth")
         }
      }
   }
}


