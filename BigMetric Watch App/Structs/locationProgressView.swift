//
//  locationProgressView.swift
//  howFar Watch App
//
//  Created by Grant Perry on 5/13/23.
//

import SwiftUI

// utilize: to show a progress view while loading async location data
// message: is the message to display
struct LocationProgressView: View {
   @EnvironmentObject var  distanceTracker: DistanceTracker

   var message: String

   var body: some View {

      ZStack(alignment: .center) {
         VStack {
            Image(systemName: "antenna.radiowaves.left.and.right")
            Spacer()
            Text("Establishing\n\(message)")
               .font(.title3)
               .foregroundColor(.gpYellow)
               .multilineTextAlignment(.center)
               .lineSpacing(6)
               .frame(width: 175, height: 75)
               .padding(.bottom, 65)

            ProgressView()

               .frame(width: 40, height: 40)
               .progressViewStyle(CircularProgressViewStyle(tint: .gpPink))
               .scaleEffect(2)
               .padding(.top, -59)
         }
         .environmentObject(distanceTracker)
         .padding(.top, 5) // Add padding to push the content down
         .horizontallyCentered()
      }
   }
}
