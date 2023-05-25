//
//  stepCounterExt.swift
//  howFar Watch App
//
//  Created by Grant Perry on 4/4/23.
//

import SwiftUI
import HealthKit

extension DistanceTracker { // queryStepCounter
   /*
    queryStepCount returns the current daily step count
    to utilize you need to pass a closure because it's an async call like...

         queryStepCount { steps in
         if let steps = steps {
         print("Number of steps: \(steps)")
         } else {
         print("Error retrieving step count.") } }
    */

   func queryStepCount(completion: @escaping (Int?) -> Void) {
      let healthStore = HKStore // HKHealthStore()

      let dataTypesToRead = HKObjectType.quantityType(forIdentifier: .stepCount)!
      let now = Date()
      let startOfDay = Calendar.current.startOfDay(for: now)
      let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
      healthStore.requestAuthorization(toShare: nil, read: Set([dataTypesToRead])) { (success, error) in
         if !success {
            print("Error requesting authorization in querystepCount with: \(error?.localizedDescription ?? "Unknown error")")
            completion(nil)
            return
         }
         let query = HKStatisticsQuery(quantityType: dataTypesToRead,
                                       quantitySamplePredicate: predicate,
                                       options: .cumulativeSum) { (_, result, error) in
            guard let sum = result?.sumQuantity() else {
               print("Error: \(error?.localizedDescription ?? "Unknown error")")
               completion(nil)
               return
            }
            let steps = sum.doubleValue(for: HKUnit.count())
            DispatchQueue.main.async {
               completion(Int(steps))
            }
         }
         healthStore.execute(query)
      }
   }
}
