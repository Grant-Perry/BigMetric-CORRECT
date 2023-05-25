//  Haptics.swift
//  howFar Watch App
//
//  Created by Grant Perry on 3/3/23.
//

import WatchKit

enum PlayHaptic {
   case start, stop, success, critical, notify, up, down

   static func tap(_ type: PlayHaptic) {
#if os(watchOS)
      let device = WKInterfaceDevice.current()
      switch type {
         case .start:
            device.play(.start)
         case .stop:
            device.play(.stop)
         case .success:
            device.play(.success)
         case .critical:
            device.play(.underwaterDepthCriticalPrompt)
         case .notify:
            device.play(.notification)
         case .up:
            device.play(.directionUp)
         case .down:
            device.play(.directionDown)
      }
#elseif os(iOS)
      switch type {
         case .start:
            print(".start")
         case .stop:
            print(".stop")
         case .success:
         print(".success")
         default:
            print("default")

      }
#endif
   }
}




