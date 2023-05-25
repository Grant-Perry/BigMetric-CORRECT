//
//  timeView.swift
//  howFar Watch App
//
//  Created by Grant Perry on 3/19/23.
//

import SwiftUI

struct TimeView: View {
   @EnvironmentObject var distanceTracker: DistanceTracker
   @EnvironmentObject var workoutManager: WorkoutManager

   @State var headerBGColor = Color(#colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1))
   @State var timeBGColor = Color(#colorLiteral(red: 0.3624623497, green: 0.8862745166, blue: 0.5439072758, alpha: 1))
   @State var timeOut = Color(#colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1))
   @State var paceColor = Color(#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1))
   @State var headText = Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))

   var body: some View {
      VStack(spacing: -10) {
         if distanceTracker.elapsedTime > 0 {
            VStack {
               Spacer()
               HStack {
                  Text("Time")
                     .modTimeVal(headText)
                  Spacer()
                  Text("Pace")
                     .modTimeVal(headText)
               }
               Spacer()
            }
            .frame(height: 40)
            .background(headerBGColor)
            .foregroundColor(.black)
            .cornerRadius(10)
         }
         Divider()
         HStack {
            HStack {
               if distanceTracker.elapsedTime > 0 {
                  Text("\(distanceTracker.formattedTimeString)")
                     .modTimeHead(timeOut)
               } else {
                  Text("")
                     .frame(maxWidth: .infinity, alignment: .center)
                     .padding(.top, 8)
                     .font(.caption2)
                     .foregroundColor(timeOut)
               }
            }
            Spacer()
            HStack {
               if distanceTracker.elapsedTime > 0 {
                  Text("\(runPace())")
                     .modTimeHead(timeOut)
               } else {
                  Text("")
                     .frame(maxWidth: .infinity, alignment: .center)
                     .padding(.top, 5)
                     .font(.caption2)
                     .foregroundColor(timeOut)
               }
            }
         }
         .frame(maxWidth: .infinity, alignment: .center)
         .background(Color.black)
         .frame(maxHeight: .infinity, alignment: .center)
      }
      .environmentObject(distanceTracker)
      .environmentObject(workoutManager)
      .padding(.top, -10)
   }

   func runPace() -> String {
      var paceTime: String = ""
      if let distance = distanceTracker.distance, distance > 0 {
         let distanceInMiles = distance
         let timeInSeconds = distanceTracker.elapsedTime
         let milePaceInSeconds = timeInSeconds / distanceInMiles // calculate the time it takes to run one mile
         if milePaceInSeconds.isFinite {
            let milePaceInMinutes = Int(milePaceInSeconds / 60) // convert the time to minutes
            let milePaceInSecondsRemainder = Int(milePaceInSeconds.truncatingRemainder(dividingBy: 60)) // calculate the remainder as seconds
            paceTime = ("\(milePaceInMinutes):\(milePaceInSecondsRemainder)")
         } else {
            paceTime = ("")
         }
      } else {
         paceTime = ("")
      }
      return paceTime
   }
}

struct timeView_Previews: PreviewProvider {
    static var previews: some View {
        TimeView()
          .environmentObject(DistanceTracker())
          .environmentObject(WorkoutManager())
    }
}
