//
//  WriteGPSData.swift
//  howFar Watch App
//
//  Created by Grant Perry on 3/19/23.
//

import CoreLocation
import WatchConnectivity


extension DistanceTracker { //GPS locations write file

   /// write the didUpdateLocations GPSLocation GPS data to the plist
   /// - Parameter GPSLocation: GPSLocation is the CLLocatiopn didUpdateLocations GPS data
   func writeGPSData(_ GPSLocation: [CLLocation], _ isForIphone: Bool) {
      self.blinkRecordBtn(false, 2)
      let lat = GPSLocation.last?.coordinate.latitude
      let long = GPSLocation.last?.coordinate.longitude
      let alt = GPSLocation.last?.altitude
      let course = GPSLocation.last?.course
      let speed = GPSLocation.last?.speed
      let timeStamp = GPSLocation.last?.timestamp
      let date = Date()
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "dd-MM-yyyy"
      let dateString = dateFormatter.string(from: date)
      dateFormatter.dateFormat = "HH:mm:ss"
      let timeString = dateFormatter.string(from: date)
      let fileName = "/GPSData.plist"
      let filePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + fileName
      print("filePath: \(filePath)")

      let GPSLocationData: [String : Any] = ["latitude": lat as Any,
                                             "longitude": long as Any,
                                             "alt": alt as Any,
                                             "course": course as Any,
                                             "speed": speed as Any,
                                             "timeStamp": timeStamp as Any,
                                             "date": dateString,
                                             "time": timeString]
      let fileManager = FileManager.default
      var locationArray: [[String: Any]] = []

      if fileManager.fileExists(atPath: filePath) {
         if let loadedData = NSArray(contentsOfFile: filePath) as? [[String : Any]] {
            locationArray = loadedData
            if isForIphone {
               // write the collected data to the iphone
               toIphone(GPSLocationData)
               return
            }
            locationArray.append(GPSLocationData)
            if NSArray(array: locationArray).write(toFile: filePath, atomically: true) {
               print("FILE EXISTS - Write Success - GPSLocationData: \(GPSLocationData)")
            } else {
               print("FILE EXISTS but WRITE FAIL - GPSLocationData: \(GPSLocationData)")
            }
         }
      } else {
         locationArray = [GPSLocationData]
         if NSArray(array: locationArray).write(toFile: filePath, atomically: true) {
            print("File NOW exist, data written - GPSLocationData: \(GPSLocationData)")
         }
         else {
            print("File DID NOT exist and write FAIL - GPSLocationData: \(GPSLocationData)")
         }
      }

      if !NSArray(array: locationArray).write(toFile: filePath, atomically: true) {
         print("Failed to write to file - HowFar-GPSData.plist")
      }
   }

   /// Write the GPSLocation data to the iPhone
   /// - Parameter GPSLocationData: GPSLocationData colllected in the writeGPSData
   func toIphone(_ GPSLocationData: [String: Any]) {
      do {
         try WCSession.default.updateApplicationContext(["GPSData": GPSLocationData])
      } catch {
         print("Error sending data to iPhone: \(error)")
      }
   }

}
