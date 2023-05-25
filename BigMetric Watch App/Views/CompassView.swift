//
//  CompassView.swift
//  howFar Watch App
//
//  Created by Grant Perry on 3/31/23.
//

import SwiftUI

struct CompassView: View {
   @State var screenBounds = WKInterfaceDevice.current().screenBounds
   @EnvironmentObject var distanceTracker: DistanceTracker
   @EnvironmentObject var workoutManager:WorkoutManager
   @Binding var heading: Double
   @Binding var routeHeading: Double
   @State var bgStart = Color(#colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.1294117719, alpha: 1))
   @State var bgStop = Color(#colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1))

   var body: some View {
      ZStack {
         // Draw the compass background
         ButtonView(stateBtnColor: Color(.white),
                    startColor: bgStart,
                    endColor: bgStop,
                    isUp: workoutManager.isLocateMgr)

         // Draw the compass needle
         Image(systemName: "location.north.fill")
            .resizable()
            .scaledToFit()
            .shadow(radius: 70)
            .frame(width: 70, height: 70)
            .foregroundColor(.gpYellow)
            .rotationEffect(.degrees(workoutManager.course))
            .opacity(0.95)
         Text(workoutManager.heading)
            .font(.title3)
            .foregroundColor(.gpPurple)
            .fontDesign(.monospaced)
            .bold()
            .shadow(radius: 12)
         VStack {
            Spacer() // Push the Text to the bottom
            HStack {
               HStack {
                  Text("\(gpNumFormat.formatNumber(workoutManager.course, 2))")
                     .font(.system(size: 40))
                     .offset(y: 35)
               }
               HStack {
                  Text("\u{00B0}") // degrees symbol
                     .font(.system(size: 36))
                     .offset(x: -3, y: 32)
                     .fontWeight(.thin)
               }
            }
            .foregroundColor(.gpMinty)
         }
      }
      .environmentObject(distanceTracker)
      .environmentObject(workoutManager)
      .font(/*@START_MENU_TOKEN@*/.headline/*@END_MENU_TOKEN@*/)
   }
}

//struct CompassView_Previews: PreviewProvider {
//   static var previews: some View {
//      CompassView(heading: .constant(0),
//                  routeHeading: .constant(0))
//      .environmentObject(DistanceTracker())
//      .environmentObject(WorkoutManager())
//
//
//   }
//
//}
