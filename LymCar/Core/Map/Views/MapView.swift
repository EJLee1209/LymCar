//
//  ContentView.swift
//  LymCar
//
//  Created by 이은재 on 12/19/23.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @Binding var mapState: MapState
    
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
                }
                
                if mapState == .locationSelected {
                    MapViewActionButton(mapState: $mapState)
                        .padding()
                }
                
            }
            if let _ = userViewModel.carPool {
                CarPoolShortcutView()
                    .padding(.bottom, 122)
                    .padding(.horizontal, 16)
            }
            
            if mapState == .searchingForLocation {
                LocationSearchView(mapState: $mapState)
                
            }
        }
    }
    
    
}

#Preview {
    MapView(mapState: .constant(.none))
        .environmentObject(MapViewModel())
        .environmentObject(UserViewModel())
}
