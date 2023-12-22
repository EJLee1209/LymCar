//
//  RootView.swift
//  LymCar
//
//  Created by 이은재 on 12/22/23.
//

import SwiftUI

struct RootView: View {
    @State var mapState: MapState = .none
    @State var selectedTab: TabMenuItem = .map
    
    var body: some View {
        ZStack(alignment: .bottom) {
            /// Tab item views - 탭바의 뷰들
            ZStack(alignment: .top) {
                switch selectedTab {
                case .history:
                    HistoryView()
                case .map:
                    MapView(mapState: $mapState)
                case .menu:
                    MenuView()
                }
            }
            
            /// Tab bar view - 탭바
            if mapState != .searchingForLocation {
                MainTabView(selectedItem: $selectedTab)
                    .transition(.move(edge: .bottom))
            }
            
            /// bottom sheet - 카풀 목록
            if mapState == .locationSelected {
                CarPoolListView()
                    .transition(.move(edge: .bottom))
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

#Preview {
    RootView()
        .environmentObject(LocationSearchViewModel())
}
