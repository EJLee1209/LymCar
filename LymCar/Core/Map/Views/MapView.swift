//
//  ContentView.swift
//  LymCar
//
//  Created by 이은재 on 12/19/23.
//

import SwiftUI
import MapKit



struct MapView: View {
    @EnvironmentObject var viewModel: LocationSearchViewModel
    @State var mapState: MapState = .none
    
    var body: some View {
        ZStack(alignment: .bottom) {
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
            if mapState == .locationSelected {
                CarPoolListView()
                    .transition(.move(edge: .bottom))
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

#Preview {
    MapView()
        .environmentObject(LocationSearchViewModel())
}
