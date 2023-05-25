//
//  ContentView.swift
//  BigMetric
//
//  Created by Grant Perry on 5/25/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            PolyMapView()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
