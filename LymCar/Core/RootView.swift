//
//  RootView.swift
//  LymCar
//
//  Created by 이은재 on 12/22/23.
//

import SwiftUI

struct RootView: View {
    @State private var mapState: MapState = .none
    @State private var selectedTab: TabMenuItem = .map
//    AppStorage("didLogin") private var didLogin = false
    @State private var didLogin = false
    
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
        .fullScreenCover(isPresented: .constant(!didLogin), content: {
            /// didLogin == false -> 로그인 화면을 보여줌
            /// LoginView에서는 @Binding 프로퍼티를 통해 로그인 성공시 didLogin을 toggle -> 로그인 화면 dismiss
            LoginView(didLogin: $didLogin)
        })
    }
}

#Preview {
    RootView()
        .environmentObject(MapViewModel())
        .environmentObject(AuthViewModel(authManager: AuthManager()))
}
