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
    @State var selectedTab: TabMenuItem = .map
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack(alignment: .top) {
                showSelectedView()
            }
            
            if mapState != .searchingForLocation {
                MainTabView(selectedItem: $selectedTab)
                    .transition(.move(edge: .bottom))
            }
            
            if mapState == .locationSelected {
                CarPoolListView()
                    .transition(.move(edge: .bottom))
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
    
    @ViewBuilder
    func showSelectedView() -> some View {
        switch selectedTab {
        case .history:
            HistoryView()
        case .map:
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
                    .transition(.move(edge: .top))
            } else if mapState == .searchingForLocation {
                LocationSearchView(mapState: $mapState)
            } else if mapState == .locationSelected {
                MapViewActionButton(mapState: $mapState)
                    .padding()
            }
        case .menu:
            MenuView()
        }
    }
}

#Preview {
    MapView()
        .environmentObject(LocationSearchViewModel())
}
