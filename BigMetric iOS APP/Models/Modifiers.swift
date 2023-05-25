//
//  Modifiers.swift
//  polyMap
//
//  Created by Grant Perry on 3/10/23.
//

import SwiftUI

struct Background: ViewModifier {
   @Environment(\.colorScheme) var colorScheme
   var background: Material { colorScheme == .light ? .regularMaterial : .thickMaterial }

   func body(content: Content) -> some View {
      content
         .background(background)
         .cornerRadius(10)
         .compositingGroup()
         .shadow(color: Color(.systemFill), radius: 5)
   }
}

extension View {
   func materialBackground() -> some View {
      self.modifier(Background())
   }

   //   @ViewBuilder
   //   func `if`<Content: View>(_ applyModifier: Bool = true, @ViewBuilder content: (Self) -> Content) -> some View {
   //      if applyModifier {
   //         content(self)
   //      } else {
   //         self
   //      }
   //   }

   func theRows() -> some View {
      self
         .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
         .background(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)).opacity(0.4))
         .foregroundColor(.white)
   }

   func theHead() -> some View {
      self
         .frame(maxWidth: .infinity, maxHeight: 30, alignment: .center)
      //         .background(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)).opacity(0.4))
         .foregroundColor(Color(#colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)))
         .font(.title3)
   }

   func headSmall() -> some View {
      self
         .frame(maxWidth: .infinity, maxHeight: 30, alignment: .center)
      //         .background(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)).opacity(0.4))
         .foregroundColor(.white)
         .font(.caption)
   }

}


