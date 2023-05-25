//
//  WorkoutList.swift
//  Workouts
//
//  Created by Grant Perry 2/21/23
//

import Foundation
import HealthKit
import SwiftUI
////
///   This view shows all the workouts in a List view
///   this will get fired by default from ContentView
///
///   The first thing that happens is the .task async fires readWorkouts and populates workouts with its results
///
struct WorkoutList: View {
   @State var workouts: [HKWorkout] = []
   @State private var isLoading: Bool = true

   var body: some View {
      ZStack {
         NavigationView {
            VStack {
               List(workouts, id: \.self) { workout in
                  WorkoutListItem(workout: workout)
               }
               .navigationBarTitle("Gp. Workouts",
                                   displayMode: .large)
               .foregroundColor(.white)
            }
            .task {
               guard let workouts = await readWorkouts(150) else { return }
               let filteredWorkouts = await filterWorkoutsWithCoords(workouts)
               self.workouts = filteredWorkouts
               self.isLoading = false
            }
         }

         if isLoading {
            LoadingView()
               .frame(maxWidth: .infinity, maxHeight: .infinity)
               .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
         }
      }
   }
}

struct LoadingView: View {
   var progress = Color(#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1))
   var bg = Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))
   var bgTop = Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))

   var body: some View {
      ZStack {
         VStack {
            Rectangle()
               .fill(bgTop)
               .frame(height: 45)
            Spacer()
         }
         VStack {
            HStack {
               Spacer()
               Image(systemName: "map.circle")
                  .resizable()
                  .frame(width: 36, height: 36)
                  .foregroundColor(.white)
                  .padding(EdgeInsets(top: 12, leading: 16, bottom: 16, trailing: 16))
            }
            Spacer()
         }
         VStack {
            Spacer(minLength: 75)
            VStack {
               Text("Loading Workouts...")
                  .foregroundColor(progress)
                  .font(.title2)
                  .padding(.bottom, 10)
               ProgressView()
                  .scaleEffect(1.5, anchor: .center)
                  .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
            }
            Spacer()
         }
      }
      .frame(width: 300, height: 300)
      .background(bg.opacity(0.8))
      .cornerRadius(20)
   }
}




