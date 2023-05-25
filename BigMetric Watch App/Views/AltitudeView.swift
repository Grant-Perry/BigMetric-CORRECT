//
//  AltitudeView.swift
//  howFar Watch App
//
//  Created by Grant Perry on 5/13/23.
//

import SwiftUI
import CoreMotion
import Combine

struct AltitudeView: View {
   @EnvironmentObject var distanceTracker: DistanceTracker
   @State var isShowingSheet = false
   // ... other properties ...
   @State var screenBounds = WKInterfaceDevice.current().screenBounds
   @StateObject private var altitudeManager = AltitudeManager()
   //// ------------- Main Button Colors --------------------
   @State var bgYardsStopTop = Color(#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1))
   @State var bgYardsStopBottom = Color(#colorLiteral(red: 1, green: 0.1271572973, blue: 0.969772532, alpha: 1))
   @State var bgYardsStartTop = Color(#colorLiteral(red: 1, green: 0.5212053061, blue: 1, alpha: 1))
   @State var bgYardsStartBottom = Color(#colorLiteral(red: 1, green: 0.1271572973, blue: 0.969772532, alpha: 1))
   @State var bgMilesStopTop =  Color(#colorLiteral(red: 0.5450980392, green: 0.1019607843, blue: 0.2901960784, alpha: 1))
   @State var bgMilesStopBottom =  Color(#colorLiteral(red: 0.5882352941, green: 0.1019607843, blue: 0.5667036281, alpha: 1))
   @State var bgMilesStartTop =   Color(#colorLiteral(red: 0.5450980392, green: 0.1019607843, blue: 0.2901960784, alpha: 1))
   @State var bgMilesStartBottom = Color(#colorLiteral(red: 0.5450980392, green: 0.1019607843, blue: 0.4244659561, alpha: 1))
   @State var isRecordingColor = Color(#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1))
   var isUp: Bool {
      return distanceTracker.isUpdating
   }
   var isRecording: Bool {
      return distanceTracker.weIsRecording
   }

   var body: some View {
      VStack {
//         if altitudeManager.altitudeString.isEmpty {
         if distanceTracker.distance == 0 {
            ZStack {
               LocationProgressView(message: "Altitude")
            }
         } else {
            Button(action: {
               self.isShowingSheet.toggle()
            }) {
               ButtonView(
                  stateBtnColor: isRecording ? (isUp ? isRecordingColor : .white) : .black,
                  startColor: !isRecording ? (distanceTracker.yardsOrMiles ? bgMilesStopTop : bgYardsStopTop) : (distanceTracker.yardsOrMiles ? bgMilesStartTop : bgYardsStartTop),
                  endColor: !isRecording ? (distanceTracker.yardsOrMiles ? bgMilesStopBottom : bgYardsStopBottom) : (distanceTracker.yardsOrMiles ? bgMilesStartBottom : bgYardsStartBottom),
                  isUp: self.isUp,
                  screenBounds: self.screenBounds
               )
               .scaleEffect(1.2)
               .overlay(
                  VStack {
                     Text("\(gpNumFormat.formatNumber(distanceTracker.altitude, distanceTracker.altitude > 100 ? 0 : 2))'")
                        .environmentObject(distanceTracker)
                        .font(.title)
                        .bold()
                        .lineLimit(1)
                        .minimumScaleFactor(0.55)
                     Image(systemName: "mountain.2")
                     Text("Altitude")
                        .font(.footnote)
                  }
               )
            }
            .sheet(isPresented: $isShowingSheet) {
               AltitudePointChart()
            }
         }
      }
//      .onAppear {
//         altitudeManager.startUpdates()
//      }
//      .onDisappear {
//         altitudeManager.stopUpdates()
//      }
   }
}

struct AltitudeView_Previews: PreviewProvider {
   static var previews: some View {
      AltitudeView()
         .environmentObject(DistanceTracker())
         .environmentObject(WorkoutManager())
   }
}
