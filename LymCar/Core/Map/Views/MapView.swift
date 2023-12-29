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
    @StateObject var viewModel: ViewModel
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
            
            VStack(spacing: 9) {
                ShowCarPoolButton(mapState: $mapState)
                if !appData.userCarPoolList.isEmpty {
                    CarPoolShortcutListView()
                }
            }
            .padding(.bottom, 122)
            
            
            if mapState == .searchingForLocation {
                LocationSearchView(mapState: $mapState)
                    .environmentObject(viewModel)
                
            }
        }
        .alert(
            viewModel.alertMessage,
            isPresented: $viewModel.alertIsPresented
        ) {
            Button(action: {}, label: { Text("확인") })
        }
    }
    
    
}

#Preview {
    MapView(
        viewModel: MapView.ViewModel(locationSearchManager: LocationSearchManager()),
        mapState: .constant(.none)
    )
    .environmentObject(
        AppData(
            authManager: AuthManager(),
            carPoolManager: CarPoolManager(),
            locationSearchManager: LocationSearchManager()
        )
    )
        
    
}
