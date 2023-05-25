//
//  Map.swift
//  Workouts
//
//  Created by Grant Perry
//

import Foundation
import UIKit
import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
   let mapView: MKMapView

   func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
      return mapView
   }

   func updateUIView(_ view: MKMapView, context: UIViewRepresentableContext<MapView>) {
   }
}

class MapViewDelegate: NSObject, MKMapViewDelegate {
   func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      if overlay is MKPolyline {
         let lineView = MKPolylineRenderer(overlay: overlay)
         lineView.strokeColor = #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1)
         lineView.lineWidth = 8
         return lineView
      }
      return MKOverlayRenderer(overlay: overlay)
   }
}

class MKMapViewWithRenderers {
   public let mapView: MKMapView;
   public let delegate: MapViewDelegate

   public init() {
      let mapView = MKMapView()

      let delegate = MapViewDelegate()
      mapView.delegate = delegate

      self.mapView = mapView
      self.delegate = delegate
   }

   func get() -> (MKMapView, MapViewDelegate) {
      return (self.mapView, self.delegate)
   }

   func randomCGFloat() -> CGFloat {
      return CGFloat(arc4random()) / CGFloat(UInt32.max)
   }

   func randomColor() -> UIColor {
      return UIColor(
         red:   randomCGFloat(),
         green: randomCGFloat(),
         blue:  randomCGFloat(),
         alpha: 1
      )
   }
}
