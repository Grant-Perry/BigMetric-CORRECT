//
//  AltitudeManager.swift
//  howFar Watch App
//
//  Created by Grant Perry on 5/13/23.
//

import SwiftUI
import CoreMotion
import Combine

class AltitudeManager: ObservableObject {
   private let altimeter = CMAltimeter()
   private var cancellable: AnyCancellable?

   @Published var altitudeString: String = ""

   func startUpdates() {
      guard CMAltimeter.isRelativeAltitudeAvailable() else {
         print("Barometer not available on this device.")
         return
      }

      cancellable = Timer.publish(every: 1, on: .main, in: .common)
         .autoconnect()
         .sink { [weak self] _ in
            self?.altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main) { data, error in
               if let data = data {
                  let altitudeInMeters = data.relativeAltitude.doubleValue
                  let altitudeInFeet = altitudeInMeters * 3.28084
                  let altitudeString = String(format: "%.2f", altitudeInFeet)
                  DispatchQueue.main.async {
                     self?.altitudeString = altitudeString
                  }
               } else if let error = error {
                  print("Error from: \(error)")
               }
            }
         }
   }

   func stopUpdates() {
      altimeter.stopRelativeAltitudeUpdates()
      cancellable?.cancel()
   }
}

