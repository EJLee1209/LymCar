//
//  ContentView.swift
//  LymCar
//
//  Created by 이은재 on 12/19/23.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var appData: AppData
    @StateObject var viewModel: MapViewModel
    @Binding var mapState: MapState
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack(alignment: .top) {
                MapViewRepresentable(mapState: $mapState)
                    .environmentObject(viewModel)
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
                        .environmentObject(viewModel)
                }
                
            }
            if let _ = appData.carPool {
                CarPoolShortcutView()
                    .padding(.bottom, 122)
                    .padding(.horizontal, 16)
            }
            
            if mapState == .searchingForLocation {
                LocationSearchView(mapState: $mapState)
                    .environmentObject(viewModel)
                
            }
        }
    }
    
    
}

#Preview {
    MapView(
        viewModel: MapViewModel(),
        mapState: .constant(.none)
    )
    .environmentObject(AppData(
        authManager: AuthManager(), carPoolManager: CarPoolManager()
    ))
}
