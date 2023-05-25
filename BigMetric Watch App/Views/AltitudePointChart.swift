//
//  AltitudePointChart.swift
//  howFar Watch App
//
//  Created by Grant Perry on 5/13/23.
//

import SwiftUI
import Charts

struct AltitudePointChart: View {
   @EnvironmentObject var distanceTracker: DistanceTracker
   var screenBounds = WKInterfaceDevice.current().screenBounds

   var body: some View {
      VStack {
         Text("Altitude Chart")
            .horizontallyCentered()
         ScrollView(.horizontal) {
            Chart(distanceTracker.altitudes) {
               BarMark(
                  x: .value("Distance", $0.dist),
                  y: .value("Altitude", $0.value)
               )

            }
         }
         .frame(width: (screenBounds.width/1.05), height: (screenBounds.height/1.05))
      }
      .padding()
   }
}

struct AltitudeDataPoint: Identifiable {
   let id = UUID()
   let value: Double
   let dist: Double
}

struct AltitudePointChart_Previews: PreviewProvider {
    static var previews: some View {
        AltitudePointChart()
          .environmentObject(DistanceTracker())
    }
}
