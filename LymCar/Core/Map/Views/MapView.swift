//
//  ContentView.swift
//  LymCar
//
//  Created by 이은재 on 12/19/23.
//

import SwiftUI
import MapKit

struct MapView: View {
    @Binding var mapState: MapState
    
    var body: some View {
        ZStack(alignment: .top) {
            MapViewRepresentable(mapState: $mapState)
                .ignoresSafeArea()
            
            if mapState == .none {
                LocationSearchActivationView()
                    .padding(.top, 40)
                    .onTapGesture {
                        withAnimation(.spring) {
                            mapState = .searchingForLocation
                        }
                    }
            } else if mapState == .searchingForLocation {
                LocationSearchView(mapState: $mapState)
            } else if mapState == .locationSelected {
                MapViewActionButton(mapState: $mapState)
                    .padding()
            }
        }
    }
    
    
}

#Preview {
    MapView(mapState: .constant(.none))
        .environmentObject(LocationSearchViewModel())
}
