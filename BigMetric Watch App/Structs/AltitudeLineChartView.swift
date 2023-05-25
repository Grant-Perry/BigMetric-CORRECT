//
//  AltitudeLineChartView.swift
//  howFar Watch App
//
//  Created by Grant Perry on 5/13/23.
//

import SwiftUI
// display a line/point chart of the altitude[] collected during workout
struct LineChart: View {
   let data: [Double]
   let gridLineCount: Int = 5 // Number of grid lines
//   var gridStep: Double = 20 // Grid step size in feet

   var body: some View {
      GeometryReader { geometry in
         let minValue = self.data.min() ?? 0
         let maxValue = self.data.max() ?? 1
         let range = maxValue - minValue
         let gridStep = self.data.max()! / Double(gridLineCount)

         // Draw horizontal grid lines and y-axis labels
         ForEach(0...gridLineCount, id: \.self) { i in
            let y = geometry.size.height * (1 - CGFloat((Double(i) * gridStep - minValue) / range))

            // Grid line
            Path { path in
               path.move(to: CGPoint(x: 0, y: y))
               path.addLine(to: CGPoint(x: geometry.size.width, y: y))
            }
            .stroke(Color.gray.opacity(0.5), lineWidth: 1)

            // Y-axis label
            Text("\(Int(minValue + Double(i) * gridStep))")
               .font(.caption)
               .position(x: 0, y: y)
         }

         // Draw line chart
         Path { path in
            for i in data.indices {
               let xPosition = geometry.size.width * CGFloat(i) / CGFloat(self.data.count - 1)
               let yPosition = geometry.size.height * (1 - CGFloat((self.data[i] - minValue) / range))
               let point = CGPoint(x: xPosition, y: yPosition)

               if i == 0 {
                  path.move(to: point)
               } else {
                  path.addLine(to: point)
               }
            }
         }
         .stroke(Color.gpBlue, lineWidth: 2)

         // Draw circles and labels for each point
         ForEach(data.indices, id: \.self) { i in
            let xPosition = geometry.size.width * CGFloat(i) / CGFloat(self.data.count - 1)
            let yPosition = geometry.size.height * (1 - CGFloat((self.data[i] - minValue) / range))

            Circle()
               .fill(Color.gpPink)
               .frame(width: 10, height: 10)
               .position(x: xPosition, y: yPosition)

            Text("\(Int(self.data[i]))")
               .font(.caption)
               .position(x: xPosition, y: yPosition - 20)
         }
      }
   }
      
}





