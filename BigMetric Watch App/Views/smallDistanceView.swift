//
//  smallDistanceView.swift
//  howFar Watch App
//
//  Created by Grant Perry on 4/15/23.
//

import SwiftUI

struct smallDistanceView: View {
#if os(watchOS)
   @State var screenBounds = WKInterfaceDevice.current().screenBounds
#else
   @State var screenBounds = UIScreen.main.bounds
#endif
   @EnvironmentObject var distanceTracker: DistanceTracker
   @EnvironmentObject  var workoutManager: WorkoutManager
   var isUp: Bool {
      return distanceTracker.isUpdating
   }
   var isRecording: Bool {
      return distanceTracker.weIsRecording
   }
   
   //// ------------- Main Button Colors --------------------
   @State var isRecordingColor = Color(#colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1))
   @State var bgYardsStopTop = Color(#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1))
   @State var bgYardsStopBottom = Color(#colorLiteral(red: 1, green: 0.1271572973, blue: 0.969772532, alpha: 1))
   @State var bgYardsStartTop = Color(#colorLiteral(red: 1, green: 0.5212053061, blue: 1, alpha: 1))
   @State var bgYardsStartBottom = Color(#colorLiteral(red: 1, green: 0.1271572973, blue: 0.969772532, alpha: 1))
   @State var bgMilesStopTop = Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1))
   @State var bgMilesStopBottom = Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
   @State var bgMilesStartTop = Color(#colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1))
   @State var bgMilesStartBottom = Color(#colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1))
   //// -------------- End Button Colors  --------------------
   
   
   
   
   var body: some View {
      ButtonView(stateBtnColor: isRecording ? (isUp ? isRecordingColor : .white) : .black,
                 startColor: !isRecording ? (distanceTracker.yardsOrMiles ? bgMilesStopTop : bgYardsStopTop) : (distanceTracker.yardsOrMiles ? bgMilesStartTop : bgYardsStartTop),
                 endColor: !isRecording ? (distanceTracker.yardsOrMiles ? bgMilesStopBottom : bgYardsStopBottom) : (distanceTracker.yardsOrMiles ? bgMilesStartBottom : bgYardsStartBottom),
                 isUp: self.isUp,
                 screenBounds: self.screenBounds)
      .environmentObject(distanceTracker)
      .environmentObject(workoutManager)
      .overlay(
         InsideButtonTextView())
      .environmentObject(distanceTracker)
      .environmentObject(workoutManager)
   }
   
}


//struct smallDistanceView_Previews: PreviewProvider {
//   static var previews: some View {
//      debugScreen()
//         .environmentObject(DistanceTracker())
//         .environmentObject(WorkoutManager())
//         .previewDisplayName("smallDistanceView Preview")
//   }
//}
