//
//  viewExt.swift
//  howFar Watch App
//
//  Created by Grant Perry on 4/3/23.
//

import SwiftUI

extension View {
   // unit is color
   func modHours(_ unit: TimeUnit) -> some View {
      self
         .font(.title3)
         .foregroundColor(.gray)
         .frame(maxWidth: .infinity, alignment: .top)
         .padding(.top, 30)
   }

   func modMinutes(_ unit: TimeUnit) -> some View {
      self
         .font(.title)
         .foregroundColor(unit.timeColor)
         .multilineTextAlignment(.trailing)
         .padding(.leading,5)
         .scaleEffect(1.5)
         .tracking(0)
   }

   func modSeconds(_ unit: TimeUnit) -> some View {
      self
         .font(.title3)
      //         .font(.system(size: 28, weight: .light))
         .foregroundColor(unit.timeColor)
         .baselineOffset(30.0)
         .multilineTextAlignment(.leading)
         .padding(.leading, -8)
   }

   func horizontallyCentered() -> some View {
            HStack {
               Spacer(minLength: 0)
               self
               Spacer(minLength: 0)
            }
         }

   func leftJustify() -> some View {
            HStack {
               self
               Spacer(minLength: 0)
            }
         }

   func rightJustify() -> some View {
            HStack {
               Spacer(minLength: 10)
               self
            }
         }
}
