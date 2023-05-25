//
//  AlertItem.swift
//  howFar Watch App
//
//  Created by Grant Perry on 5/10/23.
//
//TODO: - need to implement this error handling code
import SwiftUI

struct AlertItem: Identifiable {
   let id = UUID()
   let title: Text
   let message: Text
   let dismissButton: Alert.Button
}

struct AlertContext {
   //MARK: - MapView Errors
   static let unableToGetLocations = AlertItem(title: Text("Locations Error"),
                                               message: Text("Unable to retrieve locations at this time. InPlease try again."), dismissButton: .default(Text("Ok") ))
}



