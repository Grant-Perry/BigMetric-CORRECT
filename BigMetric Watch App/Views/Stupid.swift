//
//  Stupid.swift
//  howFar Watch App
//
//  Created by Grant Perry on 5/7/23.
//

import SwiftUI

struct Stupid: View {
   var body: some View {
      ZStack {
//         Color(rgb: 155, 169, 128)
         LinearGradient(gradient: Gradient(colors: [Color(rgb: 147, 27, 76), Color(rgb: 157, 29, 84)]), startPoint: .top, endPoint: .bottom)

            .ignoresSafeArea()
         
         Text("Flight")
            .font(.largeTitle)
            .foregroundColor(Color(rgb: 221, 236, 253))

      }
   }
}

struct Stupid_Previews: PreviewProvider {
   static var previews: some View {
      Stupid()
   }
}
