//
//  showAllWeather.swift
//  howFar Watch App
//
//  Created by Grant Perry on 4/19/23.
//

import SwiftUI


struct showAllWeather: View {
   @EnvironmentObject var weatherKitManager: WeatherKitManager
   @EnvironmentObject var geoCodeHelper: GeoCodeHelper
   @EnvironmentObject var distanceTracker: DistanceTracker

   @State private var address = ""
   private var gradient: Gradient {
      Gradient(colors: [.gpBlue, .gpRed])
   }

   var body: some View {
      todaysWeather()
   }


   func todaysWeather() -> HStack<TupleView<(some View, some View, Spacer)>> {
      return HStack(alignment: .center) {
         Gauge(value: Double(weatherKitManager.tempVar) ?? 0, in: (Double(weatherKitManager.lowTempVar) ?? 0)...(Double(weatherKitManager.highTempVar) ?? 0)) {
            Text("Temp")
         } currentValueLabel: {
            Text(weatherKitManager.tempVar)
         }
         .gaugeStyle(.accessoryCircular)
         .tint(gradient)
         .frame(width: 50, height: 50)
         .scaleEffect(0.95)
         .font(.system(size:10))
         .foregroundColor(.white)
         .padding(.top, -4)
         .padding(.bottom, 5)
         VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .center, spacing: 2) {
               Image(systemName: weatherKitManager.symbolVar)
                  .font(.system(size:20))
                  .foregroundColor(.white)
               Text("\(weatherKitManager.lowTempVar)")
                  .font(.system(size:20))
                  .foregroundColor(TemperatureColor.from(temperature: Double(weatherKitManager.lowTempVar) ?? 0))

               Text("/")
                  .font(.system(size:20))
                  .foregroundColor(.white)
               Text("\(weatherKitManager.highTempVar)")
                  .font(.system(size:20))
                  .foregroundColor(TemperatureColor.from(temperature: Double(weatherKitManager.highTempVar) ?? 0))
            }
            Text(address)
               .onAppear {
                  geoCodeHelper.getCityNameHelper(distanceTracker.currentCoords.latitude,
                                                  distanceTracker.currentCoords.longitude) { result in
                     address = result
                  }
               }
               .font(.system(size: 12))
               .foregroundColor(.white)
         }
         .padding(.leading, 10)
         Spacer()
      }
   }
}

struct showAllWeather_Previews: PreviewProvider {
   static var previews: some View {
      let weatherKitManager = WeatherKitManager()
      let geoCodeHelper = GeoCodeHelper()
      let distanceTracker = DistanceTracker()
      return showAllWeather()
         .environmentObject(weatherKitManager)
         .environmentObject(geoCodeHelper)
         .environmentObject(distanceTracker)
   }
}
