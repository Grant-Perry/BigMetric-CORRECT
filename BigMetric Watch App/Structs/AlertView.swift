//
//  AlertView.swift
//  howFar Watch App
//
//  Created by Grant Perry on 4/25/23.
//

import Foundation
import SwiftUI

struct AlertView: View {
   @State private var showAlert = true
   var title: String
   var message: String
   var buttonText: String

   var body: some View {
      VStack {
         Text("")
         .alert(isPresented: $showAlert) {
            Alert(
               title: Text(title),
               message: Text(message),
               dismissButton: .default(Text(buttonText)) {
                  // Handle the action when the alert is dismissed
               }
            )
         }
      }
   }
}

struct AlertView_Previews: PreviewProvider {
   static var previews: some View {
      AlertView(title: "Important Message",
                message: "This is an alert.",
                buttonText: "dismiss")
   }
}
