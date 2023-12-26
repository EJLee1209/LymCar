//
//  RootView.swift
//  LymCar
//
//  Created by 이은재 on 12/22/23.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var viewModel: UserViewModel
    @State private var mapState: MapState = .none
    @State private var selectedTab: TabMenuItem = .map
    @State private var loginViewIsPresented = false
    @State private var showSplashView = true
    
    var body: some View {
        ZStack {
            if showSplashView {
                SplashView()
            } else {
                NavigationView {
                    
                    ZStack(alignment: .bottom) {
                        /// Tab item views - 탭바의 뷰들
                        ZStack(alignment: .top) {
                            switch selectedTab {
                            case .history:
                                HistoryView()
                            case .map:
                                MapView(mapState: $mapState)
                            case .menu:
                                MenuView(loginViewIsPresented: $loginViewIsPresented)
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
                    .fullScreenCover(isPresented: $loginViewIsPresented, content: {
                        /// didLogin == false -> 로그인 화면을 보여줌
                        /// LoginView에서는 @Binding 프로퍼티를 통해 로그인 성공시 didLogin을 toggle -> 로그인 화면 dismiss
                        LoginView(loginViewIsPresented: $loginViewIsPresented)
                    })
                }
                .tint(.white)
                
                
            }
        }
        .task {
            if let _ = await viewModel.checkUserAndFetchUserCarPool() { }
            else { loginViewIsPresented.toggle() }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    showSplashView.toggle()
                }
            }
        }
        .onAppear {
            /// 네비게이션바 타이틀 속성 변경
            UINavigationBar.appearance().titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 20, weight: .bold)
            ]
        }
        
    }
}



#Preview {
    RootView()
        .environmentObject(MapViewModel())
        .environmentObject(UserViewModel())
        .environmentObject(AuthViewModel())
}
