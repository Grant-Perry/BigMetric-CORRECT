//
//  showHeartBeat.swift
//  howFar
//
//  Created by Grant Perry on 1/31/23.
//

import SwiftUI

struct showHeartBeat: View {
   @EnvironmentObject var distanceTracker: DistanceTracker
   var body: some View {
      VStack{
         HStack(alignment: .center) {
            colorHeartBeat()
               .frame(width: 100)
//            Text("❤️")
//               .font(.system(size: 50))
            Spacer()
         }
         HStack{
            Text("\(String(format: "%.0f", distanceTracker.heartRate))")
               .onAppear(perform: distanceTracker.startHeartRate)
               .fontWeight(.regular)
               .font(.system(size: 70))

            Text("BPM")
               .font(.headline)
               .fontWeight(.bold)
               .foregroundColor(Color.red)
               .padding(.bottom, 28.0)

            Spacer()
         }
      }
      .environmentObject(distanceTracker)
      .padding()
      //       .onAppear(perform: start)
   }
}

//struct showHeartBeat_Previews: PreviewProvider {
//   static var previews: some View {
//      showHeartBeat().environmentObject(DistanceTracker())
//   }
//}
