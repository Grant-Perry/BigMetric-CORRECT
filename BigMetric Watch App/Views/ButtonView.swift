//
//  buttonVIew.swift
//  howFar Watch App
//
//  Created by Grant Perry on 4/2/23.
//

import SwiftUI
import WatchKit

struct ButtonView: View {

   @EnvironmentObject var distanceTracker: DistanceTracker
   @EnvironmentObject var workoutManager: WorkoutManager
//   @Binding var selectedTab: Int

   var stateBtnColor = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
   var startColor = Color(#colorLiteral(red: 1, green: 0.5409764051, blue: 0.8473142982, alpha: 1))
   var endColor = Color(#colorLiteral(red: 1, green: 0.1271572973, blue: 0.969772532, alpha: 1))
   var isUp: Bool
   var screenBounds = WKInterfaceDevice.current().screenBounds

   var body: some View {
      VStack(alignment: .center, spacing:0) {
         ZStack {
            Circle()
               .fill(stateBtnColor)
               .frame(width: (screenBounds.width/1.5) * 1.03, height: (screenBounds.height/1.5) * 1.03)
               .blur(radius: self.isUp ? 13 : 0)
         }
         .overlay(
            Circle()
               .fill(LinearGradient(gradient: Gradient(colors: [startColor, endColor]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing))
               .frame(width: (screenBounds.width/1.5) * 0.97,
                      height: (screenBounds.height/1.5) * 0.97))
      }
      .environmentObject(distanceTracker)
      .environmentObject(workoutManager)
   }
}

//struct ButtonView_Previews: PreviewProvider {
//   static var previews: some View {
//      ButtonView(stateBtnColor: Color(.white), isUp: true)
//         .environmentObject(DistanceTracker())
//         .environmentObject(WorkoutManager())
//
//   }
//}
