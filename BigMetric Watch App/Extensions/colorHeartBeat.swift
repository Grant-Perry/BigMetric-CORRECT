//
//  colorHeartBeat.swift
//  howFar
//
//  Created by Grant Perry on 1/31/23.
//

import SwiftUI

struct colorHeartBeat: View {
  @EnvironmentObject var distanceTracker: DistanceTracker

   @State var measuring = false

   let blue = Color(#colorLiteral(red: 0, green: 0.3725490196, blue: 1, alpha: 1))
   let red = Color(#colorLiteral(red: 1, green: 0, blue: 0, alpha: 1))
   
    var body: some View {
       ZStack {
          Color.black
          VStack(alignment: .leading) {
//             Text("Measuring Heart Rate")
//                .foregroundColor(.white)
//                .bold()
             heartIcon()
                .stroke(style:
                           StrokeStyle(lineWidth: 5,
                                       lineCap: .round,
                                       lineJoin: .round,
                                       miterLimit: 0,
                                       dash: [150, 15],
                                       dashPhase: measuring ? -83 : 83)
                )
                .frame(width: 64, height: 64)
                .foregroundStyle(
                  .angularGradient(
                     colors: [blue, red, blue],
                     center: .center,
                     startAngle: .degrees(measuring ? 360 : 0),
                     endAngle: .degrees(measuring ? 720 : 360)
                  )
                )
                .hueRotation(.degrees(measuring ? 0 : 360))
                .onAppear {
                   withAnimation(.linear(duration: 2.5)
                     .repeatForever(autoreverses: false)) {
                        measuring.toggle()
                     }
                }
          }
       }
    }
}


struct colorHeartBeat_Previews: PreviewProvider {
    static var previews: some View {
        colorHeartBeat()
    }
}
