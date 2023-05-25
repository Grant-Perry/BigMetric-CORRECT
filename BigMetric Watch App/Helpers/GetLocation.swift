//
//  GetLocation.swift
//  howFar Watch App
//
//  Created by Grant Perry on 4/16/23.
//

import Foundation
import CoreLocation


class GetLocation: NSObject, CLLocationManagerDelegate {
   private let currentLocationDelegate = CLLocationManager()

   // MARK: - Singleton
   static let shared = GetLocation()

   // MARK: - Private Init
   private override init() {
      super.init()
      currentLocationDelegate.delegate = self
      currentLocationDelegate.desiredAccuracy = kCLLocationAccuracyBest
      currentLocationDelegate.requestWhenInUseAuthorization()
      
   }

   // MARK: - Stored completion handler property
   private var completionHandler: ((Result<CLLocationCoordinate2D, Error>) -> Void)?

   // MARK: - Request Location
   func getCurrentLocationKILL() async throws -> CLLocationCoordinate2D {
      return try await withCheckedThrowingContinuation { continuation in
         completionHandler = { result in
            switch result {
               case .success(let coordinate):
                  continuation.resume(returning: coordinate)
               case .failure(let error):
                  continuation.resume(throwing: error)
            }
         }
         currentLocationDelegate.requestLocation()
      }
   }

   enum LocationError: Error {
      case requestTimeout
   }

   func getCurrentLocation() async throws -> CLLocationCoordinate2D {
      return try await withCheckedThrowingContinuation { continuation in
         let timeoutHandler = DispatchWorkItem { [self] in
            if let completionHandler = completionHandler {
               completionHandler(.failure(LocationError.requestTimeout))
            }
         }

         completionHandler = { result in
            timeoutHandler.cancel()
            switch result {
               case .success(let coordinate):
                  continuation.resume(returning: coordinate)
               case .failure(let error):
                  continuation.resume(throwing: error)
            }
         }
         currentLocationDelegate.requestLocation()

         // Set a timeout for the location request
         DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: timeoutHandler) // 10 seconds timeout
      }
   }

   // MARK: - CLLocationManagerDelegate Methods
   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      if let location = locations.last {
         let latitude = location.coordinate.latitude
         let longitude = location.coordinate.longitude

         print("Latitude: \(latitude), Longitude: \(longitude)")

         // Call the completion handler with the coordinate
         completionHandler?(.success(location.coordinate))
         completionHandler = nil // Reset the completionHandler after calling it
      }
   }

   func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print("Failed to secure user location: \(error.localizedDescription) [CurrentLocation]")

      // Call the completion handler with the error
      completionHandler?(.failure(error))
      completionHandler = nil // Reset the completionHandler after calling it
   }
}



